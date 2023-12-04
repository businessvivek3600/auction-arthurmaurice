import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/app_tour_controller.dart';

class AppTourView extends GetView<AppTourController> {
  const AppTourView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AppTourView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'AppTourView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
