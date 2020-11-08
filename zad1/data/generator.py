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
