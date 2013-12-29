import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:observe/observe.dart';

class LanguageTool extends Object with ChangeNotifier {
  String LanguageToolPath;
  String _inputText = ''; 
  @reflectable get inputText => _inputText;
  @reflectable set inputText(val) {
    _inputText = notifyPropertyChange(#inputText, _inputText, val);
  }
  String _outputText = ''; 
  @reflectable get outputText => _outputText;
  @reflectable set outputText(val) {
    _outputText = notifyPropertyChange(#outputText, _outputText, val);
  }
  StreamSubscription<String> outputStreamSub;
  
  LanguageTool(String this.LanguageToolPath) {
    outputStreamSub = this.changes.where((List<ChangeRecord> record) => new RegExp(r'outputText').hasMatch(record.join(',')))
                      .map((e) => e.toString().replaceAllMapped(new RegExp(r'(^(?:.|\n)+to:  ?)|(^(?:.|\n)+from: )|(.+$)', caseSensitive: false), (Match m) => ''))
                        .listen((List<ChangeRecord> record) {
                        });
  }
    
  Future<bool> start() {
    Completer compl = new Completer();
    compl.complete(
    Process.start(
        'java',
        ['-jar',
         '$LanguageToolPath/languagetool-commandline.jar',
         '-l',
         'en',
         '--api'
        ],
        runInShell: true).then((process) {
          process.stdout
          .transform(new Utf8Decoder())
              .listen((String line) => outputText = line);
          this.changes.listen((List<ChangeRecord> record) {
            if (new RegExp(r'inputText').hasMatch(record[0].toString())) {
              process.stdin.writeln(inputText);
              process.stdin.writeln();
            }
          });
        })
        );
    return compl.future;
  }
  
  StreamSubscription<String> proofread(String text) {
    inputText = text;
    return outputStreamSub;
  }
}




