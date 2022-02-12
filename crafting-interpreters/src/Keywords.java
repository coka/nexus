package jlox;

import static jlox.TokenType.*;

import java.util.HashMap;

class Keywords {
  private static HashMap<String, TokenType> keywords;

  static {
    keywords = new HashMap<String, TokenType>();
    keywords.put("and", AND);
    keywords.put("class", CLASS);
    keywords.put("else", ELSE);
    keywords.put("false", FALSE);
    keywords.put("for", FOR);
    keywords.put("fun", FUN);
    keywords.put("if", IF);
    keywords.put("nil", NIL);
    keywords.put("or", OR);
    keywords.put("return", RETURN);
    keywords.put("super", SUPER);
    keywords.put("this", THIS);
    keywords.put("true", TRUE);
    keywords.put("var", VAR);
    keywords.put("while", WHILE);
  }

  static TokenType getTokenType(String lexeme, TokenType defaultType) {
    TokenType keywordType = keywords.get(lexeme);
    if (keywordType != null) {
      return keywordType;
    } else {
      return defaultType;
    }
  }
}
