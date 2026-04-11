import 'package:flutter/material.dart';
import 'viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/costum_viewmodel.dart';
import 'viewmodels/notification_viewmodel.dart';
import 'views/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => CostumViewModel()),
        ChangeNotifierProvider(create: (_) => OrderViewModel()),
      ],
      child: MaterialApp(
        title: 'Noctoriagoras Cosrent',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
