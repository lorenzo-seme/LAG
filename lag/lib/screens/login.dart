import 'package:flutter/material.dart';
import 'package:lag/screens/home.dart';
import 'package:lag/utils/impact.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  static bool _passwordVisible = false;
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  //final Impact impact = Impact();
  bool isChecked = false;

  Future<void> setSavedUsername(bool isChecked) async {
      final sp = await SharedPreferences.getInstance();
      await sp.setBool("saved_credentials", isChecked);
  }


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
                  child: Image.asset('assets/logo_login.png', scale: 3), // pensavo di mettere la scitta LAG con la A fatta dal cervello
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome! ',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 30),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Login',
                ),
                const SizedBox(
                  height: 25,
                ),
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
                        borderSide: BorderSide(color: Colors.purple, width: 2.0)),
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
                        borderSide: BorderSide(color: Colors.purple, width: 2.0)),
                    prefixIcon: const Icon(
                      Icons.lock,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        // Based on passwordVisible state choose the icon
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
                                      builder: (context) => const Home()),
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                  ..removeCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(8),
                                      duration: Duration(seconds: 2),
                                      content: Text(
                                          "Username or password incorrect"),
                                    ),
                                  );
                              }
                            }
                          } else {
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(8),
                                  duration: Duration(seconds: 2),
                                  content: Text("IMPACT backend is down"),
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
                const Spacer(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "By logging in, you agree to LAG's\nTerms & Conditions and Privacy Policy",
                    style: TextStyle(fontSize: 12),
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


