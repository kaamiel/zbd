
# ZBD 2020 Zadanie 4

Termin 17 stycznia

## Temat

Chcemy zaprojektować uproszczony system wyświetlania reklam internautom.

Mamy trzy typy procesów:
1. Podaje informacje o tym, że możemy wyświetlić reklamę internaucie zapisując do bazy unikalny identyfikator internauty (cookie jakieś) oraz jego adres IP
2. Dowiaduje się o tym, że pojawiła się możliwość wyświetlenia reklamy (proces typu 1 zgłosił) pobiera informację o identyfikatorze, wzbogaca ją (np. dopisuje geolokalizację czyli kraj i miasto) i zapisuje te informacje w bazie
3. Dowiaduje się, że można wyemitować internaucie reklamę i robi jedną z trzech rzeczy:
  1. emituje reklamę tylko w oparciu o informacje z procesu 1 czasem,
  2. emituje reklamę w oparciu o informacje z procesów 1 i 2 czasem,
  3. nie emituje reklamy.

Emisja reklamy polega na zapisaniu do bazy danych informacji o tym, że reklama ma być wyemitowana. Emisja musi nastąpić bardzo szybko (rzędu 20ms) po otrzymaniu informacji od procesu typue 1.

## Zadanie

Przeprowadzić analizę wydajności rozwiązań opartych na redisie i na postgresie przy założeniu mocnych ograniczeń sprzętowych serwera bazodanowego.

## Pytania i odpowiedzi

* W jaki sposób drugi typ procesu powinien dowiadywać się o nowym wpisie do tabeli? Czy powinien on subskrybować  jakiś Redis Pub/Sub czy może powinniśmy zrealizować to w inny sposób?  

Nie powinno się to odbywać przez zastosowanie aktywnego czekania. PostgreSQL dysponuje instrukcją NOTIFY a Redis dysponuje instrukcją PUBLISH i to są dobre pomysły na realizację tego zadania. 

* Czy w przypadku trzeciego typu procesu słowo "czasem" odnosi się do tego, że emisja reklamy odbywa się czasem a czasem się nie odbywa czy że czasem odbywa się ona na podstawie czegoś a czasem całkiem losowo?

Losowo. Proces typu trzeciego po otrzymaniu informacji o pojawieniu się możliwości wyświetlenia reklamy może albo podjąć decyzję o jej wyświetleniu natychmiast (np. zna IP i wie, że powinien wyświetlić reklamę), albo wstrzymać się na chwilkę, poczekać na dodatkowe informacje z procesu typu drugiego i wtedy podjąć decyzję o emisji reklamy. Nie jest naszym zadaniem modelowanie tego procesu, więc możemy przyjąć jakieś prawdopodobieństwa np. (10% - natychmiast TAK, 30% - po informacji z drugiego procesu TAK, 60% po informacji z drugiego procesu NIE).

* I czy wymóg szybkiego wyemitowania reklamy wiąże się z tym, żebyśmy nie wprowadzali jakiś sleepów w kodzie czy raczej jest to kwestia, którą mielibyśmy poruszyć w ramach raportu?

To jest kwestia do poruszenia w raporcie. Dobrze by było, gdyby w raporcie została zawarta informacja o tym jaki jest duży narzut komunikacji z bazą danych na czas działania algorytmu, czyli ile z tych dostępnych 20 ms możemy wykorzystać na rzeczywiste obliczenia.

* Czy powinniśmy symulować ograniczenia sprzętowe np. za pomocą cgroups i limitów na cpu/pamięć czy o co chodzi w tym punkcie? 

Tak. Powinniśmy założyć mocne ograniczenia na przykład: jeden procesor, jeden wątek, 0.5GB RAM.

* Czy zakładamy coś na temat liczby procesów typu 1–3 w systemie? Na przykład czy procesów każdego typu może być wiele, po jednym na typ, czy jeszcze inaczej?

Myślę, że warto uwzględnić w raporcie różne możliwości. Rozsądnym minimum jest po kilka procesów każdego typu
