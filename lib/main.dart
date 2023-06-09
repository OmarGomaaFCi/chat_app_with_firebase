import 'package:chat_app/business/auth/auth_cubit.dart';
import 'package:chat_app/business/chats/chats_cubit.dart';
import 'package:chat_app/core/app_router.dart';
import 'package:chat_app/core/constants/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
late String initialRoute;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For apply the full screen mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // For apply portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  FirebaseAuth.instance.authStateChanges().listen((user) {
    // You have logged out , no user
    // you should go to login page
    if(user == null){
      initialRoute = AppRoutes.loginScreenRoute;
    }else {
      initialRoute = AppRoutes.homeScreenRoute;
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    AuthCubit authCubit = AuthCubit();
    ChatsCubit chatsCubit = ChatsCubit();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.blueAccent,
          ),
          titleTextStyle: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter(authCubit , chatsCubit).generateRoute,
    );
  }
}
