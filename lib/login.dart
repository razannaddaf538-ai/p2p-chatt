import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'mainscreen.dart'; // استدعاء الشاشة الرئيسية لفتحها بعد الدخول

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 55,
                backgroundColor: AppColors.primary,
                child: Icon(
                  Icons.chat_bubble,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "P2P Chat",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              const TextField(
                decoration: InputDecoration(
                  hintText: "اسم المستخدم",
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  //  الانتقال للشاشة الرئيسية عند الضغط
                  onPressed: () {
                    Navigator.pushReplacement(
                      context, 
                      MaterialPageRoute(builder: (context) => MainScreen())
                    );
                  },
                  child: const Text("دخول"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

