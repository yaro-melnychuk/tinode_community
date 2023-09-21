import 'package:example/controllers/chat_controller.dart';
import 'package:example/controllers/contacts_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';

void main() => runApp(const App());

class HomePage extends GetView<ContactsController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(title: const Text('Tinode by community')),
        body: Column(
          children: [
            Expanded(child: _buildListContacts()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => controller.login('alice', 'alice123'),
                  child: const Text('Alice'),
                ),
                ElevatedButton(
                  onPressed: () => controller.login('bob', 'bob123'),
                  child: const Text('Bob'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // TODO i don't know how to sign out
                  },
                  child: const Text('SignOut'),
                ),
              ],
            )
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  ListView _buildListContacts() {
    return ListView.builder(
      itemCount: controller.topics.length,
      itemBuilder: (_, i) {
        final item = controller.topics[i];
        return ListTile(
          onTap: () => Get.toNamed('/chat', arguments: item),
          title: Text(item.public['fn']),
          subtitle: Text(item.topic ?? ''),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: kToolbarHeight),
      child: FloatingActionButton(
        onPressed: () {},
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}

class ChatPage extends GetView<ChatController> {
  ChatPage({Key? key}) : super(key: key);
  final _txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(title: Text(controller.topic.public['fn'] ?? '')),
        body: Column(
          children: [
            _buildListMessage(),
            _buildInput(),
          ],
        ),
      ),
    );
  }

  TextField _buildInput() {
    return TextField(
      controller: _txtController,
      textInputAction: TextInputAction.send,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      autofocus: true,
      onSubmitted: (v) {
        controller.sendText(v);
        _txtController.clear();
      },
    );
  }

  Expanded _buildListMessage() {
    return Expanded(
      child: ListView.builder(
        itemCount: controller.messages.length,
        itemBuilder: (_, i) {
          final item = controller.messages[i];
          Widget widget;
          if (item.content.isNotEmpty) widget = Text(item.content);
          widget = const SizedBox();
          return ListTile(
            title: widget,
          );
        },
      ),
    );
  }
}
