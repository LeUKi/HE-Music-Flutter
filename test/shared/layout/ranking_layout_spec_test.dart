import 'package:flutter_test/flutter_test.dart';
import 'package:he_music_flutter/shared/layout/ranking_layout_spec.dart';

void main() {
  test('ranking row cover stops growing past desktop cap', () {
    final compact = resolveRankingRowLayoutSpec(maxWidth: 420);
    final desktop = resolveRankingRowLayoutSpec(maxWidth: 1440);

    expect(compact.coverSide, greaterThan(0));
    expect(desktop.coverSide, lessThanOrEqualTo(176));
    expect(desktop.coverSide, greaterThanOrEqualTo(compact.coverSide));
  });

  test('ranking grid adds columns on wide widths', () {
    final compact = resolveRankingGridLayoutSpec(maxWidth: 420);
    final desktop = resolveRankingGridLayoutSpec(maxWidth: 980);

    expect(compact.crossAxisCount, 3);
    expect(desktop.crossAxisCount, greaterThan(compact.crossAxisCount));
    expect(desktop.itemWidth, greaterThan(0));
  });
}
