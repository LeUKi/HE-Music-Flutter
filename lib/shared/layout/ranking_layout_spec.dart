import 'dart:math' as math;

class RankingRowLayoutSpec {
  const RankingRowLayoutSpec({required this.coverSide});

  final double coverSide;
}

class RankingGridLayoutSpec {
  const RankingGridLayoutSpec({
    required this.crossAxisCount,
    required this.itemWidth,
    required this.spacing,
  });

  final int crossAxisCount;
  final double itemWidth;
  final double spacing;
}

RankingRowLayoutSpec resolveRankingRowLayoutSpec({
  required double maxWidth,
  double maxCoverSide = 176,
  double spacing = 12,
}) {
  final safeWidth = math.max(maxWidth, 0).toDouble();
  final rawCoverSide = (safeWidth - spacing * 2) / 3;
  final coverSide = rawCoverSide.clamp(0, maxCoverSide).toDouble();
  return RankingRowLayoutSpec(coverSide: coverSide);
}

RankingGridLayoutSpec resolveRankingGridLayoutSpec({
  required double maxWidth,
  double minItemWidth = 150,
  double spacing = 12,
  int minCrossAxisCount = 3,
}) {
  final safeWidth = math.max(maxWidth, 0).toDouble();
  final estimatedCount = ((safeWidth + spacing) / (minItemWidth + spacing))
      .floor();
  final crossAxisCount = math.max(minCrossAxisCount, estimatedCount);
  final totalSpacing = spacing * (crossAxisCount - 1);
  final itemWidth = (safeWidth - totalSpacing) / crossAxisCount;

  return RankingGridLayoutSpec(
    crossAxisCount: crossAxisCount,
    itemWidth: itemWidth,
    spacing: spacing,
  );
}
