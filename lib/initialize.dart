import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart' hide LayoutBuilder;
import 'package:get_it/get_it.dart';
import 'package:thinkhub_client/workbench/updater/document_controller.dart';
import 'package:thinkhub_client/workbench/layout/layout_builder.dart';

import 'features/storage/hive_document.dart';
import 'features/storage/hive_storage.dart';
import 'features/theme/notifier/theme_notifier.dart';
import 'features/theme/services/theme_service_prefs.dart';

final sl = GetIt.instance;

final hiveStorageInstance = sl.get<HiveStorage>();
final hiveDocumentInstance = sl.get<HiveDocument>();
final documentControllerInstance = sl.get<DocumentController>();
final layoutBuilderInstance = sl.get<LayoutBuilder>();

Future initialize() async {
  registerFactory();

  /// 前置数据库需要同步
  await hiveStorageInstance.init();
  await documentControllerInstance.init();

  SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) =>
      {documentControllerInstance.loadDocumentByOpenId()});
}

void registerFactory() {
  WidgetsFlutterBinding.ensureInitialized();

  sl.registerLazySingleton<ThemeServicePrefs>(() => ThemeServicePrefs());
  sl.get<ThemeServicePrefs>().init();
  sl.registerLazySingleton<ThemeNotifier>(
      () => ThemeNotifier(sl<ThemeServicePrefs>())..loadAll());

  sl.registerLazySingleton<DocumentController>(() => DocumentController());
  sl.registerLazySingleton<HiveStorage>(() => HiveStorage());
  sl.registerLazySingleton<HiveDocument>(() => HiveDocument());

  sl.registerLazySingleton<LayoutBuilder>(() => LayoutBuilder());
}
