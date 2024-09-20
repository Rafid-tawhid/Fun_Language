import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DictionaryApp extends StatefulWidget {
  @override
  _DictionaryAppState createState() => _DictionaryAppState();
}

class _DictionaryAppState extends State<DictionaryApp> {
  TextEditingController _textEditingController = TextEditingController();
  String _meaning = '';

  Future<void> getWordMeaning(String word) async {
    String apiUrl =
        'https://api.dictionaryapi.dev/api/v2/entries/en_US/$word';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> meanings = jsonDecode(response.body);
        if (meanings.isNotEmpty) {
          setState(() {
            _meaning = meanings[0]['meanings'][0]['definitions'][0]['definition'];
          });
        } else {
          setState(() {
            _meaning = 'No meaning found for this word.';
          });
        }
      } else {
        setState(() {
          _meaning = 'Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _meaning = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
            hintText: 'Enter a word',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(onPressed: () async {
              String word = _textEditingController.text.trim();
              if (word.isNotEmpty) {
                EasyLoading.show(maskType: EasyLoadingMaskType.black);
                await getWordMeaning(word);
                EasyLoading.dismiss();
              }
            }, icon: Icon(Icons.search),color: Colors.blueAccent,style: IconButton.styleFrom(backgroundColor: Colors.white),),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            if(_meaning.isNotEmpty)Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _meaning,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: MeaningfulWordsList(),
            ),
          ],
        ),
      ),
    );
  }
}

class MeaningfulWordsList extends StatelessWidget {
  final List<String> words = [
    'Love',
    'Peace',
    'Happiness',
    'Friendship',
    'Family',
    'Kindness',
    'Gratitude',
    'Success',
    'Courage',
    'Empathy',
    'Compassion',
    'Resilience',
    'Generosity',
    'Wisdom',
    'Hope',
    'Optimism',
    'Freedom',
    'Equality',
    'Creativity',
    'Passion',
    'Inspiration',
    'Motivation',
    'Understanding',
    'Trust',
    'Faith',
    'Patience',
    'Confidence',
    'Joy',
    'Humility',
    'Contentment'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.favorite, color: Colors.deepPurpleAccent),
              title: Text(
                words[index],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              trailing: Icon(Icons.info_outline, color: Colors.deepPurple),
              onTap: () async {
                EasyLoading.show(maskType: EasyLoadingMaskType.black);
                await _showWordMeaningDialog(context, words[index]);
                EasyLoading.dismiss();
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showWordMeaningDialog(BuildContext context, String word) async {
    String meaning = await _fetchMeaning(word);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          title: Text(
            word,
            style: TextStyle(
              color: Colors.deepPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            meaning,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: TextStyle(color: Colors.deepPurple),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> _fetchMeaning(String word) async {
    String apiUrl = 'https://api.dictionaryapi.dev/api/v2/entries/en_US/$word';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> meanings = jsonDecode(response.body);
        if (meanings.isNotEmpty) {
          return meanings[0]['meanings'][0]['definitions'][0]['definition'];
        } else {
          return 'No meaning found for this word.';
        }
      } else {
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}

