import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:at_location_flutter/location_modal/location_notification.dart';
import 'package:at_location_flutter/service/home_screen_service.dart';
import 'package:at_location_flutter/service/key_stream_service.dart';
import 'package:at_location_flutter/service/request_location_service.dart';
import 'package:at_location_flutter/service/send_location_notification.dart';
import 'package:at_location_flutter/service/sharing_location_service.dart';
import 'package:at_location_flutter/utils/constants/colors.dart';
import 'package:at_location_flutter/utils/constants/text_styles.dart';
import 'package:flutter/material.dart';

import 'custom_toast.dart';
import 'display_tile.dart';
import 'draggable_symbol.dart';
import 'loading_widget.dart';

class CollapsedContent extends StatefulWidget {
  bool expanded;
  LocationNotificationModel userListenerKeyword;
  AtClientImpl atClientInstance;
  String currentAtSign;
  CollapsedContent(this.expanded, this.atClientInstance,
      {this.userListenerKeyword, @required this.currentAtSign});
  @override
  _CollapsedContentState createState() => _CollapsedContentState();
}

class _CollapsedContentState extends State<CollapsedContent> {
  bool isCreator, isSharing;
  @override
  void initState() {
    super.initState();
    isSharing = widget.userListenerKeyword.isSharing;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: widget.expanded ? 431 : 205,
        padding: EdgeInsets.fromLTRB(15, 3, 15, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
          color: Theme.of(context).brightness == Brightness.light
              ? AllColors().WHITE
              : AllColors().Black,
          boxShadow: [
            BoxShadow(
              color: AllColors().DARK_GREY,
              blurRadius: 10.0,
              spreadRadius: 1.0,
              offset: Offset(0.0, 0.0),
            )
          ],
        ),
        child: (forUser(widget.expanded, context)));
  }

  Widget forUser(bool expanded, BuildContext context) {
    bool amICreator =
        widget.userListenerKeyword.atsignCreator == widget.currentAtSign;
    DateTime to = widget.userListenerKeyword.to;
    String time;
    if (to != null)
      time =
          'until ${timeOfDayToString(TimeOfDay.fromDateTime(widget.userListenerKeyword.to))} today';
    else
      time = '';

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          amICreator
              ? DraggableSymbol()
              : SizedBox(
                  height: 10,
                ),
          SizedBox(
            height: 3,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DisplayTile(
                        title: amICreator
                            ? '${widget.userListenerKeyword.receiver}'
                            : '${widget.userListenerKeyword.atsignCreator}',
                        atsignCreator: amICreator
                            ? '${widget.userListenerKeyword.receiver}'
                            : '${widget.userListenerKeyword.atsignCreator}',
                        subTitle: amICreator
                            ? '${widget.userListenerKeyword.receiver}'
                            : '${widget.userListenerKeyword.atsignCreator}'),
                    Text(
                      amICreator
                          ? 'This user does not share their location'
                          : '',
                      style: CustomTextStyles().grey12,
                    ),
                    Text(
                      amICreator
                          ? 'Sharing my location $time'
                          : 'Sharing their location $time',
                      style: CustomTextStyles().black12,
                    )
                  ],
                ),
              ),
              Transform.rotate(
                angle: 5.8,
                child: Container(
                  alignment: Alignment.center,
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: AllColors().ORANGE,
                  ),
                  child: Icon(
                    Icons.send_outlined,
                    color: AllColors().WHITE,
                    size: 25,
                  ),
                ),
              )
            ],
          ),
          expanded
              ? Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Divider(),
                      amICreator
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Share my Location',
                                  style: CustomTextStyles().darkGrey16,
                                ),
                                Switch(
                                    value: isSharing,
                                    onChanged: (value) async {
                                      LoadingDialog().show();
                                      try {
                                        var result;
                                        if (widget.userListenerKeyword.key
                                            .contains("sharelocation")) {
                                          result = await SharingLocationService()
                                              .updateWithShareLocationAcknowledge(
                                                  widget.userListenerKeyword,
                                                  isSharing: value);
                                        } else if (widget
                                            .userListenerKeyword.key
                                            .contains("requestlocation")) {
                                          result = await RequestLocationService()
                                              .requestLocationAcknowledgment(
                                                  widget.userListenerKeyword,
                                                  true,
                                                  isSharing: value);
                                        }
                                        if (result) {
                                          if (!value) {
                                            SendLocationNotification().sendNull(
                                                widget.userListenerKeyword);
                                          }
                                          setState(() {
                                            isSharing = value;
                                          });
                                        } else {
                                          CustomToast().show(
                                              'Something went wrong, try again.',
                                              context);
                                        }
                                        LoadingDialog().hide();
                                      } catch (e) {
                                        print(e);
                                        CustomToast().show(
                                            'something went wrong , please try again.',
                                            context);
                                        LoadingDialog().hide();
                                      }
                                    })
                              ],
                            )
                          : SizedBox(),
                      amICreator ? Divider() : SizedBox(),
                      amICreator
                          ? Expanded(
                              child: InkWell(
                                onTap: () async {
                                  try {
                                    var result = await RequestLocationService()
                                        .sendRequestLocationEvent(widget
                                            .userListenerKeyword.receiver);
                                    if (result == true) {
                                      CustomToast().show(
                                          'Request Location sent', context);
                                    } else {
                                      CustomToast().show(
                                          'Something went wrong, try again.',
                                          context);
                                    }
                                  } catch (e) {
                                    print(e);
                                    CustomToast().show(
                                        'Something went wrong, try again.',
                                        context);
                                  }
                                },
                                child: Text(
                                  'Request Location',
                                  style: CustomTextStyles().darkGrey16,
                                ),
                              ),
                            )
                          : SizedBox(),
                      ((amICreator) &&
                              (widget.userListenerKeyword.key
                                  .contains("sharelocation")))
                          ? Divider()
                          : SizedBox(),
                      ((amICreator) &&
                              (widget.userListenerKeyword.key
                                  .contains("sharelocation")))
                          ? Expanded(
                              child: InkWell(
                                onTap: () async {
                                  LoadingDialog().show();
                                  try {
                                    var result;
                                    if (widget.userListenerKeyword.key
                                        .contains("sharelocation")) {
                                      result = await SharingLocationService()
                                          .deleteKey(
                                              widget.userListenerKeyword);
                                    } else if (widget.userListenerKeyword.key
                                        .contains("requestlocation")) {
                                      // result = await RequestLocationService()
                                      //     .removePerson(
                                      //         widget.userListenerKeyword);
                                      result = false; // TODO: Remove this
                                    }
                                    if (result) {
                                      SendLocationNotification()
                                          .sendNull(widget.userListenerKeyword);
                                      LoadingDialog().hide();

                                      Navigator.pop(context);
                                    } else {
                                      LoadingDialog().hide();

                                      CustomToast().show(
                                          'Something went wrong, try again.',
                                          context);
                                    }
                                  } catch (e) {
                                    print(e);
                                    CustomToast().show(
                                        'something went wrong , please try again.',
                                        context);
                                    LoadingDialog().hide();
                                  }
                                },
                                child: Text(
                                  'Remove Person',
                                  style: CustomTextStyles().orange16,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                )
              : SizedBox(
                  height: 2,
                )
        ]);
  }

  Widget participants(Function() onTap) {
    return Padding(
      padding: EdgeInsets.only(left: 56),
      child: InkWell(
        onTap: onTap,
        child: Text(
          'See Participants',
          style: CustomTextStyles().orange14,
        ),
      ),
    );
  }
}