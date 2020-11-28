
# ZBD 2020 Zadanie 2

Termin 6 grudnia

## Dane

Proszę wygenerować plik z danymi mający następujące kolumny:
* data (np. 2020-01-01, 2020-01-02, ...
* kategoria (np. A, B, ...
* wartość 1
* ....
* wartość n

Wartości niech będą liczbami całkowitymi, generowanymi poprzez zaokrąglenie wartości losowanych z rozkładu normalnego.

Intuicja:
* kategoria to informacja o tym co mierzymy np. liczba pasażerów na lotnisku Jasionka, liczba pasażerów na lotnisku Okęcie
* wartość_i to konkretna liczba, np. całkowita liczba pasażerów, liczba pasażerów w wieku 10-20, ...

## Program

Mamy napisać program, który odpowiada na dwie kategorie zapytań:
* jaka jest suma wartości k w przedziale dat od, do (dla danych parametrów: k, od, do)
* jaka jest suma wartości  k kategorii i w przedziale dat od, do (dla dacztery parametry: k, od, do, kategoria)

Czyli w SQL to by było na przykład w drugiej kategorii:
```sql
SELECT SUM(wartosc_6) FROM dane WHERE data BETWEEN '2020-01-05' AND '2020-01-08' AND kategoria = 'C';
```

## Zadanie

Proszę rozwiązać to zadanie na trzy różne sposoby, porównując wydajność każdego z nich w zależności od wybranych parametrów
1. Korzystając z file_fdw i operując bezpośrednio na wygenerowanym pliku CSV
2. Korzystając z jednej i tylko jednej tabeli (można założyć dodatkowe indeksy, ...) w postgresie
3. Korzystając z rozszerzenia cstore_fdw (działa tylko w postgresie 12!)

Proszę przygotować raport o wydajności każdego z tych rozwiązań. Rozwiązanie ma być jednym plikiem PDF z opisem,  wykresami i takimi tam.

Porównanie wydajności powinno uwzględniać co najmniej takie pytania:
* co się dzieje jak w tabeli jest tylko jedna kolumna, a co jak tych kolumn jest kilkaset (bonus: ile maksymalnie kolumn może być w tej tabeli)?
* co się dzieje jak przedziały dat w pytaniach są długie a co jak są krótkie?
* co się dzieje jak kategoria jest jedna a co jak jest ich dużo?
* jak duże są pliki z danymi?
* jak bardzo potrafią pomóc indeksy w postgresie?
* (bonus) a może da się użyć PARTITON w postgresie?
