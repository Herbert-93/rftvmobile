import 'package:flutter/material.dart';

/// The fixed set of content categories shown on the Home screen and used to
/// group "highlights" on the Live TV screen. These must match the category
/// options an admin can choose in the admin panel's Programs form.
const List<String> kProgramCategories = [
  'News',
  'Sports',
  'Movies',
  'Shows',
  'Documentaries',
];

IconData categoryIcon(String? category) {
  switch (category) {
    case 'News':
      return Icons.newspaper_rounded;
    case 'Sports':
      return Icons.sports_soccer_rounded;
    case 'Movies':
      return Icons.movie_rounded;
    case 'Shows':
      return Icons.tv_rounded;
    case 'Documentaries':
      return Icons.menu_book_rounded;
    default:
      return Icons.play_circle_outline_rounded;
  }
}
