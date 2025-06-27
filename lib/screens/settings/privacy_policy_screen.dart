import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Kebijakan Privasi',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Privasi Anda sangat penting bagi kami. Kebijakan Privasi ini menjelaskan bagaimana aplikasi Gym Management System ("Aplikasi") menangani data Anda. Aplikasi ini dirancang untuk berfungsi sepenuhnya offline.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              '1. Tidak Ada Pengumpulan Data Online',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Kami tidak mengumpulkan, menyimpan, atau mentransmisikan informasi pribadi Anda ke server online mana pun. Semua data yang Anda masukkan ke dalam Aplikasi disimpan secara eksklusif di penyimpanan lokal perangkat Anda.',
            ),
            SizedBox(height: 12),
            Text(
              '2. Data yang Disimpan di Perangkat Anda',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Aplikasi ini menyimpan data berikut secara lokal di perangkat Anda: informasi anggota, detail langganan, catatan pembayaran, data kehadiran, dan data lain yang Anda masukkan untuk tujuan manajemen gym. Data ini tetap berada di perangkat Anda dan tidak dapat kami akses.',
            ),
            SizedBox(height: 12),
            Text(
              '3. Kontrol dan Tanggung Jawab Pengguna',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Anda memiliki kontrol penuh atas data Anda. Anda dapat menambah, mengubah, dan menghapus data Anda kapan saja melalui fitur di dalam Aplikasi. Karena data disimpan secara lokal, menghapus Aplikasi dari perangkat Anda akan menghapus semua data terkait secara permanen.',
            ),
            SizedBox(height: 12),
            Text(
              '4. Tidak Ada Pembagian Data dengan Pihak Ketiga',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Karena kami tidak mengumpulkan data Anda, kami tidak membagikan informasi pribadi Anda dengan pihak ketiga mana pun.',
            ),
            SizedBox(height: 12),
            Text(
              '5. Keamanan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Keamanan data Anda bergantung pada keamanan fisik dan digital perangkat Anda. Kami menyarankan Anda untuk menggunakan kata sandi atau metode penguncian lain pada perangkat Anda untuk melindungi data dari akses yang tidak sah.',
            ),
             SizedBox(height: 12),
            Text(
              '6. Privasi Anak',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Aplikasi ini tidak ditujukan untuk digunakan oleh siapa pun yang berusia di bawah 13 tahun. Kami tidak secara sadar mengumpulkan informasi yang dapat diidentifikasi secara pribadi dari anak-anak di bawah 13 tahun.',
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