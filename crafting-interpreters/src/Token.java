package jlox;

class Token {
  TokenType type;
  String lexeme;
  Object value;

  Token(TokenType type, String lexeme) {
    this.type = type;
    this.lexeme = lexeme;
  }

  Token(TokenType type, String lexeme, Object value) {
    this.type = type;
    this.lexeme = lexeme;
    this.value = value;
  }

  @Override
  public String toString() {
    return this.type + " " + this.lexeme + " " + this.value;
  }
}
