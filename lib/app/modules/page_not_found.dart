import 'package:action_tds/app/routes/app_pages.dart';
import 'package:action_tds/constants/constants_index.dart';
import 'package:action_tds/utils/utils_index.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// The not found screen
class PageNotFound extends StatelessWidget {
  /// Constructs a [HomeScreen]
  const PageNotFound({super.key, required this.state});
  final GoRouterState state;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page not found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.home);
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            height5(kToolbarHeight),
            Expanded(child: assetLottie(MyLottie.pageNotFound)),
            height20(),
            titleLargeText('Page not found', context, color: Colors.red),
            height5(),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 16.0),
              child: bodyLargeText(
                  'Sorry, the data you are looking for not matched in our record',
                  context,
                  textAlign: TextAlign.center),
            ),
            height20(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(Routes.home);
                      }
                    },
                    child: const Text('Go Back'))
              ],
            ),
            height100(Get.height * 0.1),
          ],
        ),
      ),
    );
  }
}
