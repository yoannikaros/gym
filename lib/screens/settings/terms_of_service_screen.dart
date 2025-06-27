import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Syarat & Ketentuan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Dengan menginstal dan menggunakan aplikasi Gym Management System ("Aplikasi"), Anda setuju untuk terikat oleh syarat dan ketentuan berikut. Jika Anda tidak setuju, mohon untuk tidak menggunakan Aplikasi ini.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '1. Aplikasi Offline & Penyimpanan Data Lokal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Aplikasi ini beroperasi 100% offline. Semua data yang Anda masukkan, termasuk informasi anggota, transaksi, dan data lainnya, disimpan secara eksklusif di penyimpanan lokal perangkat Anda. Tidak ada data yang dikirim, dibagikan, atau disimpan di server eksternal atau cloud.',
            ),
            SizedBox(height: 12),
            Text(
              '2. Tanggung Jawab Pengguna',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Anda bertanggung jawab penuh atas keamanan perangkat Anda. Karena data disimpan secara lokal, kehilangan atau kerusakan perangkat dapat mengakibatkan kehilangan data secara permanen. Kami sangat menyarankan Anda untuk melakukan backup data secara mandiri dan berkala.',
            ),
            SizedBox(height: 12),
            Text(
              '3. Lisensi Penggunaan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Anda diberikan lisensi terbatas, non-eksklusif, dan tidak dapat dialihkan untuk menginstal dan menggunakan Aplikasi ini hanya untuk tujuan pengelolaan gym pada perangkat pribadi Anda.',
            ),
            SizedBox(height: 12),
            Text(
              '4. Tanpa Jaminan (No Warranties)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Aplikasi ini disediakan "sebagaimana adanya" tanpa jaminan apa pun. Kami tidak menjamin bahwa aplikasi akan bebas dari kesalahan atau bug. Kami tidak bertanggung jawab atas kehilangan data, kerusakan, atau kerugian lain yang timbul dari penggunaan Aplikasi ini.',
            ),
            SizedBox(height: 12),
            Text(
              '5. Batasan Penggunaan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Anda tidak diizinkan untuk: (a) merekayasa balik, membongkar, atau mencoba mengekstrak kode sumber Aplikasi; (b) memodifikasi, menyewakan, atau mendistribusikan ulang Aplikasi; (c) menggunakan Aplikasi untuk tujuan ilegal.',
            ),
            SizedBox(height: 12),
            Text(
              '6. Perubahan Ketentuan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Kami dapat memperbarui Syarat & Ketentuan ini dari waktu ke waktu. Versi terbaru akan tersedia di dalam Aplikasi. Penggunaan berkelanjutan Anda setelah pembaruan merupakan persetujuan Anda terhadap perubahan tersebut.',
            ),
            SizedBox(height: 24),
            Text(
              'Terakhir diperbarui: Juni 2024',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
} 