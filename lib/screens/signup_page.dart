import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_spaces/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_spaces/providers/spaces_provider.dart';

class SignUpPage extends ConsumerStatefulWidget{
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
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
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading? null :() async {
                final email=_emailController.text.trim();
                final pass=_passController.text.trim();
                
                setState(() {
                  _isLoading = true;
                });

                try{
                  final AuthResponse res = await AuthService().signUp(email: email, password: pass);

                  if(!context.mounted) return;

                  ref.invalidate(spacesProvider);

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
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                context.go('/login');
              }, 
              child: Text("Have an account? Login!"),
            )
          ],
        )
      )
    );
  }
}