+++
title = "Задания к модулю 1 (состояние программы)"
date = 2026-10-24
description = ""
insert_anchor_links = "heading"

[extra.pdf]
source = "document.typ"
+++

## Что это такое

Подобные задания будут на зачёте.  Списать на зачёте не получится.  Он будет устным.  Поэтому нужно научиться их решать самостоятельно

Задания разбиты по компетенциям (то есть по знаниям и навыкам, владение которыми вам нужно показать)

---

## Компетенция 1. Находить выражения в тексте программы
Для каждого задания найдите все выражения, в том числе вложенные.  При наличии составного выражения покажите, из каких выражений оно состоит.

### Задание 1.1.

```python
count = 12
label = "boxes"
print(count, label)
```

### Задание 1.2.

```python
result = float("2.5") + 1.5
print(result)
```

### Задание 1.3.

```python
def make_word(n):
    return "id-" + str(n)

text = make_word(7)
print(text)
```

### Задание 1.4.

```python
a = 2
b = a
a = 3
print(a, b)
```

### Задание 1.5.

```python
x = 4
print(str(float(x)) + " points")
```

---

## Компетенция 2. Предсказывать результат вычисления выражения

В каждом задании дано начальное состояние программы на диаграмме и одно или несколько выражений. Определите тип и значение результата каждого выражения. Если вычисление вызывает ошибку, укажите, где и почему она возникает.

### Задание 2.1.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: a
        object: a_value
      - name: b
        object: b_value
objects:
  a_value:
    type: int
    value: 8
  b_value:
    type: int
    value: 3
{% </python_state> %}

Вычисляется выражение:

```python
a + b * 2
```

### Задание 2.2.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: word
        object: word_value
      - name: n
        object: n_value
objects:
  word_value:
    type: str
    value: ha
  n_value:
    type: int
    value: 3
{% </python_state> %}

Вычисляется выражение:

```python
word + str(n)
```

### Задание 2.3.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: price
        object: price_value
      - name: count
        object: count_value
objects:
  price_value:
    type: float
    value: 2.5
  count_value:
    type: int
    value: 4
{% </python_state> %}

Независимо друг от друга вычисляются выражения:

```python
price * count
```

```python
price + count / 2
```

### Задание 2.4.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: x
        object: shared_number
      - name: y
        object: shared_number
      - name: text
        object: text_value
objects:
  shared_number:
    type: int
    value: 6
  text_value:
    type: str
    value: "6"
{% </python_state> %}

Независимо друг от друга вычисляются выражения:

```python
x + int(text)
```

```python
str(y) + text
```

### Задание 2.5.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: a
        object: number
      - name: b
        object: text
objects:
  number:
    type: int
    value: 5
  text:
    type: str
    value: "5"
{% </python_state> %}

Независимо друг от друга вычисляются выражения:

```python
a + b
```

```python
a + int(b)
```

---

## Компетенция 3. Предсказывать изменение состояния после одной инструкции

Дано начальное состояние на диаграмме и одна инструкция. Нарисуйте состояние после её выполнения.

### Задание 3.1.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: x
        object: shared
      - name: y
        object: shared
objects:
  shared:
    type: int
    value: 8
{% </python_state> %}

Выполняется инструкция:

```python
x = x + 5
```

### Задание 3.2.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: text
        object: original
      - name: label
        object: original
objects:
  original:
    type: str
    value: red
{% </python_state> %}

Выполняется инструкция:

```python
text = text + "!"
```

### Задание 3.3.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: nums
        object: numbers
      - name: alias
        object: numbers
objects:
  numbers:
    type: list
    value:
      - object: one
      - object: two
  one:
    type: int
    value: 1
  two:
    type: int
    value: 2
{% </python_state> %}

Выполняется инструкция:

```python
alias.append(3)
```

### Задание 3.4.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: first
        object: old_list
      - name: second
        object: old_list
objects:
  old_list:
    type: list
    value:
      - object: one
  one:
    type: int
    value: 1
{% </python_state> %}

Выполняется инструкция:

```python
second = [1, 2]
```

### Задание 3.5.

Начальное состояние:

{% <python_state> %}
frames:
  global:
    bindings:
      - name: score
        object: score_value
      - name: text
        object: text_value
objects:
  score_value:
    type: float
    value: 3.5
  text_value:
    type: str
    value: "3.5"
{% </python_state> %}

Выполняется инструкция:

```python
text = str(float(text) + score)
```

---

## Компетенция 4. Предсказывать последовательность состояний программы

В начале каждого задания пользовательских имён и объектов ещё нет. Нарисуйте состояние программы после каждой строки. Объясните, какие имена появляются или меняют связи и какие объекты изменяются.

### Задание 4.1.

```python
a = 4
b = a
a = a * 2
c = b + 1
```

### Задание 4.2.

```python
word = "go"
copy = word
word = word + "!"
copy = copy + "?"
```

### Задание 4.3.

```python
nums = [1]
copy = nums
nums.append(2)
copy.append(3)
```

### Задание 4.4.

```python
first = [5]
second = [5]
first.append(6)
second = first
```

### Задание 4.5.

```python
n = 2
s = str(n)
n = float(s) + 0.5
s = str(n)
```

---

## Компетенция 5. Предсказывать вывод программы с `def` и `return`

Определите точный вывод в консоль и пошагово объясните выполнение: вызовы функций, связывание аргументов с параметрами, выполнение `return`, дальнейшее использование возвращённых объектов.

### Задание 5.1.

```python
def double(value):
    return value + value

print(double(3))
print(double(1.5))
```

### Задание 5.2.

```python
number = 7

def grow(number):
    number = number + 1
    return number

print(grow(number))
print(number)
```

### Задание 5.3.

```python
def add(a, b):
    return a + b

def twice(value):
    return add(value, value)

print(add(twice(2), twice(3)))
```

### Задание 5.4.

```python
def extend(values, item):
    values.append(item)
    return values

original = [1]
result = extend(original, 2)

print(original)
print(result)
```

### Задание 5.5. Печать внутри функции и `return`

```python
def decorate(s):
    print("Processing", s)
    return "[" + s + "]"
    print("Done")

print("Result:", decorate("cat"))
```

---


