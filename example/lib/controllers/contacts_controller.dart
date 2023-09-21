import 'dart:developer';

import 'package:get/get.dart';
import 'package:tinode_community/tinode.dart';

const key = 'AQEAAAABAAD_rAp4DJh05a1HAwFT3A6K';
const host = 'sandbox.tinode.co';

class ContactsController extends GetxController {
  final tinode =
      Tinode('Moein', ConnectionOptions(host, key, secure: true), true);

  final RxList<TopicSubscription> topics = RxList.empty();

  @override
  void onInit() {
    super.onInit();
    _connect();
  }

  @override
  void onClose() {
    super.onClose();
    tinode.disconnect();
  }

  Future<void> login(String user, String pass) async {
    if (tinode.isAuthenticated) return;
    var result = await tinode.loginBasic(user, pass, null);
    log('User Id: ${result.params['user']}');

    var me = tinode.getMeTopic();
    me.onSubsUpdated.listen(_onSubUpdated);
    await me.subscribe(MetaGetBuilder(me).withLaterSub(null).build(), null);
  }

  Future<void> _connect() async {
    await tinode.connect();
    log('Is Connected:${tinode.isConnected}');
  }

  void _onSubUpdated(List<TopicSubscription> topics) {
    for (var item in topics) {
      log('Sub[${item.topic}]: ${item.public['fn']} - Unread Messages:${item.unread}');
    }

    this.topics.addAll(topics);
  }
}
