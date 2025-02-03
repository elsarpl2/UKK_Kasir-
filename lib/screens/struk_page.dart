import 'package:flutter/material.dart';

class StrukPage extends StatelessWidget {
  final List<Map<String, dynamic>> keranjang;
  final Map<String, dynamic>? selectedMember;
  final double totalBayar;

  const StrukPage({
    Key? key,
    required this.keranjang,
    required this.selectedMember,
    required this.totalBayar,
  }) : super(key: key);

  String _formatRupiah(dynamic amount) {
    return 'Rp ${amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Pembayaran'),
        // Hapus IconButton untuk histori
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (selectedMember != null) ...[
              Text(
                'Nama Pelanggan: ${selectedMember?['nama_pelanggan']}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                'Alamat: ${selectedMember?['alamat']}',
                style: const TextStyle(fontSize: 14),
              ),
              Text(
                'No. Telepon: ${selectedMember?['no_telp']}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
            ],
            const Text('Struk Pembayaran'),
            const Divider(),
            Column(
              children: keranjang.map((produk) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(produk['nama_produk'])),
                    Text('${produk['jumlah']} x ${_formatRupiah(produk['harga'])}'),
                    Text('= ${_formatRupiah(produk['subtotal'])}'),
                  ],
                );
              }).toList(),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatRupiah(
                      keranjang.fold(0.0, (sum, item) => sum + item['subtotal'])),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (selectedMember != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Diskon (3%):',
                    style: TextStyle(color: Colors.green),
                  ),
                  Text(
                    '- ${_formatRupiah(keranjang.fold(0.0, (sum, item) => sum + item['subtotal']) * 0.03)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Bayar: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatRupiah(totalBayar),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Colors.pink),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate back to PembayaranPage
                Navigator.pop(context);
              },
              child: const Text('Konfirmasi & Kembali ke Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }
}
