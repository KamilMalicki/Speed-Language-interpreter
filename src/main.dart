// main.dart

import 'dart:io';
import 'lexer.dart';
import 'parser.dart';
import 'interpreter.dart';
import './libs/math_libs.dart' as math_lib;

void main(List<String> arguments) {
  print("Speed Language - Wersja 1.0 (autor: Kamil Malicki)");
  print("https://github.com/KamilMalicki");
  print("");

  if (arguments.isEmpty) {
    print("Uzycie: ./main.exe <nazwa_pliku>");
    return;
  }

  final String filePath = arguments[0];
  if (!File(filePath).existsSync()) {
    print("Blad: Plik '$filePath' nie istnieje.");
    return;
  }

  try {
    final String sourceCode = File(filePath).readAsStringSync();
    //print("--- Etap 1: Tokenizacja ---");
    //print("Kod zrodlowy z pliku:");
    //print("-------------------------");
    //print(sourceCode);
    //print("-------------------------");

    final lexer = Lexer(sourceCode);
    final tokens = lexer.tokenize();
    //print("Wynik tokenizacji: $tokens");
    //print("");

    //print("--- Etap 2: Parsowanie ---");
    final parser = Parser(tokens);
    final ast = parser.parseProgram();
    //print("Wynik parsowania: Pomyslnie utworzono drzewo AST.");
    //print("");
    
    //print("--- Etap 3: Interpretacja ---");
    // Przekazanie wbudowanych bibliotek do interpretera
    final interpreter = Interpreter(libraries: {
      'math': {
        ...math_lib.functions,
        ...math_lib.variables,
      }
    });
    interpreter.interpret(ast);

    //print("--- Koniec programu ---");
  } catch (e) {
    print("Błąd: Wystapil nieoczekiwany problem.");
    print("Exception: $e");
  }
}