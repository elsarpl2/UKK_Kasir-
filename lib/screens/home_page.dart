import 'package:flutter/material.dart';
import 'riwayat_transaksi_page.dart';
import 'produk_page.dart';
import 'pembayaran_page.dart';
import 'pelanggan_page.dart'; // Halaman untuk Pelanggan
import 'profile_page.dart'; // Halaman untuk Profile
import 'registrasi_page.dart'; // Halaman untuk Registrasi
import 'package:supabase_flutter/supabase_flutter.dart'; // Mengimpor Supabase untuk database

class HomePage extends StatefulWidget {
  final String nama;
  final String role; // Menambahkan role untuk hak akses
  const HomePage({Key? key, required this.nama, required this.role}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> produkList = [];

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  // Fungsi untuk mengambil data produk dari tabel 'produk'
  Future<void> fetchProduk() async {
    try {
      final response = await supabase.from('produk').select().order('produk_id');
      if (response is List) {
        setState(() {
          produkList = List<Map<String, dynamic>>.from(response);
        });
      } else {
        print('Gagal mengambil data produk');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  // Fungsi untuk menangani perubahan tab pada BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Fungsi untuk menampilkan halaman sesuai dengan tab yang dipilih berdasarkan role
  Widget _buildPage(int index) {
    if (widget.role == 'Admin') {
      switch (index) {
        case 0:
          return ProdukPage();
        case 1:
          return PelangganPage();
        case 2:
          return RegistrasiPage(); // Tambahkan untuk Admin
        default:
          return const Center(
            child: Text(
              'Halaman Kosong',
              style: TextStyle(fontSize: 24, color: Colors.pink),
            ),
          );
      }
    } else if (widget.role == 'Petugas') {
      switch (index) {
        case 0:
          return ProdukPage();
        case 1:
          return PembayaranPage(produkList: produkList);
        case 2:
          return RiwayatTransaksiPage();
        default:
          return const Center(
            child: Text(
              'Halaman Kosong',
              style: TextStyle(fontSize: 24, color: Colors.pink),
            ),
          );
      }
    }
    return const Center(
      child: Text(
        'Halaman Kosong',
        style: TextStyle(fontSize: 24, color: Colors.pink),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[100],
        title: Text(
          'GlowPay - ${widget.nama}',
          style: const TextStyle(color: Colors.pinkAccent),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white), // Profile Icon
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(), // Navigasi ke halaman Profile
                ),
              );
            },
          ),
        ],
      ),
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.pink,
        backgroundColor: Colors.pink[100],
        items: widget.role == 'Admin'
            ? const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.production_quantity_limits),
                  label: 'Produk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Pelanggan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'User', // Tombol baru untuk Admin
                ),
              ]
            : const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.production_quantity_limits),
                  label: 'Produk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payment),
                  label: 'Pembayaran',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'Riwayat',
                ),
              ],
      ),
    );
  }
}
