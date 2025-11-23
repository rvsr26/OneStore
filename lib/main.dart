import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Providers
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';

// Screens
import 'screens/login_page.dart';
import 'screens/onboarding_page.dart';
import 'screens/main_screen.dart';

void main() async {
  // 1. 🛡️ Ensure bindings are initialized before Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. 🔥 Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Offline Persistence (Optional but good)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, 
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 3. 🧩 Setup MultiProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      // 4. 🎨 Only listen to ThemeProvider here. 
      // Do NOT listen to AuthProvider here (prevents the crash).
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Shop',
            
            // Theme Logic
            themeMode: theme.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.indigo,
              scaffoldBackgroundColor: Colors.grey[50],
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.indigo,
              scaffoldBackgroundColor: const Color(0xFF121212),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                elevation: 0,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            // 5. 🏠 The Safe Root Route
            // We use a wrapper widget to handle Auth switching internally
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

// 6. 🛡️ The Crash Fixer: AuthWrapper
// This isolates the Auth updates to just this widget, leaving MaterialApp stable.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Listen to AuthProvider ONLY inside this widget
    final auth = Provider.of<AuthProvider>(context);

    if (auth.isAuthLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Switch screens based on login state
    if (auth.isLoggedIn) {
      return MainScreen();
    } else {
      return OnboardingPage();
    }
  }
}