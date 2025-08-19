// interpreter.dart

import 'ast.dart';
import 'lexer.dart';
import 'dart:math';
import 'dart:io';

class ReturnValue {
  final dynamic value;
  ReturnValue(this.value);
}

class Interpreter implements Visitor {
  List<Map<String, dynamic>> scopes = [{}];
  final Map<String, Map<String, dynamic>> libraries;

  Interpreter({this.libraries = const {}}) {
    _loadLibraries();
  }

  Map<String, dynamic> get currentScope => scopes.last;

  void _loadLibraries() {
    libraries.forEach((libName, libContent) {
      libContent.forEach((symbolName, symbolValue) {
        if (symbolValue is Function) {
          scopes[0][symbolName] = symbolValue;
        } else {
          scopes[0][symbolName] = symbolValue;
        }
      });
    });
  }

  @override
  dynamic visitNumberExpression(NumberExpression expr) => expr.value;
  @override
  dynamic visitBooleanExpression(BooleanExpression expr) => expr.value;
  @override
  dynamic visitStringExpression(StringExpression expr) => expr.value;

  @override
  dynamic visitBinaryExpression(BinaryExpression expr) {
    if (expr.operator.type == TokenType.OR) {
      final left = expr.left.accept(this);
      if (left is bool && left) return true;
      final right = expr.right.accept(this);
      return left || right;
    }
    if (expr.operator.type == TokenType.AND) {
      final left = expr.left.accept(this);
      if (left is bool && !left) return false;
      final right = expr.right.accept(this);
      return left && right;
    }

    final left = expr.left.accept(this);
    final right = expr.right.accept(this);

    if (expr.operator.type == TokenType.PLUS &&
        (left is String || right is String)) {
      return left.toString() + right.toString();
    }

    switch (expr.operator.type) {
      case TokenType.PLUS:
        return left + right;
      case TokenType.MINUS:
        return left - right;
      case TokenType.MULTIPLY:
        return left * right;
      case TokenType.DIVIDE:
        if (right == 0) throw Exception('Blad: Dzielenie przez zero.');
        return left / right;
      case TokenType.POWER:
        return pow(left, right);
      case TokenType.EQUAL_EQUAL:
        return left == right;
      case TokenType.XOR:
        return left ^ right;
      case TokenType.GREATER_THAN:
        return left > right;
      case TokenType.LESS_THAN:
        return left < right;
      case TokenType.GREATER_THAN_OR_EQUAL:
        return left >= right;
      case TokenType.LESS_THAN_OR_EQUAL:
        return left <= right;
      default:
        throw Exception('Blad: Nieznany operator.');
    }
  }

  @override
  dynamic visitUnaryExpression(UnaryExpression expr) {
    final right = expr.right.accept(this);
    switch (expr.operator.type) {
      case TokenType.NOT:
        if (right is! bool)
          throw Exception('Blad: Operator "!" wymaga wartosci logicznej.');
        return !right;
      case TokenType.MINUS:
        if (right is! num)
          throw Exception('Blad: Operator "-" wymaga wartosci numerycznej.');
        return -right;
      default:
        throw Exception('Blad: Nieznany operator unarny.');
    }
  }

  @override
  dynamic visitVariableExpression(VariableExpression expr) {
    for (var i = scopes.length - 1; i >= 0; i--) {
      if (scopes[i].containsKey(expr.name)) {
        return scopes[i][expr.name];
      }
    }
    throw Exception('Blad: Zmienna "${expr.name}" nie zostala zdefiniowana.');
  }

  @override
  dynamic visitAssignmentExpression(AssignmentExpression expr) {
    final value = expr.value.accept(this);
    for (var i = scopes.length - 1; i >= 0; i--) {
      if (scopes[i].containsKey(expr.name)) {
        scopes[i][expr.name] = value;
        return value;
      }
    }
    currentScope[expr.name] = value;
    return value;
  }

  @override
  dynamic visitIfStatement(IfStatement statement) {
    final condition = statement.condition.accept(this);
    if (condition is! bool)
      throw Exception(
          'Blad: Warunek w instrukcji "if" musi byc wartoscia logiczna.');
    if (condition) {
      for (final expr in statement.ifBlock) expr.accept(this);
    } else if (statement.elseBlock != null) {
      for (final expr in statement.elseBlock!) expr.accept(this);
    }
    return null;
  }

  @override
  dynamic visitWhileStatement(WhileStatement statement) {
    var conditionValue = statement.condition.accept(this);
    if (conditionValue is! bool)
      throw Exception(
          'Blad: Warunek w petli "while" musi byc wartoscia logiczna.');

    while (conditionValue) {
      for (final expr in statement.body) {
        expr.accept(this);
      }
      conditionValue = statement.condition.accept(this);
    }
    return null;
  }

  @override
  dynamic visitFunctionDeclaration(FunctionDeclaration declaration) {
    scopes[0][declaration.name] = declaration;
    return null;
  }

  @override
  dynamic visitFunctionCall(FunctionCall call) {
    if (call.name == 'print') {
      if (call.arguments.length != 1) {
        throw Exception('Blad: Funkcja print() oczekuje 1 argumentu.');
      }
      final value = call.arguments[0].accept(this);
      stdout.write(value);
      return null;
    }
    if (call.name == 'println') {
      if (call.arguments.length != 1) {
        throw Exception('Blad: Funkcja println() oczekuje 1 argumentu.');
      }
      final value = call.arguments[0].accept(this);
      stdout.writeln(value);
      return null;
    }
    if (call.name == 'input') {
      if (call.arguments.length > 1) {
        throw Exception(
            'Blad: Funkcja input() oczekuje maksymalnie 1 argumentu.');
      }
      if (call.arguments.isNotEmpty) {
        final prompt = call.arguments[0].accept(this);
        stdout.write(prompt);
      }
      return stdin.readLineSync();
    }
    if (call.name == 'length') {
      if (call.arguments.length != 1) {
        throw Exception('Blad: Funkcja length() oczekuje 1 argumentu.');
      }
      final value = call.arguments[0].accept(this);
      if (value is String) {
        return value.length.toDouble();
      }
      throw Exception(
          'Blad: Funkcja length() moze byc uzyta tylko na stringach.');
    }

    final func = scopes[0][call.name];
    if (func is Function) {
      final arguments = call.arguments.map((arg) => arg.accept(this)).toList();
      return func(arguments);
    }
    if (func is! FunctionDeclaration)
      throw Exception('Blad: "${call.name}" nie jest funkcja.');
    if (func.parameters.length != call.arguments.length) {
      throw Exception(
          'Blad: Funkcja "${call.name}" oczekuje ${func.parameters.length} argumentow, ale otrzymano ${call.arguments.length}.');
    }
    final newScope = <String, dynamic>{};
    for (var i = 0; i < func.parameters.length; i++) {
      newScope[func.parameters[i]] = call.arguments[i].accept(this);
    }
    scopes.add(newScope);
    try {
      for (final statement in func.body) {
        statement.accept(this);
      }
    } on ReturnValue catch (e) {
      scopes.removeLast();
      return e.value;
    }
    scopes.removeLast();
    return null;
  }

  @override
  dynamic visitMethodCall(MethodCall call) {
    final object = call.object.accept(this);
    if (call.methodName == 'toNumber') {
      if (call.arguments.isNotEmpty) {
        throw Exception('Blad: Metoda toNumber() nie przyjmuje argumentow.');
      }
      if (object is String) {
        try {
          return double.parse(object);
        } catch (_) {
          return -1.0;
        }
      }
    }
    if (call.methodName == 'toString') {
      if (call.arguments.isNotEmpty) {
        throw Exception('Blad: Metoda toString() nie przyjmuje argumentow.');
      }
      if (object is String || object is double || object is bool) {
        return object.toString();
      }
    }
    throw Exception(
        'Blad: Nieznana metoda "${call.methodName}" na obiekcie typu ${object.runtimeType}.');
  }

  @override
  dynamic visitReturnStatement(ReturnStatement statement) {
    final value = statement.value.accept(this);
    throw ReturnValue(value);
  }

  void interpret(List<Expression> program) {
    for (final expr in program) expr.accept(this);
  }
}
