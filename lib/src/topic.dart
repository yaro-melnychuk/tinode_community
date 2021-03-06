import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:tinode/src/models/message-status.dart' as MessageStatus;
import 'package:tinode/src/models/topic-names.dart' as TopicNames;
import 'package:tinode/src/models/access-mode.dart';
import 'package:tinode/src/services/auth.dart';
import 'package:tinode/src/services/cache-manager.dart';
import 'package:tinode/src/services/tinode.dart';
import 'package:tinode/src/topic-me.dart';
import 'package:get_it/get_it.dart';

import 'models/get-query.dart';
import 'models/message.dart';
import 'models/set-params.dart';

/// TODO: Implement `attachCacheToTopic` too

class Topic {
  bool _new;
  String name;
  AccessMode acs;
  DateTime created;
  DateTime updated;
  bool _subscribed;
  bool noEarlierMsgs;

  AuthService _authService;
  CacheManager _cacheManager;
  TinodeService _tinodeService;

  PublishSubject onData = PublishSubject<dynamic>();

  Topic(String topicName) {
    _resolveDependencies();
    name = topicName;
  }

  void _resolveDependencies() {
    _authService = GetIt.I.get<AuthService>();
    _cacheManager = GetIt.I.get<CacheManager>();
    _tinodeService = GetIt.I.get<TinodeService>();
  }

  // See if you have subscribed to this topic
  bool get isSubscribed {
    return _subscribed;
  }

  Future subscribe(GetQuery getParams, SetParams setParams) async {
    // If the topic is already subscribed, return resolved promise
    if (isSubscribed) {
      return;
    }

    // Send subscribe message, handle async response.
    // If topic name is explicitly provided, use it. If no name, then it's a new group topic, use "new".
    var ctrl = await _tinodeService.subscribe(name != '' ? name : TopicNames.TOPIC_NEW, getParams, setParams);

    if (ctrl['code'] >= 300) {
      // Do nothing if the topic is already subscribed to.
      return ctrl;
    }

    _subscribed = true;
    acs = (ctrl['params'] != null && ctrl['params']['acs'] != null) ? ctrl['params']['acs'] : acs;

    // Set topic name for new topics and add it to cache.
    if (_new) {
      _new = false;

      // Name may change new123456 -> grpAbCdEf
      name = ctrl['topic'];
      created = ctrl['ts'];
      updated = ctrl['ts'];

      if (name != TopicNames.TOPIC_ME && name != TopicNames.TOPIC_FND) {
        // Add the new topic to the list of contacts maintained by the 'me' topic.
        TopicMe me = _tinodeService.getTopic(TopicNames.TOPIC_ME);
        if (me != null) {
          me.processMetaSub([
            {'noForwarding': true, 'topic': name, 'created': ctrl['ts'], 'updated': ctrl['ts'], 'acs': acs}
          ]);
        }
      }

      if (setParams != null && setParams.desc != null) {
        setParams.desc.noForwarding = true;
        processMetaDesc(setParams.desc);
      }
    }
    return ctrl;
  }

  Message createMessage(dynamic data, bool echo) {
    return _tinodeService.createMessage(name, data, echo);
  }

  Future publishMessage(Message message) async {
    if (!isSubscribed) {
      return Future.error(Exception('Cannot publish on inactive topic'));
    }

    message.setStatus(MessageStatus.SENDING);

    try {
      var ctrl = await _tinodeService.publishMessage(message);
      var seq = ctrl['params']['seq'];
      if (seq != null) {
        message.setStatus(MessageStatus.SENT);
      }
      message.ts = ctrl['ts'];
      swapMessageId(message, seq);
      routeData(message);
    } catch (e) {
      print('WARNING: Message rejected by the server');
      print(e.toString());
      message.setStatus(MessageStatus.FAILED);
      onData.add(null);
    }
  }

  Future leave(bool unsubscribe) async {
    if (!isSubscribed && !unsubscribe) {
      return Future.error(Exception('Cannot publish on inactive topic'));
    }

    var ctrl = await _tinodeService.leave(name, unsubscribe);
    resetSub();
    if (unsubscribe) {
      _cacheManager.cacheDel('topic', name);
      gone();
    }
    return ctrl;
  }

  Future getMeta(GetQuery params) {
    return _tinodeService.getMeta(name, params);
  }

  Future getMessagesPage(int limit, bool forward) {
    var query = startMetaQuery();
    var promise = getMeta(query.build());

    if (forward) {
      query.withLaterData(limit);
    } else {
      query.withEarlierData(limit);
      promise = promise.then((ctrl) {
        if (ctrl != null && ctrl['params'] != null && (ctrl['params']['count'] == null || ctrl.params.count == 0)) {
          noEarlierMsgs = true;
        }
      });
    }

    return promise;
  }

  Future setMeta(SetParams params) async {
    // Send Set message, handle async response.
    var ctrl = await _tinodeService.setMeta(name, params);
    if (ctrl && ctrl.code >= 300) {
      // Not modified
      return ctrl;
    }

    if (params.sub != null) {
      params.sub.topic = name;
      if (ctrl['params'] && ctrl['params']['acs']) {
        params.sub.acs = ctrl.params.acs;
        params.sub.updated = ctrl.ts;
      }
      if (params.sub.user == null) {
        // This is a subscription update of the current user.
        // Assign user ID otherwise the update will be ignored by _processMetaSub.
        params.sub.user = _authService.userId;
        params.desc ??= SetDesc();
      }
      params.sub.noForwarding = true;
      processMetaSub([params.sub]);
    }

    if (params.desc != null) {
      if (ctrl.params && ctrl.params.acs) {
        params.desc.acs = ctrl.params.acs;
        params.desc.updated = ctrl.ts;
      }
      processMetaDesc(params.desc);
    }

    if (params.tags != null) {
      processMetaTags(params.tags);
    }

    if (params.cred) {
      processMetaCreds([params.cred], true);
    }

    return ctrl;
  }

  startMetaQuery() {}
  gone() {}
  resetSub() {}
  processMetaCreds(List<dynamic> a, bool b) {}
  swapMessageId(Message m, int newSeqId) {}
  processMetaDesc(SetDesc a) {}
  processMetaTags(List<String> a) {}
  allMessagesReceived(int count) {}
  processMetaSub(List<dynamic> a) {}
  routeMeta(dynamic a) {}
  routeData(dynamic a) {}
  routePres(dynamic a) {}
  routeInfo(dynamic a) {}
}
