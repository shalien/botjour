import 'dart:io';

import 'package:bel_adn/bel_adn.dart';
import 'package:botjour/botjour.dart';
import 'package:nyxx/nyxx.dart';
import 'package:rss_dart/dart_rss.dart';
import 'package:sha_env/sha_env.dart';

Future<void> main() async {
  await load();

  if (fromEnvironmentString('DISCORD_GUILD_ID').isEmpty) {
    stderr.writeln('DISCORD_GUILD_ID is not set');
    exit(1);
  }

  String guildId = fromEnvironmentString('DISCORD_GUILD_ID');

  if (fromEnvironmentString('BEAU_GOSSE_DISCORD_TOKEN').isEmpty) {
    stderr.writeln('BEAU_GOSSE_DISCORD_TOKEN is not set');
    exit(1);
  }

  String token = fromEnvironmentString('BEAU_GOSSE_DISCORD_TOKEN');

  final NyxxGateway client =
      await Nyxx.connectGateway(token, GatewayIntents.allUnprivileged);

  client.onReady.listen((ReadyEvent e) async {
    print('Bot is ready');
    print('Trying to greet');

    final RssItem? item = await BonjourMadameClient().getLastUsableItem();

    if (item == null) {
      stderr.writeln('No item found');
      exit(1);
    }

    final String luiTitle = item.title!;
    final String luiFirstImage = item.content!.images.first;
    final String? link = item.link;

    if (link == null) {
      stderr.writeln('No link found');
      exit(1);
    }

    Uri url = Uri.parse(link);

    if (await MagnifiqueCoupleUtils().bonjourMadamePostExists(url)) {
      print('Post already exists');
      exit(0);
    }

    Source? source = await MagnifiqueCoupleUtils().saveBonjourMadamePost(url);

    if (source == null) {
      print('Post already exists');
      exit(0);
    }

    Destination? destination =
        await MagnifiqueCoupleUtils().saveBonjourMadameDestination(url);

    if (destination == null) {
      print('Destination already exists');
      exit(0);
    }

    Media? media = await MagnifiqueCoupleUtils()
        .saveBonjourMadameMedia(url, source, destination);

    if (media == null) {
      print('Media already exists');
      exit(0);
    }

    GuildTextChannel channel = (await client.channels
        .fetch(Snowflake(1154137527842775180))) as GuildTextChannel;

    EmbedImageBuilder? eib =
        EmbedImageBuilder(url: Uri.tryParse(luiFirstImage.split('?').first)!);

    await channel.sendMessage(
      MessageBuilder(
        embeds: [
          EmbedBuilder(
            title: luiTitle,
            url: Uri.parse(link),
            image: eib,
            color: DiscordColor(0xEC1D1D),
            author: EmbedAuthorBuilder(
              name: 'Bonjour Madame',
              url: Uri.parse('https://www.bonjourmadame.fr/'),
              iconUrl: Uri.parse(
                  'https://i0.wp.com/bonjourmadame.fr/wp-content/uploads/2018/12/cropped-favicon.jpg'),
            ),
          ),
        ],
      ),
    );

    exit(0);
  });
}
