import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:cardblaze/services/premium_service.dart';

// ─── Service singleton ────────────────────────────────────────────────────────

final premiumServiceProvider = Provider<PremiumService>((ref) {
  final svc = PremiumService();
  ref.onDispose(svc.dispose);
  return svc;
});

// ─── Live stream — use this for all premium gates in the UI ───────────────────

final premiumStatusProvider = StreamProvider<bool>((ref) {
  return ref.read(premiumServiceProvider).premiumStatus;
});

// ─── One-shot future (for non-reactive checks, e.g. before a mutation) ────────

final isPremiumProvider = FutureProvider<bool>((ref) {
  return ref.read(premiumServiceProvider).isPremium();
});

// ─── Offerings (paywall packages) ─────────────────────────────────────────────

final offeringsProvider = FutureProvider<List<Package>>((ref) {
  return ref.read(premiumServiceProvider).getOfferings();
});
