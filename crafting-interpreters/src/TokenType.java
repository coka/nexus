package jlox;

enum TokenType {
  // Standalone tokens.
  LEFT_PAREN,
  RIGHT_PAREN,
  LEFT_BRACE,
  RIGHT_BRACE,
  DOT,
  COMMA,
  SEMICOLON,
  PLUS,
  MINUS,
  STAR,

  // Tokens requiring lookahead.
  SLASH,
  LESS,
  GREATER,
  LESS_EQUAL,
  GREATER_EQUAL,
  EQUAL_EQUAL,
  BANG_EQUAL,

  // Literals.
  NUMBER,
  STRING,
  IDENTIFIER,

  // Keywords.
  AND,
  CLASS,
  ELSE,
  FALSE,
  FOR,
  FUN,
  IF,
  NIL,
  OR,
  RETURN,
  SUPER,
  THIS,
  TRUE,
  VAR,
  WHILE,

  // Required for tests.
  EOF
}
