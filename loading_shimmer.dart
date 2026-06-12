import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/theme.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardDark,
      highlightColor: AppTheme.cardDark2.withOpacity(0.5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(height: 260, radius: 24),
            const SizedBox(height: 20),
            _ShimmerBox(height: 28, width: 140),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (_, __) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ShimmerBox(width: 72, height: 120, radius: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _ShimmerBox(height: 28, width: 160),
            const SizedBox(height: 12),
            for (int i = 0; i < 5; i++) ...[
              _ShimmerBox(height: 60, radius: 16),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double? width;
  final double radius;

  const _ShimmerBox({
    required this.height,
    this.width,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
