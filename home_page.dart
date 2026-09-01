import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'history_page.dart';
import 'favorite_page.dart';
import 'saved_page.dart';
import 'login_page.dart';
import 'category_page.dart';
import 'chatbot_page.dart';
import 'place_details_page.dart';
import 'trip_planner_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController search = TextEditingController();

  // COLORS
  static const Color charcoal = Color(0xFF1F2933);
  static const Color teal = Color(0xFF2A9D8F);
  static const Color lightGray = Color(0xFFF1F3F4);

  // CATEGORIES
  final categories = [
    ["Historical", Icons.account_balance, "assets/historical.jpg"],
    ["Spiritual", Icons.temple_hindu, "assets/spiritual.jpg"],
    ["Mountains", Icons.landscape, "assets/mountains.jpg"],
    ["Beaches", Icons.beach_access, "assets/beaches.jpg"],
  ];

  // MESSAGE
  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: charcoal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // FAVORITE
  Future<void> toggleFavorite(String placeId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage("Please login first");
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(placeId);

    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
      showMessage("Removed from favorites");
      return;
    }

    final placeDoc = await FirebaseFirestore.instance
        .collection('places')
        .doc(placeId)
        .get();

    if (!placeDoc.exists) {
      showMessage("Place not found");
      return;
    }

    final data = placeDoc.data() as Map<String, dynamic>;

    await ref.set({
      'placeId': placeId,
      'name': data['name'] ?? 'Unknown Place',
      'city': data['city'] ?? 'Maharashtra',
      'location': data['location'] ?? 'Maharashtra',
      'category': data['category'] ?? '',
      'imageUrl': data['imageUrl'] ?? '',
      'description': data['description'] ?? '',
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'createdAt': FieldValue.serverTimestamp(),
    });

    showMessage("Added to favorites");
  }

  Stream<bool> isFavorite(String placeId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(false);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(placeId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // SAVED
  Stream<bool> isSaved(String placeId) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(false);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved')
        .doc(placeId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> toggleSaved(String placeId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage("Please login first");
      return;
    }

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved')
        .doc(placeId);

    final doc = await ref.get();

    if (doc.exists) {
      await ref.delete();
      showMessage("Removed from saved");
      return;
    }

    final placeDoc = await FirebaseFirestore.instance
        .collection('places')
        .doc(placeId)
        .get();

    if (!placeDoc.exists) {
      showMessage("Place not found");
      return;
    }

    final data = placeDoc.data() as Map<String, dynamic>;

    await ref.set({
      'placeId': placeId,
      'name': data['name'] ?? 'Unknown Place',
      'city': data['city'] ?? 'Maharashtra',
      'location': data['location'] ?? 'Maharashtra',
      'category': data['category'] ?? '',
      'imageUrl': data['imageUrl'] ?? '',
      'description': data['description'] ?? '',
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'savedAt': FieldValue.serverTimestamp(),
    });

    showMessage("Saved successfully");
  }

  // FIRESTORE
  Stream<QuerySnapshot> getPlaces() {
    return FirebaseFirestore.instance
        .collection('places')
        .snapshots();
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGray,

      drawer: _drawer(context),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_outlined),
        label: const Text("Travel Assistant"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatbotPage(),
            ),
          );
        },
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _topBar(),
              _hero(),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    _sectionTitle(
                      "Explore Maharashtra",
                      "Discover amazing places across the state",
                    ),

                    const SizedBox(height: 20),

                    _categories(),

                    const SizedBox(height: 45),

                    _sectionTitle(
                      "Popular Destinations",
                      "Places you should not miss",
                    ),

                    const SizedBox(height: 20),

                    _places(),

                    const SizedBox(height: 35),

                    _startJourney(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TOP BAR
  Widget _topBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        25,
        20,
        25,
        18,
      ),
      color: charcoal,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(
                      Icons.menu,
                      size: 28,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),

              const SizedBox(width: 5),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hello, Traveler! 👋",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 3),

                    Text(
                      "Where do you want to explore today?",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.notifications_none,
                  size: 27,
                  color: Colors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 15),

          TextField(
            controller: search,
            onChanged: (_) {
              setState(() {});
            },
            decoration: InputDecoration(
              hintText: "Search places, cities...",
              hintStyle: const TextStyle(
                color: Colors.grey,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: charcoal,
              ),
              suffixIcon: search.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: charcoal,
                ),
                onPressed: () {
                  search.clear();
                  setState(() {});
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HERO
  Widget _hero() {
    return SizedBox(
      width: double.infinity,
      height: 460,
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/splash_bg.jpg",
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(50),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [
                charcoal.withOpacity(.90),
                charcoal.withOpacity(.15),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.end,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                "Discover महाराष्ट्र माझा",
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Explore.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),

              Text(
                "Experience.",
                style: TextStyle(
                  color: teal,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Text(
                "Remember.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SECTION TITLE
  Widget _sectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: charcoal,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // CATEGORIES
  Widget _categories() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int count = 4;

        if (constraints.maxWidth < 900) {
          count = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics:
          const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.4,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];

            return _categoryCard(
              category[0] as String,
              category[1] as IconData,
              category[2] as String,
            );
          },
        );
      },
    );
  }

  // CATEGORY CARD
  Widget _categoryCard(
      String title,
      IconData icon,
      String image,
      ) {
    return InkWell(
      borderRadius:
      BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CategoryPage(
              category: title,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(18),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter:
            ColorFilter.mode(
              charcoal.withOpacity(.55),
              BlendMode.darken,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(.08),
              blurRadius: 10,
              offset:
              const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              padding:
              const EdgeInsets.all(10),
              decoration:
              const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: teal,
                size: 25,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PLACES
  Widget _places() {
    return StreamBuilder<QuerySnapshot>(
      stream: getPlaces(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
            "Firebase Error:\n${snapshot.error}",
            style: const TextStyle(
              color: Colors.red,
            ),
          );
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(
                color: teal,
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const Text(
            "No places found",
          );
        }

        final searchText =
        search.text.toLowerCase();

        final places =
        snapshot.data!.docs.where(
              (place) {
            final data =
            place.data()
            as Map<String, dynamic>;

            final name =
                data['name']
                    ?.toString()
                    .toLowerCase() ??
                    "";

            final city =
                data['city']
                    ?.toString()
                    .toLowerCase() ??
                    "";

            return name.contains(searchText) ||
                city.contains(searchText);
          },
        ).toList();

        if (places.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "No matching places found",
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            int count = 3;

            if (constraints.maxWidth < 1000) {
              count = 2;
            }

            if (constraints.maxWidth < 600) {
              count = 1;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount: places.length,
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: count,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.55,
              ),
              itemBuilder:
                  (context, index) {
                final place = places[index];

                final data =
                place.data()
                as Map<String, dynamic>;

                final latitude =
                (data['latitude'] as num?)
                    ?.toDouble();

                final longitude =
                (data['longitude'] as num?)
                    ?.toDouble();

                return _placeCard(
                  place.id,
                  data['name']
                      ?.toString() ??
                      "Unknown Place",
                  data['city']
                      ?.toString() ??
                      "Maharashtra",
                  data['location']
                      ?.toString() ??
                      "Maharashtra",
                  data['category']
                      ?.toString() ??
                      "",
                  latitude,
                  longitude,
                  data['imageUrl']
                      ?.toString() ??
                      "",
                  data['description']
                      ?.toString() ??
                      "",
                );
              },
            );
          },
        );
      },
    );
  }

  // PLACE CARD
  Widget _placeCard(
      String placeId,
      String title,
      String city,
      String location,
      String category,
      double? latitude,
      double? longitude,
      String imageUrl,
      String description,
      ) {
    return InkWell(
      borderRadius:
      BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PlaceDetailsPage(
                  placeId: placeId,
                  title: title,
                  city: city,
                  location: location,
                  category: category,
                  latitude: latitude,
                  longitude: longitude,
                  imageUrl: imageUrl,
                  description: description,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(.12),
              blurRadius: 12,
              offset:
              const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
          BorderRadius.circular(20),
          child: Stack(
            children: [
              // IMAGE
              Positioned.fill(
                child: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) {
                    return Container(
                      color:
                      Colors.grey.shade300,
                      child: const Icon(
                        Icons
                            .image_not_supported,
                        size: 50,
                      ),
                    );
                  },
                )
                    : Container(
                  color:
                  Colors.grey.shade300,
                  child: const Icon(
                    Icons.image,
                    size: 50,
                  ),
                ),
              ),

              // GRADIENT
              Positioned.fill(
                child: Container(
                  decoration:
                  BoxDecoration(
                    gradient:
                    LinearGradient(
                      begin:
                      Alignment.topCenter,
                      end:
                      Alignment.bottomCenter,
                      colors: [
                        charcoal.withOpacity(.05),
                        charcoal.withOpacity(.25),
                        charcoal.withOpacity(.90),
                      ],
                    ),
                  ),
                ),
              ),

              // CONTENT
              Padding(
                padding:
                const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Spacer(),

                        StreamBuilder<bool>(
                          stream:
                          isFavorite(placeId),
                          builder:
                              (context, snapshot) {
                            final favorite =
                                snapshot.data ??
                                    false;

                            return Container(
                              decoration:
                              const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  favorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: favorite
                                      ? teal
                                      : charcoal,
                                ),
                                onPressed: () {
                                  toggleFavorite(
                                    placeId,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const Spacer(),

                    Text(
                      title,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: teal,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            city,
                            overflow:
                            TextOverflow.ellipsis,
                            style:
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    const Row(
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          color: teal,
                          size: 17,
                        ),
                        SizedBox(width: 5),
                        Text(
                          "View Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // START JOURNEY
  Widget _startJourney() {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(25),
        color: charcoal,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Ready for your next adventure?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  "Explore the beauty of Maharashtra.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const TripPlannerPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: teal,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 15,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              "Plan My Trip",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DRAWER
  Widget _drawer(BuildContext context) {
    return Drawer(
      backgroundColor: lightGray,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration:
            BoxDecoration(
              color: charcoal,
            ),
            accountName: Text(
              "Traveler",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              "Explore Maharashtra",
            ),
            currentAccountPicture:
            CircleAvatar(
              backgroundColor: teal,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),

          _drawerItem(
            context,
            Icons.person_outline,
            "Profile",
          ),

          _drawerItem(
            context,
            Icons.history,
            "History",
          ),

          _drawerItem(
            context,
            Icons.favorite_outline,
            "Favorites",
          ),

          _drawerItem(
            context,
            Icons.bookmark_outline,
            "Saved",
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: charcoal,
            ),
            title: const Text("Logout"),
            onTap: () async {
              await FirebaseAuth.instance
                  .signOut();

              if (!context.mounted) {
                return;
              }

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // DRAWER ITEM
  Widget _drawerItem(
      BuildContext context,
      IconData icon,
      String title,
      ) {
    return ListTile(
      leading: Icon(
        icon,
        color: charcoal,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: charcoal,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);

        if (title == "Profile") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const ProfilePage(),
            ),
          );
        } else if (title == "History") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const HistoryPage(),
            ),
          );
        } else if (title == "Favorites") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const FavoritePage(),
            ),
          );
        } else if (title == "Saved") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const SavedPage(),
            ),
          );
        }
      },
    );
  }

  // DISPOSE
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }
}
