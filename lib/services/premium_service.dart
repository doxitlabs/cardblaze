import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';

// ─── Product IDs ──────────────────────────────────────────────────────────────

class PremiumProductIds {
  static const monthly = 'cardblaze_pro_monthly';
  static const yearly = 'cardblaze_pro_yearly';
}

// ─── Free tier limits ─────────────────────────────────────────────────────────

class PremiumLimits {
  static const int maxDecks = 1;
  static const int maxCardsPerDeck = 15;
  static const int maxCardsPerDeckPro = 100;
  static const int maxAiInputChars = 500;
}

// ─── PremiumService ───────────────────────────────────────────────────────────

class PremiumService {
  // Entitlement identifier as defined in the RevenueCat dashboard.
  static const String entitlementId = 'cardblaze_pro';

  // Dev builds use RevenueCat's Test Store (simulated purchases, no Play
  // Console needed); the Play Store build uses the Google Play public key.
  static const String _testStoreApiKey = 'test_BWxepqviwgugxcmMZVgrYIsrrEj';
  static const String _googlePlayApiKey = 'YOUR_RC_GOOGLE_API_KEY';
  static const String _apiKey = isDevBuild ? _testStoreApiKey : _googlePlayApiKey;

  final _statusController = StreamController<bool>.broadcast();

  static Future<void> init() async {
    await Purchases.setLogLevel(isDevBuild ? LogLevel.debug : LogLevel.warn);
    final config = PurchasesConfiguration(_apiKey);
    await Purchases.configure(config);
  }

  Stream<bool> get premiumStatus async* {
    yield await isPremium();

    void listener(CustomerInfo info) => _emit(info);
    Purchases.addCustomerInfoUpdateListener(listener);
    yield* _statusController.stream;
    Purchases.removeCustomerInfoUpdateListener(listener);
  }

  void _emit(CustomerInfo info) {
    if (!_statusController.isClosed) {
      _statusController.add(info.entitlements.active.containsKey(entitlementId));
    }
  }

  // True only for local builds made with --dart-define=CARDBLAZE_DEV=true —
  // they use RevenueCat's Test Store, where Pro is tested via a simulated
  // purchase. Compile-time constant, so the Play build can't be switched.
  static const isDevBuild = bool.fromEnvironment('CARDBLAZE_DEV');

  Future<bool> isPremium() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(entitlementId);
    } catch (_) {
      return false;
    }
  }

  // purchases_flutter 10.x: purchasePackage returns PurchaseResult
  Future<CustomerInfo?> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      final info = result.customerInfo;
      _emit(info);
      return info;
    } on PurchasesErrorCode catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      final result = await Purchases.restorePurchases();
      _emit(result);
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (_) {
      return [];
    }
  }

  void dispose() => _statusController.close();
}
