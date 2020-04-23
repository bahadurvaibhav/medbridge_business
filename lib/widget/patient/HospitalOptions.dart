import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:medbridge_business/domain/HospitalOption.dart';
import 'package:medbridge_business/gateway/IdNameResponse.dart';
import 'package:medbridge_business/util/Colors.dart';
import 'package:medbridge_business/util/style.dart';
import 'package:medbridge_business/util/validate.dart';

class HospitalOptions extends StatefulWidget {
  final String patientId;
  final List<IdNameResponse> hospitals;
  final List<IdNameResponse> treatments;
  final bool editable;
  final bool selectable;
  final List<HospitalOption> hospitalOptions;

  HospitalOptions({
    Key key,
    @required this.patientId,
    @required this.hospitals,
    @required this.treatments,
    @required this.editable,
    @required this.selectable,
    @required this.hospitalOptions,
  }) : super(key: key);

  @override
  HospitalOptionsState createState() => HospitalOptionsState();
}

class HospitalOptionsState extends State<HospitalOptions> {
  final _hospitalOptionsFormKey = GlobalKey<FormState>();
  TextEditingController hospitalTypeAheadController =
      new TextEditingController();
  FocusNode hospitalTypeAheadFocus = FocusNode();
  TextEditingController treatmentTypeAheadController =
      new TextEditingController();
  FocusNode treatmentTypeAheadFocus = FocusNode();
  List<HospitalOption> hospitalOptions = new List();
  TextEditingController costController = new TextEditingController();
  FocusNode costFocus = FocusNode();
  TextEditingController hospitalStayDurationController =
      new TextEditingController();
  FocusNode hospitalStayDurationFocus = FocusNode();
  TextEditingController completeStayDurationController =
      new TextEditingController();
  FocusNode completeStayDurationFocus = FocusNode();
  TextEditingController travelAssistCommentsController =
      new TextEditingController();
  FocusNode travelAssistCommentsFocus = FocusNode();
  TextEditingController accommodationAssistCommentsController =
      new TextEditingController();
  FocusNode accommodationAssistCommentsFocus = FocusNode();
  TextEditingController notesController = new TextEditingController();
  FocusNode notesFocus = FocusNode();
  String preferredHospitalId = "";

  int currentIndex;
  final SwiperController swiperController = SwiperController();
  bool optionSelected = false;

  @override
  void initState() {
    currentIndex = 0;
    optionSelected = !widget.editable && !widget.selectable;
    hospitalOptions = widget.hospitalOptions;
    super.initState();
  }

  List<HospitalOption> getHospitalOptions() {
    return hospitalOptions;
  }

  @override
  void dispose() {
    hospitalTypeAheadController.dispose();
    hospitalTypeAheadFocus.dispose();
    costController.dispose();
    costFocus.dispose();
    treatmentTypeAheadController.dispose();
    treatmentTypeAheadFocus.dispose();
    hospitalStayDurationController.dispose();
    hospitalStayDurationFocus.dispose();
    completeStayDurationController.dispose();
    completeStayDurationFocus.dispose();
    travelAssistCommentsController.dispose();
    travelAssistCommentsFocus.dispose();
    accommodationAssistCommentsController.dispose();
    accommodationAssistCommentsFocus.dispose();
    notesController.dispose();
    notesFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String heading = 'HOSPITAL OPTIONS:';
    if (optionSelected) {
      heading = 'SELECTED TREATMENT:';
    }
    Widget title = Text(
      heading,
      style: addPatientHeadingStyle(),
    );

    if (widget.editable) {
      return Form(
        key: _hospitalOptionsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            title,
            SizedBox(
              height: 20,
            ),
            selectHospitals('Hospital name*'),
            selectTreatments('Treatment name*'),
            Row(
              children: <Widget>[
                Expanded(
                  child: TextFormField(
                    controller: hospitalStayDurationController,
                    focusNode: hospitalStayDurationFocus,
                    validator: validateName,
                    decoration: InputDecoration(
                      hintText: 'Duration of Hospital Stay*',
                    ),
                    onFieldSubmitted: (term) {
                      hospitalStayDurationFocus.unfocus();
                      FocusScope.of(context)
                          .requestFocus(completeStayDurationFocus);
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: TextFormField(
                    controller: completeStayDurationController,
                    focusNode: completeStayDurationFocus,
                    validator: validateName,
                    decoration: InputDecoration(
                      hintText: 'Duration of complete Stay*',
                    ),
                    onFieldSubmitted: (term) {
                      completeStayDurationFocus.unfocus();
                      FocusScope.of(context).requestFocus(costFocus);
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: costController,
              focusNode: costFocus,
              validator: validateName,
              decoration: InputDecoration(
                hintText: 'Cost*',
              ),
              onFieldSubmitted: (term) {
                costFocus.unfocus();
                FocusScope.of(context).requestFocus(travelAssistCommentsFocus);
              },
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: travelAssistCommentsController,
              focusNode: travelAssistCommentsFocus,
              validator: validateName,
              decoration: InputDecoration(
                hintText: 'Travel Assistance Comments*',
              ),
              onFieldSubmitted: (term) {
                travelAssistCommentsFocus.unfocus();
                FocusScope.of(context)
                    .requestFocus(accommodationAssistCommentsFocus);
              },
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: accommodationAssistCommentsController,
              focusNode: accommodationAssistCommentsFocus,
              validator: validateName,
              decoration: InputDecoration(
                hintText: 'Accommodation Assistance Comments*',
              ),
              onFieldSubmitted: (term) {
                accommodationAssistCommentsFocus.unfocus();
                FocusScope.of(context).requestFocus(notesFocus);
              },
              textInputAction: TextInputAction.next,
            ),
            TextFormField(
              controller: notesController,
              focusNode: notesFocus,
              decoration: InputDecoration(
                hintText: 'Notes',
              ),
            ),
            SizedBox(
              height: 20,
            ),
            RaisedButton.icon(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.0),
              ),
              color: primary,
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              label: Text(
                "Add Hospital Option",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: addHospitalOption,
            ),
            SizedBox(
              height: 20,
            ),
            getSwiper(),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          title,
          SizedBox(
            height: 15,
          ),
          getSwiper(),
        ],
      );
    }
  }

  String preferredHospitalOptionId = "-1";

  Widget getSelectButton(HospitalOption option) {
    return Row(
      children: <Widget>[
        Radio(
          value: option.id,
          groupValue: preferredHospitalOptionId,
          onChanged: (value) {
            setState(() {
              preferredHospitalOptionId = value;
            });
          },
        ),
        Text('Select option for treatment'),
      ],
    );
  }

  Widget getDeleteButton(index) {
    return IconButton(
      icon: Icon(
        Icons.delete,
        color: Colors.grey,
      ),
      onPressed: () => deleteHospitalOption(index),
    );
  }

  Widget getSwiper() {
    var screenWidth = MediaQuery.of(context).size.width;
    double height = 480.0;
    SwiperPagination pagination = SwiperPagination(
      builder: DotSwiperPaginationBuilder(
        activeColor: primary,
        color: primary,
        size: 5.0,
        activeSize: 12.0,
      ),
    );
    if (optionSelected) {
      height = 420.0;
      pagination = SwiperPagination(
        builder: DotSwiperPaginationBuilder(
          activeColor: primary,
          color: primary,
          size: 0.0,
          activeSize: 0.0,
        ),
      );
    }
    return ConstrainedBox(
      constraints: new BoxConstraints.loose(new Size(screenWidth, height)),
      child: Swiper(
        controller: swiperController,
        itemCount: hospitalOptions.length,
        autoplay: false,
        index: currentIndex,
        onIndexChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) => showHospitalOptionCard(index),
        pagination: pagination,
        loop: false,
        autoplayDisableOnInteraction: true,
      ),
    );
  }

  Widget getListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hospitalOptions.length,
      itemBuilder: (BuildContext ctxt, int index) {
        return showHospitalOptionCard(index);
      },
    );
  }

  Widget showHospitalOptionCard(int index) {
    HospitalOption option = hospitalOptions[index];
    Widget actionButton = SizedBox();
    if (widget.editable) {
      actionButton = Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          getDeleteButton(index),
        ],
      );
    } else if (widget.selectable) {
      actionButton = getSelectButton(option);
    }
    double spacingHeight = 10;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              actionButton,
              showTitleValue('Hospital Name', option.hospitalName),
              SizedBox(height: spacingHeight),
              showTitleValue('Treatment Name', option.treatmentName),
              SizedBox(height: spacingHeight),
              showTitleValue(
                  'Duration of Hospital Stay', option.hospitalStayDuration),
              SizedBox(height: spacingHeight),
              showTitleValue(
                  'Duration of complete Stay', option.completeStayDuration),
              SizedBox(height: spacingHeight),
              showTitleValue('Cost', option.cost),
              SizedBox(height: spacingHeight),
              showTitleValue(
                  'Travel Assistance Comments', option.travelAssistNotes),
              SizedBox(height: spacingHeight),
              showTitleValue('Accommodation Assistance Comments',
                  option.accommodationAssistNotes),
              SizedBox(height: spacingHeight),
              showTitleValue('Notes', option.notes),
              SizedBox(height: spacingHeight),
            ],
          ),
        ),
      ),
    );
  }

  showTitleValue(String title, String value) {
    if (value == null) {
      value = "";
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: goldenStyle(),
        ),
        Wrap(
          children: <Widget>[
            Text(
              value,
            ),
          ],
        ),
      ],
    );
  }

  deleteHospitalOption(index) {
    hospitalOptions.removeAt(index);
    setState(() {});
  }

  addHospitalOption() {
    print('addHospitalOption()');
    String hospitalName = hospitalTypeAheadController.text;
    String treatmentName = treatmentTypeAheadController.text;
    if (!_hospitalOptionsFormKey.currentState.validate()) {
      print('Hospital Option Form invalid');
    } else {
      print('Hospital Option Form valid');
      hospitalOptions.add(
        new HospitalOption(
          "",
          preferredHospitalId,
          hospitalName,
          treatmentName,
          hospitalStayDurationController.text,
          completeStayDurationController.text,
          costController.text,
          travelAssistCommentsController.text,
          accommodationAssistCommentsController.text,
          notesController.text,
        ),
      );
      hospitalTypeAheadController.text = "";
      treatmentTypeAheadController.text = "";
      hospitalStayDurationController.text = "";
      completeStayDurationController.text = "";
      costController.text = "";
      travelAssistCommentsController.text = "";
      accommodationAssistCommentsController.text = "";
      notesController.text = "";
      setState(() {});
    }
  }

  Widget selectTreatments(String hintText) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: treatmentTypeAheadController,
        textInputAction: TextInputAction.next,
        focusNode: treatmentTypeAheadFocus,
        style: TextStyle(color: Colors.blue),
        decoration: InputDecoration(hintText: hintText),
        onSubmitted: (term) {
          treatmentTypeAheadFocus.unfocus();
          FocusScope.of(context).requestFocus(hospitalStayDurationFocus);
        },
      ),
      validator: validateName,
      suggestionsCallback: (pattern) {
        List<IdNameResponse> filteredTreatments = new List();
        widget.treatments.forEach((treatment) {
          if (treatment.name.contains(pattern)) {
            filteredTreatments.add(treatment);
          }
        });
        return filteredTreatments;
      },
      itemBuilder: (context, IdNameResponse suggestion) {
        return ListTile(
          title: Text(suggestion.name),
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (IdNameResponse suggestion) {
        treatmentTypeAheadController.text = suggestion.name;
      },
    );
  }

  Widget selectHospitals(String hintText) {
    return TypeAheadFormField(
      textFieldConfiguration: TextFieldConfiguration(
        controller: hospitalTypeAheadController,
        textInputAction: TextInputAction.next,
        focusNode: hospitalTypeAheadFocus,
        style: TextStyle(color: Colors.blue),
        decoration: InputDecoration(hintText: hintText),
        onSubmitted: (term) {
          hospitalTypeAheadFocus.unfocus();
          FocusScope.of(context).requestFocus(treatmentTypeAheadFocus);
        },
      ),
      validator: validateName,
      suggestionsCallback: (pattern) {
        List<IdNameResponse> filteredHospitals = new List();
        widget.hospitals.forEach((hospital) {
          if (hospital.name.contains(pattern)) {
            filteredHospitals.add(hospital);
          }
        });
        return filteredHospitals;
      },
      itemBuilder: (context, IdNameResponse suggestion) {
        return ListTile(
          title: Text(suggestion.name),
        );
      },
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      onSuggestionSelected: (IdNameResponse suggestion) {
        hospitalTypeAheadController.text = suggestion.name;
        preferredHospitalId = suggestion.id;
      },
    );
  }
}
