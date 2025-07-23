import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/game_models.dart';
import '../controllers/game_controller.dart';

/// Widget untuk color bar yang menerima marble drop
class ColorBarWidget extends StatelessWidget {
  final Color color;
  final int groupIndex;
  final GameController controller;

  const ColorBarWidget({
    super.key,
    required this.color,
    required this.groupIndex,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Marble>(
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        return Container(
          width: 50,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color,
                color.withOpacity(0.7),
                color.withOpacity(0.5),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(15),
            border:
                isHovering
                    ? Border.all(color: Colors.white, width: 4)
                    : Border.all(
                      color: Colors.white.withOpacity(0.8),
                      width: 2,
                    ),
            boxShadow: [
              // Shadow untuk efek 3D yang dalam
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
                spreadRadius: 2,
              ),
              // Inner shadow untuk efek cekung
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
              // Highlight shadow
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(-2, -2),
              ),
              if (isHovering)
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
            ],
          ),
          child: Obx(
            () => Center(
              child: Text(
                '${controller.groups[groupIndex].length}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      onWillAccept: (marble) => marble != null,
      onAccept: (marble) {
        controller.addMarbleToGroup(marble, groupIndex);
      },
    );
  }
}
