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
          'color': const Color(0xFF9A5B35),
          'image': 'assets/historical.jpg',
        };

      case 'spiritual':
        return {
          'title': 'Find Peace Within',
          'subtitle':
          'Discover sacred temples and peaceful spiritual destinations.',
          'icon': Icons.temple_hindu,
          'color': const Color(0xFFD28A25),
          'image': 'assets/spiritual.jpg',
        };

      case 'mountains':
        return {
          'title': 'Into the Wild',
          'subtitle':
          'Explore breathtaking Sahyadri mountains, valleys and forts.',
          'icon': Icons.landscape,
          'color': const Color(0xFF477A52),
          'image': 'assets/mountains.jpg',
        };

      case 'beaches':
        return {
          'title': 'Escape to the Coast',
          'subtitle':
          'Relax beside Maharashtra’s beautiful Arabian Sea coastline.',
          'icon': Icons.beach_access,
          'color': const Color(0xFF27869A),
          'image': 'assets/beaches.jpg',
        };

      default:
        return {
          'title': 'Explore Maharashtra',
          'subtitle': 'Discover beautiful places across Maharashtra.',
          'icon': Icons.travel_explore,
          'color': Colors.black,
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
      backgroundColor: const Color(0xFFF7F8FA),

      body: CustomScrollView(
        slivers: [

          // BEAUTIFUL HEADER
          SliverAppBar(
            expandedHeight: 460,
            pinned: true,

            backgroundColor: info['color'],

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
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              background: Stack(
                fit: StackFit.expand,
                children: [

                  Image.asset(
                    info['image'],
                    fit: BoxFit.fill,
                  ),

                  // DARK GRADIENT
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(.15),
                          Colors.black.withOpacity(.25),
                          Colors.black.withOpacity(.85),
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

                        Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(.18),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white
                                  .withOpacity(.4),
                            ),
                          ),

                          child: Icon(
                            info['icon'],
                            color: Colors.white,
                            size: 30,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          info['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

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

          // CONTENT
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
                        child: CircularProgressIndicator(),
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

                final places = snapshot.data!.docs;

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {

                      final doc = places[index];

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
                      (data['latitude'] as num?)
                          ?.toDouble();

                      final longitude =
                      (data['longitude'] as num?)
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
    final info = categoryInfo;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // IMAGE
            SizedBox(
              height: 330,

              child: Stack(
                children: [

                  Positioned.fill(
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                      imageUrl,
                      fit: BoxFit.fill,

                      errorBuilder:
                          (_, __, ___) {
                        return _imagePlaceholder();
                      },
                    )
                        : _imagePlaceholder(),
                  ),

                  // IMAGE GRADIENT
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
                                .withOpacity(.65),
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
                      const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: info['color'],
                        borderRadius:
                        BorderRadius.circular(30),
                      ),

                      child: Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.bold,
                          letterSpacing: .6,
                        ),
                      ),
                    ),
                  ),

                  // LOCATION ON IMAGE
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

                        const SizedBox(width: 5),

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

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [

                      Icon(
                        Icons.place_outlined,
                        size: 17,
                        color: info['color'],
                      ),

                      const SizedBox(width: 5),

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

                  const SizedBox(height: 14),

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

                  const SizedBox(height: 20),

                  // ACTION BUTTONS
                  Row(
                    children: [

                      Expanded(
                        child: _actionButton(
                          icon: Icons.map_outlined,
                          text: 'Map',
                          color: info['color'],
                          onTap: latitude != null &&
                              longitude != null
                              ? () => openLocation(
                            latitude,
                            longitude,
                          )
                              : null,
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _actionButton(
                          icon: Icons.hotel_outlined,
                          text: 'Lodge',
                          color: info['color'],
                          onTap: () =>
                              openLodge(name),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _actionButton(
                          icon:
                          Icons.restaurant_outlined,
                          text: 'Food',
                          color: info['color'],
                          onTap: latitude != null &&
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
    required Color color,
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
        foregroundColor: color,

        side: BorderSide(
          color: color.withOpacity(.35),
        ),

        padding:
        const EdgeInsets.symmetric(
          vertical: 12,
        ),

        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(13),
        ),
      ),
    );
  }

  // IMAGE PLACEHOLDER
  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,

      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 55,
          color: Colors.grey,
        ),
      ),
    );
  }

  // EMPTY
  Widget _emptyCard() {
    final info = categoryInfo;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(45),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        children: [

          Icon(
            info['icon'],
            size: 55,
            color: info['color'],
          ),

          const SizedBox(height: 15),

          const Text(
            "No places found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            "We couldn't find any places in this category.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ERROR
  Widget _errorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(25),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        children: [

          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 45,
          ),

          const SizedBox(height: 10),

          const Text(
            "Something went wrong",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
