import 'package:flutter_test/flutter_test.dart';
import 'package:psito_solitaire/src/game/scores.dart';
import 'package:shared_preferences/shared_preferences.dart';

Score score(String name, int points, [int seconds = 60]) =>
    Score(name: name, points: points, seconds: seconds, game: 1);

void main() {
  test('more points come first, and the time breaks ties', () {
    var scores = insertScore(const [], score('slow', 500, 90));
    scores = insertScore(scores, score('best', 700));
    scores = insertScore(scores, score('quick', 500, 30));
    expect(scores.map((s) => s.name), ['best', 'quick', 'slow']);
  });

  test('only the ten best are kept', () {
    var scores = <Score>[];
    for (var i = 0; i < 12; i++) {
      scores = insertScore(scores, score('$i', 100 - i));
    }
    expect(scores.length, maxScores);
    expect(scores.last.name, '9');
  });

  test('the time is shown as minutes and seconds', () {
    expect(formatTime(5), '0:05');
    expect(formatTime(125), '2:05');
  });

  test('scores survive saving and a damaged file is ignored', () async {
    SharedPreferences.setMockInitialValues({});
    const store = ScoreStore();
    await store.save([score('Ana', 90)]);
    expect((await store.load()).single.name, 'Ana');

    SharedPreferences.setMockInitialValues({'scores': 'not json'});
    expect(await store.load(), isEmpty);
  });
}
