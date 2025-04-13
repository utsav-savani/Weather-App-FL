import 'package:assessmentfounder/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('weather app test', () {
    setUp(() async {
      await GetIt.instance.reset();
    });

    testWidgets('tap on search, enter city, and verify weather displays', (
      WidgetTester tester,
    ) async {
      try {
        app.main();

        await tester.pump();
        print('App launched');

        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(seconds: 1));
          print('Waiting for UI to stabilize... ${i + 1}/10 seconds');
        }

        bool appLoaded = false;
        try {
          final scaffold = find.byType(Scaffold);
          appLoaded = scaffold.evaluate().isNotEmpty;
          print('App UI loaded: Scaffold found');
        } catch (e) {
          print('Error checking if app loaded: $e');
        }

        expect(appLoaded, true, reason: 'App should be loaded after waiting');

        await tester.pump(const Duration(seconds: 3));

        print('Widget tree after initialization:');
        for (var widget in tester.allWidgets) {
          if (widget is AppBar ||
              widget is TextField ||
              widget is Card ||
              widget is FloatingActionButton) {
            print('Found ${widget.runtimeType}');
          }
        }

        final searchIconFinder = find.byIcon(Icons.search);
        if (searchIconFinder.evaluate().isEmpty) {
          print('Search icon not found, looking for other actionable elements');

          final fab = find.byType(FloatingActionButton);
          if (fab.evaluate().isNotEmpty) {
            print('Found FloatingActionButton instead');
            await tester.tap(fab.first);
          } else {
            final iconButton = find.byType(IconButton);
            if (iconButton.evaluate().isNotEmpty) {
              print('Found IconButton as fallback');
              await tester.tap(iconButton.first);
            } else {
              throw Exception('Could not find any search/action elements');
            }
          }
        } else {
          print('Found search icon');
          await tester.ensureVisible(searchIconFinder.first);
          await tester.tap(searchIconFinder.first);
        }

        print('Tapped search-related element');

        await tester.pump(const Duration(seconds: 2));

        Finder textField = find.byType(TextField);
        for (int i = 0; i < 5; i++) {
          if (textField.evaluate().isNotEmpty) {
            break;
          }
          print('TextField not found yet, waiting...');
          await tester.pump(const Duration(seconds: 1));
          textField = find.byType(TextField);
        }

        expect(
          textField,
          findsWidgets,
          reason: 'Search text field should be visible',
        );
        print('Found text field');

        await tester.enterText(textField.first, 'London');
        print('Entered city name: London');
        await tester.testTextInput.receiveAction(TextInputAction.done);

        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(seconds: 1));
          print('Waiting for search results... ${i + 1}/5 seconds');
        }

        final searchResult = find.text('London');
        if (searchResult.evaluate().isNotEmpty) {
          print('Found London in search results');
          await tester.tap(searchResult.first);

          for (int i = 0; i < 5; i++) {
            await tester.pump(const Duration(seconds: 1));
            print('Waiting for weather data... ${i + 1}/5 seconds');
          }
        } else {
          print(
            'London not found in search results, checking if already on weather screen',
          );
        }

        bool foundWeatherData = false;

        final cards = find.byType(Card);
        if (cards.evaluate().isNotEmpty) {
          print('Found ${cards.evaluate().length} Cards on screen');
          foundWeatherData = true;
        }

        if (!foundWeatherData) {
          final tempText = find.textContaining('°', findRichText: true);
          if (tempText.evaluate().isNotEmpty) {
            print('Found temperature display');
            foundWeatherData = true;
          }
        }

        if (!foundWeatherData) {
          final weatherTerms = [
            'humidity',
            'wind',
            'pressure',
            'clouds',
            'rain',
            'weather',
          ];
          for (final term in weatherTerms) {
            final weatherText = find.textContaining(term, findRichText: true);
            if (weatherText.evaluate().isNotEmpty) {
              print('Found weather term: $term');
              foundWeatherData = true;
              break;
            }
          }
        }

        expect(
          foundWeatherData,
          true,
          reason: 'Should find weather data on screen',
        );
        print('Test completed successfully - found weather data');
      } catch (e, stackTrace) {
        print('Test failed with error: $e');
        print('Stack trace: $stackTrace');

        print('Widget tree at failure point:');
        for (var widget in tester.allWidgets) {
          print('${widget.runtimeType}');
        }

        rethrow;
      }
    });
  });
}
