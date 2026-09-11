import 'package:ditonton/data/models/genre_model.dart';
import 'package:ditonton/data/models/movie_detail_model.dart';
import 'package:ditonton/data/models/movie_table.dart';
import 'package:ditonton/data/models/tv_series_model.dart';
import 'package:ditonton/domain/entities/season.dart';
import 'package:ditonton/domain/entities/tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ditonton/common/constants.dart';
import 'dummy_data/dummy_objects.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('movie detail model serializes and maps every field', () {
    final model = MovieDetailResponse.fromJson({
      'adult': false,
      'backdrop_path': null,
      'budget': 100,
      'genres': [
        {'id': 1, 'name': 'Action'},
      ],
      'homepage': 'homepage',
      'id': 1,
      'imdb_id': null,
      'original_language': 'en',
      'original_title': 'Title',
      'overview': 'Overview',
      'popularity': 10,
      'poster_path': '/poster.jpg',
      'release_date': '2020-01-01',
      'revenue': 200,
      'runtime': 120,
      'status': 'Released',
      'tagline': 'Tagline',
      'title': 'Title',
      'video': false,
      'vote_average': 8,
      'vote_count': 20,
    });
    expect(model.toJson()['genres'], [
      {'id': 1, 'name': 'Action'},
    ]);
    expect(model.toEntity().title, 'Title');
    expect(model.props, hasLength(21));
    expect(GenreModel(id: 1, name: 'Action').props, [1, 'Action']);
  });

  test('table and TV entities expose mappings and equality properties', () {
    final table = MovieTable.fromEntity(testMovieDetail);
    expect(MovieTable.fromMap(table.toJson()).toEntity().id, 1);
    expect(table.props, hasLength(4));
    const tv = TvSeries(
      id: 1,
      name: 'TV',
      overview: 'Overview',
      posterPath: null,
      voteAverage: 8,
      firstAirDate: '2020-01-01',
    );
    expect(tv.props, hasLength(6));
    final model = TvSeriesModel.fromJson({
      'id': 1,
      'name': 'TV',
      'overview': 'Overview',
      'poster_path': null,
      'vote_average': 8,
      'first_air_date': '2020-01-01',
    });
    expect(model.toEntity(), tv);
    expect(model.props, hasLength(6));
    expect(TvSeriesResponse.fromJson(const {}).results, isEmpty);
  });

  test('season and episode expose all equality properties', () {
    const episode = Episode(
      id: 1,
      name: 'Pilot',
      episodeNumber: 1,
      overview: '',
      airDate: '',
      voteAverage: 8,
      stillPath: null,
    );
    const season = Season(
      id: 1,
      name: 'Season 1',
      seasonNumber: 1,
      episodeCount: 1,
      overview: '',
      posterPath: null,
      episodes: [episode],
    );
    expect(episode.props, hasLength(7));
    expect(season.props, hasLength(7));
  });

  test('theme constants are available', () {
    expect(kHeading5.fontSize, 23);
    expect(kHeading6.fontSize, 19);
    expect(kSubtitle.fontSize, 15);
    expect(kBodyText.fontSize, 13);
    expect(kTextTheme.bodyMedium, kBodyText);
    expect(kDrawerTheme.backgroundColor, isNotNull);
    expect(kColorScheme.primary, kMikadoYellow);
    expect(BASE_IMAGE_URL, contains('tmdb'));
  });
}
