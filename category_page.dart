import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage({
    super.key,
    required this.category,
  });

  // CATEGORY INFORMATION
  Map<String, dynamic> get categoryInfo {
    switch (category.toLowerCase()) {
      case 'historical':
        return {
          'title': 'Walk Through History',
          'subtitle':
          'Discover forts, palaces and stories that shaped Maharashtra.',
          'icon': Icons.account_balance,
          'image': 'assets/historical.jpg',
        };

      case 'spiritual':
        return {
          'title': 'Find Peace Within',
          'subtitle':
          'Discover sacred temples and peaceful spiritual destinations.',
          'icon': Icons.temple_hindu,
          'image': 'assets/spiritual.jpg',
        };

      case 'mountains':
        return {
          'title': 'Into the Wild',
          'subtitle':
          'Explore breathtaking Sahyadri mountains, valleys and forts.',
          'icon': Icons.landscape,
          'image': 'assets/mountains.jpg',
        };

      case 'beaches':
        return {
          'title': 'Escape to the Coast',
          'subtitle':
          'Relax beside Maharashtra’s beautiful Arabian Sea coastline.',
          'icon': Icons.beach_access,
          'image': 'assets/beaches.jpg',
        };

      default:
        return {
          'title': 'Explore Maharashtra',
          'subtitle':
          'Discover beautiful places across Maharashtra.',
          'icon': Icons.travel_explore,
          'image': 'assets/splash_bg.jpg',
        };
    }
  }

  // MAP
  Future<void> openLocation(
      double latitude,
      double longitude,
      ) async {
    if (kIsWeb) {
      final url = Uri.parse(
        'https://www.google.com/maps/search/?api=1'
            '&query=$latitude,$longitude',
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

  // LODGE
  Future<void> openLodge(String placeName) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/hotels+near+'
          '${Uri.encodeComponent(placeName)}',
    );

    await launchUrl(
      url,
      webOnlyWindowName: '_blank',
    );
  }

  // FOOD
  Future<void> openFood(
      double latitude,
      double longitude,
      ) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/food+near+me/'
          '@$latitude,$longitude,14z',
    );

    await launchUrl(
      url,
      webOnlyWindowName: '_blank',
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    final info = categoryInfo;

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),

      body: CustomScrollView(
        slivers: [

          // HEADER
          SliverAppBar(
            expandedHeight: 560,
            pinned: true,

            backgroundColor: Colors.black,
            foregroundColor: Colors.white,

            elevation: 0,

            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 55,
                bottom: 18,
              ),

              title: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              background: Stack(
                fit: StackFit.expand,
                children: [

                  // IMAGE
                  Image.asset(
                    info['image'],
                    fit: BoxFit.fill,
                  ),

                  // DARK OVERLAY
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(.20),
                          Colors.black.withOpacity(.45),
                          Colors.black.withOpacity(.90),
                        ],
                      ),
                    ),
                  ),

                  // HEADER CONTENT
                  Positioned(
                    left: 30,
                    right: 30,
                    bottom: 65,

                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,

                      children: [

                        // ICON
                        Container(
                          padding:
                          const EdgeInsets.all(12),

                          decoration:
                          BoxDecoration(
                            color: Colors.black
                                .withOpacity(.75),

                            shape: BoxShape.circle,

                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(.5),
                            ),
                          ),

                          child: Icon(
                            info['icon'],
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(height: 18),

                        // TITLE
                        Text(
                          info['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // SUBTITLE
                        Text(
                          info['subtitle'],
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // FIRESTORE PLACES
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              22,
              30,
              22,
              40,
            ),

            sliver: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('places')
                  .where(
                'category',
                isEqualTo: category,
              )
                  .snapshots(),

              builder: (context, snapshot) {

                // ERROR
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: _errorCard(
                      snapshot.error.toString(),
                    ),
                  );
                }

                // LOADING
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(50),

                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }

                // EMPTY
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: _emptyCard(),
                  );
                }

                final places =
                    snapshot.data!.docs;

                return SliverList(
                  delegate:
                  SliverChildBuilderDelegate(
                        (context, index) {

                      final doc =
                      places[index];

                      final data =
                      doc.data()
                      as Map<String, dynamic>;

                      final name =
                          data['name']
                              ?.toString() ??
                              'Unknown Place';

                      final city =
                          data['city']
                              ?.toString() ??
                              'Maharashtra';

                      final location =
                          data['location']
                              ?.toString() ??
                              city;

                      final description =
                          data['description']
                              ?.toString() ??
                              'Discover this beautiful destination in Maharashtra.';

                      final imageUrl =
                          data['imageUrl']
                              ?.toString() ??
                              '';

                      final latitude =
                      (data['latitude']
                      as num?)
                          ?.toDouble();

                      final longitude =
                      (data['longitude']
                      as num?)
                          ?.toDouble();

                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 25,
                        ),

                        child: _placeCard(
                          context,
                          name,
                          city,
                          location,
                          description,
                          imageUrl,
                          latitude,
                          longitude,
                        ),
                      );
                    },

                    childCount: places.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // PLACE CARD
  Widget _placeCard(
      BuildContext context,
      String name,
      String city,
      String location,
      String description,
      String imageUrl,
      double? latitude,
      double? longitude,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius:
        BorderRadius.circular(24),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // IMAGE
            SizedBox(
              height: 330,

              child: Stack(
                children: [

                  // IMAGE
                  Positioned.fill(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,

                      errorBuilder:
                          (_, __, ___) {
                        return _imagePlaceholder();
                      },
                    )
                        : _imagePlaceholder(),
                  ),

                  // IMAGE DARK GRADIENT
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
                            Colors.transparent,
                            Colors.black
                                .withOpacity(.75),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // CATEGORY BADGE
                  Positioned(
                    top: 18,
                    left: 18,

                    child: Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),

                      decoration:
                      BoxDecoration(
                        color: Colors.black,

                        borderRadius:
                        BorderRadius.circular(
                          30,
                        ),
                      ),

                      child: Text(
                        category.toUpperCase(),

                        style:
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.bold,
                          letterSpacing: .6,
                        ),
                      ),
                    ),
                  ),

                  // LOCATION
                  Positioned(
                    bottom: 18,
                    left: 18,
                    right: 18,

                    child: Row(
                      children: [

                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 18,
                        ),

                        const SizedBox(
                          width: 5,
                        ),

                        Expanded(
                          child: Text(
                            city,

                            style:
                            const TextStyle(
                              color: Colors.white,
                              fontWeight:
                              FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CARD CONTENT
            Padding(
              padding:
              const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  // NAME
                  Text(
                    name,

                    style:
                    const TextStyle(
                      fontSize: 23,
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  // LOCATION
                  Row(
                    children: [

                      const Icon(
                        Icons.place_outlined,
                        size: 17,
                        color: Colors.black,
                      ),

                      const SizedBox(
                        width: 5,
                      ),

                      Expanded(
                        child: Text(
                          location,

                          style: TextStyle(
                            color:
                            Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // DESCRIPTION
                  Text(
                    description,

                    maxLines: 3,

                    overflow:
                    TextOverflow.ellipsis,

                    style: TextStyle(
                      color:
                      Colors.grey.shade700,
                      height: 1.5,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ACTION BUTTONS
                  Row(
                    children: [

                      Expanded(
                        child: _actionButton(
                          icon:
                          Icons.map_outlined,
                          text: 'Map',
                          onTap:
                          latitude != null &&
                              longitude != null
                              ? () => openLocation(
                            latitude,
                            longitude,
                          )
                              : null,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: _actionButton(
                          icon:
                          Icons.hotel_outlined,
                          text: 'Lodge',
                          onTap: () =>
                              openLodge(name),
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: _actionButton(
                          icon: Icons
                              .restaurant_outlined,
                          text: 'Food',
                          onTap:
                          latitude != null &&
                              longitude != null
                              ? () => openFood(
                            latitude,
                            longitude,
                          )
                              : null,
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
    );
  }

  // ACTION BUTTON
  Widget _actionButton({
    required IconData icon,
    required String text,
    required VoidCallback? onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,

      icon: Icon(
        icon,
        size: 17,
      ),

      label: Text(
        text,

        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),

      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.black,

        backgroundColor:
        const Color(0xFFF2F2F2),

        side: const BorderSide(
          color: Color(0xFFD0D0D0),
        ),

        padding:
        const EdgeInsets.symmetric(
          vertical: 12,
        ),

        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(13),
        ),
      ),
    );
  }

  // IMAGE PLACEHOLDER
  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFD6D6D6),

      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 55,
          color: Colors.black54,
        ),
      ),
    );
  }

  // EMPTY
  Widget _emptyCard() {
    final info = categoryInfo;

    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(45),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(25),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(.06),
            blurRadius: 15,
          ),
        ],
      ),

      child: Column(
        children: [

          Icon(
            info['icon'],
            size: 55,
            color: Colors.black,
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(
            "No places found",

            style: TextStyle(
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            "We couldn't find any places in this category.",

            textAlign:
            TextAlign.center,

            style: TextStyle(
              color:
              Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ERROR
  Widget _errorCard(String error) {
    return Container(
      padding:
      const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(.06),
            blurRadius: 12,
          ),
        ],
      ),

      child: Column(
        children: [

          const Icon(
            Icons.error_outline,
            color: Colors.black,
            size: 45,
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            "Something went wrong",

            style: TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            error,

            textAlign:
            TextAlign.center,

            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
