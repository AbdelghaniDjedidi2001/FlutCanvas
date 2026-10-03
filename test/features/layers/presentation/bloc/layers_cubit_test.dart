import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/layers/presentation/bloc/layers_cubit.dart';
import 'package:flutcanvas/features/layers/presentation/bloc/layers_state.dart';

void main() {
  group('LayersCubit Tests', () {
    late LayersCubit cubit;

    setUp(() {
      cubit = LayersCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state has empty search and activeTab 0', () {
      expect(cubit.state.searchQuery, isEmpty);
      expect(cubit.state.activeTab, equals(0));
    });

    blocTest<LayersCubit, LayersState>(
      'setSearchQuery updates query',
      build: () => cubit,
      act: (c) => c.setSearchQuery('rectangle'),
      expect: () => [
        const LayersState(searchQuery: 'rectangle'),
      ],
    );

    blocTest<LayersCubit, LayersState>(
      'setActiveTab switches between elements and comments tab',
      build: () => cubit,
      act: (c) => c.setActiveTab(1),
      expect: () => [
        const LayersState(activeTab: 1),
      ],
    );
  });
}
