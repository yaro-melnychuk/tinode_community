import 'dart:developer';

import 'package:example/controllers/contacts_controller.dart';
import 'package:get/get.dart';
import 'package:tinode_community/tinode.dart' hide Get;

const key = 'AQEAAAABAAD_rAp4DJh05a1HAwFT3A6K';
const host = 'sandbox.tinode.co';

class ChatController extends GetxController {
  final tinode = Get.find<ContactsController>().tinode;
  final topic = Get.arguments as TopicSubscription;

  RxList<DataMessage> messages = RxList.empty();

  String get topicId => topic.topic ?? '';

  Topic get grp => tinode.getTopic(topicId);

  @override
  void onInit() {
    super.onInit();
    _sub();
  }

  // @override
  // void onClose() {
  //   super.onClose();
  //   grp.leave(true);
  // }

  Future<void> _sub() async {
    log(topicId, name: 'ChatController._sub');
    grp.onData.listen(_listenMessage);
    if (!grp.isSubscribed) {
      await grp.subscribe(
        MetaGetBuilder(grp).withLaterSub(10).withLaterData(10).build(),
        null,
      );
    }
  }

  void _listenMessage(DataMessage? mes) {
    if (mes == null) return;

    print('DataMessage: ${mes.content}');
    messages.add(mes);
  }

  Future<void> sendText(String? v) async {
    if (v == null) return;
    var msg = grp.createMessage(v, false);
    await grp.publishMessage(msg);
  }
}
