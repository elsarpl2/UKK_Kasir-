import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart'; // Pastikan mengimpor halaman login

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  String _role = '';
  bool _isLoading = true; // Status loading
  String? _errorMessage; // Menyimpan pesan error jika ada
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fungsi untuk mengambil data pengguna berdasarkan username dari Supabase
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username'); // Ambil username yang disimpan saat login

    if (username != null) {
      try {
        // Mengambil data pengguna berdasarkan username dari Supabase
        final response = await supabase
            .from('user') // Pastikan nama tabel sudah benar
            .select('username, role') // Pastikan kolom sesuai
            .eq('username', username)
            .single();

        if (response != null) {
          setState(() {
            _username = username;
            _role = response['role'] ?? 'Tidak diketahui'; // Jika role kosong, beri nilai default
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Pengguna tidak ditemukan';
            _isLoading = false;
          });
        }
      } catch (e) {
        print("Error: $e"); // Log error untuk debugging
        setState(() {
          _errorMessage = 'Terjadi kesalahan: $e';
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Username tidak ditemukan di SharedPreferences';
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk logout
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus data pengguna
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Ganti dengan halaman login
      (Route<dynamic> route) => false, // Hapus semua route sebelumnya
    );
  }

  // Fungsi untuk menampilkan konfirmasi logout
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300], // Warna latar belakang tombol
                foregroundColor: Colors.black, // Warna teks
              ),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                _logout(); // Panggil fungsi logout
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Warna latar belakang tombol
                foregroundColor: Colors.white, // Warna teks
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const CircularProgressIndicator() // Menampilkan indikator loading
              : Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Ikon Profil - Ganti dengan ikon produk skincare
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blueAccent,
                          child: const Icon(
                            Icons.medical_services, // Ikon yang lebih menggambarkan produk skincare
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Menampilkan pesan error jika ada
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        // Username
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.person, size: 30),
                            const SizedBox(width: 10),
                            Text(
                              'Username: $_username',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Role
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.work, size: 30), // Ikon role
                            const SizedBox(width: 10),
                            Text(
                              'Role: $_role',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Tombol Logout
                        ElevatedButton(
                          onPressed: _showLogoutConfirmation, // Panggil dialog konfirmasi logout
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
}
