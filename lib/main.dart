import 'package:flutter/material.dart';
import 'package:green_finance/models/item_model.dart';
import 'package:green_finance/page/navigation_page.dart';
import 'package:green_finance/page/register_page.dart';
import 'package:green_finance/page/screens/input/add_item_page.dart';
import 'package:green_finance/page/screens/input/input_detail_expense_page.dart';
import 'package:green_finance/page/screens/input/input_detail_income_page.dart';
import 'package:green_finance/page/screens/input/input_expense_other_page.dart';
import 'package:green_finance/page/screens/input/input_expense_vegetable_page.dart';
import 'package:green_finance/page/screens/input/input_income_page.dart';
import 'package:green_finance/page/screens/report/report_detail_page.dart';
import 'package:green_finance/page/splash_page.dart';
import 'package:green_finance/repositories/Expense_repository.dart';
import 'package:green_finance/repositories/auth_repository.dart';
import 'package:green_finance/repositories/income_repository.dart';
import 'package:green_finance/repositories/item_repository.dart';
import 'package:green_finance/repositories/lov_repository.dart';
import 'package:green_finance/repositories/profile_repository.dart';
import 'package:green_finance/repositories/recap_repository.dart';
import 'package:green_finance/repositories/report_repository.dart';
import 'package:green_finance/repositories/route_observer.dart';
import 'package:green_finance/viewmodels/home_view_model.dart';
import 'package:green_finance/viewmodels/input_expense_view_model.dart';
import 'package:green_finance/viewmodels/input_income_view_model.dart';
import 'package:green_finance/viewmodels/item_view_model.dart';
import 'package:green_finance/viewmodels/lov_item_view_model.dart';
import 'package:green_finance/viewmodels/profile_view_model.dart';
import 'package:green_finance/viewmodels/recap_view_model.dart';
import 'package:green_finance/viewmodels/report_detail_view_model.dart';
import 'package:green_finance/viewmodels/report_view_model.dart';
import 'package:provider/provider.dart';
import 'viewmodels/auth_view_model.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:green_finance/page/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AuthViewModel authViewModel;
  late ItemViewModel itemViewModel;
  late ReportViewModel reportViewModel;
  late ReportDetailViewModel reportDetailViewModel;
  late RecapDetailViewModel recapDetailViewModel;
  late HomeViewModel homeViewModel;
  late InputIncomeViewModel inputIncomeViewModel;
  late InputExpenseViewModel inputExpenseViewModel;
  late ProfileViewModel profileViewModel;
  late LovItemViewModel lovItemViewModel;
  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepository();
    final itemRepository = ItemRepository();
    final reportRepository = ReportRepository();
    final recapRepository = RecapRepository();
    final inputRepository = IncomeRepository();
    final expenseRepository = ExpenseRepository();
    final profileRepository = ProfileRepository();
    final lovItemRepository = LovItemRepository();
    authViewModel = AuthViewModel(authRepository);
    itemViewModel = ItemViewModel(itemRepository);
    reportViewModel = ReportViewModel(reportRepository);
    reportDetailViewModel = ReportDetailViewModel(reportRepository);
    recapDetailViewModel = RecapDetailViewModel(recapRepository);
    homeViewModel = HomeViewModel(recapRepository);
    inputIncomeViewModel = InputIncomeViewModel(inputRepository);
    inputExpenseViewModel = InputExpenseViewModel(expenseRepository);
    profileViewModel = ProfileViewModel(profileRepository);
    lovItemViewModel = LovItemViewModel(lovItemRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authViewModel),
        ChangeNotifierProvider(create: (_) => itemViewModel),
        ChangeNotifierProvider(create: (_) => reportViewModel),
        ChangeNotifierProvider(create: (_) => reportDetailViewModel),
        ChangeNotifierProvider(create: (_) => recapDetailViewModel),
        ChangeNotifierProvider(create: (_) => homeViewModel),
        ChangeNotifierProvider(create: (_) => inputIncomeViewModel),
        ChangeNotifierProvider(create: (_) => inputExpenseViewModel),
        ChangeNotifierProvider(create: (_) => profileViewModel),
        ChangeNotifierProvider(create: (_) => lovItemViewModel),
      ],
      child: MaterialApp(
        title: 'Green Finance App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        navigatorObservers: [routeObserver],
        home: const SplashPage(),
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case SplashPage.routeName:
              return MaterialPageRoute(
                builder: (_) => const SplashPage(),
              );
            case InputExpenseOtherPage.routeName:
              return MaterialPageRoute(
                builder: (_) => const InputExpenseOtherPage(),
              );
            case InputExpenseVegetablePage.routeName:
              return MaterialPageRoute(
                builder: (_) => const InputExpenseVegetablePage(),
                settings: settings,
              );
            case InputExpenseDetailPage.routeName:
              final itemId = settings.arguments as Map<String, dynamic>;
              final id = itemId['id'];
              final type = itemId['type'];
              return MaterialPageRoute(
                builder: (_) => InputExpenseDetailPage(
                  id: id,
                  type: type,
                ),
              );
            case InputIncomePage.routeName:
              return MaterialPageRoute(
                builder: (_) => const InputIncomePage(),
                settings: settings,
              );
            case InputIncomeDetailPage.routeName:
              final itemId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => InputIncomeDetailPage(id: itemId),
              );
            case ReportDetailPage.routeName:
              return MaterialPageRoute(
                builder: (_) => const ReportDetailPage(),
                settings: settings,
              );
            case AddItemPage.routeName:
              final item = settings.arguments as ItemModel?;
              return MaterialPageRoute(builder: (_) => AddItemPage(item: item));
            case NavigationPage.routeName:
              return MaterialPageRoute(builder: (_) => const NavigationPage());
            case RegisterPage.routeName:
              return MaterialPageRoute(builder: (_) => const RegisterPage());
            default:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
          }
        },
      ),
    );
  }
}
