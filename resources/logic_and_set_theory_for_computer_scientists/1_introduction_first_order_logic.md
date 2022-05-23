## 🧠 1. Logic and set theory for Computer Scientists

[🔙 Home Page](https://github.com/Valaraucoo/engineering-notes/)

| Title         | 1. Logic and set theory for Computer Scientists |
|---------------|-------------------------------------------------|
| Source        | Lecture                                         |
| Author        | N/A                                             |
| What to learn | First order logic, introduction to logic        |
| Scope/Topic   | `Maths`                                         |
| Description   | Classical logic, first order logic              |
| Status        | `In progress`                                   |
| Language      | 🇵🇱 Polish                                     |
| Last update   | 23.05.2022                                      |

Tematyka: **Wstęp, Klasyczny Rachunek Zdań** 

Literatura: [1], rozdział I, [2], str.15-71., [3], rozdz.1, [4], rozdział 4.

1. Grzegorczyk A., *Zarys logiki matematycznej,* PWN, Warszawa, 1984.
2. Porębska M., Suchoń W., *Elementarny wykład logiki formalnej z ćwiczeniami komputerowymi, Universitas,* Kraków, 1999.
3. Świrydowicz K., *Podstawy logiki modalnej,* Wydawnictwo Naukowe UAM, Poznań, 2004.
4. Witkowska-Maksimczuk B., *Podstawy logiki w przykładach i zadaniach,* Wyższa Szkoła Administracyjno-Społeczna w Warszawie, Warszawa, 2013.
5. Urchs M., Nasieniewski M., Kwiatkowski S., [_Klasyczny Rachunek Zdań. Wykład i zadania. Skrypt dla studentów pierwszego roku_](https://repozytorium.umk.pl/bitstream/handle/item/2975/M.%20Nasieniewski%2C%20Klasyczny%20rachunek%20zda%C5%84.%20z%20M.%20Urchsem%20i%20S.%20Kwiatkowskim%2C%20Wyd%2C%20UMK%2C%20Toru%C5%84%201997%20CALA%20KSIAZKA.pdf?sequence=1), Uniwersytet Mikołaja Kopernika, Toruń, 1997

### Logika, Klasyczny Rachunek Zdań (KRZ)

**Logika** — nauka o poprawnym rozumowaniu w języku naturalnym / formalizacja pewnej części języka naturalnego.

Aspekty języka naturalnego:

- syntaktyczny (strukturalny, w jaki sposób prawidłowo tworzyć wyrażenia w danym języku)
- znaczeniowy (co oznaczają w danym języku dane oznaczenia)


💡 Najczęściej aspekt prawdziwości jest redukowany do **dwuwartościowości** logicznej – prawda, fałsz.

**Zdanie** — zdanie w języku naturalnym, któremu można przypisać wartość prawdy lub fałszu.

- Na zdaniach wykonujemy pewne operacje, które mogą prowadzić do powstania innych zdań/ bardziej złożonych zdań.
- Jeżeli p i q są zdaniami, to not p, p and q, p or q, p → q, p ↔q też są zdaniami
- Zmienne zdaniowe — służą do budowania zdań.

**Logiczna konsekwencja** — Niech A1, A2, ... An będzie dowolnym, skończonym ciągiem schematów logicznych, czyli takich zdań prostych lub złożonych, które są poprawnie zbudowanymi wyrażeniami. 
Mówimy, że schemat logiczny B jest logiczną konsekwencją schematów A1, ..., An jeśli:

Przy każdym układzie wartości logicznych takim, że prawdziwe są wszystkie schematy A1, ..., An prawdziwe jest też B. Oznaczamy:

$$ \frac{A_1, \ldots,A_n}{B} $$

**Reguły wnioskowania** — operacje, które skończonym ciągom schematów A1, ..., An przypisują schemat B, w taki sposób, że B jest logiczną konsekwencją A1, ..., An.

**System dedukcyjny** — to uporządkowana trójką <F, Ax, R>, gdzie F jest językiem, Ax zbiorem aksjomatów, a R to zbiór dostępnych reguł wnioskowania.

**Klasyczny Rachunek Zdań (KRZ)** — ekstensjonalny i dwuwartościowy. To system formalny logiki matematycznej, formuły reprezentujące zdania mogą być tworzone z formuł atomowych za pomocą **zbioru aksjomatów KRZ**.

💡 **System ekstensjolany** — ograniczenia względem naturalnego użycia języka, implikujące uproszczenia na poziomie formalnym.


- Alfabet KRZ:
    - Zmienne zdaniowe: $p_1, p_2, \ldots, p_n$ (jest ich przeliczalna ilość)
    - Operatory/funktory unarne: $\sim$ (negacja)
    - Operatory/funktory binarne: $\implies, \iff, \land, \lor$
- Język KRZ:
    - $\forall _i (p_i \in F)$, każda zmienna zdaniowa KRZ należy do języka KRZ
    - Jeżeli $p, q \in F$ to $\sim p \in F$ etc.
- [Aksjomatyka KRZ](https://pl.wikipedia.org/wiki/Klasyczny_rachunek_zda%C5%84)
- Reguły KRZ:
    - Reguła odrywania — *modus ponens*:
    $$ \frac{\alpha \implies \beta, \alpha}{\beta} $$

    - Przy pomocy reguły odrywania możemy tworzyć nowe, prawdziwe formuły ze zbioru aksjomatów

**Dowód formalny** — dowód formalny formuły $\phi$ w oparciu o zbiory formuł Ax, język KRZ ($\Sigma$) i zbiór reguł KRZ nazywamy dowolny skończony ciąg formuł $D = \langle \Psi_1, \Psi _2, \ldots, \Psi _n \rangle$ taki, że:

- $\phi = \Psi_n$ — dowodzona formuła jest n-tym elementem ciągu dowodu formalnego
- $\Psi_1\in Ax \cup \Sigma$ — pierwszy wyraz dowodu jest albo aksjomatem, albo poprawnym zdaniem KRZ
- $\forall _i \Psi_i\in Ax\cup \Sigma \lor \exists _{r \in R}$ taka, że $\Psi _i$ powstaje z wcześniejszych formuł w ciągu D przez zastosowanie do nich reguły R

Formuła $\phi$ jest wywodliwa/ma dowód na podstawie zbioru $\Sigma$ (zwanego założeniami) przy ustalonych $Ax$  i $R$, gdy istnieje dowód formalny dla $\phi$ oparty o aksjomaty, język i reguły systemu. Oznaczamy: $\Sigma \vdash \phi$.

Jeżeli zbiór $\Sigma$  jest zbiorem pustym, to zapisujemy: $\vdash \phi$. W KRZ $\vdash \phi$ oznacza, że albo $\phi$ jest aksjomatem, albo da się ją wyprowadzić przez *modus ponens* z aksjomatów — czyli $\phi$ jest tautologią, co zapisujemy $\vDash \phi$

- Każdy aksjomat posiada dowód na podstawie zbioru pustego

*Przykład:*

Dla dowolnej formuły $\phi$ formuła $\phi \implies \phi$ jest twierdzeniem KRZ.

*Dowód:*

<img width="800px" src="/images/1_introduction_first_order_logic/1.png">

**Twierdzenie o dedukcji** — jeżeli $\Sigma$ jest pewnym skończonym zbiorem formuł należących oraz $\phi$  i $\psi$ to dowolne formuły, wówczas:

$$ \Sigma \cup \{ \phi \} \; \vdash \; \psi \Longleftrightarrow \Sigma \vdash \phi \implies \psi $$

Twierdzenie o dedukcji jest regułą wnioskowania KRZ.

<img width="800px" src="/images/1_introduction_first_order_logic/2.png">

Wg twierdzenia o dedukcji implikacja jest prawdziwa, tylko wtedy, gdy jeśli na podstawie jej poprzednika da się wydedukować następnik.

💡 Tezą systemu KRZ nazywamy każdą formułę języka KRZ, która posiada dowód formalny z pustego zbioru przesłanek: $\vdash \phi$

**Twierdzenie o pełności KRZ** — każda teza KRZ jest tautologią $\vdash A \Leftrightarrow \Vdash A$.

Pojęcie tautologii jest więc w KRZ — równoznaczne z pojęciem twierdzenia (tezy), prawda w sensie syntaktycznym i w sensie semantycznym są ze sobą identyczne. Inaczej mówiąc, wnioskiem z tw. o pełności jest fakt, że każdą tautologię KRZ można udowodnić.

**KRZ jest rozstrzygalny**, oznacza to, że istnieje efektywna metoda ustalająca dla dowolnej formuły KRZ, czy jest ona w nim prawdziwa. 

Metoda jest efektywna dla rozwiązania danego problemu, jeżeli zadana jest wyczerpująco i jednoznacznie, a przeto prowadzi z logiczną koniecznością każdorazowo do poprawnej odpowiedzi.