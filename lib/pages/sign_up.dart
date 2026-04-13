import 'package:flutter/material.dart';
import 'package:projek_akhir/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:projek_akhir/auth/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Deklarasi var
  final authService = AuthService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void signUp() async {
  try {
    final response = await authService.signUpWithEmailPassword(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nameController.text.trim(),
    );

    // Contoh penggunaan response (hilangkan warning)
    if (response.user != null) {
      print("User baru: ${response.user?.id}");
    }

    await Future.delayed(Duration(milliseconds: 800));

    if (Supabase.instance.client.auth.currentSession != null) {
      Navigator.pop(context);
    }

    } catch (e) {
      String errorMessage = 'Terjadi kesalahan';
      
      if (e is AuthException) {
        errorMessage = e.message;           // ini yang paling penting
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Tidak bisa terhubung ke server (cek internet)';
      } else {
        errorMessage = e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
      print("ERROR AUTH: $e");   // lihat di console
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Center(
          child: Column( 
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Sign Up",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold
                ),
              ),

              Text("Create and account to continue!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey
                ),
              ),
        
              SizedBox(height: 20),
              Text("Full Name",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey
                ),
              ),
              _nameField(),

              SizedBox(height: 20),
              Text("Email",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey
                ),
              ),
              _usernameField(),

              SizedBox(height: 20),
              Text("Set Password",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey
                ),
              ),
              _passwordField(),
        
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: signUp, 
        
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                ),
        
                child: Text("Register")
              ),

              SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  SizedBox(width: 8),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.blue,
                      shadowColor: Colors.transparent,
                      overlayColor: Colors.transparent,
                    ),

                    child: Text("Login"),
                  ),
                ],
              )
            ],
            
          )
        ),
      )
    );
  }

  Widget _nameField() {
    return TextField(
      controller: _nameController,

      decoration: InputDecoration(
        hintText: 'Full Name',
        hintStyle: TextStyle(
          color: Colors.grey, // warna hint text
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        
       focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      )
    );
  }

  Widget _usernameField() {
    return TextField(
      controller: _emailController,

      decoration: InputDecoration(
        hintText: 'Email',
        hintStyle: TextStyle(
          color: Colors.grey, // warna hint text
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        
       focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      )
    );
  }

  Widget _passwordField() {
    return  TextField(
      controller: _passwordController,

      obscureText: true,

      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: TextStyle(
          color: Colors.grey, // warna hint text
        ),

        border: OutlineInputBorder(),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

}