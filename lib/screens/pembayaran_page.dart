import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'struk_page.dart'; // Import StrukPage

class PembayaranPage extends StatefulWidget {
  final List<Map<String, dynamic>> produkList;

  const PembayaranPage({Key? key, required this.produkList}) : super(key: key);

  @override
  _PembayaranPageState createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final List<Map<String, dynamic>> _keranjang = [];
  String _searchQuery = '';
  List<Map<String, dynamic>> _members = [];
  Map<String, dynamic>? _selectedMember;
  bool isLoading = false;
  String errorMessage = '';
  bool _isDataSaved = false;

  // Menyimpan stok produk dalam map untuk akses yang lebih cepat
  Map<int, int> produkStok = {};

  @override
  void initState() {
    super.initState();
    _fetchMembers();
    _fetchStokProduk();  // Ambil stok produk saat awal
  }

  // Fungsi untuk mengambil stok produk dari Supabase dan menyimpannya
  Future<void> _fetchStokProduk() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await Supabase.instance.client
          .from('produk')
          .select('produk_id, stok');

      for (var item in response) {
        produkStok[item['produk_id']] = item['stok'];
      }

      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching stok produk: $error';
      });
    }
  }

  Future<void> _fetchMembers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await Supabase.instance.client
          .from('pelanggan')
          .select()
          .order('nama_pelanggan')
          .limit(100);

      setState(() {
        _members = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching members: $error';
      });
    }
  }

  double get _totalBayar {
    double subtotal = _keranjang.fold(0.0, (sum, item) => sum + item['subtotal']);
    double diskon = _selectedMember != null ? subtotal * 0.03 : 0.0;
    return subtotal - diskon;
  }

  String _formatRupiah(dynamic amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  void _tambahKeKeranjang(Map<String, dynamic> produk) {
    final stok = produkStok[produk['produk_id']] ?? 0;  // Menggunakan data stok lokal

    setState(() {
      final existingProductIndex =
          _keranjang.indexWhere((item) => item['produk_id'] == produk['produk_id']);
      if (existingProductIndex == -1) {
        if (stok > 0) {
          _keranjang.add({
            ...produk,
            'jumlah': 1,
            'subtotal': produk['harga'],
          });
        } else {
          _showAlert('Stok tidak cukup');
        }
      } else {
        int jumlah = _keranjang[existingProductIndex]['jumlah'];
        if (jumlah < stok) {
          _keranjang[existingProductIndex]['jumlah']++;
          _keranjang[existingProductIndex]['subtotal'] =
              _keranjang[existingProductIndex]['jumlah'] * produk['harga'];
        } else {
          _showAlert('Stok tidak cukup');
        }
      }
    });
  }

  void _kurangiDariKeranjang(Map<String, dynamic> produk) {
    setState(() {
      final existingProductIndex =
          _keranjang.indexWhere((item) => item['nama_produk'] == produk['nama_produk']);
      if (existingProductIndex != -1) {
        if (_keranjang[existingProductIndex]['jumlah'] > 1) {
          _keranjang[existingProductIndex]['jumlah']--;
          _keranjang[existingProductIndex]['subtotal'] =
              _keranjang[existingProductIndex]['jumlah'] * produk['harga'];
        } else {
          _keranjang.removeAt(existingProductIndex);
        }
      }
    });
  }

  Future<void> _simpanKeDatabase() async {
    try {
      final pelangganId = _selectedMember != null ? _selectedMember!['pelanggan_id'] : null;

      final response = await Supabase.instance.client.from('penjualan').insert({
        'tgl_penjualan': DateTime.now().toIso8601String(),
        'total_harga': _totalBayar,
        'pelanggan_id': pelangganId,
      }).select();

      if (response.isEmpty) {
        throw Exception("Gagal menyimpan transaksi penjualan");
      }

      final penjualanId = response[0]['penjualan_id'];

      // Simpan detail_penjualan
      for (var item in _keranjang) {
        await Supabase.instance.client.from('detail_penjualan').insert({
          'penjualan_id': penjualanId,
          'produk_id': item['produk_id'],
          'jumlah_produk': item['jumlah'],
          'subtotal': item['subtotal'],
        });
      }

      setState(() {
        _isDataSaved = true;
      });
    } catch (error) {
      setState(() {
        _isDataSaved = false;
      });
      print('Error saat menyimpan ke database: $error');
    }
  }

  void _bayar() async {
    await _simpanKeDatabase();

    // Arahkan ke halaman Struk
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StrukPage(
          keranjang: _keranjang,
          selectedMember: _selectedMember,
          totalBayar: _totalBayar,
        ),
      ),
    );
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Peringatan'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (query) => setState(() => _searchQuery = query),
                    decoration: const InputDecoration(
                      labelText: 'Cari Produk...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButton<Map<String, dynamic>>(
                    value: _selectedMember,
                    hint: const Text('Pilih Member'),
                    isExpanded: true,
                    items: _members.map((member) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: member,
                        child: Text(member['nama_pelanggan']),
                      );
                    }).toList(),
                    onChanged: (member) {
                      setState(() {
                        _selectedMember = member;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.produkList.isNotEmpty
                        ? widget.produkList.where((produk) {
                            return produk['nama_produk']
                                .toLowerCase()
                                .contains(_searchQuery.toLowerCase());
                          }).length
                        : 0,
                    itemBuilder: (context, index) {
                      final produk = widget.produkList.where((produk) {
                        return produk['nama_produk']
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase());
                      }).toList()[index];

                      int jumlahProduk = _keranjang.firstWhere(
                          (item) => item['nama_produk'] == produk['nama_produk'],
                          orElse: () => {'jumlah': 0})['jumlah'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        child: ListTile(
                          leading: const Icon(Icons.shopping_bag, color: Colors.pink),
                          title: Text(produk['nama_produk']),
                          subtitle: Text('${_formatRupiah(produk['harga'])}\nStok: ${produkStok[produk['produk_id']] ?? 0}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (jumlahProduk > 0)
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.red),
                                  onPressed: () => _kurangiDariKeranjang(produk),
                                ),
                              Text(
                                jumlahProduk.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.green),
                                onPressed: () => _tambahKeKeranjang(produk),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _keranjang.isEmpty || _isDataSaved ? null : _bayar,
                    child: const Text('Bayar'),
                  ),
                ),
              ],
            ),
    );
  }
}
