import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpPage extends StatefulWidget{
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading=false;
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
            onPressed: _isLoading? null :() async {
              final email=_emailController.text.trim();
              final pass=_passController.text.trim();
              
              setState(() {
                _isLoading = true;
              });

              try{
                final AuthResponse res = await supabase.auth.signUp(
                  email: email,
                  password: pass,
                );

                final Session? session = res.session;
                final User? user = res.user;

                if(!context.mounted) return;

                context.go('/home');
              }
              catch(e){
                print('Signup failed: $e');

                if(context.mounted) {
                  if(e is AuthException) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while signing up. Try again later.')));
                  }
                }
              }

              setState(() {
                _isLoading = false;
              });
            },
            child:_isLoading?CircularProgressIndicator():  Text('Sign Up!')
          )
        ],
      )
    );
  }
}