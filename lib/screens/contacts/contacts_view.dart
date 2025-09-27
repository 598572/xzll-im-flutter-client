import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xzll_im_flutter_client/screens/contacts/contacts_logic.dart';

class ContactsView extends GetView<ContactsLogic> {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("contacts".tr), centerTitle: true),
      body: CustomScrollView(slivers: []),
    );
  }
}
