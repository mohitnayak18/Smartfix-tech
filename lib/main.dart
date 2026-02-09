import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/utils/utils.dart';
import 'api_calls/services/services.dart';
import 'navigators/navigators.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();

    await initializeServices();

    runApp(const MyApp());
  } catch (error) {
    Utility.printELog('❌ Firebase initialization failed: $error');
  }
}

Future<void> initializeServices() async {
  Get.put(CommonService(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
    );

    return ScreenUtilInit(
      designSize: const Size(375, 745),
      builder: (ctx, _) => GetMaterialApp(
        locale: const Locale('en'),
        title: 'SmartFix App',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        getPages: AppPages.pages,
        translations: TranslationFile(),
        initialRoute: AppPages.initial,
        theme: themeData(context),
        enableLog: true,
      ),
    );
  }
}
