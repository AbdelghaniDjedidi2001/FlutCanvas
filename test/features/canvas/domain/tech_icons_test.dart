import 'package:flutter_test/flutter_test.dart';
import 'package:flutcanvas/features/canvas/domain/models/tech_icons.dart';

void main() {
  group('TechIconRegistry', () {
    test('contains 40+ curated icons across categories', () {
      expect(TechIconRegistry.icons.length, greaterThanOrEqualTo(40));

      final categories = TechIconRegistry.icons.map((i) => i.category).toSet();
      expect(categories, contains(TechIconCategory.cloudCompute));
      expect(categories, contains(TechIconCategory.databases));
      expect(categories, contains(TechIconCategory.networking));
      expect(categories, contains(TechIconCategory.devops));
      expect(categories, contains(TechIconCategory.clients));
    });

    test('findById returns matching icon definition', () {
      final lambda = TechIconRegistry.findById('aws_lambda');
      expect(lambda, isNotNull);
      expect(lambda!.name, 'AWS Lambda');
      expect(lambda.category, TechIconCategory.cloudCompute);
      expect(lambda.defaultLabel, 'AWS Lambda');

      final docker = TechIconRegistry.findById('docker');
      expect(docker, isNotNull);
      expect(docker!.name, 'Docker');
      expect(docker.category, TechIconCategory.devops);

      final nonExistent = TechIconRegistry.findById('non_existent_123');
      expect(nonExistent, isNull);
    });

    test('filter by category returns only icons in that category', () {
      final dbIcons = TechIconRegistry.filter(
        category: TechIconCategory.databases,
      );
      expect(dbIcons.isNotEmpty, isTrue);
      expect(dbIcons.every((i) => i.category == TechIconCategory.databases), isTrue);
      expect(dbIcons.any((i) => i.id == 'postgresql'), isTrue);
      expect(dbIcons.any((i) => i.id == 'redis'), isTrue);
      expect(dbIcons.any((i) => i.id == 'mongodb'), isTrue);
    });

    test('filter by query performs case-insensitive match on name, id, and keywords', () {
      final queryResults = TechIconRegistry.filter(query: 'postgres');
      expect(queryResults.isNotEmpty, isTrue);
      expect(queryResults.first.id, 'postgresql');

      // Keyword match: "sql" should match multiple DBs
      final sqlResults = TechIconRegistry.filter(query: 'sql');
      expect(sqlResults.length, greaterThanOrEqualTo(3));

      // Case insensitivity
      final upperResults = TechIconRegistry.filter(query: 'KUBERNETES');
      expect(upperResults.any((i) => i.id == 'kubernetes'), isTrue);
    });

    test('filter with both category and query narrows results', () {
      final results = TechIconRegistry.filter(
        query: 'cache',
        category: TechIconCategory.databases,
      );
      expect(results.any((i) => i.id == 'redis'), isTrue);
      expect(results.every((i) => i.category == TechIconCategory.databases), isTrue);
    });
  });
}
