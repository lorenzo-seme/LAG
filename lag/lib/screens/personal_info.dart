import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersonalInfo extends StatefulWidget {
  const PersonalInfo({super.key});

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  DateTime selectedDate = (DateTime.now().month == 2 && DateTime.now().day == 29) 
                  ? DateTime(DateTime.now().year - 6, 2, 28) // manage leap year
                  : DateTime(DateTime.now().year - 6, DateTime.now().month, DateTime.now().day);

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1920, 1),
        lastDate: (DateTime.now().month == 2 && DateTime.now().day == 29) 
                  ? DateTime(DateTime.now().year - 6, 2, 28) // manage leap year
                  : DateTime(DateTime.now().year - 6, DateTime.now().month, DateTime.now().day));
    if (picked != null && picked != selectedDate) {
      dateController.text = DateFormat('yyyy-MM-dd').format(picked).toString();
    }
  }

  void _loadPrefs() async {
    final sp = await SharedPreferences.getInstance();
    String dob = sp.getString('dob') ?? "";
    String name = sp.getString('name') ?? "";
    setState(() {
      dateController.text = dob;
      nameController.text = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
        title: const Text(
                'Personal Info',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),
              ),
        backgroundColor: const Color.fromARGB(255, 227, 211, 244),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text("Info about you for a tailored experience",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 8.0),
                child: TextFormField(
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                  controller: nameController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    prefixIcon: const Icon(
                      Icons.person,
                    ),
                    hintText: 'Name',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 8.0),
                child: TextFormField(
                  onTap: () {
                    _selectDate(context);
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Date of Birth is required';
                    }
                    return null;
                  },
                  controller: dateController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0))),
                    prefixIcon: const Icon(
                      Icons.calendar_month,
                    ),
                    hintText: 'Date of Birth: YYYY-MM-DD',
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final sp = await SharedPreferences.getInstance();
                        await sp.setString('dob', dateController.text.toString());
                        await sp.setString('name', nameController.text.toString());
                        DateTime birthDate = DateTime.parse(dateController.text.toString());
                        DateTime now = DateTime.now();
                        int userAge = now.year - birthDate.year;
                          if (now.month < birthDate.month ||
                            (now.month == birthDate.month && now.day < birthDate.day)) {
                          userAge--;
                          }
                        await sp.setString('userAge', userAge.toString());
                        await Provider.of<HomeProvider>(context, listen: false).updateSP();
                        Navigator.of(context).pop();
                      }
                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 55, vertical: 12)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF384242))),
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 15,),
                  ElevatedButton(
                    onPressed: () async {
                      final sp = await SharedPreferences.getInstance();
                      await sp.remove('dob');
                      await sp.remove('name');
                      await sp.remove('userAge');
                      await Provider.of<HomeProvider>(context, listen: false).updateSP();
                      Navigator.of(context).pop();

                    },
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 12)),
                        foregroundColor:
                            MaterialStateProperty.all<Color>(const Color.fromRGBO(255, 255, 255, 1)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 228, 106, 106))),
                    child: const Text('Forget my info'),
                  ),
              ],)
            ],
          ),
        ),
      ),
    );
  }
}