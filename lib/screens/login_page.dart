import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_spaces/services/auth_service.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _isLoading=false;

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
                final AuthResponse res = await AuthService().login(email: email, password: pass);

                if(!context.mounted) return;

                context.go('/home');
              }
              catch(e){
                print('Login failed: $e');

                if(context.mounted) {
                  if(e is AuthException) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while logging in. Try again later.')));
                  }
                }
              }

              setState(() {
                _isLoading = false;
              });
            },
            child: _isLoading?CircularProgressIndicator(): Text('Login!'),
          ),
          TextButton(
            onPressed: () {
              context.go('/signup');
            }, 
            child: Text("Don't have an account? Sign up!"),
          )
        ],
      )
    );
  }
}