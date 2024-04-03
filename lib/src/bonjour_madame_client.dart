import 'package:http/http.dart';
import 'package:rss_dart/dart_rss.dart';

final String rssStr = 'https://bonjourmadame.fr/feed/';
final Uri rssUri = Uri.parse(rssStr);

final class BonjourMadameClient {
  Future<RssFeed> getFeed() async {
    var response = await get(rssUri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load feed');
    }

    var feed = RssFeed.parse(response.body);

    return feed;
  }

  Future<List<RssItem>> getItems() async {
    var feed = await getFeed();

    return feed.items;
  }

  Future<RssItem?> getLastUsableItem() async {
    var items = await getItems();

    for (var item in items) {
      if (item.link == null || item.content == null) {
        continue;
      }

      var link = Uri.parse(item.link!);

      var linkYear = link.pathSegments[0];
      var linkMonth = link.pathSegments[1];
      var linkDay = link.pathSegments[2];

      var linkDate = DateTime.parse('$linkYear-$linkMonth-$linkDay');

      if (linkDate.weekday == DateTime.saturday ||
          linkDate.weekday == DateTime.sunday) {
        continue;
      }

      return item;
    }

    return null;
  }
}
