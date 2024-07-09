import 'package:flutter/material.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/personal_info.dart';
import 'package:lag/utils/barplotHR.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      appBar: AppBar(
        title: const Text("Resting heart rate", style: TextStyle(fontSize: 24, color: Colors.black)),
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
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.monitor_heart),
                                trailing: SizedBox(
                                  width: 10,
                                  child: ((widget.provider.monthlyHeartRateData.last.value > 80.0)) ? Icon(Icons.thumb_down) : Icon(Icons.thumb_up),
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
                                      Text("Your resting heart rate should be between 55 and 80 bpm. A resting heart rate between 81 and 90 doubles the risk of premature death. If greater than 90, the risk is three times higher. If your resting heart rate is lower than 55 and you're not an athlete... contact your doctor!", style: TextStyle(fontSize: 14.0)),
                                      // fonte https://heart.bmj.com/content/99/12/882.full?sid=90e3623c-1250-4b94-928c-0a8f95c5b36b
                                    ],
                                  ),
                                ),
                            ],
                          ),
                      ),
                    ),
                  ),

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
                                title: (widget.provider.monthlyHeartRateData.isEmpty) ? 
                                  const CircularProgressIndicator.adaptive() : 
                                  Text("Keep your resting heart rate low!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                subtitle: !_isRhrCalculatorExpanded
                                    ? const Text('Check your cholesterol levels and do exercise, tap here to learn more about this latter point.', style: TextStyle(fontSize: 15.0))
                                    : null,
                              ),
                              if(_isRhrCalculatorExpanded & !(widget.provider.ageInserted) & (widget.provider.showAlertForAge)) ...[

                                Column(
                                  children: [
                                    const Text("Estimates were made assuming that your age is 25. \nAdd your personal information for a customized advice!",
                                      style: TextStyle(fontSize: 11.0, fontStyle: FontStyle.italic),),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          child: const Text('To Personal Info',
                                            style: TextStyle(fontSize: 11.0)),
                                          onPressed: () async {
                                            await Navigator.of(context).push(
                                              MaterialPageRoute(builder: (context) => PersonalInfo())
                                            );
                                            final sp = await SharedPreferences.getInstance();
                                            final name = sp.getString('name');
                                            final userAge = sp.getString('userAge');
                                            setState(() {
                                              widget.provider.showAlertForAge = false;
                                              if (userAge != null && name != null) {
                                                widget.provider.nick = name;
                                                widget.provider.age = int.parse(userAge);
                                              } 
                                            });
                                          },
                                        ),

                                        TextButton(
                                          child: const Text('Do not ask again',
                                            style: TextStyle(fontSize: 11.0)),
                                          onPressed: () {
                                            setState(() {
                                              widget.provider.showAlertForAge = false;
                                            });
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                ] else if(_isRhrCalculatorExpanded)...[
                                Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Exercise is the best way to lower your resting heart rate. Here we guide you in setting a target heart rate to be maintained while exercising. Keep in mind that high-intensity aerobic training is the best way, but if you don't exercise regularly, you should check with your doctor before you set a target heart rate. We recommend you to gradually increase the intensity. ", style: TextStyle(fontSize: 14.0),),
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
                ],
              ),
          ),
        ),
      ),
    );
  }
}