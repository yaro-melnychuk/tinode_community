import 'model.dart';

class SetParams {
  TopicDescription? desc;
  TopicSubscription? sub;
  List<String>? tags;
  Credential? cred;

  SetParams({this.desc, this.sub, this.tags, this.cred});
}
