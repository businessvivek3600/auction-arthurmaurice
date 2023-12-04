import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/utils_index.dart';

enum LoadMoreStatus { idle, loading, error, done, noMore }

class LoadMoreContainer extends StatefulWidget {
  const LoadMoreContainer({
    super.key,
    required this.builder,
    required this.finishWhen,
    required this.onLoadMore,
    this.onRefresh,
    this.loadingWidget,
    this.showLoading = true,
    this.showNoMore = false,
    this.showToast = true,
    this.toastMessage,
    this.height,
    this.loadingHeight,
    this.axis = Axis.vertical,
    this.animationDuration = 500,
  });
  final Widget Function(
      ScrollController scrollController, LoadMoreStatus status) builder;
  final bool finishWhen;
  final Future<void> Function() onLoadMore;
  final Future<void> Function()? onRefresh;
  final Widget Function(BuildContext context, LoadMoreStatus status)?
      loadingWidget;
  final bool showLoading;
  final bool showNoMore;
  final bool showToast;
  final String? toastMessage;
  final double? height;
  final double? loadingHeight;
  final int animationDuration;
  final Axis axis;
  @override
  State<LoadMoreContainer> createState() => _LoadMoreContainerState();
}

class _LoadMoreContainerState extends State<LoadMoreContainer> {
  final ScrollController _scrollController = ScrollController();
  bool _hasMoreItems = false;
  LoadMoreStatus _loadMoreStatus = LoadMoreStatus.idle;

  @override
  void initState() {
    afterBuildCreated(() => _scrollController.addListener(_listener));
    super.initState();
  }

  void _listener() async {
    // logger.i(
    //     'LoadMoreContainer scrollController called: ${_scrollController.position.pixels} ${_scrollController.position.maxScrollExtent}');
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      logger.i('LoadMoreContainer finishWhen called: ${widget.finishWhen}');
      _hasMoreItems = !widget.finishWhen;

      if (_loadMoreStatus != LoadMoreStatus.loading && _hasMoreItems) {
        setState(() => _loadMoreStatus = LoadMoreStatus.loading);
        await widget.onLoadMore().then((value) => _scrollController
            .animateTo(_scrollController.position.maxScrollExtent,
                duration: Duration(milliseconds: widget.animationDuration),
                curve: Curves.easeIn)
            .then((value) =>
                setState(() => _loadMoreStatus = LoadMoreStatus.idle)));
      } else if (_hasMoreItems == false) {
        setState(() => _loadMoreStatus = LoadMoreStatus.noMore);
        if (widget.showToast) {
          Fluttertoast.showToast(msg: widget.toastMessage ?? 'No more items');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // logger.i(
    //     'LoadMoreContainer build called: $_loadMoreStatus hasmore: $_hasMoreItems');
    List<Widget> children = [];
    if (widget.axis == Axis.horizontal) {
      children.add(
          Expanded(child: widget.builder(_scrollController, _loadMoreStatus)));
      if (_loadMoreStatus == LoadMoreStatus.loading && widget.showLoading) {
        children.add(widget.loadingWidget != null
            ? widget.loadingWidget!(context, _loadMoreStatus)
            : const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator.adaptive()));
      }
      return Row(children: children);
    }
    var height = _loadMoreStatus == LoadMoreStatus.loading && widget.showLoading
        ? (widget.loadingWidget != null ? null : (widget.loadingHeight ?? 50))
        : 0.toDouble();
    var child = SizedBox(
      height: widget.height,
      child: Column(
        children: [
          Expanded(child: widget.builder(_scrollController, _loadMoreStatus)),
          AnimatedContainer(
            duration: Duration(milliseconds: widget.animationDuration),
            height: height,
            child: AnimatedOpacity(
              opacity: _loadMoreStatus == LoadMoreStatus.loading ? 1 : 0,
              duration: Duration(milliseconds: widget.animationDuration),
              child: widget.loadingWidget != null
                  ? widget.loadingWidget!(context, _loadMoreStatus)
                  : Container(
                      width: height,
                      padding: const EdgeInsets.all(8.0),
                      child: const Center(
                          child: CircularProgressIndicator.adaptive())),
            ),
          ),
          if (_loadMoreStatus == LoadMoreStatus.noMore && widget.showNoMore)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: capText('No more items', context),
            ),
        ],
      ),
    );
    if (widget.onRefresh == null) return child;
    return RefreshIndicator(
      onRefresh: widget.onRefresh!,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: child,
    );
  }
}
