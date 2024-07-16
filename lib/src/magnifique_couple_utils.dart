import 'package:bel_adn/bel_adn.dart';
import 'package:sha_env/sha_env.dart';

final class MagnifiqueCoupleUtils {
  final MagnifiqueCoupleClient _magnifiqueCoupleClient;

  MagnifiqueCoupleUtils()
      : _magnifiqueCoupleClient = MagnifiqueCoupleClient(
            host: fromEnvironmentString('MAGNIFIQUECOUPLE_HOST'),
            accessToken: fromEnvironmentString('BEAU_GOSSE_MG_TOKEN'));

  Future<Topic> getBonjourMadameTopic() async {
    List<Topic> topics =
        await _magnifiqueCoupleClient.topics.index(name: 'bonjour_madame');

    if (topics.isEmpty) {
      throw Exception('No topic found');
    }

    if (topics.length > 1) {
      throw Exception('Too many topics found');
    }

    return topics.first;
  }

  Future<Supplier> getBonjourMadameSupplier() async {
    List<Supplier> suppliers = await _magnifiqueCoupleClient.suppliers
        .index(host: 'www.bonjourmadame.fr');

    if (suppliers.isEmpty) {
      throw Exception('No supplier found');
    }

    if (suppliers.length > 1) {
      throw Exception('Too many suppliers found');
    }

    return suppliers.first;
  }

  Future<Search> getBonjourMadameSearch() async {
    Search search;

    List<Search> searches = await _magnifiqueCoupleClient.searches.index(
        topicId: (await getBonjourMadameTopic()).id,
        supplierId: (await getBonjourMadameSupplier()).id);

    if (searches.isEmpty) {
      search = await _magnifiqueCoupleClient.searches.store(
          topicId: (await getBonjourMadameTopic()).id,
          supplierId: (await getBonjourMadameSupplier()).id);

      return search;
    }

    if (searches.length > 1) {
      throw Exception('Too many searches found');
    }

    return searches.first;
  }

  Future<bool> bonjourMadamePostExists(Uri link) async {
    List<Source> sources =
        await _magnifiqueCoupleClient.sources.index(link: link);

    return sources.isNotEmpty;
  }

  Future<Source?> saveBonjourMadamePost(Uri link) async {
    Search search = await getBonjourMadameSearch();

    Source source = await _magnifiqueCoupleClient.sources.store(
        link: link,
        searchId: search.id,
        topicId: search.topicId,
        supplierId: search.supplierId);

    return source;
  }

  Future<bool> bonjourMadameDestinationExists(Uri link) async {
    List<Destination> destinations = await _magnifiqueCoupleClient.destinations
        .index(filename: link.pathSegments.last);

    return destinations.isNotEmpty;
  }

  Future<Destination?> saveBonjourMadameDestination(Uri link) async {
    Destination destination = await _magnifiqueCoupleClient.destinations.store(
      filename: link.pathSegments.last,
    );

    return destination;
  }

  Future<Media?> saveBonjourMadameMedia(
      Uri link, Source source, Destination destination) async {
    Media media = await _magnifiqueCoupleClient.medias
        .store(sourceId: source.id, destinationId: destination.id, link: link);

    return media;
  }
}
