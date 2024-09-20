import 'package:flutter/material.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Certificates and Recognition'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: certificateList.length,
          itemBuilder: (context, index) {
            final certificate = certificateList[index];
            return Card(
              elevation: 5,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, size: 40, color: Colors.amber),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            certificate['title']??'',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            certificate['organization']??'',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Issued: ${certificate['date']}',
                            style: const TextStyle(color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.indigo),
                      onPressed: () {
                        // Add share functionality
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.download, color: Colors.indigo),
                      onPressed: () {
                        // Add download functionality
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

final certificateList = [
  {
    'title': 'Flutter Developer Certification',
    'organization': 'Google Developers',
    'date': 'May 2023',
  },
  {
    'title': 'Advanced AI Recognition',
    'organization': 'OpenAI Academy',
    'date': 'August 2024',
  },
  // Add more certificates here
];
