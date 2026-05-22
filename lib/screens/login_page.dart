import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  void dispose(){
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              label: Text('Email ID'),
            ),
          ),
          TextField(
            controller: _passController,
            obscureText: true,
            decoration: InputDecoration(
              label: Text('Password'),
            ),
          ),
          FilledButton(
            onPressed: () async {
              final email=_emailController.text.trim();
              final pass=_passController.text.trim();

              try{
                final AuthResponse res = await supabase.auth.signInWithPassword(
                  email: email,
                  password: pass,
                );
                final Session? session = res.session;
                final User? user = res.user;
              }
              catch(e){
                print('Login failed: $e');
              }
            },
            child: Text('Login!')
          )
        ],
      )
    );
  }
}