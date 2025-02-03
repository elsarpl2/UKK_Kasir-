import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganPage extends StatefulWidget {
  const PelangganPage({Key? key}) : super(key: key);

  @override
  _PelangganPageState createState() => _PelangganPageState();
}

class _PelangganPageState extends State<PelangganPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pelangganList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPelanggan();
  }

  Future<void> fetchPelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select().order('pelanggan_id');
      if (response is List) {
        setState(() {
          pelangganList = List<Map<String, dynamic>>.from(response);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showError('Gagal memuat data pelanggan.');
    }
  }

  Future<void> tambahPelanggan(String nama, String alamat, String noTelp) async {
    try {
      await supabase.from('pelanggan').insert({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'no_telp': noTelp,
      }).select();
      fetchPelanggan();
      _showSuccess('Data berhasil ditambahkan');
    } catch (e) {
      _showError('Gagal menambahkan pelanggan.');
    }
  }

  Future<void> editPelanggan(int id, String nama, String alamat, String noTelp) async {
    try {
      await supabase.from('pelanggan').update({
        'nama_pelanggan': nama,
        'alamat': alamat,
        'no_telp': noTelp,
      }).eq('pelanggan_id', id).select();
      fetchPelanggan();
      _showSuccess('Data berhasil diperbarui');
    } catch (e) {
      _showError('Gagal mengedit pelanggan.');
    }
  }

  Future<void> hapusPelanggan(int id) async {
    try {
      await supabase.from('pelanggan').delete().eq('pelanggan_id', id).select();
      fetchPelanggan();
      _showSuccess('Data berhasil dihapus');
    } catch (e) {
      _showError('Gagal menghapus pelanggan.');
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

  void _showFormDialog({int? id, String? nama, String? alamat, String? noTelp}) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController namaController = TextEditingController(text: nama ?? '');
    final TextEditingController alamatController = TextEditingController(text: alamat ?? '');
    final TextEditingController noTelpController = TextEditingController(text: noTelp ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(id == null ? 'Tambah Pelanggan' : 'Edit Pelanggan'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Pelanggan'),
                validator: (value) => value!.isEmpty ? 'Nama pelanggan tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: alamatController,
                decoration: const InputDecoration(labelText: 'Alamat'),
                validator: (value) => value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: noTelpController,
                decoration: const InputDecoration(labelText: 'No Telepon'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Nomor telepon harus berupa angka';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (id == null) {
                  tambahPelanggan(
                    namaController.text,
                    alamatController.text,
                    noTelpController.text,
                  );
                } else {
                  editPelanggan(
                    id,
                    namaController.text,
                    alamatController.text,
                    noTelpController.text,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Pelanggan')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pelangganList.isEmpty
              ? const Center(child: Text('Tidak ada data pelanggan.'))
              : ListView.builder(
                  itemCount: pelangganList.length,
                  itemBuilder: (context, index) {
                    final pelanggan = pelangganList[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(pelanggan['nama_pelanggan'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Alamat: ${pelanggan['alamat'] ?? 'Unknown'}'),
                            Text('No Telepon: ${pelanggan['no_telp'] ?? 'Unknown'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showFormDialog(
                                  id: pelanggan['pelanggan_id'],
                                  nama: pelanggan['nama_pelanggan'],
                                  alamat: pelanggan['alamat'],
                                  noTelp: pelanggan['no_telp'],
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                hapusPelanggan(pelanggan['pelanggan_id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}