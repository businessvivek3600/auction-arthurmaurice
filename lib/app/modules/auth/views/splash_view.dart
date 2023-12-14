import 'package:action_tds/utils/utils_index.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../services/handleNotification/notification_services.dart';

import '../../../routes/app_pages.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    initController();
    Future.delayed(const Duration(seconds: 0),
        () async => await NotificationSetup.initFCM(false));
  }

  @override
  void dispose() {
    _controller.removeListener(_listner);
    _controller.dispose();
    super.dispose();
  }

  late VideoPlayerController _controller;
  int duration = 0;
  int position = 0;
  void initController() {
    _controller = VideoPlayerController.asset('assets/videos/splash_2.mp4')
      ..initialize()
          // ..setLooping(true)
          .then((_) {
        _controller.play();
        duration = _controller.value.duration.inMilliseconds;
        if (_controller.value.isCompleted) {
          logger.i('Video Completed');
        }
      });
    _controller.addListener(_listner);
  }

  void _listner() {
    setState(() {});
    if (_controller.value.hasError) {
      logger.e('Lister errr',
          tag: 'SplashView', error: _controller.value.errorDescription);
    }
    if (_controller.value.isInitialized) {
      duration = _controller.value.duration.inMilliseconds;
      if (_controller.value.position.inMilliseconds >= 3 * 1000) {
        context.go(Routes.intro);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildBody(),
    );
  }

  Stack buildBody() {
    return Stack(
      children: [
        Container(
          height: double.maxFinite,
          width: double.maxFinite,
          color: Colors.black,
          child: _controller.value.isInitialized
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height,
                      child: Transform.scale(
                        scale: (_controller.value.aspectRatio /
                            (getWidth(context) / getHeight(context))),
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  ],
                )
              : Container(),
        ),
        // Positioned(
        //   top: 100,
        //   child: titleLargeText(
        //     '${getWidth(context) / getHeight(context)}\n'
        //     '${_controller.value.aspectRatio}\n'
        //     '${(getWidth(context) / getHeight(context)) / _controller.value.aspectRatio}'
        //     '\n${_controller.value.size}',
        //     context,
        //     color: Colors.white,
        //   ),
        // ),
      ],
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Container(
  //         decoration: BoxDecoration(
  //           gradient: globalPageGradient(),
  //         ),
  //         child: Center(
  //             child: ConstrainedBox(
  //           constraints: const BoxConstraints(maxWidth: 200, maxHeight: 200),
  //           child: Image.asset(
  //             'assets/images/logo-no-background.png',
  //             // height: 100,
  //             // width: 100,
  //           ),
  //         ))),
  //   );
  // }
}
