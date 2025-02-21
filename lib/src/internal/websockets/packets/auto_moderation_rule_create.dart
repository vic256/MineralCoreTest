import 'package:mineral/core/api.dart';
import 'package:mineral/core/events.dart';
import 'package:mineral/framework.dart';
import 'package:mineral/src/internal/services/event_service.dart';
import 'package:mineral/src/internal/mixins/container.dart';
import 'package:mineral/src/internal/websockets/websocket_packet.dart';
import 'package:mineral/src/internal/websockets/websocket_response.dart';

class AutoModerationRuleCreate with Container implements WebsocketPacket {
  @override
  Future<void> handle(WebsocketResponse websocketResponse) async {
    EventService manager = container.use<EventService>();
    MineralClient client = container.use<MineralClient>();

    dynamic payload = websocketResponse.payload;

    Guild? guild = client.guilds.cache.get(payload['guild_id']);
    if (guild != null) {
      ModerationRule moderationRule = ModerationRule.fromPayload(payload);
      guild.moderationRules.cache.set(moderationRule.id, moderationRule);

      manager.controller.add(ModerationRulesCreateEvent(moderationRule));
    }
  }
}
