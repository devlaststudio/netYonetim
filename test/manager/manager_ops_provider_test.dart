import 'package:flutter_test/flutter_test.dart';
import 'package:site_yonetimi_app/data/providers/manager_ops_provider.dart';

void main() {
  test('ManagerOpsProvider loads legacy members and preview data', () async {
    final provider = ManagerOpsProvider();

    await provider.loadMockData();

    expect(provider.legacyMembers, isNotEmpty);
    expect(provider.autoNotificationRules, isNotEmpty);

    await provider.prepareImportPreview(sourceName: 'test.xlsx');

    expect(provider.importPreviewRows, isNotEmpty);
    expect(provider.importErrorCount, greaterThan(0));
  });

  test('Import row edit updates validation status', () async {
    final provider = ManagerOpsProvider();

    await provider.loadMockData();
    await provider.prepareImportPreview(sourceName: 'test.xlsx');

    final initialError = provider.importErrorCount;

    await provider.updateImportPreviewRow(
      rowNumber: 4,
      block: 'A',
      unitNo: '4',
      ownerName: 'Mert Kaya',
      tenantName: '',
      sqm: 120,
    );

    provider.revalidateImportPreviewRows();

    expect(provider.importErrorCount, lessThan(initialError));
  });

  test('Applying preview without warnings skips warning rows', () async {
    final provider = ManagerOpsProvider();

    await provider.loadMockData();
    await provider.prepareImportPreview(sourceName: 'test.xlsx');

    final valid = provider.importValidCount;
    final warnings = provider.importWarningCount;
    final errors = provider.importErrorCount;

    final summary = await provider.applyImportPreview(includeWarnings: false);

    expect(summary.inserted, valid);
    expect(summary.skipped, warnings + errors);
    expect(provider.importPreviewRows, isEmpty);
  });
}
