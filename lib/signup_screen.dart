import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController aadharCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  bool agreeTerms = false;
  bool isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate() || !agreeTerms) return;

    setState(() => isLoading = true);

    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      await userCred.user?.sendEmailVerification();

      await _firestore.collection("users").doc(userCred.user?.uid).set({
        "name": nameCtrl.text.trim(),
        "username": usernameCtrl.text.trim(),
        "phone": phoneCtrl.text.trim(),
        "email": emailCtrl.text.trim(),
        "aadhar": aadharCtrl.text.trim(),
        "createdAt": DateTime.now(),
        "emailVerified": false,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful! Verify your email.")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name")),
                TextFormField(controller: usernameCtrl, decoration: const InputDecoration(labelText: "Username")),
                TextFormField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Phone")),
                TextFormField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email")),
                TextFormField(controller: aadharCtrl, decoration: const InputDecoration(labelText: "Aadhaar")),
                TextFormField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
                TextFormField(controller: confirmPasswordCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Confirm Password")),
                Row(
                  children: [
                    Checkbox(
                      value: agreeTerms,
                      onChanged: (val) => setState(() => agreeTerms = val!),
                    ),
                    const Expanded(child: Text("I agree to Terms & Conditions")),
                  ],
                ),
                const SizedBox(height: 20),
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signup, child: const Text("Register")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
