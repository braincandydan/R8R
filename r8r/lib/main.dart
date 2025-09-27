import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/locations/location_list_screen.dart';
import 'screens/locations/location_detail_screen.dart';
import 'screens/rating/rating_screen.dart';
import 'screens/rating/rate_selection_screen.dart';
import 'screens/rating/rate_new_screen.dart';
import 'screens/rewards/rewards_screen.dart';
import 'screens/locations/add_location_screen.dart';
import 'widgets/bottom_nav_bar.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/rating_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const R8RApp());
}

class R8RApp extends StatelessWidget {
  const R8RApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => RatingService()),
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp.router(
            title: 'R8R - Wing & Beer App',
      theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFD00000), // Red accent color
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.montserratTextTheme(),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
              ),
              cardTheme: const CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                color: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD00000), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            routerConfig: _createRouter(authService),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthService authService) {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = authService.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';

        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }
        if (isLoggedIn && isLoggingIn) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => MainLayout(child: child),
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
            GoRoute(
              path: '/locations',
              builder: (context, state) => const LocationListScreen(),
            ),
            GoRoute(
              path: '/rate',
              builder: (context, state) => const RateSelectionScreen(),
            ),
            GoRoute(
              path: '/rewards',
              builder: (context, state) => const RewardsScreen(),
            ),
            GoRoute(
              path: '/location/:id',
              builder: (context, state) {
                final locationId = state.pathParameters['id']!;
                return LocationDetailScreen(locationId: locationId);
              },
            ),
            GoRoute(
              path: '/rate/:locationId',
              builder: (context, state) {
                final locationId = state.pathParameters['locationId']!;
                return RatingScreen(locationId: locationId);
              },
            ),
            GoRoute(
              path: '/add-location',
              builder: (context, state) => const AddLocationScreen(),
            ),
            GoRoute(
              path: '/rate-new',
              builder: (context, state) => const RateNewScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    int currentIndex = 0;

    // Determine current tab index based on route
    if (currentLocation == '/locations') {
      currentIndex = 0; // Find
    } else if (currentLocation == '/rate' || currentLocation.startsWith('/rate/')) {
      currentIndex = 1; // Rate Wings
    } else if (currentLocation == '/rewards') {
      currentIndex = 2; // Rewards
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavBar(currentIndex: currentIndex),
    );
  }
}