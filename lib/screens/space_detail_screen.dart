import 'package:flutter/material.dart';

class SpaceDetailScreen extends StatelessWidget {
  final String spaceID;
  final String spaceName;

  const SpaceDetailScreen({
    super.key,
    required this.spaceID,
    required this.spaceName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(spaceName),
      ),
    );
  }
}