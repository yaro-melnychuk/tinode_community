import 'package:example/controllers/contacts_controller.dart';
import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/chat_controller.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(primarySwatch: Colors.green),
      getPages: getPages(),
    );
  }

  List<GetPage<dynamic>> getPages() {
    return [
      GetPage(
        name: '/',
        page: HomePage.new,
        binding: BindingsBuilder(() {
          Get.lazyPut(ContactsController.new);
        }),
      ),
      GetPage(
        name: '/chat',
        page: ChatPage.new,
        binding: BindingsBuilder(() {
          Get.lazyPut(ChatController.new);
        }),
      ),
    ];
  }
}
