import 'dart:async';
import '../lib/languagetool.dart';
//import 'package:languagetool/languagetool.dart';

main() {
  LanguageTool lt = new LanguageTool('../LanguageTool-2.3');
  lt.start().then((_) => lt.proofread('sample sentence')
      .onData((String result) => print(result)));
}