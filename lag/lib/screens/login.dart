import 'package:flutter/material.dart';
import 'package:lag/providers/homeProvider.dart';
import 'package:lag/screens/home.dart';
import 'package:lag/services/impact.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  final HomeProvider provider;
  const Login({super.key, required this.provider});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static bool _passwordVisible = false;
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isChecked = false;

  Future<void> setSavedUsername(bool isChecked) async {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool("saved_credentials", isChecked);
  } //setSavedUsername

  void _showPassword() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  } //_showPassword

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: 24.0, right: 24.0, top: 50, bottom: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Image.asset('assets/logo_1.png', scale: 3),
                      Image.asset('assets/logo_2.png', scale: 1.3)
                    ],
                  ), 
                ),
                const SizedBox(height: 30),
                const Text('Welcome to LAG!',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 25),
                TextFormField(
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Username is required';
                    }
                    return null;
                  },
                  controller: userController,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Color(0xFF4e50bf), width: 2.0)),
                    prefixIcon: const Icon(
                      Icons.person,
                    ),
                    hintText: 'Username',
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                TextFormField(
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                  controller: passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        borderSide: BorderSide(color: Color(0xFF4e50bf), width: 2.0)),
                    prefixIcon: const Icon(
                      Icons.lock,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _showPassword();
                      },
                    ),
                    hintText: 'Password',
                  ),
                ),

                Row(
                  children: [
                    Checkbox(
                      activeColor: const Color(0xFF4e50bf),
                      value: isChecked,
                      onChanged: (value) async{
                        setState(() {
                          isChecked = value!;
                        });
                        await setSavedUsername(isChecked);
                      },
                    ),
                    const Text('Remember me'),
                  ],
                ),
                Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (await Impact.isImpactUp()) {
                            if (_formKey.currentState!.validate()) {
                              final result = await Impact.getAndStoreTokens(userController.text,passwordController.text,);
                              if (result == 200) {
                                final sp = await SharedPreferences.getInstance();
                                await sp.setString('username', userController.text);
                                await sp.setString('password', passwordController.text);
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>  Home(provider: widget.provider,)),
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Color.fromARGB(255, 243, 110, 110),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(8),
                                      duration: Duration(seconds: 2),
                                      content: Text("Username or password incorrect",
                                        textAlign: TextAlign.center,),
                                    ),
                                  );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color.fromARGB(255, 243, 110, 110),
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(8),
                                  duration: Duration(seconds: 2),
                                  content: Text("IMPACT backend is down",
                                    textAlign: TextAlign.center,),
                                ),
                              );
                          }
                          ;
                        },
                        style: ButtonStyle(
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 12),
                          ),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xFF384242)),
                        ),
                        child: const Text('Log In'),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


