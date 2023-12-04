import '/components/component_index.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/constants/constants_index.dart';
import '/utils/utils_index.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:lottie/lottie.dart';
// import 'package:rive/rive.dart';

Widget assetSvg(String path,
        {BoxFit? fit,
        bool fullPath = false,
        Color? color,
        double? width,
        double? height}) =>
    SvgPicture.asset(
      fullPath ? path : 'assets/svgs/$path',
      fit: fit ?? BoxFit.contain,
      color: color,
      width: width,
      height: height,
    );
// Widget assetRive(String path, {BoxFit? fit, bool fullPath = false}) =>
//     RiveAnimation.asset(
//       fullPath ? path : 'assets/rive/$path',
//       fit: fit ?? BoxFit.contain,
//     );
LottieBuilder assetLottie(String path,
        {BoxFit? fit,
        bool fullPath = false,
        double? width,
        double? height,
        LottieDelegates? delegates}) =>
    Lottie.asset(
      fullPath ? path : 'assets/lottie/$path',
      fit: fit ?? BoxFit.contain,
      width: width,
      height: height,
      delegates: delegates,
    );

Widget assetImages(String path,
        {BoxFit? fit,
        bool fullPath = false,
        Color? color,
        double? width,
        double? height}) =>
    Image.asset(
      fullPath ? path : 'assets/images/$path',
      fit: fit ?? BoxFit.contain,
      color: color,
      width: width,
      height: height,
    );

ImageProvider assetImageProvider(String path,
        {BoxFit? fit, bool fullPath = false}) =>
    AssetImage(fullPath ? path : 'assets/images/$path');

ImageProvider netImageProvider(String path,
        {BoxFit? fit, Color? color, double? width, double? height}) =>
    NetworkImage(path);

Widget buildCachedNetworkImage(String image,
    {double? h,
    double? w,
    double? borderRadius,
    BoxFit? fit,
    bool fullPath = false,
    String? placeholder}) {
  return LayoutBuilder(builder: (context, bound) {
    w ??= bound.maxWidth;
    return CachedNetworkImage(
      imageUrl: image,
      fit: fit ?? BoxFit.cover,
      imageBuilder: (context, image) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        child: Container(
            decoration: BoxDecoration(
                image:
                    DecorationImage(image: image, fit: fit ?? BoxFit.cover))),
      ),
      placeholder: (context, url) => Center(
        child: SizedBox(
          height: h ?? 50,
          width: w ?? 100,
          child: Center(
              child: CircularProgressIndicator(
            color: getTheme(context).textTheme.bodyText1?.color,
          )),
        ),
      ),
      errorWidget: (context, url, error) => ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 0),
        child: SizedBox(
            height: h ?? 50,
            width: w ?? 100,
            child: Center(child: assetImages(placeholder ?? MyPng.logo))),
      ),
      cacheManager: CacheManager(Config("${AppConst.appName}_$image",
          stalePeriod: const Duration(days: 30))),
    );
  });
}

enum ImageLoadingMode { per, size, shimmer, none }

Widget buildCachedImageWithLoading(
  String image, {
  double? h,
  double? w,
  // double? ph,
  // double? pw,
  BoxFit? fit,
  bool fullPath = false,
  bool showText = false,
  ImageLoadingMode loadingMode = ImageLoadingMode.shimmer,
  Color loadingColor = Colors.grey,
  String? placeholder,
  bool cache = true,
  double borderRadius = 0,
  Alignment placeholderAlignment = Alignment.center,
  Alignment imageAlignment = Alignment.center,
}) {
  return LayoutBuilder(builder: (context, bound) {
    w ??= bound.maxWidth;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: h,
        width: w,
        child: FastCachedImage(
          url: image,
          gaplessPlayback: false,
          filterQuality: FilterQuality.high,
          fit: fit ?? BoxFit.contain,
          fadeInDuration: const Duration(seconds: 1),
          alignment: imageAlignment,
          errorBuilder: (context, exception, stacktrace) => Container(
              padding: EdgeInsets.all(w! * 0.1),
              child: Align(
                  alignment: placeholderAlignment,
                  child: assetImages(placeholder ?? MyPng.logo,
                      fit: BoxFit.contain))),
          loadingBuilder: (context, progress) {
            bool isMb = (inKB(progress.totalBytes ?? 0)).abs() >= 1000;
            double per = (progress.progressPercentage.value) * 100;
            return progress.isDownloading
                ? Container(
                    color: Colors.white30,
                    child: loadingMode != ImageLoadingMode.shimmer
                        ? Stack(
                            alignment: Alignment.center,
                            children: [
                              if (progress.totalBytes != null)
                                Text(
                                    loadingMode == ImageLoadingMode.per
                                        ? '${per.toStringAsFixed(0)}%'
                                        : loadingMode == ImageLoadingMode.size
                                            ? '${isMb ? inMB(progress.downloadedBytes).toStringAsFixed(1) : inKB(progress.downloadedBytes).toStringAsFixed(0)} / ${isMb ? inMB(progress.totalBytes ?? 0).toStringAsFixed(1) : inKB(progress.downloadedBytes).toStringAsFixed(0)} ${isMb ? "Mb" : 'kb'}'
                                            : '',
                                    style: const TextStyle(
                                        color: Colors.red, fontSize: 10)),
                              if (loadingMode == ImageLoadingMode.per)
                                SizedBox(
                                    width: w ?? 40,
                                    height: h ?? 40,
                                    child: CircularProgressIndicator(
                                        color: loadingColor,
                                        value:
                                            progress.progressPercentage.value)),
                            ],
                          )
                        : loadingMode == ImageLoadingMode.none
                            ? Container()
                            : const DefaultRefreshEffect(
                                loading: true,
                                child: SizedBox(
                                  height: 300,
                                  width: 300,
                                  child: Text(
                                    'Loading...\n\n\n\n\n\n\n\n',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ))
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  });
}

Future<void> clearFastCacheImage(String image) async {
  bool isCached = FastCachedImageConfig.isCached(imageUrl: image);
  logger.w(' $image isCached1 $isCached');
  await FastCachedImageConfig.deleteCachedImage(imageUrl: image);
  bool isCached2 = FastCachedImageConfig.isCached(imageUrl: image);
  logger.w(' $image isCached2 $isCached2');
}

int inKB(int bytes) => (bytes / 1024).round();
int inMB(int bytes) => (bytes / (1024 * 1024)).round();
