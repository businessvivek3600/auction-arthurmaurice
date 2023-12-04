import 'package:action_tds/app_popup_window/pop_up_window.dart';
import 'package:flutter/material.dart';

class PopUpWidget extends StatelessWidget {
  PopUpWidget({super.key});
  GlobalKey btnKey = GlobalKey();
  KumiPopupWindow? popupWindow;

  ValueNotifier<bool> isSelect = ValueNotifier(false);
  var aaa = "false";
  @override
  Widget build(BuildContext context) {
    return MaterialButton(
        key: btnKey,
        height: 50,
        color: Colors.redAccent,
        onPressed: () {
          /*showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context1, StateSetter setBottomSheetState) {
                            return SingleChildScrollView(
                              child: Container(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setBottomSheetState(() {
                                        aaa = "true";
                                      });
                                      },
                                      child: Text("asdasdasd"),
                                    ),
                                    TextField(
                                      controller: TextEditingController(text: aaa),
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [WhitelistingTextInputFormatter.digitsOnly], //只允许输入数字
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      });*/
          showPopupWindow(
            context,
            //childSize:Size(240, 800),
            gravity: KumiPopupGravity.centerBottom,
            //curve: Curves.elasticOut,
            bgColor: Colors.grey.withOpacity(0.5),
            clickOutDismiss: true,
            clickBackDismiss: true,
            customAnimation: false,
            customPop: false,
            customPage: false,
            // targetRenderBox: (btnKey.currentContext.findRenderObject() as RenderBox),
            //needSafeDisplay: true,
            underStatusBar: false,
            underAppBar: false,
            //offsetX: -180,
            //offsetY: 50,
            duration: const Duration(milliseconds: 300),
            onShowStart: (pop) {
              print("showStart");
            },
            onShowFinish: (pop) {
              print("showFinish");
            },
            onDismissStart: (pop) {
              print("dismissStart");
            },
            onDismissFinish: (pop) {
              print("dismissFinish");
            },
            onClickOut: (pop) {
              print("onClickOut");
            },
            onClickBack: (pop) {
              print("onClickBack");
            },
            childFun: (pop) {
              return StatefulBuilder(
                  key: GlobalKey(),
                  builder: (popContext, popState) {
                    return GestureDetector(
                      onTap: () {
                        //isSelect.value = !isSelect.value;
                        popState(() {
                          aaa = "sasdasd";
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        height: 800,
                        width: 300,
                        color: Colors.redAccent,
                        alignment: Alignment.center,
                        child: Text(aaa),
                      ),
                    );
                  });
            },
          );
        },
        child: const Text("popup"));
  }
}
