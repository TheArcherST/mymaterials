#import "@preview/rubber-article:1.5.2": *
#import "@preview/ctheorems:2.0.0": *
#import "@preview/codly:2.0.0" as codly
#import thm-themes.ams: *
#import "@preview/latex-lookalike:0.1.4"
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
  title: "Задания к модулю 1 (состояние программы)",
  authors: ("Основы программирования на Python",),
  date: "Октябрь 2026",
)

#outline(title: [Содержание])
#pagebreak()

// Монохромные листинги в духе LaTeX listings с двумя линиями.
#show: codly.theme(
  "clean",
  syntax: none,
  foreground: black,
  muted: luma(100),
  line: (text: (font: "New Computer Modern Mono", size: 10pt, fill: black)),
  number: (text: (font: "New Computer Modern", size: 7pt, fill: luma(90))),
)
#show: codly.set_(
  lang-position: none,
  file-position: none,
  radius: 0pt,
  padding: 0pt,
  breakable: false,
  width: 100%,
  column-gutter: 8pt,
)
#show: codly.line-set_(fill: none, stroke: none, inset: (x: 0pt, y: 0.6pt))
#show: codly.number-set_(numbering: "1", placement: "outside", align: right + horizon)
#let number-offset = 11pt
#show raw.where(block: true): it => block(
  width: 100%, above: 12pt, below: 12pt, breakable: false,
)[
  #line(length: 100%, stroke: 0.7pt + black)
  #v(6pt)
  #move(dx: -number-offset)[#codly.new(it)]
  #v(6pt)
  #line(length: 100%, stroke: 0.7pt + black)
]

#heading(level: 1, numbering: none, outlined: false)[Что это такое]

Подобные задания будут на зачёте. Списать на зачёте не получится. Он будет устным. Поэтому нужно научиться их решать самостоятельно.

Задания разбиты по компетенциям (то есть по знаниям и навыкам, владение которыми вам нужно показать).


= Находить выражения в тексте программы

Для каждого задания найдите все выражения, в том числе вложенные. При наличии составного выражения покажите, из каких выражений оно состоит.


== Задание


```python
count = 12
label = "boxes"
print(count, label)
```


== Задание


```python
result = float("2.5") + 1.5
print(result)
```


== Задание


```python
def make_word(n):
    return "id-" + str(n)

text = make_word(7)
print(text)
```


== Задание


```python
a = 2
b = a
a = 3
print(a, b)
```


== Задание


```python
x = 4
print(str(float(x)) + " points")
```


= Предсказывать результат вычисления выражения

В каждом задании дано начальное состояние программы на диаграмме и одно или несколько выражений. Определите тип и значение результата каждого выражения. Если вычисление вызывает ошибку, укажите, где и почему она возникает.


== Задание


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
  caption: [Начальное состояние для задания 2.1.],
)


Вычисляется выражение:


```python
a + b * 2
```


== Задание


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
  caption: [Начальное состояние для задания 2.2.],
)


Вычисляется выражение:


```python
word + str(n)
```


== Задание


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
  caption: [Начальное состояние для задания 2.3.],
)


Независимо друг от друга вычисляются выражения:


```python
price * count
```


```python
price + count / 2
```


== Задание


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
  caption: [Начальное состояние для задания 2.4.],
)


Независимо друг от друга вычисляются выражения:


```python
x + int(text)
```


```python
str(y) + text
```


== Задание


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
  caption: [Начальное состояние для задания 2.5.],
)


Независимо друг от друга вычисляются выражения:


```python
a + b
```


```python
a + int(b)
```


= Предсказывать изменение состояния после одной инструкции

Дано начальное состояние на диаграмме и одна инструкция. Нарисуйте состояние после её выполнения.


== Задание


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
  caption: [Начальное состояние для задания 3.1.],
)


Выполняется инструкция:


```python
x = x + 5
```


== Задание


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
  caption: [Начальное состояние для задания 3.2.],
)


Выполняется инструкция:


```python
text = text + "!"
```


== Задание


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
  caption: [Начальное состояние для задания 3.3.],
)


Выполняется инструкция:


```python
alias.append(3)
```


== Задание


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
  caption: [Начальное состояние для задания 3.4.],
)


Выполняется инструкция:


```python
second = [1, 2]
```


== Задание


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
  caption: [Начальное состояние для задания 3.5.],
)


Выполняется инструкция:


```python
text = str(float(text) + score)
```


= Предсказывать последовательность состояний программы

В начале каждого задания пользовательских имён и объектов ещё нет. Нарисуйте состояние программы после каждой строки. Объясните, какие имена появляются или меняют связи и какие объекты изменяются.


== Задание


```python
a = 4
b = a
a = a * 2
c = b + 1
```


== Задание


```python
word = "go"
copy = word
word = word + "!"
copy = copy + "?"
```


== Задание


```python
nums = [1]
copy = nums
nums.append(2)
copy.append(3)
```


== Задание


```python
first = [5]
second = [5]
first.append(6)
second = first
```

#import "@preview/rubber-article:1.5.2": *
#import "@preview/ctheorems:2.0.0": *
#import "@preview/codly:2.0.0" as codly
#import thm-themes.ams: *
#import "@preview/latex-lookalike:0.1.4"
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
  title: "Задания к модулю 1 (состояние программы)",
  authors: ("Основы программирования на Python",),
  date: "Октябрь 2026",
)

#outline(title: [Содержание])
#pagebreak()

// Монохромные листинги в духе LaTeX listings с двумя линиями.
#show#import "@preview/rubber-article:1.5.2": *
#import "@preview/ctheorems:2.0.0": *
#import "@preview/codly:2.0.0" as codly
#import thm-themes.ams: *
#import "@preview/latex-lookalike:0.1.4"
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
  title: "Задания к модулю 1 (состояние программы)",
  authors: ("Основы программирования на Python",),
  date: "Октябрь 2026",
)

#outline(title: [Содержание])
#pagebreak()

// Монохромные листинги в духе LaTeX listings с двумя линиями.
#show: codly.theme(
  "clean",
  syntax: none,
  foreground: black,
  muted: luma(100),
  line: (text: (font: "New Computer Modern Mono", size: 10pt, fill: black)),
  number: (text: (font: "New Computer Modern", size: 7pt, fill: luma(90))),
)
#show: codly.set_(
  lang-position: none,
  file-position: none,
  radius: 0pt,
  padding: 0pt,
  breakable: false,
  width: 100%,
  column-gutter: 8pt,
)
#show: codly.line-set_(fill: none, stroke: none, inset: (x: 0pt, y: 0.6pt))
#show: codly.number-set_(numbering: "1", placement: "outside", align: right + horizon)
#let number-offset = 11pt
#show raw.where(block: true): it => block(
  width: 100%, above: 12pt, below: 12pt, breakable: false,
)[
  #line(length: 100%, stroke: 0.7pt + black)
  #v(6pt)
  #move(dx: -number-offset)[#codly.new(it)]
  #v(6pt)
  #line(length: 100%, stroke: 0.7pt + black)
]

#heading(level: 1, numbering: none, outlined: false)[Что это такое]

Подобные задания будут на зачёте. Списать на зачёте не получится. Он будет устным. Поэтому нужно научиться их решать самостоятельно.

Задания разбиты по компетенциям (то есть по знаниям и навыкам, владение которыми вам нужно показать).


= Находить выражения в тексте программы

Для каждого задания найдите все выражения, в том числе вложенные. При наличии составного выражения покажите, из каких выражений оно состоит.


== Задание


```python
count = 12
label = "boxes"
print(count, label)
```


== Задание


```python
result = float("2.5") + 1.5
print(result)
```


== Задание


```python
def make_word(n):
    return "id-" + str(n)

text = make_word(7)
print(text)
```


== Задание


```python
a = 2
b = a: codly.theme(
  "clean",
  syntax: none,
  foreground: black,
  muted: luma(100),
  line: (text: (font: "New Computer Modern Mono", size: 10pt, fill: black)),
  number: (text: (font: "New Computer Modern", size: 7pt, fill: luma(90))),
)
#show: codly.set_(
  lang-position: none,
  file-position: none,
  radius: 0pt,
  padding: 0pt,
  breakable: false,
  width: 100%,
  column-gutter: 8pt,
)
#show: codly.line-set_(fill: none, stroke: none, inset: (x: 0pt, y: 0.6pt))
#show: codly.number-set_(numbering: "1", placement: "outside", align: right + horizon)
#let number-offset = 11pt
#show raw.where(block: true): it => block(
  width: 100%, above: 12pt, below: 12pt, breakable: false,
)[
  #line(length: 100%, stroke: 0.7pt + black)
  #v(6pt)
  #move(dx: -number-offset)[#codly.new(it)]
  #v(6pt)
  #line(length: 100%, stroke: 0.7pt + black)
]

#heading(level: 1, numbering: none, outlined: false)[Что это такое]

Подобные задания будут на зачёте. Списать на зачёте не получится. Он будет устным. Поэтому нужно научиться их решать самостоятельно.

Задания разбиты по компетенциям (то есть по знаниям и навыкам, владение которыми вам нужно показать).


= Находить выражения в тексте программы

Для каждого задания найдите все выражения, в том числе вложенные. При наличии составного выражения покажите, из каких выражений оно состоит.


== Задание


```python
count = 12
label = "boxes"
print(count, label)
```


== Задание


```python
result = float("2.5") + 1.5
print(result)
```


== Задание


```python
def make_word(n):
    return "id-" + str(n)

text = make_word(7)
print(text)
```


== Задание


```python
a = 2
b = a
== Задание


```python
n = 2
s = str(n)
n = float(s) + 0.5
s = str(n)
```


= Предсказывать вывод программы с def и return

Определите точный вывод в консоль и пошагово объясните выполнение: вызовы функций, связывание аргументов с параметрами, выполнение return, дальнейшее использование возвращённых объектов.


== Задание


```python
def double(value):
    return value + value

print(double(3))
print(double(1.5))
```


== Задание


```python
number = 7

def grow(number):
    number = number + 1
    return number

print(grow(number))
print(number)
```


== Задание


```python
def add(a, b):
    return a + b

def twice(value):
    return add(value, value)

print(add(twice(2), twice(3)))
```


== Задание


```python
def extend(values, item):
    values.append(item)
    return values

original = [1]
result = extend(original, 2)

print(original)
print(result)
```


== Печать внутри функции и return


```python
def decorate(s):
    print("Processing", s)
    return "[" + s + "]"
    print("Done")

print("Result:", decorate("cat"))
```

