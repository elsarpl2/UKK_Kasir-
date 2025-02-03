import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({Key? key}) : super(key: key);

  @override
  _ProdukPageState createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> filteredProdukList = [];
  bool isLoading = true;
  String _searchQuery = ''; // variabel pencarian

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    try {
      final response = await supabase.from('produk').select().order('produk_id');
      if (response is List) {
        setState(() {
          produkList = List<Map<String, dynamic>>.from(response);
          filteredProdukList = produkList;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showError('Gagal memuat data produk.');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Gagal memuat data produk: $e');
    }
  }

  void searchProduk(String query) {
    final results = produkList.where((produk) {
      final namaProduk = produk['nama_produk']?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();
      return namaProduk.contains(searchQuery);
    }).toList();

    setState(() {
      filteredProdukList = results;
      _searchQuery = query; // update query pencarian
    });
  }

  Future<void> tambahProduk(String title, double price, int stock) async {
    try {
      await supabase.from('produk').insert({
        'nama_produk': title,
        'harga': price,
        'stok': stock,
      }).select();
      fetchProduk();
      _showSuccess('Data berhasil ditambahkan');
    } catch (e) {
      _showError('Gagal menambahkan produk: $e');
    }
  }

  Future<void> editProduk(int id, String title, double price, int stock) async {
    try {
      await supabase.from('produk').update({
        'nama_produk': title,
        'harga': price,
        'stok': stock,
      }).eq('produk_id', id).select();
      fetchProduk();
      _showSuccess('Data berhasil diperbarui');
    } catch (e) {
      _showError('Gagal mengedit produk: $e');
    }
  }

  Future<void> hapusProduk(int id) async {
    try {
      await supabase.from('produk').delete().eq('produk_id', id).select();
      fetchProduk();
      _showSuccess('Data berhasil dihapus');
    } catch (e) {
      _showError('Gagal menghapus produk: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showFormDialog({int? id, String? title, double? price, int? stock}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController titleController = TextEditingController(text: title ?? '');
    final TextEditingController priceController = TextEditingController(text: price?.toString() ?? '');
    final TextEditingController stockController = TextEditingController(text: stock?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Tambah Produk' : 'Edit Produk'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (value) => value!.isEmpty ? 'Nama produk tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Harga harus berupa angka';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Harga harus lebih besar dari 0';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Stok harus berupa angka';
                  }
                  if (int.parse(value) <= 0) {
                    return 'Stok harus lebih besar dari 0';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (id == null) {
                  tambahProduk(
                    titleController.text,
                    double.parse(priceController.text),
                    int.parse(stockController.text),
                  );
                } else {
                  editProduk(
                    id,
                    titleController.text,
                    double.parse(priceController.text),
                    int.parse(stockController.text),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Produk')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (query) => searchProduk(query),
              decoration: const InputDecoration(
                labelText: 'Cari Produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredProdukList.isEmpty
                    ? const Center(child: Text('Tidak ada data produk.'))
                    : ListView.builder(
                        itemCount: filteredProdukList.length,
                        itemBuilder: (context, index) {
                          final produk = filteredProdukList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(produk['nama_produk'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Harga: Rp ${produk['harga'] ?? 0}'),
                                  Text('Stok: ${produk['stok'] ?? 0}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      _showFormDialog(
                                        id: produk['produk_id'],
                                        title: produk['nama_produk'],
                                        price: produk['harga'],
                                        stock: produk['stok'],
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      hapusProduk(produk['produk_id']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
