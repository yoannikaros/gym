import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'admin@gym.com',
      query: 'subject=Kontak%20Aplikasi%20Gym',
    );
    await launchUrl(emailLaunchUri);
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/6281234567890');
    await launchUrl(whatsappUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontak Kami'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hubungi Kami',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: const Text('admin@gym.com'),
              subtitle: const Text('Email'),
              onTap: _launchEmail,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.green),
              title: const Text('+62 812-3456-7890'),
              subtitle: const Text('WhatsApp'),
              onTap: _launchWhatsApp,
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.location_on, color: Colors.blue),
              title: Text('Jl. Contoh Alamat No. 123, Jakarta'),
              subtitle: Text('Alamat'),
            ),
          ],
        ),
      ),
    );
  }
} 