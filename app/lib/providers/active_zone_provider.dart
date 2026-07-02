import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared active zone state across auto and tele tabs
/// When either tab transitions zones, the other tab picks up the same zone on init/return
final activeZoneProvider = StateProvider<String>((ref) => 'alliance');
