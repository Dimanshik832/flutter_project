import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'screens/shared/auth_screen.dart';
import 'screens/shared/verify_email_screen.dart';
import 'navigation/main_navigation.dart';
import 'firebase_options.dart';
import 'services/app_state_notifier.dart';
import 'services/notification_navigation_service.dart';
import 'services/push_token_service.dart';
import 'notifications/local_notifications.dart';
import 'l10n/app_localizations.dart';


final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();




@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  await LocalNotificationsService.initialize(
    onNotificationTap: NotificationNavigationService.handleNotificationTap,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final AppStateNotifier appStateNotifier = AppStateNotifier();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _onAppStateChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    MyApp.appStateNotifier.addListener(_onAppStateChanged);
  }

  @override
  void dispose() {
    MyApp.appStateNotifier.removeListener(_onAppStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MyApp.appStateNotifier,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DormFix',
          navigatorKey: NotificationNavigationService.navigatorKey,
          navigatorObservers: [routeObserver],

          locale: MyApp.appStateNotifier.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('pl'),
            Locale('ru'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          themeMode: MyApp.appStateNotifier.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFD),
            appBarTheme: const AppBarTheme(
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A1F44),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF0A1F44)),
              bodyMedium: TextStyle(color: Color(0xFF0A1F44)),
              bodySmall: TextStyle(color: Color(0xFF0A1F44)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              fillColor: Colors.white,
              filled: true,
            ),
            cardColor: Colors.white,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              titleTextStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
              bodySmall: TextStyle(color: Colors.white70),
            ),
            inputDecorationTheme: InputDecorationTheme(
              fillColor: const Color(0xFF1E1E1E),
              filled: true,
            ),
            cardColor: const Color(0xFF1E1E1E),
          ),

          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _pushInitialized = false;
  bool _initialMessageHandled = false;
  String? _lastUid;

  @override
  void initState() {
    super.initState();
    _initPush();
    _checkInitialMessage();
  }

  Future<void> _checkInitialMessage() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && !_initialMessageHandled) {
      _initialMessageHandled = true;
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        NotificationNavigationService.handleNotificationTap(initialMessage.data);
      }
    }
  }

  Future<void> _initPush() async {
    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await LocalNotificationsService.showForegroundNotification(message);
    });

    
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotificationNavigationService.handleNotificationTap(message.data);
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((_) {
      PushTokenService.saveFcmToken();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        final uid = user?.uid;

        
        if (uid != _lastUid) {
          _lastUid = uid;
          _pushInitialized = false;
          _initialMessageHandled = false;
        }

        if (user != null) {
          if (!_pushInitialized) {
            _pushInitialized = true;
            PushTokenService.saveFcmToken();
          }

          if (!user.emailVerified) {
            return const VerifyEmailScreen();
          }

          return const MainNavigation();
        }

        return const AuthScreen();
      },
    );
  }
}
