import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/game_models.dart';
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
              colors: [color.withOpacity(0.8), color, color.withOpacity(0.6)],
            ),
            borderRadius: BorderRadius.circular(18),
            border:
                isHovering
                    ? Border.all(color: Colors.white, width: 6)
                    : Border.all(
                      color: Colors.white.withOpacity(0.7),
                      width: 3,
                    ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(3, 3),
              ),
              if (isHovering)
                BoxShadow(
                  color: Colors.white.withOpacity(0.5),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
            ],
          ),
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show grouped marbles count
                if (controller.groups[groupIndex].isNotEmpty)
                  Container(
                    width: 25,
                    height: 25,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${controller.groups[groupIndex].length}',
                        style: TextStyle(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Show mini marbles representation
                if (controller.groups[groupIndex].isNotEmpty)
                  const SizedBox(height: 5),
                ...controller.groups[groupIndex]
                    .take(6)
                    .map(
                      (marble) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(vertical: 1),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
              ],
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
