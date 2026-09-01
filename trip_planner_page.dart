import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class TripPlannerPage extends StatefulWidget {
const TripPlannerPage({super.key});

@override
State<TripPlannerPage> createState() => _TripPlannerPageState();
}

class _TripPlannerPageState extends State<TripPlannerPage> {
final budgetController = TextEditingController();

String? selectedDestination;

int travelers = 2;
int nights = 2;
int selectedStars = 3;

bool showPlan = false;

final List<String> destinations = [
"Mumbai",
"Pune",
"Lonavala",
"Mahabaleshwar",
"Nashik",
"Aurangabad",
"Alibaug",
"Kolhapur",
"Shirdi",
"Matheran",
"Ratnagiri",
"Solapur",
];

@override
void dispose() {
budgetController.dispose();
super.dispose();
}

// --------------------------------------------------
// GOOGLE MAPS
// --------------------------------------------------

Future<void> openGoogleMaps(String url) async {
final uri = Uri.parse(url);

if (kIsWeb) {
await launchUrl(
uri,
webOnlyWindowName: '_blank',
);
} else {
await launchUrl(
uri,
mode: LaunchMode.externalApplication,
);
}
}

// --------------------------------------------------
// FIND HOTELS
// --------------------------------------------------

Future<void> findHotels() async {
if (selectedDestination == null) {
showMessage("Please select a destination 📍");
return;
}

final query =
"$selectedStars star hotels near $selectedDestination";

final url =
"https://www.google.com/maps/search/?api=1"
"&query=${Uri.encodeComponent(query)}";

await openGoogleMaps(url);
}

// --------------------------------------------------
// FIND FOOD
// --------------------------------------------------

Future<void> findFood() async {
if (selectedDestination == null) {
showMessage("Please select a destination 📍");
return;
}

final query =
"restaurants and food near $selectedDestination";

final url =
"https://www.google.com/maps/search/?api=1"
"&query=${Uri.encodeComponent(query)}";

await openGoogleMaps(url);
}

// --------------------------------------------------
// MESSAGE
// --------------------------------------------------

void showMessage(String message) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(message),
behavior: SnackBarBehavior.floating,
backgroundColor: Colors.black,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
);
}

// --------------------------------------------------
// PLAN TRIP
// --------------------------------------------------

void planTrip() {
if (selectedDestination == null) {
showMessage("Please select a destination 📍");
return;
}

if (budgetController.text.trim().isEmpty) {
showMessage("Please enter your budget 💰");
return;
}

setState(() {
showPlan = true;
});

FocusScope.of(context).unfocus();
}

// --------------------------------------------------
// HOTEL INFO
// --------------------------------------------------

Map<String, dynamic> get hotelInfo {
switch (selectedStars) {
case 1:
return {
"title": "Budget Stay",
"subtitle": "Simple and affordable accommodation",
"icon": Icons.hotel,
"description":
"A basic and affordable stay for travelers who want to spend more time exploring.",
"features": [
"Basic rooms",
"Essential amenities",
"Budget friendly",
"Short trips",
],
};

case 2:
return {
"title": "Comfort Stay",
"subtitle": "Comfort with additional facilities",
"icon": Icons.apartment,
"description":
"A comfortable option with more facilities than a basic budget stay.",
"features": [
"Comfortable rooms",
"Additional amenities",
"Family friendly",
"Weekend trips",
],
};

case 3:
return {
"title": "Standard Hotel",
"subtitle": "Comfortable stay with good facilities",
"icon": Icons.business,
"description":
"A balanced choice for travelers looking for comfort, convenience and good facilities.",
"features": [
"Comfortable rooms",
"Guest facilities",
"Family friendly",
"Longer stays",
],
};

case 4:
return {
"title": "Premium Hotel",
"subtitle": "Higher-comfort accommodation",
"icon": Icons.domain,
"description":
"A premium stay with additional services and a more relaxing experience.",
"features": [
"Premium rooms",
"Enhanced facilities",
"More services",
"Relaxing trips",
],
};

default:
return {
"title": "Luxury Hotel",
"subtitle": "Luxury-focused accommodation",
"icon": Icons.star,
"description":
"A luxury-oriented stay for travelers looking for premium facilities and services.",
"features": [
"Luxury rooms",
"Premium facilities",
"Enhanced services",
"Special trips",
],
};
}
}

// --------------------------------------------------
// FOOD INFO
// --------------------------------------------------

Map<String, dynamic> get foodInfo {
switch (selectedStars) {
case 1:
return {
"title": "Local & Budget Dining",
"description":
"Explore local restaurants, cafés, street food and traditional food spots.",
"icon": Icons.ramen_dining,
};

case 2:
return {
"title": "Casual Dining",
"description":
"Choose family restaurants, local restaurants and casual cafés.",
"icon": Icons.restaurant,
};

case 3:
return {
"title": "Comfort Dining",
"description":
"Consider well-rated restaurants, cafés and hotel dining options.",
"icon": Icons.restaurant_menu,
};

case 4:
return {
"title": "Premium Dining",
"description":
"Enjoy premium restaurants, hotel dining and local food experiences.",
"icon": Icons.dining,
};

default:
return {
"title": "Fine Dining",
"description":
"Explore fine-dining restaurants and premium culinary experiences.",
"icon": Icons.local_dining,
};
}
}

// --------------------------------------------------
// BUILD
// --------------------------------------------------

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFFE7E7E7),

body: SafeArea(
child: CustomScrollView(
slivers: [
SliverToBoxAdapter(
child: _header(),
),

SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.all(20),
child: _plannerCard(),
),
),

if (showPlan)
SliverToBoxAdapter(
child: Padding(
padding: const EdgeInsets.fromLTRB(
20,
0,
20,
40,
),
child: _resultSection(),
),
),
],
),
),
);
}

// --------------------------------------------------
// HEADER
// --------------------------------------------------

Widget _header() {
return Container(
padding: const EdgeInsets.fromLTRB(
20,
12,
20,
28,
),
decoration: const BoxDecoration(
color: Colors.black,
borderRadius: BorderRadius.only(
bottomLeft: Radius.circular(30),
bottomRight: Radius.circular(30),
),
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
IconButton(
onPressed: () => Navigator.pop(context),
icon: const Icon(
Icons.arrow_back,
color: Colors.white,
),
),

const SizedBox(width: 5),

const Expanded(
child: Text(
"Trip Planner",
style: TextStyle(
color: Colors.white,
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
),

Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
color: Colors.white.withOpacity(.12),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.travel_explore,
color: Colors.white,
),
),
],
),

const SizedBox(height: 18),

const Text(
"Plan your perfect trip",
style: TextStyle(
color: Colors.white,
fontSize: 30,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 7),

Text(
"Choose your destination, budget and travel preferences.",
style: TextStyle(
color: Colors.grey.shade400,
fontSize: 15,
height: 1.4,
),
),
],
),
);
}

// --------------------------------------------------
// PLANNER CARD
// --------------------------------------------------

Widget _plannerCard() {
return Container(
padding: const EdgeInsets.all(22),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(25),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.08),
blurRadius: 20,
offset: const Offset(0, 8),
),
],
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_title(
"Where do you want to go?",
"Choose your destination",
),

const SizedBox(height: 15),

_destinationDropdown(),

const SizedBox(height: 25),

_title(
"What's your budget?",
"Enter your total trip budget",
),

const SizedBox(height: 15),

_budgetField(),

const SizedBox(height: 25),

_title(
"Who's travelling?",
"Select number of travelers",
),

const SizedBox(height: 15),

_travelerSelector(),

const SizedBox(height: 25),

_title(
"How long will you stay?",
"Select number of nights",
),

const SizedBox(height: 15),

_nightSelector(),

const SizedBox(height: 25),

_title(
"Choose your hotel category",
"Select your preferred hotel level",
),

const SizedBox(height: 15),

_starSelector(),

const SizedBox(height: 30),

_planButton(),
],
),
);
}

// --------------------------------------------------
// TITLE
// --------------------------------------------------

Widget _title(String title, String subtitle) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontSize: 19,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
subtitle,
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 13,
),
),
],
);
}

// --------------------------------------------------
// DESTINATION
// --------------------------------------------------

Widget _destinationDropdown() {
return DropdownButtonFormField<String>(
value: selectedDestination,
isExpanded: true,

decoration: InputDecoration(
prefixIcon: const Icon(
Icons.location_on_outlined,
),
hintText: "Select destination",
filled: true,
fillColor: const Color(0xFFF1F1F1),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
borderSide: BorderSide.none,
),
),

items: destinations.map((destination) {
return DropdownMenuItem(
value: destination,
child: Text(destination),
);
}).toList(),

onChanged: (value) {
setState(() {
selectedDestination = value;
showPlan = false;
});
},
);
}

// --------------------------------------------------
// BUDGET
// --------------------------------------------------

Widget _budgetField() {
return TextField(
controller: budgetController,
keyboardType: TextInputType.number,

onChanged: (_) {
if (showPlan) {
setState(() {
showPlan = false;
});
}
},

decoration: InputDecoration(
prefixIcon: const Icon(
Icons.currency_rupee,
),
hintText: "Enter your budget",
filled: true,
fillColor: const Color(0xFFF1F1F1),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(16),
borderSide: BorderSide.none,
),
),
);
}

// --------------------------------------------------
// TRAVELERS
// --------------------------------------------------

Widget _travelerSelector() {
return _counterBox(
icon: Icons.people_outline,
text:
"$travelers ${travelers == 1 ? "Traveler" : "Travelers"}",
decrease: () {
if (travelers > 1) {
setState(() {
travelers--;
showPlan = false;
});
}
},
increase: () {
if (travelers < 20) {
setState(() {
travelers++;
showPlan = false;
});
}
},
);
}

// --------------------------------------------------
// NIGHTS
// --------------------------------------------------

Widget _nightSelector() {
return _counterBox(
icon: Icons.nights_stay_outlined,
text: "$nights ${nights == 1 ? "Night" : "Nights"}",
decrease: () {
if (nights > 1) {
setState(() {
nights--;
showPlan = false;
});
}
},
increase: () {
if (nights < 30) {
setState(() {
nights++;
showPlan = false;
});
}
},
);
}

// --------------------------------------------------
// COUNTER
// --------------------------------------------------

Widget _counterBox({
required IconData icon,
required String text,
required VoidCallback decrease,
required VoidCallback increase,
}) {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 15,
vertical: 12,
),
decoration: BoxDecoration(
color: const Color(0xFFF1F1F1),
borderRadius: BorderRadius.circular(16),
),
child: Row(
children: [
Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
),
child: Icon(icon),
),

const SizedBox(width: 15),

Expanded(
child: Text(
text,
style: const TextStyle(
fontSize: 16,
fontWeight: FontWeight.w600,
),
),
),

_roundButton(
Icons.remove,
decrease,
),

const SizedBox(width: 10),

_roundButton(
Icons.add,
increase,
),
],
),
);
}

// --------------------------------------------------
// ROUND BUTTON
// --------------------------------------------------

Widget _roundButton(
IconData icon,
VoidCallback onPressed,
) {
return InkWell(
onTap: onPressed,
borderRadius: BorderRadius.circular(12),
child: Container(
padding: const EdgeInsets.all(9),
decoration: BoxDecoration(
color: Colors.black,
borderRadius: BorderRadius.circular(12),
),
child: Icon(
icon,
color: Colors.white,
size: 18,
),
),
);
}

// --------------------------------------------------
// STARS
// --------------------------------------------------

Widget _starSelector() {
return LayoutBuilder(
builder: (context, constraints) {
final bool large = constraints.maxWidth > 600;

return Wrap(
spacing: 10,
runSpacing: 10,
children: List.generate(
5,
(index) {
final stars = index + 1;
final selected = selectedStars == stars;

return GestureDetector(
onTap: () {
setState(() {
selectedStars = stars;
showPlan = false;
});
},

child: AnimatedContainer(
duration:
const Duration(milliseconds: 200),

width: large
? (constraints.maxWidth - 40) / 5
    : (constraints.maxWidth - 10) / 2,

padding: const EdgeInsets.symmetric(
vertical: 16,
),

decoration: BoxDecoration(
color: selected
? Colors.black
    : const Color(0xFFF1F1F1),

borderRadius:
BorderRadius.circular(16),

border: Border.all(
color: selected
? Colors.black
    : Colors.transparent,
width: 2,
),
),

child: Column(
children: [
Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: List.generate(
stars,
(_) => const Icon(
Icons.star,
size: 15,
color: Colors.orange,
),
),
),

const SizedBox(height: 8),

Text(
"$stars Star",
style: TextStyle(
color: selected
? Colors.white
    : Colors.black,
fontWeight: FontWeight.bold,
),
),
],
),
),
);
},
),
);
},
);
}

// --------------------------------------------------
// PLAN BUTTON
// --------------------------------------------------

Widget _planButton() {
return SizedBox(
width: double.infinity,
height: 58,
child: ElevatedButton(
onPressed: planTrip,
style: ElevatedButton.styleFrom(
backgroundColor: Colors.black,
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(18),
),
),
child: const Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(Icons.auto_awesome),

SizedBox(width: 10),

Text(
"Plan My Trip",
style: TextStyle(
fontSize: 16,
fontWeight: FontWeight.bold,
),
),
],
),
),
);
}

// ==================================================
// RESULTS
// ==================================================

Widget _resultSection() {
final hotel = hotelInfo;
final food = foodInfo;

return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_resultHeader(),

const SizedBox(height: 18),

_tripSummary(),

const SizedBox(height: 25),

_sectionHeading(
"Your selected stay",
"Based on your ${selectedStars}-star preference",
),

const SizedBox(height: 12),

_hotelCard(hotel),

const SizedBox(height: 15),

_mapButton(
icon: Icons.hotel,
text: "Find Hotels on Google Maps",
onPressed: findHotels,
),

const SizedBox(height: 25),

_sectionHeading(
"Food & dining",
"Find restaurants near your destination",
),

const SizedBox(height: 12),

_foodCard(food),

const SizedBox(height: 15),

_mapButton(
icon: Icons.restaurant,
text: "Find Food on Google Maps",
onPressed: findFood,
),

const SizedBox(height: 25),

_importantNote(),
],
);
}

// --------------------------------------------------
// RESULT HEADER
// --------------------------------------------------

Widget _resultHeader() {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(25),
decoration: BoxDecoration(
color: Colors.black,
borderRadius: BorderRadius.circular(25),
),
child: Row(
children: [
Container(
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: Colors.white.withOpacity(.12),
shape: BoxShape.circle,
),
child: const Icon(
Icons.check,
color: Colors.white,
size: 30,
),
),

const SizedBox(width: 15),

const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
"Your trip plan is ready!",
style: TextStyle(
color: Colors.white,
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

SizedBox(height: 5),

Text(
"Here's your personalized starting point.",
style: TextStyle(
color: Colors.white70,
fontSize: 13,
),
),
],
),
),
],
),
);
}

// --------------------------------------------------
// SUMMARY
// --------------------------------------------------

Widget _tripSummary() {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
border: Border.all(
color: Colors.grey.shade300,
),
),
child: Column(
children: [
_summaryRow(
Icons.location_on_outlined,
"Destination",
selectedDestination ?? "",
),

const Divider(height: 25),

_summaryRow(
Icons.people_outline,
"Travelers",
"$travelers",
),

const Divider(height: 25),

_summaryRow(
Icons.nights_stay_outlined,
"Duration",
"$nights ${nights == 1 ? "night" : "nights"}",
),

const Divider(height: 25),

_summaryRow(
Icons.currency_rupee,
"Total Budget",
"₹${budgetController.text}",
),

const Divider(height: 25),

_summaryRow(
Icons.star_outline,
"Hotel Category",
"$selectedStars Star",
),
],
),
);
}

// --------------------------------------------------
// SUMMARY ROW
// --------------------------------------------------

Widget _summaryRow(
IconData icon,
String title,
String value,
) {
return Row(
children: [
Container(
padding: const EdgeInsets.all(9),
decoration: BoxDecoration(
color: const Color(0xFFEAEAEA),
borderRadius: BorderRadius.circular(10),
),
child: Icon(icon, size: 20),
),

const SizedBox(width: 13),

Expanded(
child: Text(
title,
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 14,
),
),
),

Flexible(
child: Text(
value,
textAlign: TextAlign.end,
style: const TextStyle(
fontWeight: FontWeight.bold,
fontSize: 15,
),
),
),
],
);
}

// --------------------------------------------------
// SECTION HEADING
// --------------------------------------------------

Widget _sectionHeading(
String title,
String subtitle,
) {
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
title,
style: const TextStyle(
fontSize: 21,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 4),

Text(
subtitle,
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 13,
),
),
],
);
}

// --------------------------------------------------
// HOTEL CARD
// --------------------------------------------------

Widget _hotelCard(Map<String, dynamic> hotel) {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.06),
blurRadius: 15,
offset: const Offset(0, 6),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 60,
height: 60,
decoration: BoxDecoration(
color: Colors.black,
borderRadius:
BorderRadius.circular(17),
),
child: Icon(
hotel["icon"] as IconData,
color: Colors.white,
size: 30,
),
),

const SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: List.generate(
selectedStars,
(_) => const Icon(
Icons.star,
color: Colors.orange,
size: 16,
),
),
),

const SizedBox(height: 5),

Text(
hotel["title"],
style: const TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 3),

Text(
hotel["subtitle"],
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
),
),
],
),
),
],
),

const SizedBox(height: 20),

Text(
hotel["description"],
style: TextStyle(
color: Colors.grey.shade700,
height: 1.5,
fontSize: 14,
),
),

const SizedBox(height: 18),

const Text(
"What to look for",
style: TextStyle(
fontWeight: FontWeight.bold,
fontSize: 15,
),
),

const SizedBox(height: 12),

Wrap(
spacing: 8,
runSpacing: 8,
children:
(hotel["features"] as List<String>)
    .map(
(feature) => Container(
padding:
const EdgeInsets.symmetric(
horizontal: 12,
vertical: 8,
),
decoration: BoxDecoration(
color: const Color(0xFFEAEAEA),
borderRadius:
BorderRadius.circular(20),
),
child: Text(
feature,
style: const TextStyle(
fontSize: 12,
fontWeight: FontWeight.w500,
),
),
),
)
    .toList(),
),
],
),
);
}

// --------------------------------------------------
// FOOD CARD
// --------------------------------------------------

Widget _foodCard(Map<String, dynamic> food) {
return Container(
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(22),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(.06),
blurRadius: 15,
offset: const Offset(0, 6),
),
],
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Container(
width: 58,
height: 58,
decoration: BoxDecoration(
color: const Color(0xFFEAEAEA),
borderRadius:
BorderRadius.circular(16),
),
child: Icon(
food["icon"] as IconData,
color: Colors.black,
size: 28,
),
),

const SizedBox(width: 15),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
food["title"],
style: const TextStyle(
fontSize: 17,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 7),

Text(
food["description"],
style: TextStyle(
color: Colors.grey.shade700,
fontSize: 13,
height: 1.5,
),
),
],
),
),
],
),
);
}

// --------------------------------------------------
// MAP BUTTON
// --------------------------------------------------

Widget _mapButton({
required IconData icon,
required String text,
required VoidCallback onPressed,
}) {
return SizedBox(
width: double.infinity,
height: 52,
child: OutlinedButton.icon(
onPressed: onPressed,
icon: Icon(
icon,
color: Colors.black,
),
label: Text(
text,
style: const TextStyle(
color: Colors.black,
fontWeight: FontWeight.bold,
),
),
style: OutlinedButton.styleFrom(
backgroundColor: Colors.white,
side: const BorderSide(
color: Colors.black,
width: 1.5,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(15),
),
),
),
);
}

// --------------------------------------------------
// IMPORTANT NOTE
// --------------------------------------------------

Widget _importantNote() {
return Container(
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: const Color(0xFFEAEAEA),
borderRadius: BorderRadius.circular(18),
border: Border.all(
color: Colors.grey.shade400,
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Icon(
Icons.info_outline,
color: Colors.black,
),

const SizedBox(width: 12),

Expanded(
child: Text(
"These are planning suggestions. "
"Hotel and food results are opened through Google Maps, "
"so availability, prices and ratings come directly from Maps.",
style: TextStyle(
color: Colors.grey.shade800,
fontSize: 12,
height: 1.5,
),
),
),
],
),
);
}
}
