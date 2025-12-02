import 'package:flutter/material.dart';
import '../../../app/config/theme.dart';

class AppBarHeader extends StatelessWidget {
  final String greeting;
  final VoidCallback onProfileTap;
  final VoidCallback onSettingsTap;

  const AppBarHeader({
    Key? key,
    required this.greeting,
    required this.onProfileTap,
    required this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings),
          color: vetproGreen,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: const Text(
                    'Bienvenido/a',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: vetproGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    greeting,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: vetproGreen.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: Colors.white,
          child: IconButton(
            onPressed: onProfileTap,
            icon: const Icon(Icons.person),
            color: vetproGreen,
          ),
        ),
      ],
    );
  }
}
