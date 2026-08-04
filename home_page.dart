import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget buildCategory(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.blue.shade100,
      ),
      alignment: Alignment.center,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget buildPlaceCard(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade200,
      ),
      child: Text(title, style: const TextStyle(fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Maharashtra"),
        leading: const Icon(Icons.person),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // SEARCH BAR
              TextField(
                decoration: InputDecoration(
                  hintText: "Search places...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TITLE
              const Text(
                "Explore Maharashtra",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              // CATEGORIES
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildCategory("Historical"),
                  buildCategory("Spiritual"),
                  buildCategory("Mountains"),
                  buildCategory("Beaches"),
                ],
              ),

              const SizedBox(height: 20),

              // POPULAR
              const Text(
                "Popular in Maharashtra",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              // PLACES
              buildPlaceCard("Gateway of India"),
              buildPlaceCard("Raigad Fort"),

              const SizedBox(height: 30),

              // BUTTON
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Start Your Journey"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
