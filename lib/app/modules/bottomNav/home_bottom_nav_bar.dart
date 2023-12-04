import "package:action_tds/constants/constants_index.dart";
import "package:action_tds/utils/utils_index.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";

import "/app/modules/auth/user_model.dart";
import '/app/modules/bottomNav/home/controllers/home_controller.dart';
import 'live_bids/live_auctions_page.dart';
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:persistent_bottom_nav_bar/persistent_tab_view.dart";
import "account_view/account_view.dart";
import 'bid_history/bid_history.dart';
import "/app/modules/auth/controllers/auth_controller.dart";
import 'home/views/dashboard.dart';
import "transactions/view/transactions_page.dart";

BuildContext? testContext;

// ----------------------------------------- Provided Style ----------------------------------------- //
class ProvidedStylesExample extends StatefulWidget {
  const ProvidedStylesExample({
    final Key? key,
    required this.menuScreenContext,
    this.drawer,
    // required this.body,
    // required this.floatingActionButton,
  }) : super(key: key);
  final BuildContext menuScreenContext;
  final Widget? drawer;
  // final Widget body;
  // finsal Widget floatingActionButton;

  @override
  _ProvidedStylesExampleState createState() => _ProvidedStylesExampleState();
}

class _ProvidedStylesExampleState extends State<ProvidedStylesExample> {
  late bool _hideNavBar;
  var homeController = Get.put(HomeController());
  var authController = Get.put(AuthController());
  @override
  void initState() {
    super.initState();
    _hideNavBar = false;
  }

  @override
  void dispose() {
    logger.i("dispose called on provided style example page ${DateTime.now()}");
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) =>
      GetBuilder<AuthController>(builder: (authCtrl) {
        /// build screens
        List<Widget> buildScreens() => [
              HomeDashboard(),
              LiveAuctionsPage(
                menuScreenContext: widget.menuScreenContext,
                hideNavBar: _hideNavBar,
                onScreenHideButtonPressed: (bool val) {
                  setState(() => _hideNavBar = val);
                },
              ),
              const UserBidHistory(),
              // MainScreen(
              //   menuScreenContext: widget.menuScreenContext,
              //   hideStatus: _hideNavBar,
              //   onScreenHideButtonPressed: () {
              //     setState(() {
              //       _hideNavBar = !_hideNavBar;
              //     });
              //   },
              // ),
              TransactionPage(),
              AccountView(),
            ];

        /// build nav bar items
        List<PersistentBottomNavBarItem> navBarsItems(AuthController authCtrl) {
          var user = authCtrl.getUser<AuctionUser>();
          var name = user?.firstname ?? '';
          var id = user?.firstname;
          String tabName = name.isNotEmpty ? name : 'Login';
          var profileImage = user?.profileImage ?? '';
          return [
            PersistentBottomNavBarItem(
                icon: const Icon(Icons.home),
                title: "Home",
                activeColorPrimary: Colors.blue,
                inactiveColorPrimary: Colors.grey,
                inactiveColorSecondary: Colors.purple),
            PersistentBottomNavBarItem(
              icon: const Icon(Icons.bakery_dining_rounded),
              title: "Auctions",
              activeColorPrimary: kPrimaryColor5,
              inactiveColorPrimary: Colors.grey,
              routeAndNavigatorSettings: const RouteAndNavigatorSettings(
                initialRoute: "/",
                routes: {
                  // "/first": (final context) => const MainScreen2(),
                  // "/second": (final context) => const MainScreen3(),
                },
              ),
            ),
            PersistentBottomNavBarItem(
              icon: const Icon(Icons.history_edu_rounded),
              title: "History",
              activeColorPrimary: kPrimaryColor10,
              inactiveColorPrimary: Colors.grey,
              routeAndNavigatorSettings: const RouteAndNavigatorSettings(
                initialRoute: "/",
                routes: {
                  // "/first": (final context) => const MainScreen2(),
                  // "/second": (final context) => const MainScreen3(),
                },
              ),
            ),
            PersistentBottomNavBarItem(
              icon: const FaIcon(FontAwesomeIcons.moneyBill1Wave, size: 20),
              title: "Transactions",
              activeColorPrimary: kPrimaryColor9,
              inactiveColorPrimary: Colors.grey,
              routeAndNavigatorSettings: const RouteAndNavigatorSettings(
                initialRoute: "/",
                routes: {
                  // "/first": (final context) => const MainScreen2(),
                  // "/second": (final context) => const MainScreen3(),
                },
              ),
            ),
            PersistentBottomNavBarItem(
              icon: user != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: profileImage.isNotEmpty
                                ? buildCachedNetworkImage(profileImage)
                                : assetImages(MyPng.dummyUser),
                          ),
                        ),

                        /// if id is not empty
                        if (id != null)
                          Positioned(
                            right: 0,
                            child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 1),
                                ),
                                child: Center(
                                  child: capText(
                                      id.toString().trim().substring(0, 1),
                                      context,
                                      color: Colors.white),
                                )),
                          )
                      ],
                    )
                  : const Icon(Icons.login),
              activeColorSecondary: Colors.transparent,
              inactiveColorSecondary: Colors.transparent,
              title: name.isNotEmpty ? null : 'Login',
              // contentPadding: 10,
              activeColorPrimary: Colors.indigo,
              inactiveColorPrimary: Colors.grey,
              // onPressed: (final context) {
              //   // Get.toNamed(Routes.pageNotFound);
              //   // showAccountsSheet();
              // },

              routeAndNavigatorSettings: const RouteAndNavigatorSettings(
                initialRoute: "/",
                routes: {
                  // "/first": (final context) => const MainScreen2(),
                  // "/second": (final context) => const MainScreen3(),
                },
              ),
            ),
          ];
        }

        return GetBuilder<HomeController>(
          builder: (homeCtrl) {
            return Stack(
              children: [
                Scaffold(
                  drawer: widget.drawer,
                  backgroundColor: getTheme(context).scaffoldBackgroundColor,
                  body: PersistentTabView(
                    context,
                    controller: homeCtrl.persistentTabController,
                    screens: buildScreens(),
                    items: navBarsItems(authCtrl),
                    resizeToAvoidBottomInset: true,
                    bottomScreenMargin: kBottomNavigationBarHeight,
                    margin: const EdgeInsets.all(0.0),
                    confineInSafeArea: true,
                    navBarHeight: MediaQuery.of(context).viewInsets.bottom > 0
                        ? 0.0
                        : kBottomNavigationBarHeight,
                    handleAndroidBackButtonPress: true,

                    // onWillPop: _onWillPop,
                    selectedTabScreenContext: (final context) =>
                        testContext = context,
                    backgroundColor: getTheme(context).scaffoldBackgroundColor,
                    hideNavigationBar: homeCtrl.hideNavBar,
                    // decoration: NavBarDecoration(
                    //     colorBehindNavBar: getTheme(context).primaryColor,
                    //     gradient: LinearGradient(
                    //       colors: [
                    //         getTheme(context).primaryColor,
                    //         getTheme(context).cardColor
                    //       ],
                    //       begin: Alignment.topCenter,
                    //       end: Alignment.bottomCenter,
                    //     ),
                    //     boxShadow: const [
                    //       BoxShadow(color: Colors.black12, blurRadius: 15.0),
                    //       // BoxShadow(color: Colors.white30, blurRadius: 10.0),
                    //     ],
                    //     borderRadius: const BorderRadius.only(
                    //       topLeft: Radius.circular(20),
                    //       topRight: Radius.circular(20),
                    //     )),

                    itemAnimationProperties: const ItemAnimationProperties(
                        duration: Duration(milliseconds: 400),
                        curve: Curves.fastOutSlowIn),
                    screenTransitionAnimation: const ScreenTransitionAnimation(
                        animateTabTransition: true,
                        curve: Curves.fastOutSlowIn,
                        duration: Duration(milliseconds: 500)),
                    navBarStyle: NavBarStyle.style3,
                    onItemSelected: homeCtrl.onNavBarTap,
                  ),
                ),
              ],
            );
          },
        );
      });

  Future<bool> _onWillPop(final BuildContext context) async {
    await showDialog(
      context: context,
      useSafeArea: true,
      builder: (final context) => Container(
        height: 50,
        width: 50,
        color: Colors.white,
        child: ElevatedButton(
          child: const Text("Close"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
    return false;
  }
}

//main screen
class MainScreen extends StatelessWidget {
  const MainScreen({
    final Key? key,
    required this.hideStatus,
    required this.onScreenHideButtonPressed,
    required this.menuScreenContext,
  }) : super(key: key);
  final bool hideStatus;
  final Function onScreenHideButtonPressed;
  final BuildContext menuScreenContext;

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text("Main Screen"),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed("/second");
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Main Screen"),
              ElevatedButton(
                child: const Text("Go to the next screen"),
                onPressed: () {
                  Navigator.of(context).pushNamed("/second");
                },
              ),
              ElevatedButton(
                child: const Text("Open Drawer"),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
              ElevatedButton(
                child: const Text("Hide navigation bar"),
                onPressed: () {
                  onScreenHideButtonPressed();
                },
              ),
            ],
          ),
        ),
      );
}



// ----------------------------------------- Custom Style ----------------------------------------- //

// class CustomNavBarWidget extends StatelessWidget {
//   const CustomNavBarWidget(
//     this.items, {
//     final Key key,
//     this.selectedIndex,
//     this.onItemSelected,
//   }) : super(key: key);
//   final int selectedIndex;
//   final List<PersistentBottomNavBarItem> items;
//   final ValueChanged<int> onItemSelected;

//   Widget _buildItem(
//           final PersistentBottomNavBarItem item, final bool isSelected) =>
//       Container(
//         alignment: Alignment.center,
//         height: kBottomNavigationBarHeight,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           mainAxisSize: MainAxisSize.min,
//           children: <Widget>[
//             Flexible(
//               child: IconTheme(
//                 data: IconThemeData(
//                     size: 26,
//                     color: isSelected
//                         ? (item.activeColorSecondary ?? item.activeColorPrimary)
//                         : item.inactiveColorPrimary ?? item.activeColorPrimary),
//                 child: isSelected ? item.icon : item.inactiveIcon ?? item.icon,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.only(top: 5),
//               child: Material(
//                 type: MaterialType.transparency,
//                 child: FittedBox(
//                     child: Text(
//                   item.title,
//                   style: TextStyle(
//                       color: isSelected
//                           ? (item.activeColorSecondary ??
//                               item.activeColorPrimary)
//                           : item.inactiveColorPrimary,
//                       fontWeight: FontWeight.w400,
//                       fontSize: 12),
//                 )),
//               ),
//             )
//           ],
//         ),
//       );

//   @override
//   Widget build(final BuildContext context) => Container(
//         color: Colors.white,
//         child: SizedBox(
//           width: double.infinity,
//           height: kBottomNavigationBarHeight,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: items.map((final item) {
//               final int index = items.indexOf(item);
//               return Flexible(
//                 child: GestureDetector(
//                   onTap: () {
//                     onItemSelected(index);
//                   },
//                   child: _buildItem(item, selectedIndex == index),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       );
// }
