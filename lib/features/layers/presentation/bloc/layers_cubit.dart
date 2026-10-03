import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'layers_state.dart';

@injectable
class LayersCubit extends Cubit<LayersState> {
  LayersCubit() : super(const LayersState());

  void setSearchQuery(String query) => emit(state.copyWith(searchQuery: query));

  void setActiveTab(int index) => emit(state.copyWith(activeTab: index));
}
