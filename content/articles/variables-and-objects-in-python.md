+++
title = "Переменные и объекты в Python"
date = 2026-05-28
[taxonomies]
tags = ["Python"]
+++

Переменной в Python называют имя, связанное со ссылкой на объект.

Объект — это данные, лежащие в оперативной памяти.  У объекта есть тип и значение (в оперативной памяти хранятся данные о типе объекта и данные о значении объекта).

# Как хранятся данные объектов

Оперативная память компьютера это место, в котором хранятся данные, с которыми компьютер активно работает в данный момент.

Python, по сравнению с некоторыми другими языками программирования, даёт мало свободы в управлении оперативной памятью.  Поэтому думать об оперативной памяти тут можно в упрощённой форме.  В нашем случае, можно думать об оперативной памяти как о листе бумаги.

Чтобы создать любой объект, его сначала нужно выделить под него место, затем заполнить данными о нём.  Рассмотрим, как можно думать о создании строки `"Hello world"`.

Нарисуем прямоугольник, обозначающий место в памяти, используемое под объект. Затем поместим туда его данные.

{% python_state() %}
objects:
  a:
    type: str
    value: hello world
{% end %}

Готово, объект создан: мы положили в область оперативной памяти данные о его типе и значении.  Но как этими данными пользоваться?
Чтобы использовать этот объект, нам нужно как-то указать на него, и указать, что мы хотим с ним сделать.

Мы можем указать пальцем на нарисованный прямоугольник, но Python умеет понимать только текст.  При написании программы у нас есть несколько способов указать на объект, но в основе каждого из них лежат ссылки.  Ссылка на объект — это данные, по которым Python находит место в памяти (находит наш прямоугольник).

Вот в таком коде

```python
a = "Hello"
```

Python сначала создаёт объект `"Hello"`

{% python_state() %}
objects:
  a:
    type: str
    value: Hello
{% end %}

Затем получает ссылку на него, и подписывает эту ссылку именем `a`.

{% python_state() %}
frames:
  global:
    bindings:
      - name: a
        object: a
objects:
  a:
    type: str
    value: Hello
{% end %}

И далее мы можем использовать эту ссылку, подписанную именем `a`.  Например, мы можем написать инструкцию, в соответствии с которой Python выведет информацию об объекте по этой ссылке:

```python
print(a)
```

Какие данные представляет из себя ссылка при этом не так важно.  Главное, что эти данные позволяют Python найти нужный объект в памяти.  Поэтому иногда просто говорят, что в Python имя связано с объектом (вместо того, чтобы говорить, что под именем скрывается ссылка).

Рассмотрим другой пример.  Есть такой код на Python:

```python
b = [1, "Hello world"]
```

Что хранится в этом списке?  Формально, список не хранит внутри себя эту единицу и строку; он хранит ссылки на них.  Вот как это можно нарисовать:

{% python_state() %}
objects:
  a:
    type: int
    value: 1
  b:
    type: str
    value: Hello world
  c:
    type: list
    value:
      - object: a
      - object: b

{% end %}

Как видно, тут у нас 3 объекта, один из которых является нашим списком.  И список хранит информацию о том, где находятся другие два объекта.  Иначе говоря, список хранит ссылки на свои элементы.

# Работа с данными объектов

Тип уже созданного объекта никак нельзя изменить.  Если вы создали список, вы не можете его изменить так, чтобы он стал строкой, числом, или чем-то ещё.  Но значение некоторых объектов можно изменить.  Список например поддерживает добавление новых элементов: то есть можно изменить его значение, добавив туда данные о месте нахождения ещё одного объекта.

Однако значение некоторых объектов тоже никак нельзя изменить, и нужно запомнить, какие объекты являются неизменяемыми.  Начнём с того, что нельзя изменить объекты вот с этими типами: `int`, `float`, `str`, `bool`.

Так, если вы пишете код:

```python
a = 1
a = a + 1
```

Смысл его такой:

На первой строке мы получили объект типа `int` со значением `один` и теперь имя `a` обозначает ссылку на этот объект.

{% python_state() %}
frames:
  global:
    bindings:
      - name: a
        object: a
objects:
  a:
    type: int
    value: 1
{% end %}

На второй строке, во-первых, в результате вычисления выражения `a + 1` мы получили новый объект, с типом `int` и значением `два`. Во-вторых, мы изменили ссылку имени `a`: теперь оно указывает не на объект `1`, а на объект `2`. При этом мы никак не изменяли сами объекты.

{% python_state() %}
frames:
  global:
    bindings:
      - name: a
        object: a
objects:
  a:
    type: int
    value: 2
{% end %}

То же самое относится к любым операциям со строками: объект типа `str` не может быть изменён.

```python
a = "Hello"
b = a + " World!"  # объект по ссылке `a` остался неизменным
```

{% python_state() %}
frames:
  global:
    bindings:
      - name: a
        object: a
      - name: b
        object: b
objects:
  a:
    type: str
    value: Hello
  b:
    type: str
    value: Hello World!
{% end %}

Важно понимать, что управление переменными и объектами происходит очень небольшим количеством способов — небольшим количеством механизмов языка. Сейчас мы рассмотрели
1. Получение объектов через *вычисление выражений* (примеры таких выражений: `1`, `a + 1`)
2. Создание или изменение ссылки переменной через *присваивание* (в общем виде, `имя = выражение`, например `a = 1`, `a = 1 + 2`)

Обратите внимание, что каждый из механизмов происходит в соответствии с конкретным текстом в программе, и приводит к конкретным изменениям в диаграмме.  Например, выражение `1 + 1` вычислилось, и результатом его вычисления является объект в оперативной памяти, который вы можете визуально представить так

{% python_state() %}
objects:
  a:
    type: int
    value: 2
{% end %}

Затем произошло присваивание `a = 1 + 1`, которое визуально можно представить как

{% python_state() %}
frames:
  global:
    bindings:
      - name: a
        object: a
objects:
  a:
    type: int
    value: 2
{% end %}


В целом, эти два механизма будут нас сопровождать при разработке на Python постоянно, потому важно уметь бегло считывать использование этих механизмов при чтении кода: видеть их в коде и понимать, как именно они отражаются на состоянии программы.

```python
a = 1 + 1
```

# Оптимизации использования оперативной памяти

Рассмотрим такой код.

```python
str_1 = "Hello"
str_2 = "Hello"
lst_1 = []
lst_2 = []

print(str_1, str_2, lst_1, lst_2)
```

Логично будет предположить, что после выполнения этого кода, в оперативной памяти мы увидим следующее

{% python_state() %}
frames:
  global:
    bindings:
      - name: str_1
        object: str_1
      - name: str_2
        object: str_2
      - name: lst_1
        object: lst_1
      - name: lst_2
        object: lst_2
objects:
  str_1:
    type: str
    value: Hello
  str_2:
    type: str
    value: Hello
  lst_1:
    type: list
    value: []
  lst_2:
    type: list
    value: []
composition: '{"composition":{"v":1,"h":"ps1-1lfqhaey4co","u":"1","p":{"frame:global":[118,24],"object:str_1":[560,24],"object:str_2":[559,102],"object:lst_1":[408,191],"object:lst_2":[408,270]}}}'
{% end %}

Но давайте подумаем, есть ли смысл в том, чтобы держать в памяти все 4 объекта?  Тут же есть два дубля: в памяти два раза лежит одно и то же.  Можно сохранить в памяти всего два объекта, и результат выполнения не поменяется.  Допустим, интерпретатор Python тоже так решил, и вот в этих строках

```python,hl_lines="2 4"
str_1 = "Hello"
str_2 = "Hello"
lst_1 = []
lst_2 = []

print(str_1, str_2, lst_1, lst_2)
```

Не создавал объект, а возвращал уже имеющийся, точно такой же объект.  В таком случае, получится так

{% python_state() %}
frames:
  global:
    bindings:
      - name: str_1
        object: str_1
      - name: str_2
        object: str_1
      - name: lst_1
        object: lst_1
      - name: lst_2
        object: lst_1
objects:
  str_1:
    type: str
    value: Hello
  lst_1:
    type: list
    value: []
{% end %}

Но что, если мы захотим добавить в один из списков элемент?

```python
str_1 = "Hello"
str_2 = "Hello"
lst_1 = []
lst_2 = []

lst_1.append(str_1)

print(str_1, str_2, lst_1, lst_2)
```

В таком случае получилось следующее

{% python_state() %}
frames:
  global:
    bindings:
      - name: str_1
        object: str_1
      - name: str_2
        object: str_1
      - name: lst_1
        object: lst_1
      - name: lst_2
        object: lst_1
objects:
  str_1:
    type: str
    value: Hello
  lst_1:
    type: list
    value:
      - object: str_1
composition: '{"composition":{"v":1,"h":"ps1-qdbr0sdp76","u":"1","p":{"frame:global":[118,60],"object:str_1":[619,71.88],"object:lst_1":[438,144]}}}'
{% end %}

И в выводе у нас будет

```txt
Hello Hello ['Hello'] ['Hello']
```

Что, понятное дело, не то, чего мы ожидаем.  Мы хотим, чтобы изменился только один список; мы ожидаем, что имена указывают на разные места в памяти, и хотим изменить только одно из них.  Поэтому так оптимизировать хранение списков у нас не получится.

Но что насчёт строк? А со строками дело обстоит интереснее.  Они неизменяемы.  Вы никаким образом не сможете изменить то, что находится внутри объекта с типом `str`.  Поэтому для них такая оптимизация будет работать.  По этой причине Python оставляет за собой возможность вернуть вам тот же самый объект.  Поэтому вот этот код

```python
str_1 = "Hello"
str_2 = "Hello"
lst_1 = []
lst_2 = []

lst_1.append(str_1)

print(str_1, str_2, lst_1, lst_2)
```

Может привести как к такому состоянию

{% python_state() %}
frames:
  global:
    bindings:
      - name: str_1
        object: str_1
      - name: str_2
        object: str_2
      - name: lst_1
        object: lst_1
      - name: lst_2
        object: lst_2
objects:
  str_1:
    type: str
    value: Hello
  str_2:
    type: str
    value: Hello
  lst_1:
    type: list
    value:
      - object: str_1
  lst_2:
    type: list
    value: []
composition: '{"composition":{"v":1,"h":"ps1-29w18v1iih7","u":"1","p":{"frame:global":[118,102],"object:str_1":[623,24],"object:str_2":[623,103],"object:lst_1":[467,181],"object:lst_2":[467,282]}}}'
{% end %}

Так и к такому

{% python_state() %}
frames:
  global:
    bindings:
      - name: str_1
        object: str_1
      - name: str_2
        object: str_1
      - name: lst_1
        object: lst_1
      - name: lst_2
        object: lst_2
objects:
  str_1:
    type: str
    value: Hello
  lst_1:
    type: list
    value:
      - object: str_1
  lst_2:
    type: list
    value: []
composition: '{"composition":{"v":1,"h":"ps1-15eykcowgcj","u":"1","p":{"frame:global":[118,145.37],"object:str_1":[630,24],"object:lst_1":[467,145.37],"object:lst_2":[467,246.37]}}}'
{% end %}

И, в целом, нам пока не так важно, какой из вариантов произойдёт.  Просто запомните, что для некоторых неизменяемых объектов реализация Python может переиспользовать уже существующий объект.

# Задания

## Задание 1

```python
name = "Tom"
age = 20

message = name + " is " + str(age)
age = age + 1
name = name + " Smith"

final_message = name + " is " + str(age)
```

Попробуйте самостоятельно подробно объяснить, что происходит на каждой строке:
1. Какие объекты вычисляются (с какими типами и значениями)?
2. Какие имена начинают ссылаться на какой объект?
3. На какие объекты ссылаются имена name, age, message и final_message после каждой строки?
4. Изменяется ли какой-нибудь уже существующий объект?

## Задание 2

Напишите несколько программ на Python.

Ниже приведены картинки, на которых изображено состояние программы.  Вы должны для каждой картинки написать хотя бы две программы, которые приводят именно к такому состоянию.

### Пример

{% python_state() %}
frames:
  global:
    bindings:
      - name: items
        object: items
      - name: alias
        object: items
objects:
  items:
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
{% end %}

Тут мы видим, что есть два имени. Первое имя ссылается на объект типа `list`, в значении имеющий две ссылки: на объект с типом `int` и значением `1`, и на объект с типом `int` и значением `2`.
Второе имя ссылается на тот же самый объект типа `list`.

К примеру, вот такой код приведёт к нужной нам ситуации:

```python
items = [1, 2]
alias = items
```

Но важно понимать, что к состоянию программы, приведённому на картинке, приведут ещё куча других вариантов кода.  И потому можно сказать, что результат выполнения этих вариантов будет идентичным.  Вот некоторые из них:

```python
items = [1]  # есть список, есть имя которое на него ссылается
items.append(2)  # изменили список, теперь он такой как нужен
alias = items  # теперь на него ссылается второе нужное имя
```

```python
items = [1]  # то же самое
alias = items  # сразу сделали второе имя
alias.append(2)  # теперь список такой как надо
```

```python
items = list()  # сделали сначала пустой список и первое нужное имя на него указывает
alias = items  # теперь на него ссылается второе нужное имя
items.extend([1, 2])  # изменили список: там теперь ссылки на все нужные объекты
```

Пример, где лаконичность намного хуже.  Но тем не менее его результат точно такой же как у остальных:

```python
[1, 2]  # сделали нужный список

# но никакое имя на него не указывает, так-что он сразу
#  удалился, не оказав влияния на финальное состояние

items = 1 

# используем имя, ссылающееся на единицу, чтобы сделать
#  список в котором есть ссылка на ту же единицу
items = [items]

alias = items

# используем ссылки на единицу которые у нас есть чтобы
#  получить двойку.  и изменяем список: добавляем в него 
#  ссылку на эту двойку.
alias.append(alias[0] + alias[0])
```

Выполнение каждого из этих фрагментов кода приводит к тому, что состояние программы становится таким, как изображено на картинке выше.

Указание: представляйте в уме или рисуйте промежуточные состояния кода который вы пишите.  Финальное состояние должно быть в точности таким какое нарисовано, но промежуточные могут быть очень разными, как в этом примере.

Примечания:
1. Вы можете двигать блоки на картинках.
2. Вы можете навести мышку на начало или конец стрелки, чтобы понять, куда именно она указывает.
3. Вы можете нажать `Full page` рядом с диаграммой чтобы развернуть её на всю страницу.

### Первое состояние

{% python_state() %}
frames:
  global:
    bindings:
      - name: name
        object: name
      - name: number
        object: number
objects:
  name:
    type: str
    value: Alex 22.3
  number:
    type: float
    value: 22.3
{% end %}


### Второе состояние

{% python_state() %}
frames:
  global:
    bindings:
      - name: name
        object: name
      - name: print_hello
        object: print_hello
objects:
  name:
    type: str
    value: Alex
  print_hello:
    type: function
    value: 'Печатает в консоль сообщение "Hello"'
{% end %}

### Третье состояние

{% python_state() %}
frames:
  global:
    bindings:
      - name: items
        object: items
      - name: lst
        object: items
      - name: a
        object: a
objects:
  items:
    type: list
    value:
      - object: one
      - object: a_copy
      - object: a
  a:
    type: str
    value: Hello
  a_copy:
    type: str
    value: Bye
  one:
    type: int
    value: 1
composition: '{"composition":{"v":1,"h":"ps1-buzkxta63j","u":"1","p":{"frame:global":[118,46],"object:items":[447,46],"object:a":[637,204],"object:a_copy":[637,125],"object:one":[639,24]}}}'
{% end %}

### Четвёртое состояние

{% python_state() %}
frames:
  global:
    bindings:
      - name: lst_1
        object: lst_1
      - name: lst_2
        object: lst_2
      - name: lst_3
        object: lst_3

objects:
  lst_2:
    type: list
    value:
      - object: a
      - object: one
  lst_1:
    type: list
    value:
      - object: a
      - object: one
  a:
    type: str
    value: Hello
  one:
    type: int
    value: 1
  lst_3:
    type: list
    value:
      - object: lst_2
composition: '{"composition":{"v":1,"h":"ps1-1yk3jwui8i5","u":"1","p":{"frame:global":[116,25],"object:lst_2":[468,172],"object:lst_1":[310,24],"object:a":[652,40],"object:one":[653,144],"object:lst_3":[310,171]}}}'
{% end %}


### Пятое состояние

{% python_state() %}
frames:
  global:
    bindings:
      - name: data
        object: data
      - name: user
        object: user
      - name: user_copy
        object: user_copy
objects:
  data:
    type: dict
    value:
      - key:
          object: key_users
        value:
          object: users
  users:
    type: list
    value:
      - object: user
  user:
    type: dict
    value:
      - key:
          object: key_id
        value:
          object: one
      - key:
          object: key_name
        value:
          object: test
  user_copy:
    type: dict
    value:
      - key:
          object: key_id
        value:
          object: one
      - key:
          object: key_name
        value:
          object: test
  key_users:
    type: str
    value: users
  key_id:
    type: str
    value: id
  key_name:
    type: str
    value: name
  one:
    type: int
    value: 1
  test:
    type: str
    value: Test
composition: '{"composition":{"v":1,"h":"ps1-1b6m1edqc69","u":"1","p":{"frame:global":[84,174],"object:data":[378,24],"object:users":[453,144],"object:user":[424,271.9],"object:user_copy":[427,414],"object:key_users":[354,145],"object:key_id":[211,401],"object:key_name":[210,485],"object:one":[664,298],"object:test":[662,381]}}}'
{% end %}


### Шестое состояние

{% python_state() %}
frames:
  global:
    bindings:
      - name: array
        object: array
      - name: array_copy
        object: array_copy
      - name: array_deepcopy
        object: array_deepcopy
objects:
  array:
    type: list
    value:
      - object: array_row_1
      - object: array_row_2
  array_copy:
    type: list
    value:
      - object: array_row_1
      - object: array_row_2
  array_deepcopy:
    type: list
    value:
      - object: array_deepcopy_row_1
      - object: array_deepcopy_row_2
  array_row_1:
    type: list
    value:
      - object: one
      - object: two
  array_row_2:
    type: list
    value:
      - object: three
      - object: four
  array_deepcopy_row_1:
    type: list
    value:
      - object: one
      - object: two
  array_deepcopy_row_2:
    type: list
    value:
      - object: three
      - object: four
  one:
    type: int
    value: 1
  two:
    type: int
    value: 2
  three:
    type: int
    value: 3
  four:
    type: int
    value: 4
composition: '{"composition":{"v":1,"h":"ps1-1e1xrpvc1mo","u":"1","p":{"frame:global":[79,24],"object:array":[387,24],"object:array_copy":[387,125],"object:array_deepcopy":[385,280],"object:array_row_1":[542,24],"object:array_row_2":[542,125],"object:array_deepcopy_row_1":[538,281],"object:array_deepcopy_row_2":[537,391],"object:one":[752,38],"object:two":[751,118],"object:three":[751,200],"object:four":[750,283]}}}'
{% end %}
