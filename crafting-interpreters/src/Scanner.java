package jlox;

import static jlox.TokenType.*;

import java.util.ArrayList;

class Scanner {
  String source;

  /** Scanner position. The source character at this position will be read next. */
  private int index;

  /** Beggining of the current lexeme. */
  private int start;

  Scanner(String source) {
    this.source = source;
    this.index = 0;
    this.start = 0;
  }

  ArrayList<Token> scan() {
    ArrayList<Token> tokens = new ArrayList<Token>();
    while (!this.done()) {
      this.start = this.index;
      char c = this.read();
      if (Character.isWhitespace(c)) continue;
      switch (c) {
        case '(':
          tokens.add(this.tokenize(LEFT_PAREN));
          continue;
        case ')':
          tokens.add(this.tokenize(RIGHT_PAREN));
          continue;
        case '{':
          tokens.add(this.tokenize(LEFT_BRACE));
          continue;
        case '}':
          tokens.add(this.tokenize(RIGHT_BRACE));
          continue;
        case '.':
          tokens.add(this.tokenize(DOT));
          continue;
        case ',':
          tokens.add(this.tokenize(COMMA));
          continue;
        case ';':
          tokens.add(this.tokenize(SEMICOLON));
          continue;
        case '+':
          tokens.add(this.tokenize(PLUS));
          continue;
        case '-':
          tokens.add(this.tokenize(MINUS));
          continue;
        case '*':
          tokens.add(this.tokenize(STAR));
          continue;
        case '/':
          if (this.peek() == '/') {
            this.scanComment();
          } else {
            tokens.add(this.tokenize(SLASH));
          }
          continue;
        case '<':
          if (this.peek() == '=') {
            this.read();
            tokens.add(this.tokenize(LESS_EQUAL));
          } else {
            tokens.add(this.tokenize(LESS));
          }
          continue;
        case '>':
          if (this.peek() == '=') {
            this.read();
            tokens.add(this.tokenize(GREATER_EQUAL));
          } else {
            tokens.add(this.tokenize(GREATER));
          }
          continue;
        case '=':
          this.read();
          tokens.add(this.tokenize(EQUAL_EQUAL));
          continue;
        case '!':
          this.read();
          tokens.add(this.tokenize(BANG_EQUAL));
          continue;
      }
      if (Character.isDigit(c)) {
        tokens.add(this.scanNumber());
      } else if (c == '"') {
        tokens.add(this.scanString());
      } else {
        tokens.add(this.scanAlphanumeric());
      }
    }
    tokens.add(new Token(EOF, ""));
    return tokens;
  }

  private boolean done() {
    return this.index == this.source.length();
  }

  private char read() {
    char c = this.source.charAt(this.index);
    this.index = this.index + 1;
    return c;
  }

  private char peek() {
    if (this.done()) {
      return '\0';
    } else {
      return this.source.charAt(this.index);
    }
  }

  private char peekNext() {
    if (this.index >= this.source.length() - 1) {
      return '\0';
    } else {
      return this.source.charAt(this.index + 1);
    }
  }

  private String getCurrentLexeme() {
    return this.source.substring(this.start, this.index);
  }

  private Token tokenize(TokenType type) {
    return new Token(type, this.getCurrentLexeme());
  }

  private void scanComment() {
    while (true) {
      if (this.peek() == '\n') break;
      if (this.done()) break;
      this.read();
    }
  }

  private Token scanNumber() {
    while (Character.isDigit(this.peek())) this.read();
    boolean hasFractionalPart = this.peek() == '.' && Character.isDigit(this.peekNext());
    if (hasFractionalPart) {
      this.read(); // '.'
      while (Character.isDigit(this.peek())) this.read();
    }
    String lexeme = this.getCurrentLexeme();
    Object value = Double.parseDouble(lexeme);
    return new Token(NUMBER, lexeme, value);
  }

  private Token scanString() {
    while (this.read() != '"') {}
    String lexeme = this.getCurrentLexeme();
    Object value = lexeme.substring(1, lexeme.length() - 1);
    return new Token(STRING, lexeme, value);
  }

  private Token scanAlphanumeric() {
    while (!Character.isWhitespace(this.peek())) this.read();
    String lexeme = this.getCurrentLexeme();
    return new Token(Keywords.getTokenType(lexeme, IDENTIFIER), lexeme);
  }
}
