import 'dart:math';

import '/app/modules/bottomNav/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '/components/component_index.dart';
import '/constants/asset_constants.dart';
import '/utils/utils_index.dart';

class HomeHotBids extends StatefulWidget {
  const HomeHotBids(
    this.ctr, {
    Key? key,
  }) : super(key: key);
  final HomeController ctr;

  @override
  State<HomeHotBids> createState() => _HomeHotBidsState();
}

class _HomeHotBidsState extends State<HomeHotBids> {
  final rnd = Random();
  late List<int> extents;
  int crossAxisCount = 4;

  @override
  void initState() {
    super.initState();
    extents = List<int>.generate(32, (int index) {
      var num = (rnd.nextInt(10)).clamp(8, 10);
      return num;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loading = widget.ctr.loadingDashboard;
    int total = loading ? 6 : widget.ctr.trendingAuctionProducts.length;
    return Column(
      children: [
        ///title
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: paddingDefault, vertical: 1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  titleLargeText('Trending Auctions', context),
                  width5(),
                  assetImages(MyPng.fire, height: 30, width: 30),
                ],
              ),
              bodyMedText('View All', context)
            ],
          ),
        ),
        DefaultRefreshEffect(
          loading: loading,
          child: MasonryGridView.count(
            padding: EdgeInsets.all(paddingDefault),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            itemCount: total + 2,
            itemBuilder: (context, index) {
              bool isLast = index == total || index == total + 1;
              final height = isLast
                  ? kBottomNavigationBarHeight.toInt()
                  // : (10 - (index % 3)) * 27;
                  : 270;

              return !isLast
                  ? AuctionProductCard(
                      height: height,
                      index: index,
                      loading: loading,
                      product: loading
                          ? null
                          : widget.ctr.trendingAuctionProducts[index],
                    )
                  : Container(height: height.toDouble());
            },
          ),
        ),
      ],
    );
  }
}

///
const _defaultColor = Color(0xFF34568B);

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    Key? key,
    required this.title,
    this.topPadding = 0,
    required this.child,
  }) : super(key: key);

  final String title;
  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: child,
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.index,
    this.extent,
    this.backgroundColor,
    this.bottomSpace,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      color: backgroundColor ?? _defaultColor,
      height: extent,
      child: Center(
        child: CircleAvatar(
          minRadius: 20,
          maxRadius: 20,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: Text('$index', style: const TextStyle(fontSize: 20)),
        ),
      ),
    );

    if (bottomSpace == null) {
      return child;
    }

    return Column(
      children: [
        Expanded(child: child),
        Container(
          height: bottomSpace,
          color: Colors.green,
        )
      ],
    );
  }
}

class InteractiveTile extends StatefulWidget {
  const InteractiveTile({
    Key? key,
    required this.index,
    this.extent,
    this.bottomSpace,
  }) : super(key: key);

  final int index;
  final double? extent;
  final double? bottomSpace;

  @override
  _InteractiveTileState createState() => _InteractiveTileState();
}

class _InteractiveTileState extends State<InteractiveTile> {
  Color color = _defaultColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (color == _defaultColor) {
            color = Colors.red;
          } else {
            color = _defaultColor;
          }
        });
      },
      child: Tile(
        index: widget.index,
        extent: widget.extent,
        backgroundColor: color,
        bottomSpace: widget.bottomSpace,
      ),
    );
  }
}
