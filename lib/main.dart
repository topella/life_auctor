import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:life_auctor/firebase_options.dart';
import 'package:life_auctor/home_navigation.dart';
import 'package:life_auctor/providers/item_provider_v3.dart';
import 'package:life_auctor/providers/theme_provider.dart';
import 'package:life_auctor/providers/auth_provider.dart';
import 'package:life_auctor/providers/shopping_list_provider_v2.dart';
import 'package:life_auctor/providers/history_provider.dart';
import 'package:life_auctor/providers/notification_provider.dart';
import 'package:life_auctor/providers/settings_provider.dart';
import 'package:life_auctor/services/connectivity_service.dart';
import 'package:life_auctor/services/sync_queue_service.dart';
import 'package:life_auctor/services/auth_service.dart';
import 'package:life_auctor/services/firestore_service.dart';
import 'package:life_auctor/services/expiry_check_service.dart';
import 'package:life_auctor/data/database_helper.dart';
import 'package:life_auctor/repositories/item_repository_v2.dart';
import 'package:life_auctor/repositories/shopping_list_repository_v2.dart';
import 'package:life_auctor/screens/auth/login_screen.dart';
import 'package:life_auctor/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        ChangeNotifierProxyProvider<ConnectivityService, SyncQueueService>(
          create: (context) => SyncQueueService(
            Provider.of<ConnectivityService>(context, listen: false),
          ),
          update: (_, connectivity, previous) =>
              previous ?? SyncQueueService(connectivity),
        ),

        // Singleton services
        Provider(create: (_) => firebase_auth.FirebaseAuth.instance),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => DatabaseHelper()),

        // Auth provider
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (_, authService, previous) =>
              previous ?? AuthProvider(authService),
        ),

        // Other providers
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
        ),

        // ItemRepositoryV2
        ProxyProvider5<
          DatabaseHelper,
          FirestoreService,
          firebase_auth.FirebaseAuth,
          SyncQueueService,
          ConnectivityService,
          ItemRepositoryV2
        >(
          update: (_, db, fire, auth, sync, conn, __) =>
              ItemRepositoryV2(db, fire, auth, sync, conn),
        ),

        // ShoppingListRepositoryV2
        ProxyProvider5<
          DatabaseHelper,
          FirestoreService,
          firebase_auth.FirebaseAuth,
          SyncQueueService,
          ConnectivityService,
          ShoppingListRepositoryV2
        >(
          update: (_, db, fire, auth, sync, conn, __) =>
              ShoppingListRepositoryV2(db, fire, auth, sync, conn),
        ),

        // NotificationProvider must be before expiryCheckService
        ChangeNotifierProxyProvider3<
          FirestoreService,
          firebase_auth.FirebaseAuth,
          AuthProvider,
          NotificationProvider
        >(
          create: (context) => NotificationProvider(
            firestoreService: Provider.of<FirestoreService>(
              context,
              listen: false,
            ),
            auth: firebase_auth.FirebaseAuth.instance,
          ),
          update: (context, fire, auth, authProvider, previous) {
            if (previous == null) {
              final provider = NotificationProvider(
                firestoreService: fire,
                auth: auth,
              );
              if (authProvider.isAuthenticated) {
                provider.loadNotifications();
              }
              return provider;
            }
            // On hot reload or auth state change, reload notifications if authenticated
            if (authProvider.isAuthenticated && previous.isEmpty) {
              previous.loadNotifications();
            }
            return previous;
          },
        ),

        // ExpiryCheckService
        ProxyProvider<NotificationProvider, ExpiryCheckService>(
          update: (context, notificationProvider, previous) {
            return ExpiryCheckService(
              notificationProvider: notificationProvider,
            );
          },
        ),

        // ItemProviderV3and auto-load
        ChangeNotifierProxyProvider5<
          ItemRepositoryV2,
          ConnectivityService,
          SyncQueueService,
          AuthProvider,
          ExpiryCheckService,
          ItemProviderV3
        >(
          create: (context) => ItemProviderV3(
            repository: Provider.of<ItemRepositoryV2>(context, listen: false),
            connectivity: Provider.of<ConnectivityService>(
              context,
              listen: false,
            ),
            syncQueue: Provider.of<SyncQueueService>(context, listen: false),
          ),
          update: (context, repo, conn, sync, auth, expiryCheck, previous) {
            if (previous == null) {
              final provider = ItemProviderV3(
                repository: repo,
                connectivity: conn,
                syncQueue: sync,
              );
              if (auth.isAuthenticated) {
                provider.loadItems().then((_) {
                  // Check for expiring or expired items after loading
                  expiryCheck.checkItems(provider.items);
                });
              }
              return provider;
            }
            // On hot reload or auth state change, reload items if authenticated
            if (auth.isAuthenticated && previous.isEmpty) {
              previous.loadItems().then((_) {
                // For expiring/expired items after loading
                expiryCheck.checkItems(previous.items);
              });
            } else if (!auth.isAuthenticated && previous.items.isNotEmpty) {
              // user looged out and reset notifications
              expiryCheck.onUserChanged();
            }
            return previous;
          },
        ),

        // HistoryProvider
        ChangeNotifierProxyProvider2<
          FirestoreService,
          firebase_auth.FirebaseAuth,
          HistoryProvider
        >(
          create: (context) => HistoryProvider(
            firestoreService: Provider.of<FirestoreService>(
              context,
              listen: false,
            ),
            auth: firebase_auth.FirebaseAuth.instance,
          ),
          update: (context, fire, auth, previous) {
            if (previous == null) {
              final provider = HistoryProvider(
                firestoreService: fire,
                auth: auth,
              );
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (authProvider.isAuthenticated) {
                provider.loadEvents();
              }
              return provider;
            }
            return previous;
          },
        ),

        // ShoppingListProviderV2
        ChangeNotifierProxyProvider4<
          ShoppingListRepositoryV2,
          ConnectivityService,
          SyncQueueService,
          AuthProvider,
          ShoppingListProviderV2
        >(
          create: (context) => ShoppingListProviderV2(
            repository: Provider.of<ShoppingListRepositoryV2>(
              context,
              listen: false,
            ),
            connectivity: Provider.of<ConnectivityService>(
              context,
              listen: false,
            ),
            syncQueue: Provider.of<SyncQueueService>(context, listen: false),
          ),
          update: (context, repo, conn, sync, auth, previous) {
            if (previous == null) {
              final provider = ShoppingListProviderV2(
                repository: repo,
                connectivity: conn,
                syncQueue: sync,
              );
              if (auth.isAuthenticated) {
                provider.loadLists();
              }
              return provider;
            }
            if (auth.isAuthenticated && previous.isEmpty) {
              previous.loadLists();
            }
            return previous;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'LifeAuctor',
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            // Use Consumer for Firebase auth and guest mode
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                // Show splash screen while loading
                if (authProvider.isLoading) {
                  return const SplashScreen();
                }

                // Navigate based on auth/guest state
                if (authProvider.isAuthenticated) {
                  return const HomeNavigation();
                } else {
                  return const LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
