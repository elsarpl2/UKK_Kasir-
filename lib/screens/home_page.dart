import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  final String nama;
  const HomePage({Key? key, required this.nama}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> produkList = [];
  late String namaPengguna;

  @override
  void initState() {
    super.initState();
    namaPengguna = widget.nama;
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    try {
      final response = await supabase.from('produk').select();
      if (response is List) {
        setState(() {
          produkList = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> tambahProduk(String title, double price, int stock) async {
    try {
      await supabase.from('produk').insert({
        'nama_produk': title,
        'harga': price,
        'stok': stock,
      }).select();
      fetchProduk();
    } catch (e) {
      print('Error adding product: $e');
    }
  }

  Future<void> editProduk(int id, String title, double price, int stock) async {
    try {
      await supabase.from('produk').update({
        'nama_produk': title,
        'harga': price,
        'stok': stock,
      }).eq('id', id).select();
      fetchProduk();
    } catch (e) {
      print('Error editing product: $e');
    }
  }

  Future<void> hapusProduk(int id) async {
    try {
      await supabase.from('produk').delete().eq('id', id).select();
      fetchProduk();
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  void _tambahProdukDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Nama Produk')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                tambahProduk(
                  titleController.text,
                  double.parse(priceController.text),
                  int.parse(stockController.text),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _editProdukDialog(int id, String title, double price, int stock) {
    TextEditingController titleController = TextEditingController(text: title);
    TextEditingController priceController = TextEditingController(text: price.toString());
    TextEditingController stockController = TextEditingController(text: stock.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Produk'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Nama Produk')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Harga'), keyboardType: TextInputType.number),
              TextField(controller: stockController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                editProduk(
                  id,
                  titleController.text,
                  double.parse(priceController.text),
                  int.parse(stockController.text),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _hapusProdukDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Produk'),
          content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                hapusProduk(id);
                Navigator.of(context).pop();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text('Halaman Utama'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    namaPengguna,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Akun'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.app_registration),
              title: const Text('Registrasi'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: produkList.length,
          itemBuilder: (context, index) {
            final produk = produkList[index];
            return Card(
              child: ListTile(
                title: Text(produk['nama_produk']),
                subtitle: Text('Rp ${produk['harga']} - Stok: ${produk['stok']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editProdukDialog(
                        produk['id'],
                        produk['nama_produk'],
                        produk['harga'].toDouble(),
                        produk['stok'].toInt(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _hapusProdukDialog(produk['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _tambahProdukDialog,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
