import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kioske Admin'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @period.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get period;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get totalSales;

  /// No description provided for @fromSelectedPeriod.
  ///
  /// In en, this message translates to:
  /// **'From the selected period'**
  String get fromSelectedPeriod;

  /// No description provided for @totalTransactions.
  ///
  /// In en, this message translates to:
  /// **'Total Transactions'**
  String get totalTransactions;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @averageTransaction.
  ///
  /// In en, this message translates to:
  /// **'Average Transaction'**
  String get averageTransaction;

  /// No description provided for @perTransaction.
  ///
  /// In en, this message translates to:
  /// **'Per transaction'**
  String get perTransaction;

  /// No description provided for @cashRegister.
  ///
  /// In en, this message translates to:
  /// **'Cash Register'**
  String get cashRegister;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalance;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get mobileMoney;

  /// No description provided for @mobilePayments.
  ///
  /// In en, this message translates to:
  /// **'Mobile payments'**
  String get mobilePayments;

  /// No description provided for @grossMargin.
  ///
  /// In en, this message translates to:
  /// **'Gross Margin'**
  String get grossMargin;

  /// No description provided for @netProfit.
  ///
  /// In en, this message translates to:
  /// **'Net Profit'**
  String get netProfit;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @hourlySales.
  ///
  /// In en, this message translates to:
  /// **'Hourly Sales'**
  String get hourlySales;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @newCustomers.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCustomers;

  /// No description provided for @returningCustomers.
  ///
  /// In en, this message translates to:
  /// **'Returning'**
  String get returningCustomers;

  /// No description provided for @top10BestSellers.
  ///
  /// In en, this message translates to:
  /// **'Top 10 Best Sellers'**
  String get top10BestSellers;

  /// No description provided for @slowestSellingProducts.
  ///
  /// In en, this message translates to:
  /// **'Slowest Selling Products'**
  String get slowestSellingProducts;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @stocks.
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get stocks;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get deliveries;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @employees.
  ///
  /// In en, this message translates to:
  /// **'Employees'**
  String get employees;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @promo.
  ///
  /// In en, this message translates to:
  /// **'Promo'**
  String get promo;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @automation.
  ///
  /// In en, this message translates to:
  /// **'Automation'**
  String get automation;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @stockManagement.
  ///
  /// In en, this message translates to:
  /// **'Stock Management'**
  String get stockManagement;

  /// No description provided for @cards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get cards;

  /// No description provided for @table.
  ///
  /// In en, this message translates to:
  /// **'Table'**
  String get table;

  /// No description provided for @searchStockPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name, category or supplier...'**
  String get searchStockPlaceholder;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @goodStock.
  ///
  /// In en, this message translates to:
  /// **'Good Stock'**
  String get goodStock;

  /// No description provided for @mediumStock.
  ///
  /// In en, this message translates to:
  /// **'Medium Stock'**
  String get mediumStock;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @productsFound.
  ///
  /// In en, this message translates to:
  /// **'product(s) found'**
  String get productsFound;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStock;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get unitPrice;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @graph.
  ///
  /// In en, this message translates to:
  /// **'Graph'**
  String get graph;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get pieces;

  /// No description provided for @stockAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Stock Analytics'**
  String get stockAnalytics;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @totalStockIn.
  ///
  /// In en, this message translates to:
  /// **'Total Stock In'**
  String get totalStockIn;

  /// No description provided for @totalStockOut.
  ///
  /// In en, this message translates to:
  /// **'Total Stock Out'**
  String get totalStockOut;

  /// No description provided for @netChange.
  ///
  /// In en, this message translates to:
  /// **'Net Change'**
  String get netChange;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @stockEvolution.
  ///
  /// In en, this message translates to:
  /// **'Stock Evolution'**
  String get stockEvolution;

  /// No description provided for @inVsOut.
  ///
  /// In en, this message translates to:
  /// **'In vs Out'**
  String get inVsOut;

  /// No description provided for @stockHistory.
  ///
  /// In en, this message translates to:
  /// **'Stock History'**
  String get stockHistory;

  /// No description provided for @dateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTime;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get type;

  /// No description provided for @supplierCustomer.
  ///
  /// In en, this message translates to:
  /// **'SUPPLIER/CUSTOMER'**
  String get supplierCustomer;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @finalStock.
  ///
  /// In en, this message translates to:
  /// **'FINAL STOCK'**
  String get finalStock;

  /// No description provided for @quantityToOrder.
  ///
  /// In en, this message translates to:
  /// **'Quantity to order *'**
  String get quantityToOrder;

  /// No description provided for @selectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select a supplier'**
  String get selectSupplier;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Notes on the order'**
  String get notesPlaceholder;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get confirmOrder;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @searchProductPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name, category or supplier...'**
  String get searchProductPlaceholder;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase price'**
  String get purchasePrice;

  /// No description provided for @salePrice.
  ///
  /// In en, this message translates to:
  /// **'Sale price'**
  String get salePrice;

  /// No description provided for @margin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get margin;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See More'**
  String get seeMore;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @beer.
  ///
  /// In en, this message translates to:
  /// **'Beer'**
  String get beer;

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @juice.
  ///
  /// In en, this message translates to:
  /// **'Juice'**
  String get juice;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Analytics - {productName}'**
  String analyticsTitle(Object productName);

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get totalRevenue;

  /// No description provided for @totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total profit'**
  String get totalProfit;

  /// No description provided for @averageMargin.
  ///
  /// In en, this message translates to:
  /// **'Average Margin'**
  String get averageMargin;

  /// No description provided for @salesEvolution.
  ///
  /// In en, this message translates to:
  /// **'Sales evolution'**
  String get salesEvolution;

  /// No description provided for @profitEvolution.
  ///
  /// In en, this message translates to:
  /// **'Profit Evolution'**
  String get profitEvolution;

  /// No description provided for @salesHistory.
  ///
  /// In en, this message translates to:
  /// **'Sales history'**
  String get salesHistory;

  /// No description provided for @detailedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Detailed Transaction History'**
  String get detailedTransactions;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total price'**
  String get totalPrice;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product details'**
  String get productDetails;

  /// No description provided for @generalInfo.
  ///
  /// In en, this message translates to:
  /// **'General Information'**
  String get generalInfo;

  /// No description provided for @financialInfo.
  ///
  /// In en, this message translates to:
  /// **'Financial Information'**
  String get financialInfo;

  /// No description provided for @unitMargin.
  ///
  /// In en, this message translates to:
  /// **'Unit Margin'**
  String get unitMargin;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @anonymousClient.
  ///
  /// In en, this message translates to:
  /// **'Anonymous Client'**
  String get anonymousClient;

  /// No description provided for @noContact.
  ///
  /// In en, this message translates to:
  /// **'No contact'**
  String get noContact;

  /// No description provided for @minStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock'**
  String get minStock;

  /// No description provided for @maxStock.
  ///
  /// In en, this message translates to:
  /// **'Maximum stock'**
  String get maxStock;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @addProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Add a category'**
  String get addProductCategory;

  /// No description provided for @editProductCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editProductCategory;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @image.
  ///
  /// In en, this message translates to:
  /// **'Product image'**
  String get image;

  /// No description provided for @browse.
  ///
  /// In en, this message translates to:
  /// **'Browse...'**
  String get browse;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected.'**
  String get noFileSelected;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @icon.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get icon;

  /// No description provided for @selectedIcon.
  ///
  /// In en, this message translates to:
  /// **'Selected icon'**
  String get selectedIcon;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @foodAndDrinks.
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get foodAndDrinks;

  /// No description provided for @addCategoryAction.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryAction;

  /// No description provided for @productManagement.
  ///
  /// In en, this message translates to:
  /// **'Product Management'**
  String get productManagement;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProduct;

  /// No description provided for @deliveryManagement.
  ///
  /// In en, this message translates to:
  /// **'Delivery Management'**
  String get deliveryManagement;

  /// No description provided for @recentDeliveriesFirst.
  ///
  /// In en, this message translates to:
  /// **'Most recent deliveries first'**
  String get recentDeliveriesFirst;

  /// No description provided for @newDelivery.
  ///
  /// In en, this message translates to:
  /// **'New delivery'**
  String get newDelivery;

  /// No description provided for @searchBySupplier.
  ///
  /// In en, this message translates to:
  /// **'Search by supplier...'**
  String get searchBySupplier;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @deliveriesFound.
  ///
  /// In en, this message translates to:
  /// **'delivery(s) found'**
  String get deliveriesFound;

  /// No description provided for @noDeliveriesFound.
  ///
  /// In en, this message translates to:
  /// **'No deliveries found'**
  String get noDeliveriesFound;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @numberOfItems.
  ///
  /// In en, this message translates to:
  /// **'Number of items'**
  String get numberOfItems;

  /// No description provided for @slips.
  ///
  /// In en, this message translates to:
  /// **'Slips'**
  String get slips;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @suppliersManagement.
  ///
  /// In en, this message translates to:
  /// **'Suppliers management'**
  String get suppliersManagement;

  /// No description provided for @newSupplier.
  ///
  /// In en, this message translates to:
  /// **'New supplier'**
  String get newSupplier;

  /// No description provided for @searchSupplierPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name or neighborhood...'**
  String get searchSupplierPlaceholder;

  /// No description provided for @suppliersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} supplier(s) found'**
  String suppliersFound(Object count);

  /// No description provided for @totalDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Total deliveries'**
  String get totalDeliveries;

  /// No description provided for @amountReceived.
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get amountReceived;

  /// No description provided for @productsSupplied.
  ///
  /// In en, this message translates to:
  /// **'Products supplied'**
  String get productsSupplied;

  /// No description provided for @otherProducts.
  ///
  /// In en, this message translates to:
  /// **'+{count} other products'**
  String otherProducts(Object count);

  /// No description provided for @averageAmountPerDelivery.
  ///
  /// In en, this message translates to:
  /// **'Average amount per delivery'**
  String get averageAmountPerDelivery;

  /// No description provided for @deliveryEvolution.
  ///
  /// In en, this message translates to:
  /// **'Delivery evolution'**
  String get deliveryEvolution;

  /// No description provided for @receivedAmountsEvolution.
  ///
  /// In en, this message translates to:
  /// **'Received amounts evolution'**
  String get receivedAmountsEvolution;

  /// No description provided for @deliveryHistory.
  ///
  /// In en, this message translates to:
  /// **'Delivery history'**
  String get deliveryHistory;

  /// No description provided for @averageAmount.
  ///
  /// In en, this message translates to:
  /// **'Average amount'**
  String get averageAmount;

  /// No description provided for @totalAmountReceived.
  ///
  /// In en, this message translates to:
  /// **'Total amount received'**
  String get totalAmountReceived;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @supplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier name'**
  String get supplierName;

  /// No description provided for @whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsapp;

  /// No description provided for @neighborhoodOptional.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood (optional)'**
  String get neighborhoodOptional;

  /// No description provided for @neighborhoodPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood, City'**
  String get neighborhoodPlaceholder;

  /// No description provided for @assignProducts.
  ///
  /// In en, this message translates to:
  /// **'Assign products'**
  String get assignProducts;

  /// No description provided for @createSupplier.
  ///
  /// In en, this message translates to:
  /// **'Create supplier'**
  String get createSupplier;

  /// No description provided for @editSupplierTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit supplier'**
  String get editSupplierTitle;

  /// No description provided for @assignedProducts.
  ///
  /// In en, this message translates to:
  /// **'Assigned products'**
  String get assignedProducts;

  /// No description provided for @employeesManagement.
  ///
  /// In en, this message translates to:
  /// **'Employees Management'**
  String get employeesManagement;

  /// No description provided for @addEmployee.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get addEmployee;

  /// No description provided for @searchEmployeePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by name, email or phone...'**
  String get searchEmployeePlaceholder;

  /// No description provided for @employeesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} employee(s) found'**
  String employeesFound(Object count);

  /// No description provided for @cashiers.
  ///
  /// In en, this message translates to:
  /// **'Cashiers'**
  String get cashiers;

  /// No description provided for @accountants.
  ///
  /// In en, this message translates to:
  /// **'Accountants'**
  String get accountants;

  /// No description provided for @coproprietors.
  ///
  /// In en, this message translates to:
  /// **'Co-proprietors'**
  String get coproprietors;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @hireDate.
  ///
  /// In en, this message translates to:
  /// **'Hire date'**
  String get hireDate;

  /// No description provided for @addNewEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add new employee'**
  String get addNewEmployeeTitle;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter password'**
  String get enterPassword;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @addEmployeeAction.
  ///
  /// In en, this message translates to:
  /// **'Add employee'**
  String get addEmployeeAction;

  /// No description provided for @transactionsEvolution.
  ///
  /// In en, this message translates to:
  /// **'Transactions evolution'**
  String get transactionsEvolution;

  /// No description provided for @periodColumn.
  ///
  /// In en, this message translates to:
  /// **'PERIOD'**
  String get periodColumn;

  /// No description provided for @salesColumn.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get salesColumn;

  /// No description provided for @transactionsColumn.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsColumn;

  /// No description provided for @avgTransactionColumn.
  ///
  /// In en, this message translates to:
  /// **'Avg per transaction'**
  String get avgTransactionColumn;

  /// No description provided for @editEmployeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit employee'**
  String get editEmployeeTitle;

  /// No description provided for @newPasswordOptional.
  ///
  /// In en, this message translates to:
  /// **'New password (optional)'**
  String get newPasswordOptional;

  /// No description provided for @leaveBlankForNoChange.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to keep current'**
  String get leaveBlankForNoChange;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @neighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get neighborhood;

  /// No description provided for @actionsColumn.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsColumn;

  /// No description provided for @deliveredProducts.
  ///
  /// In en, this message translates to:
  /// **'Delivered products'**
  String get deliveredProducts;

  /// No description provided for @confirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery'**
  String get confirmDelivery;

  /// No description provided for @vendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get vendor;

  /// No description provided for @deliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get deliveryDate;

  /// No description provided for @selectProducts.
  ///
  /// In en, this message translates to:
  /// **'Select products'**
  String get selectProducts;

  /// No description provided for @deliverySlips.
  ///
  /// In en, this message translates to:
  /// **'Delivery Slips'**
  String get deliverySlips;

  /// No description provided for @createDelivery.
  ///
  /// In en, this message translates to:
  /// **'Create delivery'**
  String get createDelivery;

  /// No description provided for @deliverySlipInfo.
  ///
  /// In en, this message translates to:
  /// **'Delivery slips will be requested upon confirmation of the delivery. The delivery will be created in \'Pending\' status and must be confirmed with the slips.'**
  String get deliverySlipInfo;

  /// No description provided for @uploadSlip.
  ///
  /// In en, this message translates to:
  /// **'Upload Slip'**
  String get uploadSlip;

  /// No description provided for @noSlipSelected.
  ///
  /// In en, this message translates to:
  /// **'No slip selected'**
  String get noSlipSelected;

  /// No description provided for @confirmDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery'**
  String get confirmDeliveryTitle;

  /// No description provided for @deliveryDetails.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get deliveryDetails;

  /// No description provided for @paymentDeductionInfo.
  ///
  /// In en, this message translates to:
  /// **'The delivery amount will be deducted from the balance of the selected method'**
  String get paymentDeductionInfo;

  /// No description provided for @deliverySlipsMandatory.
  ///
  /// In en, this message translates to:
  /// **'Delivery Slips (Mandatory)'**
  String get deliverySlipsMandatory;

  /// No description provided for @addSlipImages.
  ///
  /// In en, this message translates to:
  /// **'Add slip images'**
  String get addSlipImages;

  /// No description provided for @browseFiles.
  ///
  /// In en, this message translates to:
  /// **'Browse... No files selected.'**
  String get browseFiles;

  /// No description provided for @mandatorySlipWarning.
  ///
  /// In en, this message translates to:
  /// **'You must add at least one slip to confirm the delivery'**
  String get mandatorySlipWarning;

  /// No description provided for @noSlipSelectedMessage.
  ///
  /// In en, this message translates to:
  /// **'No slip selected\nSelect images to confirm the delivery'**
  String get noSlipSelectedMessage;

  /// No description provided for @deliveryDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery details - {vendor}'**
  String deliveryDetailsTitle(String vendor);

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @totalArticles.
  ///
  /// In en, this message translates to:
  /// **'Total articles'**
  String get totalArticles;

  /// No description provided for @product.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get product;

  /// No description provided for @noSlipAvailable.
  ///
  /// In en, this message translates to:
  /// **'No slip available'**
  String get noSlipAvailable;

  /// No description provided for @slipsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Slips will appear here once uploaded'**
  String get slipsWillAppearHere;

  /// No description provided for @customersManagement.
  ///
  /// In en, this message translates to:
  /// **'Customers Management'**
  String get customersManagement;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @searchCustomerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomerPlaceholder;

  /// No description provided for @customersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} customers found'**
  String customersFound(Object count);

  /// No description provided for @viewCustomers.
  ///
  /// In en, this message translates to:
  /// **'View Customers'**
  String get viewCustomers;

  /// No description provided for @targetCustomers.
  ///
  /// In en, this message translates to:
  /// **'Target Customers'**
  String get targetCustomers;

  /// No description provided for @loyal.
  ///
  /// In en, this message translates to:
  /// **'Loyal'**
  String get loyal;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newCustomer;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @totalPurchases.
  ///
  /// In en, this message translates to:
  /// **'Total Purchases'**
  String get totalPurchases;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @customerAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Customer Analytics'**
  String get customerAnalytics;

  /// No description provided for @consumptionHabits.
  ///
  /// In en, this message translates to:
  /// **'Consumption Habits'**
  String get consumptionHabits;

  /// No description provided for @favoriteProducts.
  ///
  /// In en, this message translates to:
  /// **'Favorite Products'**
  String get favoriteProducts;

  /// No description provided for @purchaseFrequency.
  ///
  /// In en, this message translates to:
  /// **'Purchase Frequency'**
  String get purchaseFrequency;

  /// No description provided for @preferredHours.
  ///
  /// In en, this message translates to:
  /// **'Preferred Hours'**
  String get preferredHours;

  /// No description provided for @purchaseAmounts.
  ///
  /// In en, this message translates to:
  /// **'Purchase Amounts'**
  String get purchaseAmounts;

  /// No description provided for @purchaseEvolution.
  ///
  /// In en, this message translates to:
  /// **'Purchase Evolution'**
  String get purchaseEvolution;

  /// No description provided for @revenuePerPeriod.
  ///
  /// In en, this message translates to:
  /// **'Revenue per Period'**
  String get revenuePerPeriod;

  /// No description provided for @avgValue.
  ///
  /// In en, this message translates to:
  /// **'Avg Value'**
  String get avgValue;

  /// No description provided for @smallPurchases.
  ///
  /// In en, this message translates to:
  /// **'Small purchases'**
  String get smallPurchases;

  /// No description provided for @mediumPurchases.
  ///
  /// In en, this message translates to:
  /// **'Medium purchases'**
  String get mediumPurchases;

  /// No description provided for @largePurchases.
  ///
  /// In en, this message translates to:
  /// **'Large purchases'**
  String get largePurchases;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get max;

  /// No description provided for @avg.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get avg;

  /// No description provided for @createCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Customer'**
  String get createCustomerTitle;

  /// No description provided for @createCustomerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a new customer to your database'**
  String get createCustomerSubtitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneLabel;

  /// No description provided for @neighborhoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood'**
  String get neighborhoodLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailLabel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @editCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomerTitle;

  /// No description provided for @editCustomerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update customer information'**
  String get editCustomerSubtitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @expensesManagement.
  ///
  /// In en, this message translates to:
  /// **'Expenses Management'**
  String get expensesManagement;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @paidExpenses.
  ///
  /// In en, this message translates to:
  /// **'Paid Expenses'**
  String get paidExpenses;

  /// No description provided for @pendingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Pending Expenses'**
  String get pendingExpenses;

  /// No description provided for @overdueExpenses.
  ///
  /// In en, this message translates to:
  /// **'Overdue Expenses'**
  String get overdueExpenses;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get markAsPaid;

  /// No description provided for @expenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Title'**
  String get expenseTitle;

  /// No description provided for @expenseAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenseAmount;

  /// No description provided for @expenseDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get expenseDate;

  /// No description provided for @expenseCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenseCategory;

  /// No description provided for @expenseDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get expenseDescription;

  /// No description provided for @expenseStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get expenseStatus;

  /// No description provided for @addNewExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Expense'**
  String get addNewExpenseTitle;

  /// No description provided for @editExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpenseTitle;

  /// No description provided for @recurringExpenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Recurring Expense (Monthly)'**
  String get recurringExpenseLabel;

  /// No description provided for @addExpenseButton.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseButton;

  /// No description provided for @expenseAnalyticsHeader.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get expenseAnalyticsHeader;

  /// No description provided for @monthLabel.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get monthLabel;

  /// No description provided for @quarterLabel.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get quarterLabel;

  /// No description provided for @yearLabel.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// No description provided for @monthlyAverage.
  ///
  /// In en, this message translates to:
  /// **'Monthly Average'**
  String get monthlyAverage;

  /// No description provided for @amountEvolution.
  ///
  /// In en, this message translates to:
  /// **'Amount Evolution'**
  String get amountEvolution;

  /// No description provided for @statusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Status Distribution'**
  String get statusDistribution;

  /// No description provided for @monthlyHistory.
  ///
  /// In en, this message translates to:
  /// **'Monthly History'**
  String get monthlyHistory;

  /// No description provided for @countColumn.
  ///
  /// In en, this message translates to:
  /// **'COUNT'**
  String get countColumn;

  /// No description provided for @paidColumn.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paidColumn;

  /// No description provided for @pendingColumn.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get pendingColumn;

  /// No description provided for @overdueColumn.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get overdueColumn;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @pendingAmount.
  ///
  /// In en, this message translates to:
  /// **'Pending Amount'**
  String get pendingAmount;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// No description provided for @promotionsManagement.
  ///
  /// In en, this message translates to:
  /// **'Promotions Management'**
  String get promotionsManagement;

  /// No description provided for @createPromotion.
  ///
  /// In en, this message translates to:
  /// **'Create Promotion'**
  String get createPromotion;

  /// No description provided for @activePromotions.
  ///
  /// In en, this message translates to:
  /// **'Active Promotions'**
  String get activePromotions;

  /// No description provided for @expiredPromotions.
  ///
  /// In en, this message translates to:
  /// **'Expired Promotions'**
  String get expiredPromotions;

  /// No description provided for @totalReductions.
  ///
  /// In en, this message translates to:
  /// **'Total Reductions'**
  String get totalReductions;

  /// No description provided for @totalPromotions.
  ///
  /// In en, this message translates to:
  /// **'Total Promotions'**
  String get totalPromotions;

  /// No description provided for @searchPromotionPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search by title or description...'**
  String get searchPromotionPlaceholder;

  /// No description provided for @allPromotions.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allPromotions;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @promotionType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get promotionType;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @fixedAmount.
  ///
  /// In en, this message translates to:
  /// **'Fixed Amount'**
  String get fixedAmount;

  /// No description provided for @buyXGetY.
  ///
  /// In en, this message translates to:
  /// **'Buy X Get Y'**
  String get buyXGetY;

  /// No description provided for @noPromotionsFound.
  ///
  /// In en, this message translates to:
  /// **'0 promotion(s) found'**
  String get noPromotionsFound;

  /// No description provided for @createPromotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new promotion'**
  String get createPromotionTitle;

  /// No description provided for @promotionTitle.
  ///
  /// In en, this message translates to:
  /// **'Promotion Title'**
  String get promotionTitle;

  /// No description provided for @discountValue.
  ///
  /// In en, this message translates to:
  /// **'Discount Value'**
  String get discountValue;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @addCondition.
  ///
  /// In en, this message translates to:
  /// **'Add condition'**
  String get addCondition;

  /// No description provided for @applicableProducts.
  ///
  /// In en, this message translates to:
  /// **'Applicable Products'**
  String get applicableProducts;

  /// No description provided for @applicationConditions.
  ///
  /// In en, this message translates to:
  /// **'Application Conditions'**
  String get applicationConditions;

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get reportType;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @productsReport.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get productsReport;

  /// No description provided for @customersReport.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersReport;

  /// No description provided for @dailySalesReport.
  ///
  /// In en, this message translates to:
  /// **'Daily Sales'**
  String get dailySalesReport;

  /// No description provided for @hourlySalesReport.
  ///
  /// In en, this message translates to:
  /// **'Hourly Sales'**
  String get hourlySalesReport;

  /// No description provided for @stockMovementsReport.
  ///
  /// In en, this message translates to:
  /// **'Stock Movements'**
  String get stockMovementsReport;

  /// No description provided for @purchasesReport.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchasesReport;

  /// No description provided for @searchProductsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProductsPlaceholder;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling price'**
  String get sellingPrice;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get notAssigned;

  /// No description provided for @quantitySold.
  ///
  /// In en, this message translates to:
  /// **'Quantity sold'**
  String get quantitySold;

  /// No description provided for @profitMargin.
  ///
  /// In en, this message translates to:
  /// **'Profit margin'**
  String get profitMargin;

  /// No description provided for @revenueDistribution.
  ///
  /// In en, this message translates to:
  /// **'Revenue distribution'**
  String get revenueDistribution;

  /// No description provided for @monthlySales.
  ///
  /// In en, this message translates to:
  /// **'Monthly sales'**
  String get monthlySales;

  /// No description provided for @dailySalesTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily sales trend'**
  String get dailySalesTrend;

  /// No description provided for @backToProductList.
  ///
  /// In en, this message translates to:
  /// **'Back to product list'**
  String get backToProductList;

  /// No description provided for @cost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get cost;

  /// No description provided for @profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get profit;

  /// No description provided for @activitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activitiesTitle;

  /// No description provided for @activitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Employee activities tracking on the platform'**
  String get activitiesSubtitle;

  /// No description provided for @allEmployees.
  ///
  /// In en, this message translates to:
  /// **'All employees'**
  String get allEmployees;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get allTypes;

  /// No description provided for @resetFilters.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get resetFilters;

  /// No description provided for @employee.
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get connection;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sale'**
  String get sale;

  /// No description provided for @cashier.
  ///
  /// In en, this message translates to:
  /// **'Cashier'**
  String get cashier;

  /// No description provided for @connectedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} connected to the platform'**
  String connectedMessage(Object name);

  /// No description provided for @saleMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} made a sale of {amount}'**
  String saleMessage(Object name, Object amount);

  /// No description provided for @activityDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity details'**
  String get activityDetailsTitle;

  /// No description provided for @ipAddress.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get ipAddress;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalSettings.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get generalSettings;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopName;

  /// No description provided for @shopLogo.
  ///
  /// In en, this message translates to:
  /// **'Shop Logo'**
  String get shopLogo;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @uploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload Logo'**
  String get uploadLogo;

  /// No description provided for @changeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change Logo'**
  String get changeLogo;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get invalidCredentials;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @posTitle.
  ///
  /// In en, this message translates to:
  /// **'Point of Sale'**
  String get posTitle;

  /// No description provided for @searchHere.
  ///
  /// In en, this message translates to:
  /// **'Search Here'**
  String get searchHere;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @theOrder.
  ///
  /// In en, this message translates to:
  /// **'The Order'**
  String get theOrder;

  /// No description provided for @dineIn.
  ///
  /// In en, this message translates to:
  /// **'Dine In'**
  String get dineIn;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @noItemsInOrder.
  ///
  /// In en, this message translates to:
  /// **'No items in order'**
  String get noItemsInOrder;

  /// No description provided for @addBeverages.
  ///
  /// In en, this message translates to:
  /// **'Add some delicious beverages!'**
  String get addBeverages;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @mobilePayment.
  ///
  /// In en, this message translates to:
  /// **'Mobile Payment'**
  String get mobilePayment;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @searchCustomer.
  ///
  /// In en, this message translates to:
  /// **'Search by name, phone or quarter...'**
  String get searchCustomer;

  /// No description provided for @noCustomer.
  ///
  /// In en, this message translates to:
  /// **'No Customer'**
  String get noCustomer;

  /// No description provided for @customerManagement.
  ///
  /// In en, this message translates to:
  /// **'Customer Management'**
  String get customerManagement;

  /// No description provided for @manageDatabase.
  ///
  /// In en, this message translates to:
  /// **'Manage your customer database'**
  String get manageDatabase;

  /// No description provided for @quarter.
  ///
  /// In en, this message translates to:
  /// **'Quarter'**
  String get quarter;

  /// No description provided for @purchases.
  ///
  /// In en, this message translates to:
  /// **'Purchases'**
  String get purchases;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @addCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomerTitle;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @enterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhone;

  /// No description provided for @enterQuarter.
  ///
  /// In en, this message translates to:
  /// **'Enter quarter'**
  String get enterQuarter;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmail;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
