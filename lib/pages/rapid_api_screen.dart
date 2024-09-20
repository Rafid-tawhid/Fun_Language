import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:my_messenger/providers/rapid_provider.dart';
import 'package:provider/provider.dart';

class RapidApiScreen extends StatefulWidget {
  const RapidApiScreen({super.key});

  @override
  State<RapidApiScreen> createState() => _RapidApiScreenState();
}

class _RapidApiScreenState extends State<RapidApiScreen> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final pro = Provider.of<RapidProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('GrammarBot'),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      final provider = Provider.of<RapidProvider>(context);
                      if (provider.fullResponse != null) {
                        print(provider.fullResponse.toString());
                        return Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: Container(
                              height: MediaQuery.sizeOf(context).height / 2,
                              child: SingleChildScrollView(
                                  child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      'Response',
                                      style: TextStyle(fontSize: 22),
                                    ),
                                  ),
                                  Text(
                                    provider.fullResponse,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ))),
                        );
                      } else {
                        return Text('Nothing to show');
                      }
                    });
              },
              icon: Icon(Icons.info_outline)),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (BuildContext context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
                      child: GrammarMistakesSheet(),
                    );
                  },
                );
              },
              icon: Icon(Icons.list)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  onPressed: () async {
                    if (controller.text.isNotEmpty) {
                      EasyLoading.show();
                      await pro.checkGrammar(controller.text.trim());
                      EasyLoading.dismiss();
                    }
                  },
                  child: Icon(Icons.search),
                ),
              ],
            ),
          ),
          Consumer<RapidProvider>(
            builder: (context, provider, _) {
              if (provider.grammarCheckResult != null) {
                // return Expanded(
                //     child: ListView.builder(
                //   itemCount: provider.grammarCheckResult!.matches.length,
                //   itemBuilder: (context, index) {
                //     final match = provider.grammarCheckResult!.matches[index];
                //     // return ListTile(
                //     //   title: Text(
                //     //     match.message,
                //     //     style: TextStyle(fontWeight: FontWeight.bold),
                //     //   ),
                //     //   subtitle: Column(
                //     //     crossAxisAlignment: CrossAxisAlignment.start,
                //     //     children: [
                //     //       Text('Sentence: ${match.sentence}'),
                //     //       Text('Mistake: ${provider.grammarCheckResult!.matches.first.shortMessage}'),
                //     //       // Text(
                //     //       //     'Offset: ${match.offset}, Length: ${match.length}'),
                //     //       Text(
                //     //           'Suggestion: ${match.replacements.isNotEmpty ? match.replacements[0].value : "N/A"}'),
                //     //     ],
                //     //   ),
                //     //   leading: Icon(Icons.error, color: Colors.red),
                //     //   trailing: Icon(Icons.arrow_forward),
                //     //   onTap: () {
                //     //     // Handle tap action
                //     //   },
                //     // );
                //
                //
                //   },
                // ));

                return Expanded(
                  child: ListView(
                    children: [
                      // ListTile(
                      //   title: Text('Software'),
                      //   subtitle: Text('Name: ${provider.grammarCheckResult!.software.name}\nVersion: ${provider.grammarCheckResult!.software.version}\nAPI Version: ${provider.grammarCheckResult!.software.apiVersion}\nPremium: ${provider.grammarCheckResult!.software.premium}\nPremium Hint: ${provider.grammarCheckResult!.software.premiumHint}\nStatus: ${provider.grammarCheckResult!.software.status}'),
                      // ),
                      ListTile(
                        title: Text('Warnings'),
                        subtitle: Text('Incomplete Results: ${provider.grammarCheckResult!.warnings.incompleteResults}'),
                      ),
                      ListTile(
                        title: Text('Language'),
                        subtitle: Text('Name: ${provider.grammarCheckResult!.language.name}\nDetected Language: ${provider.grammarCheckResult!.language.detectedLanguage.name} (${provider.grammarCheckResult!.language.detectedLanguage.code})'),
                      ),
                      ListTile(
                        title: Text('Matches (${provider.grammarCheckResult!.matches.length})'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: provider.grammarCheckResult!.matches.map((match) => Text('Message: ${match.message}\nShort Message: ${match.shortMessage}\nSentence: ${match.sentence}\nType: ${match.type.typeName}\nRule Description: ${match.rule.description}\n')).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Text('Nothing to show..');
              }
            },
          ),
        ],
      ),
    );

  }
}


class GrammarMistakesSheet extends StatelessWidget {
  final List<String> grammarMistakes = [
    'She don’t like pizza.',
    'We was going to the store.',
    'He go to school everyday.',
    'I didn’t went to the party.',
    'They has been here before.',
    'She didn’t saw the movie.',
    'He do not wants to go.',
    'We was playing football yesterday.',
    'There is too many people in the room.',
    'I seen her at the mall.'
  ];

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: "$text"'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: grammarMistakes.map((sentence) {
            return ListTile(
              title: Text(
                sentence,
                style: const TextStyle(fontSize: 16),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.blueAccent),
                onPressed: () => _copyToClipboard(context, sentence),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

void showGrammarMistakesModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7, // 70% of screen height
        child: GrammarMistakesSheet(),
      );
    },
  );
}