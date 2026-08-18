import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final search = TextEditingController();

  String selectedCategory = "All";
  bool saved = false;

  // fav function
  Future<void> toggleFavorite(String placeId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please login first"),
        ),
      );
      return;
    }

    final favoriteRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(placeId);

    final doc = await favoriteRef.get();

    if (doc.exists) {
      await favoriteRef.delete();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Removed from favorites"),
        ),
      );
    } else {
      await favoriteRef.set({
        'placeId': placeId,
        'savedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to favorites ❤️"),
        ),
      );
    }

    setState(() {});
  }

  // Check whether a place is already favorite
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

  // Get places from Firebase
  Stream<QuerySnapshot> getPlaces() {
    return FirebaseFirestore.instance
        .collection('places')
        .snapshots();
  }

    // MAP OPENING FUNCTION
  Future<void> openLocation(
      double latitude,
      double longitude,
      ) async {
    if (kIsWeb) {
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );

      await launchUrl(
        url,
        webOnlyWindowName: '_blank',
      );
    } else {
      final geo = Uri(
        scheme: 'geo',
        path: '$latitude,$longitude',
      );

      await launchUrl(geo);
    }
  }

  // Categories
  final categories = [
    ["Historical", Icons.account_balance],
    ["Spiritual", Icons.temple_hindu],
    ["Mountains", Icons.landscape],
    ["Beaches", Icons.beach_access],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _drawer(context),

      body: SafeArea(
        child: Column(
          children: [

            // TOP BAR
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [

                  // PROFILE
                  Builder(
                    builder: (context) {
                      return GestureDetector(
                        onTap: () {
                          Scaffold.of(context).openDrawer();
                        },
                        child: const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  // SEARCH
                  Expanded(
                    child: TextField(
                      controller: search,
                      onChanged: (_) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: "Search places...",
                        prefixIcon: const Icon(Icons.search),

                        suffixIcon: search.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            search.clear();
                            setState(() {});
                          },
                        )
                            : null,

                        filled: true,
                        fillColor: Colors.grey.shade100,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // PAGE CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // HERO
                    Container(
                      height: 210,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        image: const DecorationImage(
                          image: AssetImage(
                            "assets/splash3_bg.jpg",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Explore Maharashtra",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // CATEGORY TITLE
                    const Text(
                      "Explore by category",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // CATEGORIES
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: categories.map((category) {
                        return _category(
                          category[0] as String,
                          category[1] as IconData,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    // POPULAR
                    const Text(
                      "Popular in Maharashtra",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // FIRESTORE PLACES
                    StreamBuilder<QuerySnapshot>(
                      stream: getPlaces(),

                      builder: (context, snapshot) {

                        // ERROR
                        if (snapshot.hasError) {
                          return Text(
                            "Firebase Error:\n${snapshot.error}",
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          );
                        }

                        // LOADING
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        // EMPTY
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Text(
                            "No places found",
                          );
                        }

                        // PLACES
                        final places = snapshot.data!.docs.where((place) {
                          final name =
                          place['name'].toString().toLowerCase();

                          return name.contains(
                            search.text.toLowerCase(),
                          );
                        }).toList();

                        if (places.isEmpty) {
                          return const Text(
                            "No matching places found",
                          );
                        }

                        return Column(
                          children: places.map((place) {
                            return _place(
                              place.id,
                              place['name'].toString(),
                              place['location'].toString(),
                              (place['latitude'] as num).toDouble(),
                              (place['longitude'] as num).toDouble(),
                            );
                          }).toList(),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // START JOURNEY
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "🌄 Your journey begins!",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.explore),
                        label: const Text(
                          "Start Your Journey",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CATEGORY BUTTON
  Widget _category(String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$title places selected"),
          ),
        );
      },

      child: Container(
        width: 150,
        height: 90,

        decoration: BoxDecoration(
          border: Border.all(
            color: selectedCategory == title
                ? Colors.black
                : Colors.grey.shade400,
          ),
          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),

            const SizedBox(height: 7),

            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PLACE CARD
  Widget _place(
      String placeId,
      String title,
      String location,
      double latitude,
      double longitude,
      ){
    return GestureDetector(
      // When user clicks the place
      onTap: () {
        openLocation(latitude, longitude);
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),

        child: Row(
          children: [

            // Location icon
            Container(
              width: 75,
              height: 75,

              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),

              child: const Icon(
                Icons.location_on,
                size: 38,
              ),
            ),

            const SizedBox(width: 15),

            // Place name and location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    location,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Tap to view location",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Map icon
            const Icon(
              Icons.map,
              color: Colors.blue,
            ),

            // Favorite and Saved buttons
            Column(
              children: [

                StreamBuilder<bool>(
                  stream: isFavorite(placeId),
                  builder: (context, snapshot) {
                    final favorite = snapshot.data ?? false;

                    return IconButton(
                      icon: Icon(
                        favorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: favorite
                            ? Colors.red
                            : Colors.black,
                      ),
                      onPressed: () {
                        toggleFavorite(placeId);
                      },
                    );
                  },
                ),

                IconButton(
                  icon: Icon(
                    saved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),

                  onPressed: () {
                    setState(() {
                      saved = !saved;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // DRAWER
  Widget _drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [

          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
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

            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: Colors.black,
                size: 30,
              ),
            ),
          ),

          _drawerItem(
            context,
            Icons.person,
            "Profile",
          ),

          _drawerItem(
            context,
            Icons.history,
            "History",
          ),

          _drawerItem(
            context,
            Icons.favorite,
            "Favorites",
          ),

          _drawerItem(
            context,
            Icons.bookmark,
            "Saved",
          ),

          const Divider(),

          // LOGOUT
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),

            onTap: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
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
      leading: Icon(icon),
      title: Text(title),

      onTap: () {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$title selected"),
          ),
        );
      },
    );
  }
}
