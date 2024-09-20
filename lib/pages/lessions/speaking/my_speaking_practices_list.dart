import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_messenger/providers/speech_provider.dart';
import 'package:provider/provider.dart';

class MySpeakingPractices extends StatefulWidget {


  @override
  State<MySpeakingPractices> createState() => _MySpeakingPracticesState();
}

class _MySpeakingPracticesState extends State<MySpeakingPractices> {
  final FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;



  @override
  void initState() {
    super.initState();

    initTTS();
   Future.microtask((){
     getAllSpeakingData();
   });
  }

  void initTTS() {
    _flutterTts.getVoices.then((data) {
      try {
        List<Map> _voices = List<Map>.from(data);
        _voices = _voices.where((_voice) => _voice["name"].contains("en")).toList();
        setState(() {
          _currentVoice = _voices.first;
          setVoice(_currentVoice!);
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Practices'),
      ),
      body: Consumer<SpeechProvider>(
        builder: (context,pro,_)=>pro.isLoading?Center(child: CircularProgressIndicator(),): ListView.builder(
          itemCount: pro.speakingPracList.length,
          itemBuilder: (context, index) => Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            color: pro.isPlayingList[index] ? Colors.blue.shade50 : Colors.white,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent,
                radius: 18,
                child: Text(
                  (index + 1).toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                pro.speakingPracList[index]['text'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: pro.isPlayingList[index] ? Colors.blueAccent : Colors.black87,
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  pro.setLoadingIndex(index);

                  if (pro.isPlayingList[index]) {
                    _flutterTts.speak(pro.speakingPracList[index]['text']);
                  } else {
                    _flutterTts.stop();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: pro.isPlayingList[index] ? Colors.blueAccent : Colors.grey[300],
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    pro.isPlayingList[index] ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        )
      ));
  }

  void getAllSpeakingData() async{
    SpeechProvider provider;
    provider=Provider.of(context,listen: false);
   await provider.setIsLoading(true);
   await provider.getSpeechPractices();
    provider.setIsLoading(false);
  }
}

