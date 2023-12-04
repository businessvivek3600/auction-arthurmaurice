import 'dart:io';

import 'package:action_tds/app/modules/auth/providers/user_provider.dart';
import 'package:action_tds/app/modules/auth/user_model.dart';
import 'package:action_tds/components/global_utils.dart';
import 'package:action_tds/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:get/get.dart';
import 'package:get_cli/extensions.dart';

import '../auth/controllers/auth_controller.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool updating = false;

  Map<String, dynamic> data = {
    'firstname': '',
    'lastname': '',
    'email': '',
    'mobile': '',
    'address': '',
    'zip': '',
    'country': '',
    'state': '',
    'city': '',
  };

  Future<void> initFields() async {
    var auth = Get.put(AuthController());
    AuctionUser? user;
    await (await UserProvider.instance)
        .getUser()
        .then((value) => user = auth.getUser<AuctionUser>());

    final userData = user?.toJson();
    print('update profile user data $userData');
    if (userData != null) {
      data['firstname'] = (userData['firstname'] ?? '');
      data['lastname'] = (userData['lastname'] ?? '');
      data['email'] = (userData['email'] ?? '');
      data['mobile'] = (userData['mobile'] ?? '');
      data['address'] = (userData['address']['address'] ?? '');
      data['zip'] = (userData['address']['zip'] ?? '');
      data['country'] = (userData['address']['country'] ?? '');
      data['state'] = (userData['address']['state'] ?? '');
      data['city'] = (userData['address']['city'] ?? '');
      _firstNameController.text = data['firstname'];
      _lastNameController.text = data['lastname'];
      _emailController.text = data['email'];
      _phoneNumberController.text = data['mobile'];
      _addressController.text = data['address'];
      _zipCodeController.text = data['zip'];
      setState(() => _isLoading = false);
      print('update profile data $data ${data['country']}');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Colors.transparent,
          // shadowColor: Colors.transparent,
          title: AutoSizeText(
            'Update Profile',
            minFontSize:
                (getTheme(context).textTheme.displayLarge?.fontSize ?? 20),
            maxFontSize: 40,
          ),
          centerTitle: false,
        ),
        body: Stack(
          children: [
            globalContainer(
                child: ListView(
              padding: EdgeInsets.all(paddingDefault),
              children: [
                buildForm(context),
                if (!_isLoading)
                  MyHomePage(
                    onChange: (value) {
                      for (var element in data.entries) {
                        if (data.containsKey(element.key)) {
                          data[element.key] = value[element.key];
                        } else {
                          data.addEntries(
                              [MapEntry(element.key, value[element.key])]);
                        }
                      }
                    },
                    looading: _isLoading,
                    countryValue: data['country'] ?? '',
                    stateValue: data['state'] ?? '',
                    cityValue: data['city'] ?? '',
                  ),
                height10(),

                ///address
                TextFormField(
                  style: _getTextStyle(context),
                  controller: _addressController,
                  keyboardType: TextInputType.streetAddress,
                  textInputAction: TextInputAction.newline,
                  maxLines: 3,
                  decoration: InputDecoration(
                    filled: false,
                    isDense: false,
                    labelText: 'Address',
                    hintText: 'Enter your address',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Column(
                      children: [
                        Icon(Platform.isIOS
                            ? CupertinoIcons.location
                            : Icons.location_on),
                      ],
                    ),
                  ),
                ),
              ],
            )),

            ///hover
            if (updating)
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: getTheme(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),

        ///bottom navigation bar
        bottomNavigationBar: bottomNavBar(context, _isLoading, updating),
      ),
    );
  }

  Widget bottomNavBar(BuildContext context, bool isLoading, bool updating) {
    ///update button
    return Container(
      height: kBottomNavigationBarHeight,
      margin: EdgeInsets.all(paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            icon: const AutoSizeText(
              'Update',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            label: updating
                ? const CupertinoActivityIndicator()
                : const SizedBox(),
          ),
        ],
      ),
    );
  }

  final TextEditingController _firstNameController = TextEditingController();

  final TextEditingController _lastNameController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _phoneNumberController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _zipCodeController = TextEditingController();

  String? firstNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }
    return null;
  }

  String? lastNameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your last name';
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    } else if (GetUtils.isEmail(value) == false) {
      return 'Please enter valid email';
    }
    return null;
  }

  String? phoneNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    return null;
  }

  String? zipCodeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your zip code';
    }
    return null;
  }

  Widget buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ///first name
          TextFormField(
            style: _getTextStyle(context),
            controller: _firstNameController,
            keyboardType: TextInputType.name,
            validator: firstNameValidator,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              filled: false,
              isDense: false,
              labelText: 'First Name',
              hintText: 'Enter your first name',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.person),
            ),
          ),
          height10(),

          ///last name
          TextFormField(
            style: _getTextStyle(context),
            controller: _lastNameController,
            keyboardType: TextInputType.name,
            validator: lastNameValidator,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              filled: false,
              isDense: false,
              labelText: 'Last Name',
              hintText: 'Enter your last name',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.person_2),
            ),
          ),
          height10(),

          ///email
          TextFormField(
            style: _getTextStyle(context),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: emailValidator,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              filled: false,
              isDense: false,
              labelText: 'Email',
              hintText: 'Enter your email',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(
                  Platform.isIOS ? CupertinoIcons.mail : Icons.email_rounded),
            ),
          ),

          height10(),

          ///phone number
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: _getTextStyle(context),
                  controller: _phoneNumberController,
                  validator: phoneNumberValidator,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    NoDoubleDecimalFormatter(),
                  ],
                  maxLength: 10,
                  decoration: InputDecoration(
                    counterText: '',
                    filled: false,
                    isDense: false,
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Platform.isIOS
                        ? CupertinoIcons.phone
                        : Icons.phone_rounded),
                  ),
                ),
              ),
            ],
          ),
          height10(),
/*
          height10(),
          ///city
          TextFormField(
            style: _getTextStyle(context),
            controller: _cityController,
            keyboardType: TextInputType.streetAddress,
            validator: addressValidator,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              filled: false,
              isDense: false,
              labelText: 'City',
              hintText: 'Enter your city',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(Platform.isIOS
                  ? CupertinoIcons.home
                  : Icons.location_city_rounded),
            ),
          ),
          height10(),
          ///state
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: _getTextStyle(context),
                  controller: _stateController,
                  keyboardType: TextInputType.streetAddress,
                  validator: addressValidator,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    filled: false,
                    isDense: false,
                    labelText: 'State',
                    hintText: 'Enter your state',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Platform.isIOS
                        ? CupertinoIcons.home
                        : Icons.location_city_rounded),
                  ),
                ),
              ),

              width20(),

              ///zip code

              Expanded(
                child: 
                
            ],
          ),

*/
          TextFormField(
            style: _getTextStyle(context),
            controller: _zipCodeController,
            keyboardType: TextInputType.streetAddress,
            validator: zipCodeValidator,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              filled: false,
              isDense: false,
              labelText: 'Zip Code',
              hintText: 'Enter your zip code',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: Icon(Platform.isIOS
                  ? CupertinoIcons.pencil_ellipsis_rectangle
                  : Icons.pin_rounded),
            ),
          ),
          height10(),
        ],
      ),
    );
  }

  _getTextStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).textTheme.titleLarge?.color,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      ///submit
      _formKey.currentState?.save();
      data['firstname'] = _firstNameController.text;
      data['lastname'] = _lastNameController.text;
      data['email'] = _emailController.text;
      data['mobile'] = _phoneNumberController.text;
      data['address'] = _addressController.text.removeAll('\n');
      data['zip'] = _zipCodeController.text;
      logger.i(data);
      setState(() {
        updating = true;
      });
      await (await UserProvider.instance).updateUser(data).then((value) {
        setState(() {
          updating = false;
        });
        if (value.$1 != null) {
          Get.back();
          1.delay(() => successSnack(
              title: 'Success',
              message: value.$2,
              context: Get.context!,
              backgroundColor: const Color.fromRGBO(76, 175, 80, 1)));
        }
      }).catchError((e) {
        setState(() {
          updating = false;
        });
        logger.e('update profile error', tag: 'Update Profile page', error: e);
      });

      return;
    }
    logger.i('form is not valid');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
    required this.onChange,
    required this.looading,
    required this.countryValue,
    required this.stateValue,
    required this.cityValue,
  }) : super(key: key);
  final Function(Map<String, dynamic> data) onChange;
  final bool looading;
  final String countryValue;
  final String stateValue;
  final String cityValue;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CountryFlag _flagState = CountryFlag.ENABLE;
  String countryValue = '';
  String stateValue = '';
  String cityValue = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        countryValue = widget.countryValue;
        stateValue = widget.stateValue;
        cityValue = widget.cityValue;
      });
      print('country value $countryValue $stateValue $cityValue');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.looading)
          CSCPicker(
            showStates: true,
            showCities: true,
            flagState: _flagState,
            layout: Layout.horizontal,
            dropdownDecoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            disabledDropdownDecoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.grey.withOpacity(0.2),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            countrySearchPlaceholder: "Country",
            stateSearchPlaceholder: "State",
            citySearchPlaceholder: "City",
            countryDropdownLabel: "Country",
            stateDropdownLabel: "State",
            cityDropdownLabel: "City",
            currentCity: widget.cityValue,
            currentCountry: widget.countryValue,
            currentState: widget.stateValue,
            countryFilter: [
              ...CscCountry.values.map((e) => e).toList(),
            ],
            selectedItemStyle: TextStyle(
                color: getTheme(context).textTheme.titleLarge?.color,
                fontSize: 14),
            dropdownHeadingStyle: TextStyle(
                color: getTheme(context).textTheme.titleLarge?.color,
                fontSize: 17,
                fontWeight: FontWeight.bold),
            dropdownItemStyle: TextStyle(
                color: getTheme(context).textTheme.titleLarge?.color,
                fontSize: 14),
            dropdownDialogRadius: paddingDefault,
            searchBarRadius: 10.0,
            onCountryChanged: (value) {
              setState(() {
                countryValue = value;
                onChanged();
              });
            },
            onStateChanged: (value) {
              setState(() {
                stateValue = value ?? '';
                onChanged();
              });
            },
            onCityChanged: (value) {
              setState(() {
                cityValue = value ?? "";
                onChanged();
              });
            },
          ),
      ],
    );
  }

  void onChanged() {
    widget.onChange({
      'country': countryValue.substring(6).trim(),
      'state': stateValue,
      'city': cityValue,
    });
  }
}
