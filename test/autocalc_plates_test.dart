import 'package:flutter_test/flutter_test.dart';
import '../lib/autocalc/plates_data.dart';

void main() {
  test('plate source must be an authorized HTTPS JSON endpoint', () {
    expect(validPlateFeedUrl(''), false);
    expect(validPlateFeedUrl('http://sample.example/api'), false);
    expect(validPlateFeedUrl('https://data.example/api'), true);
    expect(validPlateFeedUrl('https://user:pass@data.example/api'), false);
  });

  Map<String, Object?> sample({bool stale = false}) => {
    'success': true,
    'stale': stale,
    'fetchedAt': DateTime.now().toIso8601String(),
    'sourceUpdatedAt': '11 Oct 2026 17:45 MYT',
    'plates': <Map<String, String>>[
      {'id': 'kuala-lumpur', 'state': 'Kuala Lumpur', 'region': 'Peninsular', 'plate': 'VRT 5435'},
      {'id': 'selangor', 'state': 'Selangor', 'region': 'Peninsular', 'plate': 'BSU 3563'},
      ...List.generate(10, (i) => {
        'id': 'state-' + i.toString(), 'state': 'Area ' + i.toString(),
        'region': 'Peninsular', 'plate': 'ABC ' + (i + 2000).toString(),
      }),
    ],
  };

  test('follows AutoQuote JSON schema without fake fallback numbers', () {
    final records = PlateSnapshot.fromJson(sample())!;
    expect(records.plates.length, 12);
    expect(records.featured.map((e) => e.state).toList(), ['Kuala Lumpur', 'Selangor']);
    expect(records.others.length, 10);
    expect(records.stale, false);
  });

  test('cached and backend-stale results are not shown as live', () {
    expect(PlateSnapshot.fromJson(sample(), cached: true)!.stale, true);
    expect(PlateSnapshot.fromJson(sample(stale: true))!.stale, true);
  });

  test('reject incomplete or unsuccessful sources', () {
    expect(PlateSnapshot.fromJson({'success': false, 'plates': []}), null);
    expect(PlateSnapshot.fromJson({'success': true, 'plates': []}), null);
  });

  test('exclude Langkawi and Labuan and invalid plate entries', () {
    expect(PlateRecord.parse({
      'id': 'labuan', 'state': 'Labuan', 'plate': 'LH 1234',
    }), null);
    expect(PlateRecord.parse({
      'id': 'kl', 'state': 'KL', 'plate': '"><script>',
    }), null);
  });
}
