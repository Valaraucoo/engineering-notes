## 🧠 3. Syllogisms

[🔙 Home Page](https://github.com/Valaraucoo/engineering-notes/)

| Title         | 3. Syllogisms  |
|---------------|----------------|
| Source        | Lecture        |
| Author        | N/A            |
| What to learn | Syllogisms     |
| Scope/Topic   | `Maths`        |
| Description   | Syllogisms     |
| Status        | `In progress`  |
| Language      | 🇵🇱 Polish    |
| Last update   | 23.05.2022     |

**Table of contents:**
1. [First order logic, introduction to logic](/resources/logic_and_set_theory_for_computer_scientists/1_introduction_first_order_logic.md)
2. [Fuzzy logic and fuzzy sets](/resources/logic_and_set_theory_for_computer_scientists/2_fuzzy_sets.md)
3. Syllogisms


**Temat:** Sylogizmy

**Zdania kategoryczne** — stwierdzają, że coś “jest”, są to zdania oznajmujące, proste i asertoryczme (stwierdzają fakt, a nie jego możliwość).

Budowa zdań kategorycznych:  zmienne nazwowe + funktory zdaniowe

- wyróżniamy dwa typy zmiennych nazwowych:
    - Podmiot — **S**ubiectum
    - Orzecznik — **P**redicatum
- wyróżniamy cztery typy funktorów zdaniowych:
    - zdania **ogólno-twierdzące**: “Każde S jest P” — `S a P`
    - zdania **szczegółowo-twierdzące**: “Niektóre S są P” — `S i P`
    - zdania **ogólno-przeczące**: “Żadne S nie jest P” — `S e P`
    - zdania **szczegółowo-przeczące**: “Niektóre S nie są P” — `S o P`

Postać normalna zdania kategorycznego w języku naturalnym:

`<operator> + <podmiot> + "być" + <orzecznik>`

```
1) Każdy tygrys jest drapieżnikiem. -> S a P

   Operator: Każdy
   Podmiot (S): Tygrys
   Orzecznik (P): Drapieżnik

2) Bywają dni, w które pada deszcz. -> Nie jest w postaci normalnej
   Niektóre dni są dniami, w które pada deszcz. -> S i P

   Operator: Niektóre
   Podmiot (S): Dni
   Orzecznik (P): Dni, w które pada deszcz
```

**Budowa sylogizmu**

**Sylogizm** to wnioskowanie o dwóch przesłankach, w którym zarówno przesłanki jak i wniosek są zdaniami kategorycznymi przy czym przesłanki mają tylko jeden termin wspólny, każdy zaś termin wniosku występuje w jednej i tylko jednej przesłance.

Poprawnie zbudowany sylogizm składa się z **trzech zdań kategorycznych**:

- dwóch przesłanek
- jednego wniosku

W sylogizmie występują zawsze trzy nazwy, z czego jedna jest obecna jest w obu przesłankach i nie występuje we wniosku (**termin średni** - zmienna *M*). Termin, który występuje jako pierwszy we wniosku oznaczamy jako *S* (**termin mniejszy**), a drugi jako *P —* orzecznik wniosku (**termin większy**).

Przykład schematu sylogizmu:

```bash
MaP
MiS
---
SiP
```

Schematy wnioskowań sylogistycznych nazywamy **trybami sylogistycznymi**. Jedynie 24 z 256 trybów sylogistycznych jest **trybami niezawodnymi**.

**Tryb niezawodny** — to taki schemat sylogizmu, który prowadzi od prawdy do prawdy. Tryb sylogistyczny jest niezawodny, gdy nie jest możliwe takie podstawienie nazw za zmienne S, P, M, aby otrzymać prawdziwe przesłanki i jednocześnie fałszywy wniosek.

**Reguły poprawności sylogizmów** — metoda pięciu warunków

<aside>
🎯 **Termin rozłożony** — jeżeli w zdaniu kategorycznym jest mowa o całym zakresie jakiejś nazwy, czyli o wszystkich określanych nią obiektach, to nazwa taka jest terminem rozłożonym. 

Inaczej: termin odnosi się do wszystkich elementów zbioru przez siebie denotowanego.

Każde S jest P          → SaP → rozłożone S
Żadne S nie jest P    → SeP → rozłożone S oraz P
Niektóre S są P         → SiP → brak
Niektóre S nie są P   → SoP  → rozłożone P

</aside>

1. Przynajmniej jedna przesłanka musi być zdaniem twierdzącym.
2. Jeśli jedna z przesłanek jest zdaniem przeczącym, to wniosek musi być przeczący.
3. Jeśli obie przesłanki są zdaniami twierdzącymi, to i wniosek musi być twierdzący.
4. Termin średni musi być rozłożony w przynajmniej jednej przesłance.
5. Jeśli jakiś termin ma być rozłożony we wniosku, to musi być też rozłożony w przesłance.

<aside>
💡 1-3 reguły jakości
4-5 reguły rozkładu

</aside>

Wnioskowanie to rozumowanie, w którym na podstawie zdania lub zdań uznanych za prawdziwe uznaje się za **prawdziwe inne zdania:**

- zdanie stwierdzające punkt wyjścia — przesłanka
- zdanie, do którego dokonujemy wnioskowania — wniosek

**Kwadrat logiczny**

- **Podporządkowanie** — ze zdania górnego wynika zdanie dolne
    - Ze zdania ogólno-twierdzącego → zdanie szczegółowo-twierdzące (Jeśli SaP to SiP)
    - Ze zdania ogólno-przeczącego → zdanie szczegółowo-przeczące (Jeśli SeP to SoP)

- **Przeciwieństwo** — zdania przeciwne nie mogą być jednocześnie prawdziwe:
    - Jeżeli SaP to fałszem jest SeP
    - Jeżeli SeP to fałszem jest SaP
- **Zdania przeciwne, choć nie mogą być razem prawdziwe, to mogą być jednak oba fałszywe**

- **Podprzeciwieństwo** — zdania podprzeciwne nie mogą być jednocześnie fałszywe:
    - Jeżeli jedno z nich jest fałszywe to prawdziwe jest drugie
    - Jeżeli fałszem jest SiP to SoP
    - Jeżeli fałszem jest SoP to SiP
- **Zdania podprzeciwne choć nie mogą być jednocześnie fałszywe, to mogą być jednoczeście prawdziwe**

- **Sprzeczność** — zdania nie mogą być ani jednocześnie prawdziwe, ani zarazem fałszywe
    - Jeżeli jedno jest fałszywe to drugie musi być prawdziwe
    - Jeżeli SaP to fałszem jest SoP
    - itp

**Wykorzystanie kwadratu logicznego**

```
Każdy struś jest ptakiem. -> SaP

Poprawne również będą:

1) Niektóre strusie są ptakami. -> SiP (zdanie podporządkowane SaP)
2) Fałszywe musi być zdanie: żaden struś nie jest ptakiem. -> ~SeP
3) Fałszywe musi być zdanie: niektóre strusie nie są ptakami. -> ~SoP (sprzeczne z SaP)
```

Związki kwadratu logicznego nie są jedynymi prawami, jakie można sformułować odnośnie zdań kategorycznych. Istnieją również inne prawa/wnioskowania:

- **bezpośrednie** — tylko jedna przesłanka:
    - związki kwadratu logicznego
    - obwersje
    - konwersje
    - kontrapozycje
- **pośrednie** — więcej niż jedna przesłanka:
    - gdy dokładnie 2 przesłanki — wnioskowanie sylogistyczne

```
KONWERSJA
1) SeP -> PeS
2) SiP -> PiS
3) SaP -> PiS
4) SoP -> niepodlega konwersji

OBWERSJA - dodanie negacji do orzecznika zdania oraz zmiana jakości zdania
           tzn. zdanie twierdzące staje się przeczącym, i na odwrót
1) SaP -> SeP'
2) SeP -> SaP'
3) SiP -> SoP'
4) SoP -> SiP'

KONTRAPOZYCJA - częściowa i zupełna; nie podlega zdanie SiP
KONTRAPOZYCJA CZĘŚCIOWA - zamiana miejscami podmiotu i orzecznika oraz zanegowaniu tego drugiego
1) SaP -> P'eS
2) SeP -> P'iS
3) SoP -> P'iS

KONTRAPOZYCJA ZUPEŁNA - zamiana miejscami podmiotu i orzecznika oraz zanegowaniu obydwu
1) SaP -> P'aS'
2) SeP -> P'oS'
3) SoP -> P'oS'

INWERSJA CZĘŚCIOWA
1) SaP -> S'oP
2) SeP -> S'iP

INWERSJA ZUPEŁNA
1) SaP -> S'iP'
2) SeP -> S'oP'
```
