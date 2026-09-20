import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';

// ─── Product IDs ──────────────────────────────────────────────────────────────

class PremiumProductIds {
  static const monthly = 'cardblaze_pro_monthly';
  static const yearly = 'cardblaze_pro_yearly';
}

// ─── Free tier limits ─────────────────────────────────────────────────────────

class PremiumLimits {
  static const int maxDecks = 3;
  static const int maxCardsPerDeck = 20;
  static const int maxAiInputChars = 500;
}

// ─── PremiumService ───────────────────────────────────────────────────────────

class PremiumService {
  static const String _entitlementId = 'pro';
  static const String _apiKey = 'YOUR_RC_API_KEY';

  final _statusController = StreamController<bool>.broadcast();

  static Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug);
    final config = PurchasesConfiguration(_apiKey);
    await Purchases.configure(config);
  }

  Stream<bool> get premiumStatus async* {
    yield await isPremium();

    void listener(CustomerInfo info) {
      if (!_statusController.isClosed) {
        _statusController.add(
          info.entitlements.active.containsKey(_entitlementId),
        );
      }
    }
    Purchases.addCustomerInfoUpdateListener(listener);
    yield* _statusController.stream;
    Purchases.removeCustomerInfoUpdateListener(listener);
  }

  Future<bool> isPremium() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(_entitlementId);
    } catch (_) {
      return false;
    }
  }

  // purchases_flutter 10.x: purchasePackage returns PurchaseResult
  Future<CustomerInfo?> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      final info = result.customerInfo;
      _statusController.add(
        info.entitlements.active.containsKey(_entitlementId),
      );
      return info;
    } on PurchasesErrorCode catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<CustomerInfo?> purchaseMonthly() =>
      _purchaseById(PremiumProductIds.monthly);

  Future<CustomerInfo?> purchaseYearly() =>
      _purchaseById(PremiumProductIds.yearly);

  Future<CustomerInfo?> _purchaseById(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? [];
      final pkg = packages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
        orElse: () {
          if (packages.isEmpty) throw Exception('No packages available');
          return packages.first;
        },
      );
      return purchase(pkg);
    } on PurchasesErrorCode catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    try {
      final result = await Purchases.restorePurchases();
      _statusController.add(
        result.entitlements.active.containsKey(_entitlementId),
      );
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
