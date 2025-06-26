import 'dart:ui';

import 'package:fiap_farms_app/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loginFailed = false;

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (e) {
      setState(() => loginFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF7E6213),
          image: DecorationImage(
            image: AssetImage("assets/images/grafismo-tech-top.png"),
            fit: BoxFit.fitWidth,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Image.asset("assets/images/logotipo.png"),
                    SizedBox(height: 15),
                    Text(
                      "Sua solução em\nplanejamento",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        color: Color(0xFF97133E),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 30),

                    /**
                     * Form
                     */
                    Container(
                      padding: EdgeInsets.all(21),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Faça seu login',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF765B04),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextField(
                            controller: emailCtrl,
                            style: TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              floatingLabelStyle: TextStyle(
                                color: Colors.transparent,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                              filled: true,
                              fillColor: Color(0xFFFFFFFF),
                            ),
                          ),
                          SizedBox(height: 15),
                          TextField(
                            controller: passwordCtrl,
                            style: TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              labelText: 'Senha',
                              floatingLabelStyle: TextStyle(
                                color: Colors.transparent,
                              ),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              filled: true,
                              fillColor: Color(0xFFFFFFFF),
                            ),
                            obscureText: true,
                          ),
                          Builder(
                            builder: (context) {
                              if (loginFailed) {
                                return Column(children: [
                                  SizedBox(height: 15),
                                  Center(
                                    child: Text(
                                      "Erro ao realizar o login.\nVerifique e-mail e senha.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF990000),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  )
                                ]);
                              }

                              return SizedBox(height: 0);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: login,
                            style: TextButton.styleFrom(
                              side: BorderSide.none,
                              backgroundColor: Color(0xFF59734A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              minimumSize: const Size(100, 60),
                            ),
                            child: const Text(
                              'Enviar',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              /**
               * Footer
               */
              Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color(0xFF97133E),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Contate-nos",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Image.asset(
                            "assets/images/instagram-icon.png",
                          ),
                          tooltip: 'Increase volume by 10',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Image.asset(
                            "assets/images/linkedin-icon.png",
                          ),
                          tooltip: 'Increase volume by 10',
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Image.asset(
                            "assets/images/whatsapp-icon.png",
                          ),
                          tooltip: 'Increase volume by 10',
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Text(
                      "0800 004 250 08\nsuporte@fiapfarms.com.br",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    SizedBox(height: 15),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Jura',
                        ),
                        children: [
                          TextSpan(
                            text: "Desenvolvido por ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          TextSpan(
                            text: "Grupo29",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 90),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
