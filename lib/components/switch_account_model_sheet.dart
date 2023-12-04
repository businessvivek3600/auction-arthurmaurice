import '/app/modules/auth/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/models/models_index.dart';
import '../app/modules/auth/controllers/auth_controller.dart';
import '../app/modules/auth/user_model.dart';
// import '../app/modules/socialApp/providers/social_user_provider.dart';
import '../app/routes/app_pages.dart';
import '../services/auth_services.dart';
import '../utils/utils_index.dart';

// void showAccountsSheet() {
//   Get.bottomSheet(
//     const ChangeAccountSheet(),
//     // backgroundColor: Colors.transparent,
//   );
// }

// class _SaveduserdropDown extends StatefulWidget {
//   const _SaveduserdropDown({Key? key, this.onChanged}) : super(key: key);
//   final Function(AppUser? user)? onChanged;

//   @override
//   State<_SaveduserdropDown> createState() => _SaveduserdropDownState();
// }

// class _SaveduserdropDownState extends State<_SaveduserdropDown> {
//   var controller = Get.put(AuthController());
//   AppUser? selectedUser;
//   @override
//   Widget build(BuildContext context) {
//     final socialUserProvider = Get.put(AppUserProvider.instance);
//     final savedUsers = socialUserProvider.users;
//     return GetBuilder<AuthController>(builder: (ctrl) {
//       return Card(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   Text(
//                     'Choose existing',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[400]),
//                   )
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: DropdownButton<AppUser?>(
//                           borderRadius: BorderRadius.circular(10),
//                           style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[600]),
//                           underline: Container(
//                               height: 1.0,
//                               decoration: const BoxDecoration(
//                                   border: Border(
//                                       bottom: BorderSide(
//                                           color: Colors.red, width: 0.0)))),
//                           isExpanded: true,
//                           hint: const Text('Select user'),
//                           disabledHint: const Text('No users found'),
//                           dropdownColor: Colors.grey[200],
//                           value: selectedUser,
//                           onChanged: (AppUser? value) {
//                             setState(() {
//                               selectedUser = value;
//                             });
//                           },
//                           selectedItemBuilder: (BuildContext context) {
//                             return savedUsers
//                                 .map(
//                                   (e) => Row(
//                                     children: [
//                                       const CircleAvatar(
//                                         radius: 10,
//                                         backgroundImage: NetworkImage(''),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Expanded(
//                                           child: Text(
//                                         '${e.firstname ?? ''}dfdf _${e.id}',
//                                         overflow: TextOverflow.ellipsis,
//                                       )),
//                                     ],
//                                   ),
//                                 )
//                                 .toList();
//                           },
//                           items: savedUsers
//                               .map(
//                                 (e) => DropdownMenuItem<AuctionUser?>(
//                                   value: e,
//                                   child: Row(
//                                     children: [
//                                       const CircleAvatar(
//                                         radius: 10,
//                                         backgroundImage: NetworkImage(''),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Expanded(
//                                           child: Text(
//                                         '${e.firstname ?? ''} _${e.id}',
//                                         overflow: TextOverflow.ellipsis,
//                                       )),
//                                     ],
//                                   ),
//                                 ),
//                               )
//                               .toList()),
//                     ),
//                   ),
//                   SizedBox(
//                     width: 50,
//                     child: ctrl.loggingIn.value
//                         ? const CupertinoActivityIndicator()
//                         : IconButton(
//                             onPressed: selectedUser == null
//                                 ? null
//                                 : () {
//                                     widget.onChanged!(selectedUser);
//                                   },
//                             icon: const Icon(Icons.arrow_forward_rounded),
//                           ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
// }

// class ChangeAccountSheet extends StatefulWidget {
//   const ChangeAccountSheet({super.key});

//   @override
//   State<ChangeAccountSheet> createState() => _ChangeAccountSheetState();
// }

// class _ChangeAccountSheetState extends State<ChangeAccountSheet> {
//   AppUser? selectedUser;
//   @override
//   Widget build(BuildContext context) {
//     final appUserProvider = Get.put(AppUserProvider.instance);
//     return BottomSheet(
//       // backgroundColor: redDark,
//       backgroundColor: Colors.transparent,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       shadowColor: Colors.transparent,
//       onClosing: () {},
//       builder: (context) => GetBuilder<AuthController>(
//           init: AuthController(),
//           builder: (authCtrl) {
//             var currentUser = authCtrl.getUser<AuctionUser>();
//             return Container(
//                 constraints: BoxConstraints(
//                     maxHeight: Get.height * 0.2, maxWidth: Get.width),
//                 margin: const EdgeInsetsDirectional.only(
//                     bottom: kBottomNavigationBarHeight, start: 10, end: 10),
//                 decoration: BoxDecoration(
//                     color: Get.theme.cardColor,
//                     borderRadius: BorderRadius.circular(20)),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     titleLargeText('Switch Account', context),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: DropdownButton<AuctionUser>(
//                             style: getTheme(context).textTheme.bodyLarge,
//                             onChanged: (e) {
//                               setState(() {
//                                 selectedUser = e;
//                               });
//                             },
//                             isExpanded: true,
//                             borderRadius: BorderRadius.circular(20),
//                             value: selectedUser as AuctionUser?,
//                             hint: Text('Select Account',
//                                 style: getTheme(context).textTheme.bodyLarge),
//                             selectedItemBuilder: (context) {
//                               return appUserProvider.users.map<Widget>((user) {
//                                 return Padding(
//                                   padding: const EdgeInsets.only(bottom: 8.0),
//                                   child: _UserTile(
//                                     user: user,
//                                     onChanged: (e) {
//                                       // setState(() {
//                                       //   selectedUser = e;
//                                       // });
//                                       // _login(e, authCtrl);
//                                     },
//                                     loggingIn: authCtrl.loggingIn.value,
//                                     currentUser: currentUser,
//                                     selected: user.id == user.id,
//                                   ),
//                                 );
//                               }).toList();
//                             },
//                             items: [
//                               ...appUserProvider.users
//                                   .map<DropdownMenuItem<AuctionUser>>(
//                                     (user) => DropdownMenuItem<AuctionUser>(
//                                       value: user,
//                                       child: _UserTile(
//                                         user: user,
//                                         onChanged: (e) {
//                                           // setState(() {
//                                           //   selectedUser = e;
//                                           // });
//                                           // _login(e, authCtrl);
//                                         },
//                                         loggingIn: authCtrl.loggingIn.value,
//                                         currentUser: currentUser,
//                                         selected: user.id == user.id,
//                                       ),
//                                     ),
//                                   )
//                                   .toList(),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),

//                     /// switch and cancel button

//                     Row(
//                       children: [
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: currentUser?.id ==
//                                         (selectedUser as AuctionUser?)?.id ||
//                                     selectedUser == null ||
//                                     authCtrl.loggingIn.value
//                                 ? null
//                                 : () {
//                                     _login(context, selectedUser, authCtrl);
//                                   },
//                             child: const Text('Switch'),
//                           ),
//                         ),
//                         width10(),
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: !authCtrl.loggingIn.value
//                                 ? () {
//                                     Navigator.pop(context);
//                                   }
//                                 : null,
//                             child: const Text('Cancel'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 )
//                 // child: ListView(
//                 //   padding:
//                 //       const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 //   children: [

//                 //   ],
//                 // ),
//                 );
//           }),
//     );
//   }

//   Future<void> _login(
//       BuildContext context, AppUser? appUser, AuthController controller) async {
//     controller.setLoggingIn(true);
//     final thenTo = Get.parameters['then'];
//     await controller
//         .login(context, loginModel: null, appUser: appUser)
//         .then((value) async {
//       if (value != null) {
//         Navigator.pop(context);
//         controller.setLoggingIn(false);
//         await AuthService.instance
//             .login((await UserProvider.instance).getToken);
//         await Future.delayed(const Duration(milliseconds: 500), () {
//           Get.offNamed(Routes.home);
//         }).then((value) {
//           Get.snackbar(
//             'Success',
//             'Account switched to ${(appUser as AuctionUser).firstname} ${(appUser).id}',
//             backgroundColor: Colors.indigo,
//           );
//           if (thenTo != null) {
//             Get.toNamed(thenTo);
//           }
//         });
//       } else {
//         controller.setLoggingIn(false);
//       }
//     }).catchError((e) {
//       controller.setLoggingIn(false);
//       Get.snackbar('Error', e.toString());
//     });
//   }
// }

// class _UserTile extends StatefulWidget {
//   const _UserTile(
//       {super.key,
//       this.onChanged,
//       required this.user,
//       required this.loggingIn,
//       required this.currentUser,
//       this.selected = false});
//   final Function(AppUser? user)? onChanged;
//   final AppUser user;
//   final bool loggingIn;
//   final AppUser? currentUser;
//   final bool selected;

//   @override
//   State<_UserTile> createState() => __UserTileState();
// }

// class __UserTileState extends State<_UserTile> {
//   @override
//   Widget build(BuildContext context) {
//     bool selected = widget.selected;
//     final user = widget.user as AuctionUser;
//     bool currentUser = (widget.currentUser as AuctionUser?)?.id == user.id;
//     return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//         margin: const EdgeInsets.symmetric(vertical: 5),
//         decoration: BoxDecoration(
//           // color: selected
//           //     ? getTheme(context).primaryColor.withOpacity(0.1)
//           //     : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Row(
//           children: [
//             const CircleAvatar(backgroundImage: NetworkImage('')),
//             width10(),
//             Text('${user.firstname} ${user.id}'),
//             const Spacer(),
//             widget.loggingIn && selected
//                 ? const CupertinoActivityIndicator()
//                 : currentUser
//                     ? const Icon(Icons.check_rounded, color: Colors.white)
//                     : const SizedBox(),
//           ],
//         ));
//   }
// }
