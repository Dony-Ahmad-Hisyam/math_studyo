import 'package:flutter/material.dart';
import '../widgets/marble_cluster_demo_widget.dart';

/// View to showcase the marble cluster design concept
class MarbleDesignShowcaseView extends StatefulWidget {
  const MarbleDesignShowcaseView({super.key});

  @override
  State<MarbleDesignShowcaseView> createState() =>
      _MarbleDesignShowcaseViewState();
}

class _MarbleDesignShowcaseViewState extends State<MarbleDesignShowcaseView>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Marble Cluster Design',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        foregroundColor: Colors.purple[700],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[100]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.scatter_plot_rounded,
                    size: 48,
                    color: Colors.purple[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Interactive Marble Clustering',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Educational game design with magnetic marble grouping',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Main demo canvas
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value * 0.05 + 0.95,
                  child: const MarbleClusterCanvas(),
                );
              },
            ),

            const SizedBox(height: 30),

            // Feature descriptions
            _buildFeatureCard(
              icon: Icons.group_work_rounded,
              title: 'Symmetric Clustering',
              description:
                  'Marbles automatically arrange in perfect clover or flower formations when grouped together.',
              color: Colors.red[600]!,
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              icon: Icons.auto_awesome,
              title: 'Glowing Connections',
              description:
                  'White connection lines create web-like patterns showing logical relationships between marbles.',
              color: Colors.blue[600]!,
            ),

            const SizedBox(height: 16),

            _buildFeatureCard(
              icon: Icons.touch_app_rounded,
              title: 'Magnetic Snapping',
              description:
                  'Marbles snap together with visual feedback, creating seamless organic merging behavior.',
              color: Colors.green[600]!,
            ),

            const SizedBox(height: 30),

            // Design specifications
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_rounded, color: Colors.purple[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Design Specifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSpecItem(
                    'Material',
                    'Deep red circular marbles with glossy texture',
                  ),
                  _buildSpecItem(
                    'Shadow',
                    'Soft drop shadows for depth perception',
                  ),
                  _buildSpecItem(
                    'Connections',
                    'Glowing white lines forming triangle patterns',
                  ),
                  _buildSpecItem(
                    'Grouping',
                    'Symmetrical 4-marble clusters in clover shape',
                  ),
                  _buildSpecItem(
                    'Interaction',
                    'Magnetic snapping with visual feedback',
                  ),
                  _buildSpecItem(
                    'Style',
                    'Flat vector illustration, mobile-friendly UI',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}
