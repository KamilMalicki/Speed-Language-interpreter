// lexer.dart

enum TokenType {
  NUMBER,
  PLUS,
  MINUS,
  MULTIPLY,
  DIVIDE,
  POWER,
  EQUAL_EQUAL,
  OR,
  NOT,
  XOR,
  GREATER_THAN,
  LESS_THAN,
  GREATER_THAN_OR_EQUAL,
  LESS_THAN_OR_EQUAL,
  LPAREN,
  RPAREN,
  LBRACE,
  RBRACE,
  COMMA,
  DOT,
  IDENTIFIER,
  ASSIGN,
  IF,
  ELSE,
  WHILE,
  RETURN,
  TRUE,
  FALSE,
  STRING,
  EOF,
  AND,
}

class Token {
  final TokenType type;
  final String value;

  Token(this.type, this.value);

  @override
  String toString() => 'Token($type, "$value")';
}

class Lexer {
  final String text;
  int pos = 0;

  Lexer(this.text);

  String _peek() {
    if (pos >= text.length) {
      return '';
    }
    return text[pos];
  }

  String _readChar() {
    if (pos >= text.length) {
      return '';
    }
    return text[pos++];
  }

  Token _processIdentifier() {
    String identifier = '';
    while (pos < text.length && (RegExp(r'[a-zA-Z_]').hasMatch(_peek()) || RegExp(r'\d').hasMatch(_peek()))) {
      identifier += _readChar();
    }
    switch (identifier) {
      case 'true':
        return Token(TokenType.TRUE, 'true');
      case 'false':
        return Token(TokenType.FALSE, 'false');
      case 'if':
        return Token(TokenType.IF, 'if');
      case 'else':
        return Token(TokenType.ELSE, 'else');
      case 'while':
        return Token(TokenType.WHILE, 'while');
      case 'return':
        return Token(TokenType.RETURN, 'return');
      default:
        return Token(TokenType.IDENTIFIER, identifier);
    }
  }

  Token _processNumber() {
    String number = '';
    while (pos < text.length && (RegExp(r'\d').hasMatch(_peek()) || _peek() == '.')) {
      number += _readChar();
    }
    return Token(TokenType.NUMBER, number);
  }

  Token _processString() {
    String value = '';
    _readChar();
    while (pos < text.length && _peek() != '"') {
      if (_peek() == '\\') {
        _readChar();
        final nextChar = _readChar();
        switch (nextChar) {
          case 'n':
            value += '\n';
            break;
          case 't':
            value += '\t';
            break;
          case '\\':
            value += '\\';
            break;
          default:
            throw Exception('Błąd leksykalny: Nieznana sekwencja specjalna \\$nextChar');
        }
      } else {
        value += _readChar();
      }
    }
    if (pos >= text.length || _peek() != '"') {
      throw Exception('Błąd leksykalny: Nieoczekiwany koniec pliku lub brak zamykającego cudzysłowu.');
    }
    _readChar();
    return Token(TokenType.STRING, value);
  }

  Token _getNextToken() {
    while (pos < text.length) {
      final char = _peek();
      if (RegExp(r'\s').hasMatch(char)) {
        pos++;
      } else if (char == '#') {
        while (pos < text.length && _peek() != '\n') {
          pos++;
        }
      } else {
        break;
      }
    }

    if (pos >= text.length) {
      return Token(TokenType.EOF, '');
    }

    final char = _peek();

    if (RegExp(r'\d').hasMatch(char)) {
      return _processNumber();
    }
    if (RegExp(r'[a-zA-Z_]').hasMatch(char)) {
      return _processIdentifier();
    }
    if (char == '"') {
      return _processString();
    }
    
    _readChar();

    if (char == '=') {
      if (_peek() == '=') {
        _readChar();
        return Token(TokenType.EQUAL_EQUAL, '==');
      }
      return Token(TokenType.ASSIGN, '=');
    }
    if (char == '&') {
      if (_peek() == '&') {
        _readChar();
        return Token(TokenType.AND, '&&');
      }
    }
    if (char == '|') {
      if (_peek() == '|') {
        _readChar();
        return Token(TokenType.OR, '||');
      }
    }
    if (char == '^') {
      return Token(TokenType.POWER, '^');
    }
    if (char == '!') {
      return Token(TokenType.NOT, '!');
    }
    if (char == '+') {
      return Token(TokenType.PLUS, '+');
    }
    if (char == '-') {
      return Token(TokenType.MINUS, '-');
    }
    if (char == '*') {
      return Token(TokenType.MULTIPLY, '*');
    }
    if (char == '/') {
      return Token(TokenType.DIVIDE, '/');
    }
    if (char == '(') {
      return Token(TokenType.LPAREN, '(');
    }
    if (char == ')') {
      return Token(TokenType.RPAREN, ')');
    }
    if (char == '{') {
      return Token(TokenType.LBRACE, '{');
    }
    if (char == '}') {
      return Token(TokenType.RBRACE, '}');
    }
    if (char == '>') {
      if (_peek() == '=') {
        _readChar();
        return Token(TokenType.GREATER_THAN_OR_EQUAL, '>=');
      }
      return Token(TokenType.GREATER_THAN, '>');
    }
    if (char == '<') {
      if (_peek() == '=') {
        _readChar();
        return Token(TokenType.LESS_THAN_OR_EQUAL, '<=');
      }
      return Token(TokenType.LESS_THAN, '<');
    }
    if (char == ',') {
      return Token(TokenType.COMMA, ',');
    }
    if (char == '.') {
      return Token(TokenType.DOT, '.');
    }

    throw Exception('Błąd leksykalny: Nieznany znak "$char"');
  }

  List<Token> tokenize() {
    final tokens = <Token>[];
    Token token = _getNextToken();
    while (token.type != TokenType.EOF) {
      tokens.add(token);
      token = _getNextToken();
    }
    tokens.add(token);
    return tokens;
  }
}