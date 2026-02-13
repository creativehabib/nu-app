import 'package:flutter/material.dart';

import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/location_screen.dart';
import '../widgets/app_bottom_nav.dart';

List<AppBottomNavItem> buildAppBottomNavItems(
  BuildContext context, {
  VoidCallback? onHomeTap,
  AppBottomNavItem? trailingItem,
}) {
  final items = [
    AppBottomNavItem(
      icon: Icons.info_outline,
      label: 'About',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AboutScreen(),
          ),
        );
      },
    ),
    AppBottomNavItem(
      icon: Icons.phone_outlined,
      label: 'Contact',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const ContactScreen(),
          ),
        );
      },
    ),
    AppBottomNavItem(
      icon: Icons.home,
      label: 'Home',
      onTap: onHomeTap,
    ),
    AppBottomNavItem(
      icon: Icons.location_on_outlined,
      label: 'Location',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const LocationScreen(),
          ),
        );
      },
    ),
    const AppBottomNavItem(
      icon: Icons.person_outline,
      label: 'Profile',
    ),
  ];

  if (trailingItem != null) {
    items.insert(items.length - 1, trailingItem);
  }

  return items;
}
