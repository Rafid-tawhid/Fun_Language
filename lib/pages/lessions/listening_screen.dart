import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ListeningScreen extends StatefulWidget {
  @override
  _ListeningScreenState createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  AudioPlayer? _currentPlayer;
  String? _currentUrl;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  PlayerState _playerState = PlayerState.stopped; // Track the current state of the player

  List<String> audioUrls = [
    "audio/sound1.mp3",
    "audio/sound2.mp3"
  ];

  List<String> audioNames = [
    "A1 English Listening Practice - Language Learning",
    "A1 English Listening Practice - Daily Routine"
  ];

  @override
  void initState() {
    super.initState();
    _currentPlayer = AudioPlayer();
    _currentPlayer?.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _currentPlayer?.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    _currentPlayer?.onPlayerStateChanged.listen((PlayerState s) {
      setState(() {
        _playerState = s; // Track changes in the player's state
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Listening Screen'),
      ),
      body: ListView.builder(
        itemCount: audioUrls.length,
        itemBuilder: (context, index) {
          final url = audioUrls[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    'images/bear.jpg',
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  audioNames[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: _currentUrl == url
                    ? Text(
                  '${_formatDuration(_position)} / ${_formatDuration(_duration)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                )
                    : Text(
                  'Track ${index + 1}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    _currentUrl == url && _playerState == PlayerState.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 36,
                  ),
                  color: Colors.blueAccent,
                  onPressed: () async {
                    EasyLoading.show();
                    await _playPauseTrack(url);
                    EasyLoading.dismiss();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _playPauseTrack(String url) async {
    if (_currentUrl == url && _playerState == PlayerState.playing) {
      // If the current track is playing, pause it
      await _currentPlayer!.pause();
    } else {
      // Stop the current track if another one is playing
      if (_currentUrl != url && _playerState == PlayerState.playing) {
        await _currentPlayer!.stop();
      }

      // Play the selected track
      await _currentPlayer!.play(AssetSource(url));

      setState(() {
        _currentUrl = url; // Update the current URL to the new track
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _currentPlayer?.dispose();
    super.dispose();
  }
}
