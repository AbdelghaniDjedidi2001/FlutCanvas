// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/canvas/data/datasources/board_local_data_source.dart'
    as _i868;
import '../../features/canvas/data/repositories/shared_prefs_board_repository.dart'
    as _i388;
import '../../features/canvas/domain/repositories/board_repository.dart'
    as _i818;
import '../../features/canvas/domain/usecases/align_elements_usecase.dart'
    as _i320;
import '../../features/canvas/domain/usecases/distribute_elements_usecase.dart'
    as _i236;
import '../../features/canvas/domain/usecases/group_elements_usecase.dart'
    as _i680;
import '../../features/canvas/domain/usecases/load_workspace_usecase.dart'
    as _i161;
import '../../features/canvas/domain/usecases/save_workspace_usecase.dart'
    as _i41;
import '../../features/canvas/domain/usecases/ungroup_elements_usecase.dart'
    as _i123;
import '../../features/canvas/presentation/bloc/boards_cubit.dart' as _i936;
import '../../features/canvas/presentation/bloc/canvas_bloc.dart' as _i796;
import '../../features/canvas/presentation/tools/tool_registry.dart' as _i939;
import '../../features/clipboard/data/services/default_clipboard_repository.dart'
    as _i680;
import '../../features/clipboard/domain/repositories/clipboard_repository.dart'
    as _i10;
import '../../features/comments/presentation/bloc/comments_cubit.dart' as _i947;
import '../../features/export/data/services/default_export_repository.dart'
    as _i158;
import '../../features/export/domain/repositories/export_repository.dart'
    as _i1051;
import '../../features/export/presentation/bloc/export_cubit.dart' as _i599;
import '../../features/layers/presentation/bloc/layers_cubit.dart' as _i653;
import '../../features/presentation_mode/presentation/bloc/presentation_cubit.dart'
    as _i837;
import '../../features/toolbar/presentation/bloc/tool_cubit.dart' as _i453;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.prefs,
      preResolve: true,
    );
    gh.factory<_i320.AlignElementsUseCase>(
      () => const _i320.AlignElementsUseCase(),
    );
    gh.factory<_i236.DistributeElementsUseCase>(
      () => const _i236.DistributeElementsUseCase(),
    );
    gh.factory<_i680.GroupElementsUseCase>(
      () => const _i680.GroupElementsUseCase(),
    );
    gh.factory<_i123.UngroupElementsUseCase>(
      () => const _i123.UngroupElementsUseCase(),
    );
    gh.factory<_i947.CommentsCubit>(() => _i947.CommentsCubit());
    gh.factory<_i653.LayersCubit>(() => _i653.LayersCubit());
    gh.factory<_i837.PresentationCubit>(() => _i837.PresentationCubit());
    gh.factory<_i453.ToolCubit>(() => _i453.ToolCubit());
    gh.lazySingleton<_i939.ToolRegistry>(() => _i939.ToolRegistry());
    gh.lazySingleton<_i10.ClipboardRepository>(
      () => _i680.DefaultClipboardRepository(),
    );
    gh.lazySingleton<_i1051.ExportRepository>(
      () => _i158.DefaultExportRepository(),
    );
    gh.factory<_i796.CanvasBloc>(
      () => _i796.CanvasBloc(
        alignElements: gh<_i320.AlignElementsUseCase>(),
        distributeElements: gh<_i236.DistributeElementsUseCase>(),
        groupElements: gh<_i680.GroupElementsUseCase>(),
        ungroupElements: gh<_i123.UngroupElementsUseCase>(),
      ),
    );
    gh.factory<_i599.ExportCubit>(
      () => _i599.ExportCubit(gh<_i1051.ExportRepository>()),
    );
    gh.lazySingleton<_i868.BoardLocalDataSource>(
      () => _i868.SharedPrefsBoardDataSource(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i818.BoardRepository>(
      () => _i388.SharedPrefsBoardRepository(gh<_i868.BoardLocalDataSource>()),
    );
    gh.factory<_i161.LoadWorkspaceUseCase>(
      () => _i161.LoadWorkspaceUseCase(gh<_i818.BoardRepository>()),
    );
    gh.factory<_i41.SaveWorkspaceUseCase>(
      () => _i41.SaveWorkspaceUseCase(gh<_i818.BoardRepository>()),
    );
    gh.factory<_i936.BoardsCubit>(
      () => _i936.BoardsCubit(
        gh<_i161.LoadWorkspaceUseCase>(),
        gh<_i41.SaveWorkspaceUseCase>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
