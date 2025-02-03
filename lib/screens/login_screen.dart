import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan data lokal
import 'package:supabase_flutter/supabase_flutter.dart'; // Mengimpor Supabase
import 'home_page.dart'; // Halaman utama setelah login

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'MEMBER LOGIN',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildTextField(
                    controller: _usernameController,
                    label: 'Email ID',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 15),
                  _buildPasswordField(),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pinkAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menangani login
  void _handleLogin(BuildContext context) async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showMessage(context, 'Email ID dan password tidak boleh kosong.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Query ke Supabase untuk mendapatkan role
      final response = await Supabase.instance.client
          .from('user')
          .select('username, role')
          .eq('username', username)
          .eq('password', password)
          .maybeSingle();

      if (response != null) {
        String role = response['role'] ?? '';

        // Simpan data user ke SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', response['username']);
        await prefs.setString('role', role);

        // Arahkan ke halaman utama dengan role yang sesuai
       if (username != null && username.isNotEmpty && role != null && role.isNotEmpty) {
  print("Navigasi ke HomePage dengan Username: $username dan Role: $role");
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => HomePage(nama: username, role: role),
    ),
  );
} else {
  print("Error: Username atau Role kosong/null");
}


        // Tampilkan pesan sukses berdasarkan role
        _showSuccessMessage(role);
      } else {
        _showMessage(context, 'Username atau password salah.');
      }
    } catch (e) {
      _showMessage(context, 'Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk menampilkan pesan menggunakan SnackBar
  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Fungsi untuk menampilkan pesan sukses
  void _showSuccessMessage(String role) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login berhasil sebagai $role'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Fungsi untuk membangun text field biasa (untuk username/email)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.pinkAccent, size: 20),
          hintText: label,
          hintStyle: const TextStyle(color: Colors.pinkAccent, fontSize: 14),
        ),
      ),
    );
  }

  // Fungsi untuk membangun text field khusus untuk password
  Widget _buildPasswordField() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.pink[50],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.pinkAccent, size: 20),
          hintText: 'Password',
          hintStyle: const TextStyle(color: Colors.pinkAccent, fontSize: 14),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.pinkAccent,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
      ),
    );
  }
}
