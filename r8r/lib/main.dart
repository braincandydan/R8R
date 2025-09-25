import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/locations/location_list_screen.dart';
import 'screens/locations/location_detail_screen.dart';
import 'screens/rating/rating_screen.dart';
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/rating_service.dart';

void main() {
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
                seedColor: const Color(0xFFE65100), // Orange theme for wings
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
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
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/locations',
          builder: (context, state) => const LocationListScreen(),
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
      ],
    );
  }
}