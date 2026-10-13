// Lightweight AutoQuote-compatible plate feed model.
// Consume a separately managed, authorized JSON endpoint; do not scrape websites.
const platesFeedUrl = String.fromEnvironment(
  'PLATES_FEED_URL',
  defaultValue: '',
);

class PlateRecord {
  const PlateRecord({required this.id, required this.state, required this.plate, required this.region});
  final String id, state, plate, region;

  static PlateRecord? parse(Object? item) {
    if (item is! Map) return null;
    final id = (item['id'] ?? '').toString().trim();
    final state = (item['state'] ?? '').toString().trim();
    var plate = (item['plate'] ?? '').toString().trim();
    if (plate.isEmpty) {
      final prefix = (item['prefix'] ?? '').toString().trim();
      final number = (item['number'] ?? '').toString().trim();
      final suffix = (item['suffix'] ?? '').toString().trim();
      plate = [prefix, number, suffix].where((v) => v.isNotEmpty).join(' ');
    }
    final region = (item['region'] ?? 'Peninsular').toString().trim();
    if (id.isEmpty || state.isEmpty || plate.isEmpty) return null;
    if (id == 'langkawi' || id == 'labuan') return null;
    // Registration numbers contain only these visible characters.
    if (!RegExp(r'^[A-Za-z0-9 -]{2,18}$').hasMatch(plate)) return null;
    return PlateRecord(id: id, state: state, plate: plate, region: region);
  }
}

class PlateSnapshot {
  const PlateSnapshot({
    required this.plates,
    required this.sourceUpdatedAt,
    required this.fetchedAt,
    required this.stale,
  });
  final List<PlateRecord> plates;
  final String sourceUpdatedAt;
  final DateTime? fetchedAt;
  final bool stale;

  static PlateSnapshot? fromJson(Object? data, {bool cached = false}) {
    if (data is! Map || data['success'] != true || data['plates'] is! List) return null;
    final records = <PlateRecord>[];
    final used = <String>{};
    for (final item in (data['plates'] as List)) {
      final entry = PlateRecord.parse(item);
      if (entry != null && used.add(entry.id)) records.add(entry);
    }
    // Never display a partially parsed or clearly incorrect feed as LIVE.
    if (records.length < 10) return null;
    final fetched = DateTime.tryParse((data['fetchedAt'] ?? '').toString());
    final now = DateTime.now();
    final old = fetched == null || now.difference(fetched).inHours > 24 ||
        fetched.isAfter(now.add(const Duration(minutes: 30)));
    return PlateSnapshot(
      plates: List.unmodifiable(records),
      sourceUpdatedAt: (data['sourceUpdatedAt'] ?? '').toString().trim(),
      fetchedAt: fetched,
      stale: cached || data['stale'] == true || old,
    );
  }

  List<PlateRecord> get featured {
    final result = <PlateRecord>[];
    for (final id in ['kuala-lumpur', 'selangor']) {
      for (final p in plates) {
        if (p.id == id) {
          result.add(p);
          break;
        }
      }
    }
    return result;
  }

  List<PlateRecord> get others {
    final rest = plates.where((p) => p.id != 'kuala-lumpur' && p.id != 'selangor').toList();
    rest.sort((a,b) => a.state.compareTo(b.state));
    return rest;
  }
}

/// Only a configured, authorized HTTPS JSON feed may be treated as a data source.
bool validPlateFeedUrl(String url) {
 final uri=Uri.tryParse(url.trim());
 return uri!=null && uri.scheme=='https' && uri.host.isNotEmpty && uri.userInfo.isEmpty;
}
