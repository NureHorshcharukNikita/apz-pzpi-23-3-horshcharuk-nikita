import 'package:flutter/material.dart';

class HomeEmptyTeamsCard extends StatelessWidget {
  const HomeEmptyTeamsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'You are not a member of any team yet.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
