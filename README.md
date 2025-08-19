# Speed-Language-interpreter
## 🚀 Wprowadzenie do Speed Language 🇵🇱

**Speed Language** to prosty, interpretowany język programowania stworzony w Dart, idealny do nauki podstawowych koncepcji kompilatorów i interpreterów. Język ten ma przejrzystą składnię, która pozwala na łatwe pisanie programów, a jego architektura modułowa (leksykalna analiza, parsowanie, interpretacja) ułatwia zrozumienie, jak działa kod od A do Z.

-----

## 🛠️ Architektura

Interpreter **Speed Language** składa się z trzech głównych komponentów:

1.  **Lexer (`lexer.dart`)**: Komponent odpowiedzialny za **tokenizację**. Przekształca surowy kod źródłowy w serię tokenów. Na przykład, `x = 5 + 3` staje się listą tokenów: `IDENTIFIER(x)`, `ASSIGN(=)`, `NUMBER(5)`, `PLUS(+)`, `NUMBER(3)`.
2.  **Parser (`parser.dart`)**: Komponent do **parsowania**. Na podstawie listy tokenów tworzy **abstrakcyjne drzewo składni** (AST - Abstract Syntax Tree). Drzewo AST jest hierarchiczną reprezentacją struktury kodu, która ułatwia jego późniejszą interpretację.
3.  **Interpreter (`interpreter.dart`)**: Komponent do **interpretacji**. Przechodzi przez drzewo AST i wykonuje zdefiniowane operacje, zarządzając zmiennymi i funkcjami w ramach lokalnych i globalnych zasięgów (scopes).

-----

## 📝 Jak pisać programy

### Składnia i typy danych

Speed Language obsługuje podstawowe typy danych i operacje:

  - **Liczby (`Number`)**: Obsługuje liczby zmiennoprzecinkowe (np. `10`, `3.14`).
  - **Wartości logiczne (`Boolean`)**: `true` i `false`.
  - **Łańcuchy znaków (`String`)**: Tekst w cudzysłowach (np. `"Hello World"`).
  - **Komentarze**: Zaczynają się od `#` i trwają do końca linii.

### Podstawowe operacje

Język wspiera standardowe operatory arytmetyczne i logiczne:

  * **Arytmetyczne**: `+` (dodawanie), `-` (odejmowanie), `*` (mnożenie), `/` (dzielenie), `^` (potęgowanie).
  * **Porównania**: `==` (równe), `>` (większe niż), `<` (mniejsze niż), `>=` (większe lub równe), `<=` (mniejsze lub równe).
  * **Logiczne**: `&&` (i logiczne), `||` (lub logiczne), `!` (negacja logiczna), `^` (alternatywa wykluczająca - XOR).

### Zmienne i przypisania

Zmienne są deklarowane i inicjalizowane za pomocą operatora `=`.

```
# Deklaracja i przypisanie zmiennej 'x'
x = 10
```

### Instrukcje warunkowe i pętle

  * **`if`/`else`**: Standardowa instrukcja warunkowa. Blok kodu jest otoczony nawiasami klamrowymi `{}`.
    ```
    if (x > 5) {
      println("x jest wieksze od 5");
    } else {
      println("x jest mniejsze lub rowne 5");
    }
    ```
  * **`while`**: Pętla, która wykonuje blok kodu tak długo, jak warunek jest prawdziwy.
    ```
    while (x < 15) {
      println("x jest: " + x.toString());
      x = x + 1;
    }
    ```

### Funkcje

Funkcje są definiowane przez podanie nazwy, listy parametrów w nawiasach `()` i bloku kodu w nawiasach klamrowych `{}`.

```
# Definicja funkcji o nazwie 'add', ktora przyjmuje dwa parametry: 'a' i 'b'
add(a, b) {
  return a + b;
}

# Wywolanie funkcji i przypisanie wyniku do zmiennej 'result'
result = add(5, 3);
println(result);
```

### Wbudowane funkcje i metody

Język posiada kilka wbudowanych funkcji:

  * **`print(argument)`**: Wypisuje argument na standardowe wyjście, bez nowej linii.
  * **`println(argument)`**: Wypisuje argument na standardowe wyjście i dodaje nową linię.
  * **`input(prompt)`**: Prosi użytkownika o wprowadzenie danych. Opcjonalny argument `prompt` wyświetla komunikat przed oczekiwaniem na dane.
  * **`length(string)`**: Zwraca długość podanego stringa.

Metody obiektów:

  * **`string.toNumber()`**: Próbuje przekonwertować string na liczbę. Zwraca `-1.0` w przypadku niepowodzenia.
  * **`number.toString()`**: Konwertuje liczbę na string.
  * **`boolean.toString()`**: Konwertuje wartość logiczną na string.

-----

### 🏃 Jak uruchomić

Aby uruchomić program napisany w Speed Language, użyj skompilowanego pliku binarnego `speedlanguage.out` i podaj ścieżkę do pliku z rozszerzeniem `.spd`.

```
# Uruchomienie pliku 'example.spd'
./speedlanguage.out example.spd
```

Projekt został napisany przez Kamila Malickiego.
