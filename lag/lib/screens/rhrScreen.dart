import 'package:flutter/material.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/personal_info.dart';
import 'package:lag/utils/barplotHR.dart';
//import 'package:lag/utils/barplot.dart';
import 'package:dropdown_button2/dropdown_button2.dart';


// CHIEDI COME AGGIUSTARE IN BASE ALLA GRANDEZZA DELLO SCHERMO
class RhrScreen extends StatefulWidget {
  final HomeProvider provider;

  const RhrScreen({super.key, required this.provider});

  @override
  _RhrScreenState createState() => _RhrScreenState();
}

class _RhrScreenState extends State<RhrScreen>{
  bool _isAvgRhrCardExpanded = false;
  bool _isRhrCalculatorExpanded = false;

  final List<String> items = [
    'Light',
    'Moderate',
    'Hard',
    'Very hard',
  ];

  Map<String, List<int>> mappedItems = {
    'Light': [20, 39],
    'Moderate': [40, 59],
    'Hard': [60, 84],
    'Very hard': [85, 100],
  };

  String? selectedValue = null;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(/*
        title: const Row(
          children: [
            //Icon(Icons.favorite),
            SizedBox(width: 10),
            Text('Resting heart rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          ],
        ),*/
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();},
          ),
        backgroundColor: const Color.fromARGB(255, 227, 211, 244), 
        ),
      
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.only(left: 12.0, right: 12.0, top: 10, bottom: 20),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Resting heart rate", style: TextStyle(fontSize: 24, color: Colors.black)),
                  //Text('About last 6 months', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 5),
                  (widget.provider.monthlyHeartRateData.isEmpty) 
                  ? CircularProgressIndicator()
                  : SizedBox(
                    height: 230,
                    width: 330,
                    child: BarChartSample7(data: widget.provider.monthlyHeartRateData, date: widget.provider.yesterday),
                  ),
                  const SizedBox(height: 20),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Card(
                      color: Color.fromARGB(255, 247, 245, 248),
                      elevation: 5,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isAvgRhrCardExpanded = ! _isAvgRhrCardExpanded;
                          });
                        },
                        child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.monitor_heart),
                                trailing: SizedBox(
                                  width: 10,
                                  child: ((widget.provider.monthlyHeartRateData.last.value > 80.0) | (widget.provider.monthlyHeartRateData.last.value < 55.0)) ? Icon(Icons.thumb_down) : Icon(Icons.thumb_up),
                                ),
                                title: (widget.provider.monthlyHeartRateData.isEmpty) ? 
                                  const CircularProgressIndicator.adaptive() : 
                                  Text("Average of current month: ${widget.provider.monthlyHeartRateData.last.value} bpm", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: !_isAvgRhrCardExpanded
                                    ? const Text('Tap to learn more', style: TextStyle(fontSize: 15.0))
                                    : null,
                              ),
                              if (_isAvgRhrCardExpanded)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Your resting heart rate should be between 55 and 80 bpm. A resting heart rate between 81 and 90 doubles the risk of premature death. If greater than 90, the risk is three times higher. ", style: TextStyle(fontSize: 14.0)),
                                      // fonte https://heart.bmj.com/content/99/12/882.full?sid=90e3623c-1250-4b94-928c-0a8f95c5b36b
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ),
                    ),
                  ),
                  // gestisci caso in cui <55, dovrebbe mostrare un alert dialog dicendo tipo "maybe you're an athlete... If not, contact your doctor!"
                  // se l'utente schiaccia su I'm an athlete, questo viene ricordato (sp) e non gli viene più mostrato questo alert

                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Card(
                      color: Color.fromARGB(255, 247, 245, 248),
                      elevation: 5,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isRhrCalculatorExpanded = ! _isRhrCalculatorExpanded;
                          });
                        },
                        child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.directions_run),
                                trailing: SizedBox(
                                  width: 10,
                                  child: widget.provider.monthlyHeartRateData.last.value > 80.0 ? Icon(Icons.thumb_down) : Icon(Icons.thumb_up),
                                ),
                                title: (widget.provider.monthlyHeartRateData.isEmpty) ? 
                                  const CircularProgressIndicator.adaptive() : 
                                  Text("Keep your resting heart rate low!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: !_isRhrCalculatorExpanded
                                    ? const Text('Check your cholesterol levels and do exercise, tap here to learn more about this latter point.', style: TextStyle(fontSize: 15.0))
                                    : null,
                              ),
                              if(_isRhrCalculatorExpanded & !(widget.provider.ageInserted) & (widget.provider.showAlertForAge)) ...[
                                AlertDialog(title: const Text('Alert'),
                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text('To be more precise, we need your age. Would you like to go to Profile page and add it? If you press no, an age of 25 will be used for the following computations.'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Yes'),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => PersonalInfo())
                                        );
                                        setState(() {
                                            widget.provider.showAlertForAge = false;
                                        });
                                      },
                                    ),
                                    TextButton(
                                      onPressed: (){
                                        setState(() {
                                          widget.provider.showAlertForAge = false;
                                        });
                                      }, 
                                      child: const Text('No'))
                                  ],
                                ),
                                ] else if(_isRhrCalculatorExpanded)...[
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Exercise is the best way to lower your resting heart rate. Here we guide you in setting a target heart rate to be maintained while exercising. Keep in mind that high-intensity aerobic training is the best way, but if you don't exercise regularly, you should check with your doctor before you set a target heart rate. We recommend you to gradually increase the intensity. ", style: TextStyle(fontSize: 14.0),),
                                      //Text("If you have heart diseases or feel pain, always contact your doctor before starting a training program!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0)),
                                      SizedBox(height: 10,),
                                      Text("Choose an intensity level: ", style: TextStyle(fontSize: 14.0)),
                                      SizedBox(height: 10,),
                                      DropdownButtonHideUnderline(
                                        child: DropdownButton2<String>(
                                          isExpanded: true,
                                          hint: const Row(
                                            children: [
                                              Icon(
                                                Icons.list,
                                                size: 16,
                                                color: Color.fromRGBO(250, 248, 230, 1),
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  'Select Item',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.yellow,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          items: items
                                              .map((String item) => DropdownMenuItem<String>(
                                                    value: item,
                                                    child: Text(
                                                      item,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                          value: selectedValue,
                                          onChanged: (String? value) {
                                            setState(() {
                                              selectedValue = value;
                                            });
                                          },
                                          buttonStyleData: ButtonStyleData(
                                            height: 40,
                                            width: 160,
                                            padding: const EdgeInsets.only(left: 14, right: 14),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(
                                                color: Colors.black26,
                                              ),
                                              color: Colors.redAccent,
                                            ),
                                            elevation: 2,
                                          ),
                                          iconStyleData: const IconStyleData(
                                            icon: Icon(
                                              Icons.arrow_forward_ios_outlined,
                                            ),
                                            iconSize: 14,
                                            iconEnabledColor: Colors.yellow,
                                            iconDisabledColor: Colors.grey,
                                          ),
                                          dropdownStyleData: DropdownStyleData(
                                            maxHeight: 200,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(14),
                                              color: Colors.redAccent,
                                            ),
                                            offset: const Offset(-20, 0),
                                            scrollbarTheme: ScrollbarThemeData(
                                              radius: const Radius.circular(40),
                                              thickness: MaterialStateProperty.all<double>(6),
                                              thumbVisibility: MaterialStateProperty.all<bool>(true),
                                            ),
                                          ),
                                          menuItemStyleData: const MenuItemStyleData(
                                            height: 40,
                                            padding: EdgeInsets.only(left: 14, right: 14),
                                          ),
                                        ),
                                      ),
                                      if(selectedValue!=null) ...[
                                        SizedBox(height: 10,),
                                        Text("Considering your age (${widget.provider.age}), your target heart rate during a ${selectedValue!.toLowerCase()} exercise session should be: "),
                                        SizedBox(height: 8,),
                                        Text("[${(((206.9-(0.67*widget.provider.age))-widget.provider.monthlyHeartRateData.last.value)*(mappedItems[selectedValue]![0]/100)+widget.provider.monthlyHeartRateData.last.value).toStringAsFixed(0)} - ${(((206.9-(0.67*widget.provider.age))-widget.provider.monthlyHeartRateData.last.value)*(mappedItems[selectedValue]![1]/100)+widget.provider.monthlyHeartRateData.last.value).toStringAsFixed(0)}]")
                                      ]
                                    ],
                                  ),
                                )
                              ],
                            ],
                          ),
                      ),
                    ),
                  ),
                  



                  /*
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      children:[
                        TextSpan(
                          text: "To better understand these data, ",
                          style: TextStyle(color: Colors.black)
                        ),
                        TextSpan(
                          text: "press here",
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {Navigator.of(context).push(MaterialPageRoute(builder: (_) => InfoRHR()));},
                        ),
                        TextSpan(
                          text: ".",
                          style: TextStyle(color: Colors.black)
                        ),
                      ]
                    ),
                  ),*/
                ],
              ),
          ),
        ),
      ),
    );
  }
}