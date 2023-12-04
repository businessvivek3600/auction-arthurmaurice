import 'package:action_tds/constants/constants_index.dart';
import 'package:action_tds/database/functions.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../bottomNav/bid_history/controllers/bidController.dart';
import '../../bottomNav/home/controllers/home_controller.dart';
import '../../bottomNav/transactions/controller/transactionController.dart';
import '/utils/utils_index.dart';
import 'package:go_router/go_router.dart';

import '/app/modules/auth/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '/app/models/root_models/root_user_model.dart';
import '/components/component_index.dart';

import '../../../../services/auth_services.dart';
import '../../../models/auth/login_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/auth_controller.dart';

class AuthView extends StatefulWidget {
  AuthView({Key? key, this.then, this.referer}) : super(key: key);
  final String? then;
  final String? referer;

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final controller = Get.put(AuthController());
  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      checkForUpdate(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: GetBuilder<AuthController>(
          init: AuthController(),
          initState: (state) {
            if (widget.referer != null) {
              logger.i('referer: ${widget.referer}');
              Future.delayed(const Duration(milliseconds: 500), () {
                controller.refererController.value.text = widget.referer ?? '';
                controller.pageController.value.animateToPage(1,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn);
              });
            }
          },
          builder: (authCtrl) {
            return Scaffold(
              body: Stack(
                children: [
                  globalContainer(),

                  ///top left clipper
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipShadowPath(
                      clipper: const MyClipper1(),
                      shadow:
                          const Shadow(blurRadius: 10, color: Colors.white24),
                      child: Container(
                        height: Get.height * 0.3,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              kPrimaryColor5,
                              kPrimaryColor6,
                            ].reversed.toList(),
                          ),
                        ),
                      ),
                    ),
                  ),

                  ///bottom left circle
                  Positioned(
                    bottom: Get.height * 0.1,
                    left: Get.width * 0.1,
                    child: Container(
                      height: Get.height * 0.04,
                      width: Get.height * 0.04,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              kPrimaryColor8,
                              kPrimaryColor9,
                            ].reversed.toList(),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.white24,
                              blurRadius: 5,
                              offset: Offset(0, 0),
                            ),
                          ]),
                    ),
                  ),

                  ///bottom right circle
                  Positioned(
                    bottom: Get.height * 0.15,
                    right: -10,
                    child: Container(
                      height: Get.height * 0.07,
                      width: Get.height * 0.07,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              getTheme().primaryColor,
                              Colors.black,
                            ],
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.white24,
                              blurRadius: 5,
                              offset: Offset(0, 0),
                            ),
                          ]),
                    ),
                  ),

                  ///top right circle
                  Positioned(
                    top: Get.height * 0.2,
                    right: Get.width * 0.1,
                    child: Container(
                      height: Get.height * 0.07,
                      width: Get.height * 0.07,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              kPrimaryColor10,
                              kPrimaryColor11,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white24,
                              blurRadius: 5,
                              offset: Offset(0, 0),
                            ),
                          ]),
                    ),
                  ),

                  ///pageview
                  Positioned(
                    top: paddingDefault * 2,
                    bottom: paddingDefault * 2,
                    left: 0,
                    right: 0,
                    child: PageView(
                      controller: authCtrl.pageController.value,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _SignInPageView(widget.then),
                        _SignUpPageView(widget.then, widget.referer),
                      ],
                    ),
                  ),

                  ///loading indicator
                  // if (authCtrl.loggingIn.value)
                  //   Positioned(
                  //     bottom: paddingDefault * 5,
                  //     left: paddingDefault * 2,
                  //     right: paddingDefault * 2,
                  //     child: const Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [CupertinoActivityIndicator()],
                  //     ),
                  //   ),
                ],
              ),
            );
          }),
    );
  }
}

class _SignInPageView extends StatelessWidget {
  const _SignInPageView(this.then);
  static final _formKey = GlobalKey<FormState>();
  final String? then;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
        init: AuthController(),
        builder: (authCtrl) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spaceDefault * 2),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        displayLarge(
                          'Sign In',
                          context,
                          fontSize: 32,
                          style: getTheme(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                  color: getTheme(context).primaryColor,
                                  fontSize: 40),
                        ),
                        height5(),
                        bodyLargeText('Sign in to continue', context),
                        height30(),
                      ],
                    ),
                  ),
                  TextFormField(
                    controller: authCtrl.emailController.value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        filled: false,
                        isDense: false,
                        hintText: 'Email or Username',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10))),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      }
                      //  else if (!GetUtils.isEmail(value)) {
                      //   return 'Please enter valid email';
                      // }
                      return null;
                    },
                  ),
                  height10(),
                  TextFormField(
                    controller: authCtrl.passwordController.value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      filled: false,
                      isDense: false,
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onFieldSubmitted: (newValue) {
                      _login(
                          context,
                          SocialLoginModel(
                              email: authCtrl.emailController.value.text,
                              password: authCtrl.passwordController.value.text),
                          null,
                          authCtrl);
                    },
                  ),
                  height20(),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: authCtrl.loggingIn.value
                              ? null
                              : () {
                                  _login(
                                      context,
                                      SocialLoginModel(
                                          email: authCtrl
                                              .emailController.value.text,
                                          password: authCtrl
                                              .passwordController.value.text),
                                      null,
                                      authCtrl);
                                },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Sign In'),
                              if (authCtrl.loggingIn.value)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    width10(),
                                    const CupertinoActivityIndicator(),
                                  ],
                                )
                            ],
                          )),
                      const Spacer(),
                      TextButton(
                        onPressed: () => context.push(Routes.forgotPassword),
                        child: bodyLargeText('Forgot Password?', context),
                      ),
                    ],
                  ),
                  height30(),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Don\'t have an account? ',
                      style: getTheme().textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Create one',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              authCtrl.pageController.value.animateToPage(1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.fastOutSlowIn);
                            },
                          style: getTheme()
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: kPrimaryColor5),
                        ),
                      ],
                    ),
                  ),
                  // _SaveduserdropDown(
                  //     onChanged: (AppUser? user) =>
                  //         _login(context, null, user, authCtrl)),
                ],
              ),
            ),
          );
        });
  }

  _login(BuildContext context, SocialLoginModel? socialLoginModel,
      AppUser? appUser, AuthController controller) async {
    try {
      bool proceed =
          appUser != null ? true : (_formKey.currentState?.validate() ?? false);
      if (proceed) {
        controller.setLoggingIn(true);
        primaryFocus?.unfocus();
        controller
            .login(context, loginModel: socialLoginModel, appUser: appUser)
            .then((value) async {
          logger.i('login value: $value');

          controller.setLoggingIn(false);
          if (value != null) {
            AuctionUser user = value as AuctionUser;
            await AuthService.instance.login();
            Get.context?.go(Routes.home);
            controller.emailController.value.clear();
            controller.passwordController.value.clear();
            initAppData();
            logger.i('authview redirecting to $then');
            Future.delayed(const Duration(milliseconds: 1000), () {
              Toasts.showSuccessNormalToast(
                  'Welcome ${user.firstname ?? ''} to our world');
              if (then != null && then != '') {
                Get.context?.push(then!);
              }
            });
          } else {
            controller.setLoggingIn(false);
          }
        });
      }
    } catch (e) {
      logger.e('login error', tag: 'AuthView', error: e);
    }
  }
}

initAppData() async {
  var homectrl = Get.put(HomeController());
  var bidctrl = Get.put(BidController());
  var transctrl = Get.put(TransactionController());
  var authctrl = Get.put(AuthController());

  ///
  homectrl.getDashboard(false);
  homectrl.getAuctionProductsByType(productType: ProductType.live, page: 1);
  homectrl.getAuctionProductsByType(productType: ProductType.upcoming, page: 1);
  homectrl.getAuctionProductsByType(productType: ProductType.closed, page: 1);
  homectrl.persistentTabController.jumpToTab(0);

  ///
  bidctrl.getBids(pageNo: 1);
  bidctrl.getWinningBids(pageNo: 1);

  ///
  transctrl.getDeposits(pageNo: 1);
  transctrl.getTransactions(pageNo: 1);

  ///
}

class _SignUpPageView extends StatelessWidget {
  _SignUpPageView(this.then, this.referer);
  final _formKey = GlobalKey<FormState>();
  final String? then;
  final String? referer;
  ValueNotifier<bool> agreeToTerms = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
        init: AuthController(),
        builder: (authCtrl) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: spaceDefault * 2),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.zero,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        height30(getHeight(context) * 0.1),
                        displayLarge(
                          'Sign Up',
                          context,
                          style: getTheme(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                  color: getTheme(context).primaryColor,
                                  fontSize: 40),
                        ),
                        height5(),
                        AutoSizeText(
                          'Create an account to continue',
                          style: getTheme(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(),
                          maxLines: 1,
                          minFontSize: 15,
                          maxFontSize: 20,
                        ),
                        height30(),
                      ],
                    ),
                  ),

                  ///referer input
                  if (referer != null && referer!.isNotEmpty)
                    Column(
                      children: [
                        TextFormField(
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          controller: authCtrl.refererController.value,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            fillColor: Colors.grey[200],
                            isDense: false,
                            hintText: 'Referer',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  height10(),

                  ///name
                  TextFormField(
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    controller: authCtrl.nameController.value,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      isDense: false,
                      hintText: 'First Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  height10(),

                  ///username
                  TextFormField(
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                    controller: authCtrl.usernameController.value,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      isDense: false,
                      hintText: 'Enter an unique username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter username';
                      }
                      return null;
                    },
                  ),
                  height10(),

                  ///email
                  TextFormField(
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600),
                    controller: authCtrl.emailController.value,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[200],
                      isDense: false,
                      hintText: 'Email',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter email';
                      } else if (!GetUtils.isEmail(value)) {
                        return 'Please enter valid email';
                      }
                      return null;
                    },
                  ),
                  height10(),

                  ///password
                  CustomPasswordTextField(
                    onPasswordVisible: (v) {},
                    builder: (isVisible, toogle) => TextFormField(
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                      controller: authCtrl.passwordController.value,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !isVisible,
                      decoration: InputDecoration(
                        fillColor: Colors.grey[200],
                        isDense: false,
                        hintText: 'Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                        suffixIcon: IconButton(
                          onPressed: () => toogle(),
                          icon: Icon(isVisible
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  ///agree to terms
                  height10(),
                  ValueListenableBuilder(
                      valueListenable: agreeToTerms,
                      builder: (context, val, _) {
                        return Row(
                          children: [
                            Checkbox(
                                value: val,
                                onChanged: (v) {
                                  primaryFocus?.unfocus();
                                  agreeToTerms.value = v ?? false;
                                }),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree to the ',
                                  style: getTheme().textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Get.toNamed(Routes.terms);
                                        },
                                      style: getTheme()
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(color: kPrimaryColor5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                  Row(
                    children: [
                      ElevatedButton(
                          onPressed: authCtrl.loggingIn.value
                              ? null
                              : () => _register(context, authCtrl),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Sign Up'),
                              if (authCtrl.loggingIn.value)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    width10(),
                                    const CupertinoActivityIndicator(),
                                  ],
                                )
                            ],
                          )),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: bodyLargeText('Forgot Password?', context),
                      ),
                    ],
                  ),
                  height30(),

                  ///footer
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: getTheme().textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Sign in',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              authCtrl.pageController.value.animateToPage(0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.fastOutSlowIn);
                            },
                          style: getTheme()
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: kPrimaryColor5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  _register(BuildContext context, AuthController controller) async {
    try {
      bool proceed = (_formKey.currentState?.validate() ?? false);
      if (proceed) {
        if (!agreeToTerms.value) {
          toast('Please agree to terms and conditions');
          return;
        }
        controller.setLoggingIn(true);
        primaryFocus?.unfocus();
        var socialRegisterModel = SocialRegisterModel(
          email: controller.emailController.value.text,
          password: controller.passwordController.value.text,
          name: controller.nameController.value.text,
          username: controller.usernameController.value.text,
          agreeTerms: agreeToTerms.value ? '1' : '0',
          reference: controller.refererController.value.text,
        );
        controller.register(context, socialRegisterModel).then((value) async {
          controller.setLoggingIn(false);
          if (value != null) {
            AuctionUser user = controller.currentUser!.value as AuctionUser;
            AuthService.instance.login();
            controller.emailController.value.clear();
            controller.passwordController.value.clear();
            controller.nameController.value.clear();
            controller.usernameController.value.clear();
            controller.refererController.value.clear();
            Get.context?.go(Routes.home);
            initAppData();
            Future.delayed(const Duration(milliseconds: 500), () {
              successSnack(
                message: 'Welcome ${user.firstname ?? ''} to our world',
                context: context,
                title: 'You are now registered',
              );
              if (then != null) {
                context.push(then!);
              }
            });
          }
        });
      }
    } catch (e) {
      logger.e('login error', tag: 'AuthView', error: e);
    }
  }
}

class MyClipper1 extends CustomClipper<Path> {
  const MyClipper1();
  @override
  Path getClip(Size size) {
    final path = Path();
    double w = size.width * (size.width > size.height ? 0.8 : 1);

    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(w * 0.2, size.height, w * 0.4, size.height * 0.8);
    path.quadraticBezierTo(
        w * 0.6, size.height * 0.6, w * 0.55, size.height * 0.4);
    path.quadraticBezierTo(w * 0.5, size.height * 0.2, w * 0.3, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(MyClipper1 oldClipper) => true;
}

@immutable
class ClipShadowPath extends StatelessWidget {
  final Shadow? shadow;
  final CustomClipper<Path> clipper;
  final Widget child;

  const ClipShadowPath({
    super.key,
    this.shadow,
    required this.clipper,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClipShadowShadowPainter(
        clipper: clipper,
        shadow: shadow,
      ),
      child: ClipPath(clipper: clipper, child: child),
    );
  }
}

class _ClipShadowShadowPainter extends CustomPainter {
  final Shadow? shadow;
  final CustomClipper<Path> clipper;

  _ClipShadowShadowPainter({this.shadow, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = shadow?.toPaint() ?? Paint();
    var clipPath = clipper.getClip(size);
    if (shadow != null) clipPath = clipPath.shift(shadow!.offset);
    canvas.drawPath(clipPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/*
  ///[old login ui ] testin purpose
  ListView _listview() {
    return ListView(
      // mainAxisAlignment: MainAxisAlignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const Center(
          child: Text(
            'Login',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Ender email and password to login',
            style: TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                TextField(
                  controller: controller.emailController.value,
                  decoration: const InputDecoration(
                    isDense: false,
                    hintText: 'Email',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller.passwordController.value,
                  decoration: const InputDecoration(
                    isDense: false,
                    hintText: 'Password',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        _SaveduserdropDown(onChanged: (AppUser? user) => _login(null, user)),

        //login button
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => _login(
              SocialLoginModel(
                  email: controller.emailController.value.text,
                  password: controller.passwordController.value.text),
              null),
          child: const Text('Login'),
        ),
      ],
    );
  }
*/

