// parser.dart

import 'ast.dart';
import 'lexer.dart';

class Parser {
  final List<Token> tokens;
  int pos = 0;

  Parser(this.tokens);

  Token get _currentToken => tokens[pos];

  Token _consume(TokenType type) {
    if (_currentToken.type == type) {
      final token = _currentToken;
      pos++;
      return token;
    }
    throw Exception('Blad parsowania: Oczekiwano $type, ale otrzymano ${_currentToken.type}');
  }

  Token _peek(int offset) {
    if (pos + offset >= tokens.length) {
      return Token(TokenType.EOF, '');
    }
    return tokens[pos + offset];
  }

  Expression _parsePrimary() {
    var expr;
    if (_currentToken.type == TokenType.NUMBER) {
      final token = _consume(TokenType.NUMBER);
      expr = NumberExpression(double.parse(token.value));
    } else if (_currentToken.type == TokenType.TRUE) {
      _consume(TokenType.TRUE);
      expr = BooleanExpression(true);
    } else if (_currentToken.type == TokenType.FALSE) {
      _consume(TokenType.FALSE);
      expr = BooleanExpression(false);
    } else if (_currentToken.type == TokenType.STRING) {
      final token = _consume(TokenType.STRING);
      expr = StringExpression(token.value);
    } else if (_currentToken.type == TokenType.IDENTIFIER) {
      if (_peek(1).type == TokenType.LPAREN) {
        expr = _parseFunctionCall();
      } else {
        final token = _consume(TokenType.IDENTIFIER);
        expr = VariableExpression(token.value);
      }
    } else if (_currentToken.type == TokenType.LPAREN) {
      _consume(TokenType.LPAREN);
      expr = _parseLogicalOR();
      _consume(TokenType.RPAREN);
    } else {
        throw Exception('Blad parsowania: Nieoczekiwany token ${_currentToken.type}');
    }

    while (_currentToken.type == TokenType.DOT) {
      _consume(TokenType.DOT);
      if (_currentToken.type != TokenType.IDENTIFIER) {
        throw Exception('Blad parsowania: Oczekiwano nazwy metody po kropce.');
      }
      final methodName = _consume(TokenType.IDENTIFIER).value;
      if (_currentToken.type == TokenType.LPAREN) {
        _consume(TokenType.LPAREN);
        final arguments = <Expression>[];
        if (_currentToken.type != TokenType.RPAREN) {
          do {
            arguments.add(_parseLogicalOR());
          } while (_currentToken.type == TokenType.COMMA && _consume(TokenType.COMMA).type == TokenType.COMMA);
        }
        _consume(TokenType.RPAREN);
        expr = MethodCall(expr, methodName, arguments);
      } else {
          throw Exception('Blad parsowania: Oczekiwano nawiasu po nazwie metody.');
      }
    }
    return expr;
  }

  Expression _parseUnary() {
    if (_currentToken.type == TokenType.NOT || _currentToken.type == TokenType.MINUS) {
      final operator = _currentToken;
      _consume(operator.type);
      final right = _parseUnary();
      return UnaryExpression(operator, right);
    }
    var left = _parsePrimary();
    while (_currentToken.type == TokenType.POWER) {
      final operator = _consume(TokenType.POWER);
      final right = _parseUnary();
      left = BinaryExpression(left, operator, right);
    }
    return left;
  }

  Expression _parseMultiplicative() {
    var left = _parseUnary();
    while (_currentToken.type == TokenType.MULTIPLY || _currentToken.type == TokenType.DIVIDE) {
      final operator = _currentToken;
      if (operator.type == TokenType.MULTIPLY) {
        _consume(TokenType.MULTIPLY);
      } else {
        _consume(TokenType.DIVIDE);
      }
      var right = _parseUnary();
      left = BinaryExpression(left, operator, right);
    }
    return left;
  }

  Expression _parseAdditive() {
    var left = _parseMultiplicative();
    while (_currentToken.type == TokenType.PLUS || _currentToken.type == TokenType.MINUS) {
      final operator = _currentToken;
      if (operator.type == TokenType.PLUS) {
        _consume(TokenType.PLUS);
      } else {
        _consume(TokenType.MINUS);
      }
      var right = _parseMultiplicative();
      left = BinaryExpression(left, operator, right);
    }
    return left;
  }

  Expression _parseComparison() {
    var left = _parseAdditive();
    if (_currentToken.type == TokenType.GREATER_THAN ||
        _currentToken.type == TokenType.LESS_THAN ||
        _currentToken.type == TokenType.GREATER_THAN_OR_EQUAL ||
        _currentToken.type == TokenType.LESS_THAN_OR_EQUAL) {
      final operator = _currentToken;
      _consume(operator.type);
      final right = _parseAdditive();
      left = BinaryExpression(left, operator, right);
    }
    return left;
  }

  Expression _parseEquality() {
    var left = _parseComparison();
    if (_currentToken.type == TokenType.EQUAL_EQUAL) {
      final operator = _consume(TokenType.EQUAL_EQUAL);
      final right = _parseComparison();
      left = BinaryExpression(left, operator, right);
    }
    return left;
  }

  Expression _parseLogicalXOR() {
    var left = _parseEquality();
    while (_currentToken.type == TokenType.XOR) {
      final operator = _consume(TokenType.XOR);
      final right = _parseEquality();
      left = BinaryExpression(left, operator, right);
    }
    return left;
  }

  Expression _parseLogicalAND() {
    var left = _parseLogicalXOR();
    while (_currentToken.type == TokenType.AND) {
      final operator = _consume(TokenType.AND);
      final right = _parseLogicalXOR();
      left = BinaryExpression(left, operator, right);
    }
    return left;
  }

  Expression _parseLogicalOR() {
    var left = _parseLogicalAND();
    while (_currentToken.type == TokenType.OR) {
      final operator = _consume(TokenType.OR);
      final right = _parseLogicalAND();
      left = BinaryExpression(left, operator, right);
    }
    return left;
  }

  List<Expression> _parseBlock() {
    _consume(TokenType.LBRACE);
    final expressions = <Expression>[];
    while (_currentToken.type != TokenType.RBRACE) {
      if (_currentToken.type == TokenType.EOF) {
        throw Exception('Blad parsowania: Oczekiwano "}", ale otrzymano EOF.');
      }
      expressions.add(_parseStatement());
    }
    _consume(TokenType.RBRACE);
    return expressions;
  }

  FunctionCall _parseFunctionCall() {
    final nameToken = _consume(TokenType.IDENTIFIER);
    _consume(TokenType.LPAREN);
    final arguments = <Expression>[];
    if (_currentToken.type != TokenType.RPAREN) {
      do {
        arguments.add(_parseLogicalOR());
      } while (_currentToken.type == TokenType.COMMA && _consume(TokenType.COMMA).type == TokenType.COMMA);
    }
    _consume(TokenType.RPAREN);
    return FunctionCall(nameToken.value, arguments);
  }

  FunctionDeclaration _parseFunctionDeclaration() {
    final nameToken = _consume(TokenType.IDENTIFIER);
    _consume(TokenType.LPAREN);
    final parameters = <String>[];
    if (_currentToken.type != TokenType.RPAREN) {
      do {
        parameters.add(_consume(TokenType.IDENTIFIER).value);
      } while (_currentToken.type == TokenType.COMMA && _consume(TokenType.COMMA).type == TokenType.COMMA);
    }
    _consume(TokenType.RPAREN);
    final body = _parseBlock();
    return FunctionDeclaration(nameToken.value, parameters, body);
  }

  ReturnStatement _parseReturnStatement() {
    _consume(TokenType.RETURN);
    final value = _parseLogicalOR();
    return ReturnStatement(value);
  }

  WhileStatement _parseWhileStatement() {
    _consume(TokenType.WHILE);
    _consume(TokenType.LPAREN);
    final condition = _parseLogicalOR();
    _consume(TokenType.RPAREN);
    final body = _parseBlock();
    return WhileStatement(condition, body);
  }

  Expression _parseStatement() {
    if (_currentToken.type == TokenType.IF) {
        _consume(TokenType.IF);
        _consume(TokenType.LPAREN);
        final condition = _parseLogicalOR();
        _consume(TokenType.RPAREN);
        final ifBlock = _parseBlock();
        List<Expression>? elseBlock;
        if (_currentToken.type == TokenType.ELSE) {
            _consume(TokenType.ELSE);
            elseBlock = _parseBlock();
        }
        return IfStatement(condition, ifBlock, elseBlock);
    }
    if (_currentToken.type == TokenType.WHILE) {
        return _parseWhileStatement();
    }
    if (_currentToken.type == TokenType.RETURN) {
        return _parseReturnStatement();
    }
    if (_currentToken.type == TokenType.IDENTIFIER && _peek(1).type == TokenType.LPAREN) {
        final int initialPos = pos;
        try {
            _parseFunctionDeclaration();
            pos = initialPos;
            return _parseFunctionDeclaration();
        } catch (_) {
            pos = initialPos;
            return _parseFunctionCall();
        }
    }

    if (_currentToken.type == TokenType.IDENTIFIER && _peek(1).type == TokenType.ASSIGN) {
        final nameToken = _consume(TokenType.IDENTIFIER);
        _consume(TokenType.ASSIGN);
        final valueExpr = _parseLogicalOR();
        return AssignmentExpression(nameToken.value, valueExpr);
    }
    
    return _parseLogicalOR();
  }

  List<Expression> parseProgram() {
    final statements = <Expression>[];
    while (_currentToken.type != TokenType.EOF) {
      statements.add(_parseStatement());
    }
    return statements;
  }
}