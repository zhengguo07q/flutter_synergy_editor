import 'dart:math' as math;
import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/think_hub_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:provider/provider.dart';

import 'core/pods/pods_observer.dart';
import 'core/route/route.dart';
import 'features/main/main_page.dart';
import 'features/theme/notifier/theme_notifier.dart';
import 'features/theme/utils/app_scroll_behavior.dart';
import 'initialize.dart' as di;
import 'initialize.dart';


main() async{
  // debugPaintSizeEnabled = true;
  // debugCheckIntrinsicSizes = true;
  // debugFocusChanges = true;

  /// 手势调试
  //debugPrintHitTestResults = true;
  //debugPrintMouseHoverEvents = true;
  //debugPrintResamplingMargin = true;
  //debugPrintGestureArenaDiagnostics = true;
  //debugPrintRecognizerCallbacksTrace = true;

  /// 构建调试
  //debugPrintBuildScope = true;
  //debugPrintScheduleBuildForStacks = true;
  //debugPrintGlobalKeyedWidgetLifecycle = true;
  //debugPrintRebuildDirtyWidgets = true;

  /// 绘制调试
  //debugPrintBeginFrameBanner = true;
  //debugPrintEndFrameBanner = true;
  //debugPrintScheduleFrameStacks = true;

  //userId = '1300';
  await initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => di.sl<ThemeNotifier>(),
        ),
      ],
      child: ProviderScope(
        observers: <ProviderObserver>[PodsObserver()],
        child: ThinkHubApp(
          themeNotifier: di.sl<ThemeNotifier>()..loadAll(),
        ),
      ),
    ),
  );
}

class ThinkHubApp extends StatelessWidget {
  const ThinkHubApp({Key? key, required this.themeNotifier}) : super(key: key);
  final ThemeNotifier themeNotifier;

  @override
  Widget build(BuildContext context) {
    // 每当用户更新主题设置时，都会重新构建 MaterialApp。
    themeNotifier.setSchemeIndex(1);
    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: AppScrollBehavior(),
          restorationScopeId: 'app',
          title: 'Flutter Editor',
          // theme: buildTheme(themeNotifier),
          // darkTheme: darkTheme(themeNotifier),
          // themeMode: themeNotifier.themeMode,
          theme: getLight(),
          darkTheme: getDark(),
          home: const MainPage(),
          // 定义一个函数来处理命名路由，以支持 Flutter Web url 导航和深层链接。
          onGenerateRoute: AppRouter.onGenerateRoute,
          localizationsDelegates: const [
            ...ThinkHubLocalizations.localizationsDelegates,
            LocaleNamesLocalizationsDelegate(),
          ],
          supportedLocales: ThinkHubLocalizations.supportedLocales,
          // 使用 AppLocalizations 根据用户的语言环境配置正确的应用程序标题。
          // appTitle 在本地化目录中的 .arb 文件中定义。
          onGenerateTitle: (_) => ThinkHubLocalizations.of(_)!.appTitle,
        );
      },
    );
  }
}

ThemeData getLight(){
  return FlexThemeData.light(
    scheme: FlexScheme.deepBlue,
    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
    blendLevel: 20,
    //appBarStyle: FlexAppBarStyle.material,
    appBarOpacity: 0.95,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 20,
      blendOnColors: false,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  );
}

ThemeData getDark(){
  return FlexThemeData.dark(
    scheme: FlexScheme.ebonyClay,
    surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
    blendLevel: 15,
    appBarStyle: FlexAppBarStyle.background,
    appBarOpacity: 0.90,
    subThemesData: const FlexSubThemesData(
      blendOnLevel: 30,
    ),
    visualDensity: FlexColorScheme.comfortablePlatformDensity,
    useMaterial3: true,
  );
}
