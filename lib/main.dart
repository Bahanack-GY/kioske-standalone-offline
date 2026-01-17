import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kioske/providers/locale_provider.dart';
import 'package:kioske/providers/auth_provider.dart';
import 'package:kioske/providers/category_provider.dart';
import 'package:kioske/providers/product_provider.dart';
import 'package:kioske/providers/order_provider.dart';
import 'package:kioske/providers/customer_provider.dart';
import 'package:kioske/providers/expense_provider.dart';
import 'package:kioske/providers/dashboard_provider.dart';
import 'package:kioske/providers/stock_provider.dart';
import 'package:kioske/providers/report_provider.dart';
import 'package:kioske/providers/activity_provider.dart';
import 'package:kioske/providers/supply_delivery_provider.dart';
import 'package:kioske/providers/supplier_provider.dart';
import 'package:kioske/providers/employee_provider.dart';
import 'package:kioske/providers/promotion_provider.dart';
import 'package:kioske/providers/settings_provider.dart';
import 'package:kioske/screens/login_screen.dart';
import 'package:kioske/screens/language_selection_screen.dart';
import 'package:kioske/theme/app_theme.dart';
import 'package:kioske/l10n/app_localizations.dart';
import 'package:kioske/screens/admin_dashboard_screen.dart';
import 'package:kioske/screens/cashier_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => SupplyDeliveryProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),
        ChangeNotifierProvider(create: (_) => PromotionProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],

      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            title: 'Kioske POS',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('fr')],
            home: localeProvider.locale == null
                ? const LanguageSelectionScreen()
                : Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      if (!authProvider.isLoggedIn) {
                        return const LoginScreen();
                      }

                      if (authProvider.isAdmin) {
                        return const AdminDashboardScreen();
                      } else {
                        return const CashierDashboardScreen();
                      }
                    },
                  ),
          );
        },
      ),
    );
  }
}
