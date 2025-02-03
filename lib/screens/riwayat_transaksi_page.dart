import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RiwayatTransaksiPage extends StatefulWidget {
  @override
  _RiwayatTransaksiPageState createState() => _RiwayatTransaksiPageState();
}

class _RiwayatTransaksiPageState extends State<RiwayatTransaksiPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> riwayatTransaksi = [];

  @override
  void initState() {
    super.initState();
    _fetchRiwayatTransaksi();
  }

  Future<void> _fetchRiwayatTransaksi() async {
    try {
      final response = await Supabase.instance.client
          .from('penjualan')
          .select('penjualan_id, tgl_penjualan, total_harga, detail_penjualan:detail_penjualan(produk_id, jumlah_produk, subtotal, produk:produk(nama_produk))')
          .order('tgl_penjualan', ascending: false);

      setState(() {
        riwayatTransaksi = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $error');
    }
  }

  Future<void> _hapusRiwayat(int penjualanId) async {
    try {
      // Hapus data pada tabel detail_penjualan terlebih dahulu
      await Supabase.instance.client.from('detail_penjualan').delete().match({'penjualan_id': penjualanId});

      // Hapus data pada tabel penjualan setelah detail_penjualan dihapus
      await Supabase.instance.client.from('penjualan').delete().match({'penjualan_id': penjualanId});

      // Fetch the updated list after deletion
      await _fetchRiwayatTransaksi();

      // Show alert dialog after successful deletion
      _showSuccessDialog();
    } catch (error) {
      print('Error menghapus riwayat: $error');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Riwayat Dihapus'),
          content: const Text('Riwayat transaksi berhasil dihapus.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Transaksi')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : riwayatTransaksi.isEmpty
              ? const Center(child: Text('Tidak ada riwayat transaksi.'))
              : ListView.builder(
                  itemCount: riwayatTransaksi.length,
                  itemBuilder: (context, index) {
                    final transaksi = riwayatTransaksi[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID Penjualan: ${transaksi['penjualan_id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('Tanggal: ${transaksi['tgl_penjualan']}'),
                            Text('Total Harga: Rp ${transaksi['total_harga']}'),
                            const SizedBox(height: 5),
                            const Text('Detail Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
                            for (var detail in transaksi['detail_penjualan'])
                              Text('- ${detail['produk']['nama_produk']}, Jumlah: ${detail['jumlah_produk']}, Subtotal: Rp ${detail['subtotal']}'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _hapusRiwayat(transaksi['penjualan_id']),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              child: const Text('Hapus Riwayat', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
