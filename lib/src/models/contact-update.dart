import 'model.dart';

class ContactUpdateEvent {
  final TopicSubscription contact;
  final String what;

  ContactUpdateEvent(this.what, this.contact);
}
