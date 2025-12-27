import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;

  CategoryItem({required this.id, required this.title, required this.icon, required this.color});
}

final List<CategoryItem> galleryCategories = [
  CategoryItem(id: 'christmas', title: 'Christmas', icon: FontAwesomeIcons.tree, color: const Color(0xFFEF9A9A)), 
  CategoryItem(id: 'newyear', title: 'New Year', icon: FontAwesomeIcons.champagneGlasses, color: const Color(0xFF90CAF9)), 
  CategoryItem(id: 'birthday', title: 'Birthday', icon: FontAwesomeIcons.cakeCandles, color: const Color(0xFFF48FB1)), 
  CategoryItem(id: 'thanks', title: 'Thanks', icon: FontAwesomeIcons.heart, color: const Color(0xFFFFF59D)), 
  CategoryItem(id: 'motherDay', title: 'Parents Day', icon: FontAwesomeIcons.personBreastfeeding, color: const Color(0xFFCE93D8)), 
  CategoryItem(id: 'teachersDay', title: 'Teachers Day', icon: FontAwesomeIcons.chalkboardUser, color: const Color(0xFFBCAAA4)), 
  CategoryItem(id: 'tour', title: 'Travel', icon: FontAwesomeIcons.plane, color: const Color(0xFFA5D6A7)), 
  CategoryItem(id: 'halloween', title: 'Halloween', icon: FontAwesomeIcons.ghost, color: const Color(0xFFFFAB91)), 
  CategoryItem(id: 'thanksgiving', title: 'Harvest', icon: FontAwesomeIcons.wheatAwn, color: const Color(0xFFFFCC80)), 
  CategoryItem(id: 'hobby', title: 'Hobby', icon: FontAwesomeIcons.puzzlePiece, color: const Color(0xFFB39DDB)), 
  CategoryItem(id: 'sports', title: 'Sports', icon: FontAwesomeIcons.futbol, color: const Color(0xFF81C784)), 
  CategoryItem(id: 'my_photos', title: 'My Photos', icon: FontAwesomeIcons.images, color: const Color(0xFF90A4AE)), 
  CategoryItem(id: 'favorites', title: 'Favorites', icon: FontAwesomeIcons.star, color: const Color(0xFFFFF176)), 
  CategoryItem(id: 'letters', title: 'Letters', icon: FontAwesomeIcons.envelopeOpenText, color: const Color(0xFFB0BEC5)), 
];
