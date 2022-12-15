## 🧠 2. Fuzzy logic and fuzzy sets

[🔙 Home Page](https://github.com/Valaraucoo/engineering-notes/)

| Title         | 2. Fuzzy logic and fuzzy sets              |
|---------------|--------------------------------------------|
| Source        | Lecture                                    |
| Author        | N/A                                        |
| What to learn | Fuzzy logic and fuzzy sets                 |
| Scope/Topic   | `Maths`                                    |
| Description   | Fuzzy logic and fuzzy sets, expert systems |
| Status        | `Done`                                     |
| Language      | 🇵🇱 Polish                                |
| Last update   | 23.05.2022                                 |

**Table of contents:**
1. [First order logic, introduction to logic](/resources/logic_and_set_theory_for_computer_scientists/1_introduction_first_order_logic.md)
2. Fuzzy logic and fuzzy sets
3. [Syllogisms](/resources/logic_and_set_theory_for_computer_scientists/3_syllogisms.md)

**Temat:** Logiki rozmyte i zbiory rozmyte

Logika rozmyta / logika wielowartościowa — uogólnienie klasycznej logiki, między 0 i 1 mamy szereg wartości pośrednich, które określają stopień przynależności elementu do zbioru.

**Definicja:**

**Zbiór rozmyty** — obiekt matematyczny ze zdefiniowaną funkcją przynależności (zwaną też funkcją charakterystyczną zbioru rozmytego), która przybiera wartości z przedziału [0, 1].

Zbiorem rozmytym $A$ w przestrzeni $X$ nazywamy zbiór uporządkowanych par:

$$
A = \{  (x, \mu _A(x)): x \in X \}
$$

gdzie $\mu _A : X \rightarrow [0,1]$ to funkcja charakterystyczna zbioru $A$. 

W teorii zbiorów rozmytych element może należeć do zbioru w pewnym stopniu, więc funkcja przynależności może przyjmować wartości z całego przedziału jednostkowego [0,1].

Element należy do zbioru rozmytego z pewnym stopniem przynależności.

Niech $A, B \subset X$, więc $A \cup X \subset X$ to:

$$
\mu _{A \cup B} (x) = ^{def} \max (\mu _A (x), \mu _B (x)) = \mu _A (x) + \mu _B (x) - \mu _A (x) \cdot \mu _B (x)
$$

<aside>
💡 Istnieje nieskończenie wiele takich funkcji, które dla $\mu : X \rightarrow \{0, 1 \}$ nie są znane dla $[0, 1]$.

</aside>

- Dla dopełnienia zbioru:

$$
\mu _{A'}(x) =^{def} 1 - \mu _A (x)
$$

- Dla iloczynu zbiorów:

$$
\mu _{A \cap B} (x) = ^{def} \min (\mu _A (x), \mu _B (x)) = \mu _A (x) \cdot \mu _B (x)
$$

**Cechy zbiorów rozmytych:**

- Przemienność, np. A or B = B or A
- Łączność
- Rozdzielność

**Definicja:** 

**T-norma** — funkcję $T: [0,1] \times [0,1] \rightarrow [0,1]$ nazywamy T-normą (normą trójkątną), gdy:

1. $T(a, c) \leq T(b, d)$, dla $a \leq b \; \wedge \; c \leq d$
2. $T(a,b) = T(b,d)$ Symetria
3. $T(T(a,b), c) = T(a, T(b,c))$ Łączność
4. $T(a, 0) = 0 \; \; \wedge \; \; T(a, 1) = a$

Własności T-normy:

- Funkcja $T_1$ jest T-normą

$$
    F_1(a, b)= 
\begin{cases}
a,& \text{if } a = 1\\
b,& \text{if} b = 1 \\
    0,              & \text{otherwise}
\end{cases}
$$

- Funkcja $T_{min} = \min (a, b)$ jest T-normą
- Jeśli funkcja T jest T-normą to $\forall _{a,b \in [0, 1]}$: $T_1 (a,b) \leq T(a,b) \leq T_{min} (a,b)$

T-normy będziemy oznaczać jako $T(a,b) \longrightarrow a =^T b$.

**Relacje rozmyte**

Relację $R$ nazywamy rozmytą, gdy jest w postaci zbioru rozmytego:

$$
R(x,y) = \{ ((x,y), \mu (x,y)): (x,y) \in X \times Y \}
$$

Założenia:

- $X, Y, Z$  — zbiory nierozmyte / klasyczne zbiory
- $R_1$ — relacja rozmyta na $X \times Y$
- $R_2$ — relacja rozmyta na $Y \times Z$

Relacja złożenia $R _1 \cdot R_2$ jest relacją rozmytą na $X \times Z$, natomiast funkcja charakterystyczna złożenia to:

$$
\mu _{R_1 \cdot R_2} (x,z) = \sup _{y \in Y} \{ \mu _{R_1} (x,y) =^T \mu _{R_2} (y,z) \}
$$

**Złożenie zbioru rozmytego z relacją rozmytą**

- $X, Y$ — zbiory nierozmyte / klasyczne zbiory
- $A$ — zbiór rozmyty określony na $X$
- $R$ — relacja rozmyta określona na $X \times X$

Złożenie $A$ z $R$ jest zbiorem rozmytym na innym zbiorze $Y$:

$$
\mu _{A \cdot R} (y) = \sup _{x \in X} \{ \mu _A (x) =^T \mu _R (x,y) \}
$$

**Implikacje rozmyte**

Implikacja rozmyta — to funkcja zgodna na brzegach z implikacją binarną i zachowująca ekstensjonalność (stopień prawdy implikacji zależy tylko od stopni prawdy poprzednika i następnika).

Przykłady implikacji rozmytych:

1. $\mu _{A \implies B} (x,y) = \min (1 , 1 - \mu _A(x) + \mu _B (y))$
2. $\mu _{A \implies B} (x,y) = \max (1 - \mu _A (x) , \mu _B (y))$
3. $\mu _{A \implies B} (x,y) = \min (\mu _A (x) , \mu _B (y))$

Własności:

<img src="/images/2_fuzzy_sets/1.png">
