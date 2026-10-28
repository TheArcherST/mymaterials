#import "@preview/rubber-article:0.5.2": *
#import "@preview/ctheorems:2.0.0": *
#import "@preview/codly:2.0.0" as codly
#import "@preview/latex-lookalike:0.1.4"
#import thm-themes.ams: *
#import "/typst/python-state.typ": python-state

#show: article.with(
  page-paper: "us-letter",
  page-margins: 1.75in,
  text-font: "New Computer Modern",
  text-size: 11pt,
  lang: "ru",
  par-first-line-indent: 1.5em,
  par-spacing: 0.55em,
  par-justify: true,
  heading-numbering: "1.1",
  page-numbering: "1",
  page-numbering-align: center,
  eq-numbering: "(1)",
  eq-chapterwise: false,
  header-display: false,
)
#show: latex-lookalike.style-outline
#show: thm-rules.with(qed-symbol: $square$)
#show raw: set text(font: "New Computer Modern Mono")
#show math.equation: set text(weight: "regular")

#maketitle(
  title: "Материалы к первому модулю зачёта",
  authors: ("Основы программирования на Python",),
  date: "Ноябрь 2026",
)

#outline(title: [Содержание])
#pagebreak()

// Код в стиле LaTeX listings, frame=tb.
#show: codly.theme(
  "clean",
  syntax: none,
  foreground: black,
  muted: luma(100),

  // Основной код
  line: (
    text: (
      font: "New Computer Modern Mono",
      size: 10pt,
      fill: black,
    ),
  ),

  // Номера строк
  number: (
    text: (
      font: "New Computer Modern",
      size: 7pt,
      fill: luma(90),
    ),
  ),
)

// Общие параметры листинга
#show: codly.set_(
  lang-position: none,
  file-position: none,
  radius: 0pt,
  padding: 0pt,
  breakable: false,
  width: 100%,

  // Расстояние между номером строки и кодом
  column-gutter: 8pt,
)

// Строки без фона и рамок
#show: codly.line-set_(
  fill: none,
  stroke: none,
  inset: (x: 0pt, y: 1pt),
)

// Номера строк слева от кода
#show: codly.number-set_(
  numbering: "1",
  placement: "outside",
  align: right + horizon,
)

#let number-offset = 11pt

#show raw.where(block: true): it => block(
  width: 100%,
  above: 12pt,
  below: 12pt,
  breakable: false,
)[
  #line(length: 100%, stroke: 0.3pt + black)

  #v(2pt)

  #move(dx: -number-offset)[
    #codly.new(it)
  ]

  #v(2pt)

  #line(length: 100%, stroke: 0.3pt + black)
]

Подобные задания будут на зачёте. Списать на зачёте не получится. Он будет устным. Поэтому нужно научиться их решать самостоятельно.

Задания разбиты по компетенциям (то есть по знаниям и навыкам, владение которыми вам нужно показать).


= Задания по компетенциям

== Находить выражения в тексте программы

Для каждого задания найдите все выражения, в том числе вложенные. При наличии составного выражения покажите, из каких выражений оно состоит.


=== Пример 1


```python
count = 12
label = "boxes"
print(count, label)
```


=== Пример 2


```python
result = float("2.5") + 1.5
print(result)
```


=== Пример 3


```python
def make_word(n):
    return "id-" + str(n)

text = make_word(7)
print(text)
```


=== Пример 4


```python
a = 2
b = a
a = 3
print(a, b)
```


=== Пример 5


```python
x = 4
print(str(float(x)) + " points")
```


== Предсказывать результат вычисления выражения

В каждом задании дано начальное состояние программы на диаграмме и одно или несколько выражений. Определите тип и значение результата каждого выражения. Если вычисление вызывает ошибку, укажите, где и почему она возникает.


=== Пример 1


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "a", object: "a_value"),
            (name: "b", object: "b_value"),
    ),),),
    objects: (
          a_value: (type: "int", value: 8),
          b_value: (type: "int", value: 3),
    ),
  )),
  caption: [Начальное состояние для примера 2.1.],
)


Вычисляется выражение:


```python
a + b * 2
```


=== Пример 2


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "word", object: "word_value"),
            (name: "n", object: "n_value"),
    ),),),
    objects: (
          word_value: (type: "str", value: "ha"),
          n_value: (type: "int", value: 3),
    ),
  )),
  caption: [Начальное состояние для примера 2.2.],
)


Вычисляется выражение:


```python
word + str(n)
```


=== Пример 3


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "price", object: "price_value"),
            (name: "count", object: "count_value"),
    ),),),
    objects: (
          price_value: (type: "float", value: 2.5),
          count_value: (type: "int", value: 4),
    ),
  )),
  caption: [Начальное состояние для примера 2.3.],
)


Независимо друг от друга вычисляются выражения:


```python
price * count
```


```python
price + count / 2
```


=== Пример 4


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "x", object: "shared_number"),
            (name: "y", object: "shared_number"),
            (name: "text", object: "text_value"),
    ),),),
    objects: (
          shared_number: (type: "int", value: 6),
          text_value: (type: "str", value: "6"),
    ),
  )),
  caption: [Начальное состояние для примера 2.4.],
)


Независимо друг от друга вычисляются выражения:


```python
x + int(text)
```


```python
str(y) + text
```


=== Пример 5


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "a", object: "number"),
            (name: "b", object: "text"),
    ),),),
    objects: (
          number: (type: "int", value: 5),
          text: (type: "str", value: "5"),
    ),
  )),
  caption: [Начальное состояние для примера 2.5.],
)


Независимо друг от друга вычисляются выражения:


```python
a + b
```


```python
a + int(b)
```


== Предсказывать изменение состояния после одной инструкции

Дано начальное состояние на диаграмме и одна инструкция. Нарисуйте состояние после её выполнения.


=== Пример 1


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "x", object: "shared"),
            (name: "y", object: "shared"),
    ),),),
    objects: (
          shared: (type: "int", value: 8),
    ),
  )),
  caption: [Начальное состояние для примера 3.1.],
)


Выполняется инструкция:


```python
x = x + 5
```


=== Пример 2


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "text", object: "original"),
            (name: "label", object: "original"),
    ),),),
    objects: (
          original: (type: "str", value: "red"),
    ),
  )),
  caption: [Начальное состояние для примера 3.2.],
)


Выполняется инструкция:


```python
text = text + "!"
```


=== Пример 3


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "nums", object: "numbers"),
            (name: "alias", object: "numbers"),
    ),),),
    objects: (
          numbers: (type: "list", value: ((object: "one",), (object: "two",),)),
          one: (type: "int", value: 1),
          two: (type: "int", value: 2),
    ),
  )),
  caption: [Начальное состояние для примера 3.3.],
)


Выполняется инструкция:


```python
alias.append(3)
```


=== Пример 4


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "first", object: "old_list"),
            (name: "second", object: "old_list"),
    ),),),
    objects: (
          old_list: (type: "list", value: ((object: "one",),)),
          one: (type: "int", value: 1),
    ),
  )),
  caption: [Начальное состояние для примера 3.4.],
)


Выполняется инструкция:


```python
second = [1, 2]
```


=== Пример 5


Начальное состояние:

#figure(
  python-state((
    frames: (global: (bindings: (
            (name: "score", object: "score_value"),
            (name: "text", object: "text_value"),
    ),),),
    objects: (
          score_value: (type: "float", value: 3.5),
          text_value: (type: "str", value: "3.5"),
    ),
  )),
  caption: [Начальное состояние для примера 3.5.],
)


Выполняется инструкция:


```python
text = str(float(text) + score)
```


== Предсказывать последовательность состояний программы

В начале каждого задания пользовательских имён и объектов ещё нет. Нарисуйте состояние программы после каждой строки. Объясните, какие имена появляются или меняют связи и какие объекты изменяются.


=== Пример 1


```python
a = 4
b = a
a = a * 2
c = b + 1
```


=== Пример 2


```python
word = "go"
copy = word
word = word + "!"
copy = copy + "?"
```


=== Пример 3


```python
nums = [1]
copy = nums
nums.append(2)
copy.append(3)
```


=== Пример 4


```python
first = [5]
second = [5]
first.append(6)
second = first
```


=== Пример 5


```python
n = 2
s = str(n)
n = float(s) + 0.5
s = str(n)
```


== Предсказывать вывод программы с `def` и `return`

Определите точный вывод в консоль и пошагово объясните выполнение: вызовы функций, связывание аргументов с параметрами, выполнение return, дальнейшее использование возвращённых объектов.


=== Пример 1


```python
def double(value):
    return value + value

print(double(3))
print(double(1.5))
```


=== Пример 2


```python
number = 7

def grow(number):
    number = number + 1
    return number

print(grow(number))
print(number)
```


=== Пример 3


```python
def add(a, b):
    return a + b

def twice(value):
    return add(value, value)

print(add(twice(2), twice(3)))
```


=== Пример 4


```python
def extend(values, item):
    values.append(item)
    return values

original = [1]
result = extend(original, 2)

print(original)
print(result)
```


=== Пример 5. Печать внутри функции и `return`


```python
def decorate(s):
    print("Processing", s)
    return "[" + s + "]"
    print("Done")

print("Result:", decorate("cat"))
```


