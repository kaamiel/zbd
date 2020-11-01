
# ZBD 2020 Zadanie 1

### Generator


```python
"""
Generator danych do zadania 1 z ZBD
"""
import random
import datetime
import string
import json


DATE_FROM = datetime.date(2019, 1, 1)
DATE_TO = datetime.date(2019, 1, 30)
DATES = []

AUDIENCE_COUNT = 100
DEMOGRAPHY_SIZE = 4
TARGETS = 10
MAX_CONTACTS = 5


random.seed(42)

def random_demography():
    "losowa demografia"
    return ''.join([random.choice(['0', '1']) for i in range(DEMOGRAPHY_SIZE)])

def random_target():
    "losowy target"
    return ''.join([random.choice([' ', '0', '1']) for i in range(DEMOGRAPHY_SIZE)])

def random_contacts():
    "losowe kontakty"
    contacts = ''
    for _ in range(random.randrange(MAX_CONTACTS)):
        value = random.choice(string.ascii_uppercase)
        contacts += value
    return contacts


DATE = DATE_FROM

while DATE <= DATE_TO:
    print("DATE {}".format(DATE))
    OBSERVATIONS = []
    for i in range(AUDIENCE_COUNT):
        PERSON = {}
        PERSON['person_id'] = i
        PERSON['demography'] = random_demography()
        PERSON['contacts'] = ''.join(random_contacts())
        OBSERVATIONS.append(PERSON)
    with open(f'audience-{DATE.isoformat()}.json', 'w') as outfile:
        json.dump(OBSERVATIONS, outfile)
    DATE = DATE + datetime.timedelta(days=1)

T = []
for i in range(TARGETS):
    T.append({'target': i, 'definition': random_target()})
with open('targets.json', 'w') as outfile:
    json.dump(T, outfile)
```


Powyższy skrypt wygeneruje wiele plików z JSON

W plikach `audience-data.json` będą opisy widzów reklam w następującej postaci:
```
... {"person_id": 14, "demography": "1011", "contacts": "EIE"}..
```

To oznacza, że osoba o identyfikatorze czternastym, dnia którego dotyczy plik (w nazwie jest data) miała demografię 1011 i obejrzała trzy reklamy E,I,E (identyfikatory reklam są jednoliterowe)

Demografia 1011 oznacza, że osoba danego dnia miała cechę pierwszą (jedynka na pierwszej pozycji) nie miała cechy drugiej (zero na drugiej pozycji) i miała cechy trzecią i czwartą. Demografia osoby może się zmieniać codziennie (np. możemy myśleć, że cecha pierwsza oznacza, że osoba wstała prawą nogą z łóżka).

W pliku `targets.json` zawarte są opisy grup demograficzncyh. Jeśli w opisie jest jedynka, to osoba musi mieć daną cechę, jeśli zero to musi jej nie mieć, a spacja oznacza, że jest to obojętne. Przykładowo osoba o demografii "1011" należy do grup "1011" oraz " 01 ", ale nie należy do grupy " 1  ".

Naszym zadaniem jest przygotowanie zapytania, które będzie liczyć ile osób z każdej grupy obejrzało którą reklamę każdego dnia, czyli np.


```
dzien | grupa | reklama | osob

------

2019-01-01 | 1 | A | 40

2019-01-01 | 1 | B | 27

...
```


Proszę rozwiązać to zadanie na dwa sposoby:
1. Korzystając tylko z dwóch tabel (audience i targets), w których będą zapisane wprost JSONy (typ jsonb). Wersja JSONowa
2. Korzystając z dowolnych tabel, przygotowując skrypt w SQL lub pgSQL, który jednorazowo przeniesie dane z JSONów do tych tabel, a następnie przygotowując zapytania na tych tabelach. Wersja SQLowa

Proszę przygotować raport o wydajności każdego z tych rozwiązań.

