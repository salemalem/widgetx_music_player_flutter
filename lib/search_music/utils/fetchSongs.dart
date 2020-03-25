import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

Future<List<List<String>>> fetchSongs(url)  async {
  List<String> songArtists = [];
  List<String> songNames = [];
  List<String> songLinks = [];
  List<String> songDurations = [];
  List<String> songImages = [];

  RegExp songImageRegex = new RegExp(
    r"url\('(.*?)'\);",
    caseSensitive: false,
    multiLine: false,
  );

  final response = await http.get(url);
  if (response.statusCode == 200) {
    dom.Document document = parse(response.body);
    var songNamesFromResponse = document.getElementsByClassName('track__title');
    var songArtistsFromResponse = document.getElementsByClassName('track__desc');
    var songImagesFromResponse = document.getElementsByClassName('track__img');
    var songDurationsFromResponse = document.getElementsByClassName('track__fulltime');
    var songLinksFromResponse = document.getElementsByClassName('track__download-btn');

    if (songArtistsFromResponse.length > 0) {
      for (var i = 0; i < songNamesFromResponse.length; i++) {
        songNames.add(songNamesFromResponse[i].text.trimLeft().trimRight());
        songArtists.add(songArtistsFromResponse[i].text.trimLeft().trimRight());
        songDurations.add(
            songDurationsFromResponse[i].text.trimLeft().trimRight());
        songLinks.add(songLinksFromResponse[i].attributes['href']);
        final songImageRegexMatch = songImageRegex.
          firstMatch(songImagesFromResponse[i].attributes['style']);
        final String songImageSrc = "https://hotmo.org/" + songImageRegexMatch.group(1);
        songImages.add(songImageSrc);
      }
    }
    return [songImages, songNames, songArtists, songDurations, songLinks];
  } else {
    throw Exception('Failed to load');
  }
}