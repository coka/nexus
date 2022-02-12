package jlox;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;

class Interpreter {
  public static void main(String[] args) throws IOException {
    var source = new String(Files.readAllBytes(Paths.get(args[0])), StandardCharsets.UTF_8.name());
    var tokens = new Scanner(source).scan();
    for (var t : tokens) {
      System.out.println(t);
    }
  }
}
