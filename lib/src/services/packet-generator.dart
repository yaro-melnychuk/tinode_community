import 'package:get_it/get_it.dart';

import '../models/model.dart';
import 'service.dart';

class PacketGenerator {
  late ConfigService _configService;

  PacketGenerator() {
    _configService = GetIt.I.get<ConfigService>();
  }

  Packet generate(String type, String? topicName) {
    PacketData packetData;
    switch (type) {
      case Hi:
        packetData = HiPacketData(
          ver: _configService.appVersion,
          ua: _configService.userAgent,
          dev: _configService.deviceToken,
          lang: _configService.humanLanguage,
          platf: _configService.platform,
        );
        break;

      case Acc:
        packetData = AccPacketData(
          user: null,
          scheme: null,
          secret: null,
          login: false,
          tags: null,
          desc: null,
          cred: null,
          token: null,
        );
        break;

      case Login:
        packetData = LoginPacketData(
          scheme: null,
          secret: null,
          cred: null,
        );
        break;

      case Sub:
        packetData = SubPacketData(
          topic: topicName,
          set: null,
          get: null,
        );
        break;

      case Leave:
        packetData = LeavePacketData(
          topic: topicName,
          unsub: false,
        );
        break;

      case Pub:
        packetData = PubPacketData(
          topic: topicName,
          noecho: false,
          content: null,
          head: null,
          from: null,
          seq: null,
          ts: null,
        );
        break;

      case Get:
        packetData = GetPacketData(
          topic: topicName,
          what: null,
          desc: null,
          sub: null,
          data: null,
        );
        break;

      case Set:
        packetData = SetPacketData(
          topic: topicName,
          desc: null,
          sub: null,
          tags: null,
        );
        break;

      case Del:
        packetData = DelPacketData(
          topic: topicName,
          what: null,
          delseq: null,
          hard: false,
          user: null,
          cred: null,
        );
        break;

      case Note:
        packetData = NotePacketData(
          topic: topicName,
          seq: null,
          what: null,
        );
        break;
      default:
        packetData = null as dynamic;
    }

    return Packet(type, packetData, Tools.getNextUniqueId());
  }
}
