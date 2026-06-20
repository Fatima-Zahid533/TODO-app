import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';
import 'auth_provider.dart';
class AuthScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = ref.read(authServiceProvider);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passController, obscureText: true, decoration: InputDecoration(labelText: 'Password')),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => auth.signUpWithEmail(emailController.text, passController.text),
              child: Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: () => auth.signInWithEmail(emailController.text, passController.text),
              child: Text('Sign In'),
            ),
            Divider(),
            ElevatedButton(
              onPressed: () => auth.signInWithGoogle(),
              child: Text('Continue with Google'),
            ),
          ],
        ),
      ),
    );
  }
}