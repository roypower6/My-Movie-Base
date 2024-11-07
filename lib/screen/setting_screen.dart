import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '앱 정보',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 20),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    spreadRadius: 2,
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Powered by',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 28,
                      ),
                      color: Colors.white,
                      child: Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/6/6e/Tmdb-312x276-logo.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              indent: 25,
              endIndent: 25,
            ),
            const ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('앱 버전'),
              subtitle: Text('1.0.2'),
            ),
            const ListTile(
              leading: Icon(Icons.email, color: Colors.red),
              title: Text('개발자 이메일'),
              subtitle: Text('roy040707@gmail.com'),
            ),
            const ListTile(
              leading: Icon(Icons.person, color: Colors.green),
              title: Text('개발자'),
              subtitle: Text('Rhee Seung gi'),
            ),
            const ListTile(
              leading: Icon(UniconsLine.github, color: Colors.white),
              title: Text('Github 아이디'),
              subtitle: Text('roypower6'),
            ),
          ],
        ),
      ),
    );
  }
}
