// ast.dart

import 'lexer.dart';

abstract class Expression {
  dynamic accept(Visitor visitor);
}

class NumberExpression implements Expression {
  final double value;
  NumberExpression(this.value);
  @override
  dynamic accept(Visitor visitor) => visitor.visitNumberExpression(this);
}

class BooleanExpression implements Expression {
  final bool value;
  BooleanExpression(this.value);
  @override
  dynamic accept(Visitor visitor) => visitor.visitBooleanExpression(this);
}

class StringExpression implements Expression {
  final String value;
  StringExpression(this.value);
  @override
  dynamic accept(Visitor visitor) => visitor.visitStringExpression(this);
}

class BinaryExpression implements Expression {
  final Expression left;
  final Token operator;
  final Expression right;
  BinaryExpression(this.left, this.operator, this.right);
  @override
  dynamic accept(Visitor visitor) => visitor.visitBinaryExpression(this);
}

class UnaryExpression implements Expression {
  final Token operator;
  final Expression right;
  UnaryExpression(this.operator, this.right);
  @override
  dynamic accept(Visitor visitor) => visitor.visitUnaryExpression(this);
}

class VariableExpression implements Expression {
  final String name;
  VariableExpression(this.name);
  @override
  dynamic accept(Visitor visitor) => visitor.visitVariableExpression(this);
}

class AssignmentExpression implements Expression {
  final String name;
  final Expression value;
  AssignmentExpression(this.name, this.value);
  @override
  dynamic accept(Visitor visitor) => visitor.visitAssignmentExpression(this);
}

class IfStatement implements Expression {
  final Expression condition;
  final List<Expression> ifBlock;
  final List<Expression>? elseBlock;
  IfStatement(this.condition, this.ifBlock, this.elseBlock);
  @override
  dynamic accept(Visitor visitor) => visitor.visitIfStatement(this);
}

class WhileStatement implements Expression {
  final Expression condition;
  final List<Expression> body;
  WhileStatement(this.condition, this.body);
  @override
  dynamic accept(Visitor visitor) => visitor.visitWhileStatement(this);
}

class FunctionDeclaration implements Expression {
  final String name;
  final List<String> parameters;
  final List<Expression> body;
  FunctionDeclaration(this.name, this.parameters, this.body);
  @override
  dynamic accept(Visitor visitor) => visitor.visitFunctionDeclaration(this);
}

class FunctionCall implements Expression {
  final String name;
  final List<Expression> arguments;
  FunctionCall(this.name, this.arguments);
  @override
  dynamic accept(Visitor visitor) => visitor.visitFunctionCall(this);
}

class MethodCall implements Expression {
  final Expression object;
  final String methodName;
  final List<Expression> arguments;
  MethodCall(this.object, this.methodName, this.arguments);
  @override
  dynamic accept(Visitor visitor) => visitor.visitMethodCall(this);
}

class ReturnStatement implements Expression {
  final Expression value;
  ReturnStatement(this.value);
  @override
  dynamic accept(Visitor visitor) => visitor.visitReturnStatement(this);
}

abstract class Visitor {
  dynamic visitNumberExpression(NumberExpression expr);
  dynamic visitBooleanExpression(BooleanExpression expr);
  dynamic visitStringExpression(StringExpression expr);
  dynamic visitBinaryExpression(BinaryExpression expr);
  dynamic visitUnaryExpression(UnaryExpression expr);
  dynamic visitVariableExpression(VariableExpression expr);
  dynamic visitAssignmentExpression(AssignmentExpression expr);
  dynamic visitIfStatement(IfStatement statement);
  dynamic visitWhileStatement(WhileStatement statement);
  dynamic visitFunctionDeclaration(FunctionDeclaration declaration);
  dynamic visitFunctionCall(FunctionCall call);
  dynamic visitMethodCall(MethodCall call);
  dynamic visitReturnStatement(ReturnStatement statement);
}
