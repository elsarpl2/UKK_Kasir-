import 'package:flutter/material.dart'; // Mengimpor paket Flutter untuk penggunaan Material Design
import 'package:supabase_flutter/supabase_flutter.dart'; // Mengimpor paket Supabase untuk mengakses backend
import 'screens/login_screen.dart'; // Mengimpor layar login yang sudah dibuat

Future<void> main() async {
  // Inisialisasi Supabase, menghubungkan aplikasi dengan Supabase untuk autentikasi dan database
  await Supabase.initialize(
    url: 'https://niihorptiulyvdrxclrv.supabase.co', // URL Supabase Project
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5paWhvcnB0aXVseXZkcnhjbHJ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMzI4NTMsImV4cCI6MjA1MTcwODg1M30.ZdJSbArO1kFgHlGbntHIg6nrzzjDaIIq-Sntlh7XW6g', // Anon Key Supabase
  );

  // Menjalankan aplikasi setelah inisialisasi selesai
  runApp(const MyApp()); // Menjalankan aplikasi dengan MyApp sebagai root widget
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Konstruktor MyApp, digunakan untuk menginisialisasi widget

  @override
  Widget build(BuildContext context) {
    // Membangun widget untuk aplikasi
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Menonaktifkan banner debug di pojok kanan atas
      title: 'Login App', // Judul aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Menentukan warna utama untuk tema aplikasi
      ),
      home: LoginScreen(), // Menampilkan halaman login sebagai halaman utama aplikasi
    );
  }
}
