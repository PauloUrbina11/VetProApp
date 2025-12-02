import 'package:flutter/material.dart';
import '../widgets/login_form.dart';
import '../widgets/register_form.dart';
import '../../../../app/config/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true; // Control del tab activo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: softGreen,
        body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                    child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(children: [
                          /// LOGO
                          Image.asset('assets/images/paw_white.png',
                              width: 85, height: 85),

                          const SizedBox(height: 20),

                          /// TÍTULO
                          const Text('VETPROAPP',
                              style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.5)),

                          const SizedBox(height: 25),

                          /// TABS
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // TAB LOGIN
                                GestureDetector(
                                    onTap: () => setState(() => isLogin = true),
                                    child: Column(children: [
                                      Text('Iniciar sesión',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: isLogin
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.6),
                                              fontWeight: isLogin
                                                  ? FontWeight.bold
                                                  : FontWeight.normal)),
                                      if (isLogin)
                                        Container(
                                            margin:
                                                const EdgeInsets.only(top: 4),
                                            height: 2,
                                            width: 80,
                                            color: Colors.white)
                                    ])),

                                const SizedBox(width: 40),

                                // TAB REGISTER
                                GestureDetector(
                                    onTap: () =>
                                        setState(() => isLogin = false),
                                    child: Column(children: [
                                      Text('Registrarse',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: !isLogin
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.6),
                                              fontWeight: !isLogin
                                                  ? FontWeight.bold
                                                  : FontWeight.normal)),
                                      if (!isLogin)
                                        Container(
                                            margin:
                                                const EdgeInsets.only(top: 4),
                                            height: 2,
                                            width: 80,
                                            color: Colors.white)
                                    ])),
                              ]),

                          const SizedBox(height: 35),

                          /// FORM DINÁMICO
                          Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                  color: lightGreen.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(18)),
                              child: isLogin
                                  ? const LoginForm()
                                  : const RegisterForm()),

                          if (isLogin) ...[
                            const SizedBox(height: 20),
                            GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/reset');
                                },
                                child: Text('¿Has olvidado tu contraseña?',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white.withOpacity(0.9),
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.bold))),
                          ],

                          const SizedBox(height: 40),
                        ]))))));
  }
}
