import 'package:mineral/core/api.dart';
import 'package:mineral/core/builders.dart';
import 'package:mineral/framework.dart';
import 'package:mineral/src/api/builders/component_builder.dart';
import 'package:mineral/src/api/channels/dm_channel.dart';
import 'package:mineral/src/api/managers/message_reaction_manager.dart';
import 'package:mineral/src/api/messages/message_attachment.dart';
import 'package:mineral/src/api/messages/message_sticker_item.dart';
import 'package:mineral/src/api/messages/partial_message.dart';
import 'package:mineral/src/internal/mixins/container.dart';
import 'package:mineral_ioc/ioc.dart';

class DmMessage extends PartialMessage<DmChannel> with Container {
  User author;

  DmMessage(
    super.id,
    super.content,
    super.tts,
    super.embeds,
    super.allowMentions,
    super.reference,
    super.components,
    super.stickers,
    super.payload,
    super.attachments,
    super.flags,
    super.pinned,
    super._guildId,
    super.channelId,
    super.reactions,
    this.author,
  );

  factory DmMessage.from({ required DmChannel channel, required dynamic payload }) {
    MineralClient client = ioc.use<MineralClient>();
    User? user = client.users.cache.get(payload['author']['id']);

    List<EmbedBuilder> embeds = [];
    for (dynamic element in payload['embeds']) {
      List<Field> fields = [];
      if (element['fields'] != null) {
        for (dynamic item in element['fields']) {
          Field field = Field(name: item['name'], value: item['value'], inline: item['inline'] ?? false);
          fields.add(field);
        }
      }

      EmbedBuilder embed = EmbedBuilder(
        title: element['title'],
        description: element['description'],
        url: element['url'],
        timestamp: element['timestamp'] != null ? DateTime.parse(element['timestamp']) : null,
        footer: element['footer'] != null ? Footer(
          text: element['footer']['text'],
          iconUrl: element['footer']['icon_url'],
          proxyIconUrl: element['footer']['proxy_icon_url'],
        ) : null,
        image: element['image'] != null ? Image(
          url: element['image']['url'],
          proxyUrl: element['image']['proxy_url'],
          height: element['image']['height'],
          width: element['image']['width'],
        ) : null,
        author: element['author'] != null ? Author(
          name: element['author']['name'],
          url: element['author']['url'],
          proxyIconUrl: element['author']['proxy_icon_url'],
          iconUrl: element['author']['icon_url'],
        ) : null,
        fields: fields,
      );

      embeds.add(embed);
    }

    List<MessageStickerItem> stickers = [];
    if (payload['sticker_items'] != null) {
      for (dynamic element in payload['sticker_items']) {
        MessageStickerItem sticker = MessageStickerItem.from(element);
        stickers.add(sticker);
      }
    }

    List<MessageAttachment> messageAttachments = [];
    if (payload['attachments'] != null) {
      for (dynamic element in payload['attachments']) {
        MessageAttachment attachment = MessageAttachment.from(element);
        messageAttachments.add(attachment);
      }
    }

    List<ComponentBuilder> components = [];
    if (payload['components'] != null) {
      for (dynamic element in payload['components']) {
        ComponentBuilder component = ComponentBuilder.wrap(element, payload['guild_id']);
        components.add(component);
      }
    }

    final message = DmMessage(
      payload['id'],
      payload['content'],
      payload['tts'] ?? false,
      embeds,
      payload['allow_mentions'] ?? false,
      payload['reference'],
      components,
      stickers,
      payload['payload'],
      messageAttachments,
      payload['flags'],
      payload['pinned'],
      null,
      channel.id,
      MessageReactionManager<DmChannel, DmMessage>(channel),
      user!,
    );

    message.reactions.message = message;

    return message;
  }
}
