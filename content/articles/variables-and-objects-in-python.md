+++
title = "Переменные и объекты в Python"
date = 2026-05-28
[taxonomies]
tags = ["Python"]
+++

Переменной в Python называют имя, связанное с объектом.

Объектом в Python называют отдельный фрагмент данных, лежащий в оперативной памяти компьютера.  Этот фрагмент данных состоит из типа объекта и значения объекта.

# Как хранятся данные объектов

Оперативная память компьютера это место, в котором хранятся данные, с которыми компьютер активно работает в данный момент.  Сейчас мы сосредоточимся на том, что находится в опреативной памяти между выполнением инструкций из нашей программы на Python.

Давайте попробуем понять, какие данные окажутся в памяти после выполнения вот такой инструкции:

```python
a = "Hello World"
```

Представим, что перед нами лист бумаги, на котором написано всё то, что компьтер сохраняет в оперативную память.  Как уже было сказано, в оперативной памяти хранится то, с чем компьютер работает в данный момент.  Ну, кажется логичным, что там должна быть записана строка с текстом `Hello World`.  Это действительно так, компьютер загрузит в оперативную память эту строку.  Давайте отразим это на бумаге:

{% python_state() %}
objects:
  a:
    type: str
    value: Hello World
{% end %}

Эта аналогия с листом бумаги очень грубая, но её достаточно чтобы понимать, как работает программа на Python.

Python с данными работает как с объектами, и наша строка не является исключением.  В оперативной памяти выделилось место под наш объект, записались его тип и значение.  Поскольку это строка, тип объекта будет `str`.

Но что дальше?  Просто записать данные в оперативную память немного бессмысленно, поскольку после завершения программы эти данные просто сотрутся.  Что можно сделать полезного с ними?  Например, можно их напечатать в консоль.  Например вот так...

```python
a = "Hello World"
print(a)  # Hello World
```

Давайте разбираться, что именно при этом происходит.  Тут важно понимать, что Python воспринимает этот код не как что-то цельное, а как набор из двух отдельных инструкций, выполняемых по отдельности.  Для первой инструкции мы уже поняли, что интерпретатор запишет в память строку `"Hello World"`.  Но что он сделает дальше, при выполнении второй инструкции?  Он находится в такой ситуации:

Инструкция, которую он должен выполнить:

```python
print(a)
```
Данные в оперативной памяти, с которыми он может работать при её выполнении:

{% python_state() %}
objects:
  a:
    type: str
    value: Hello World
{% end %}

Как он должен понять, что такое `a`?  Он с такими вводными это никак не сможет понять.  В опретивной памяти должна быть ещё информация о том, что обозначает имя `a`.  На самом деле после выполнения инструкции

```python
a = "Hello World"
```

В опреативной памяти окажется следующее:

{% python_state() %}
frames:
  global:
    bindings:
      - name: a
        object: a
objects:
  a:
    type: str
    value: Hello World
{% end %}

И исходя уже из этого, Python поймёт, что обозначает имя `a`. И соответсвенно напечатает объект, с которым это имя связано.

Получается, что смотря на данные в опративной памяти, теперь мы можем точно сказать, что произойдёт при выполнении нашей второй инструкции.  Именно так Python и определяет, что ему надо сделать.

Про ссылку на объект, которая изображена на диаграмме точкой рядом с именем `a`, можно думать как про адрес дома.  Адрес дома ведь это тоже по сути просто некоторые данные, и мы, люди, понимаем, как можно используя эти данные определить, где дом находится.  Ссылка это тоже некоторые данные, находящиеся в оперативной памяти (например число).  Но нам, людям, сложно будет понять, где находится память, даже если мы знаем эти данные.  Вот например число `141651`.  Как определить, где находится объект в памяти, зная это число?  Мы не знаем, но Python знает как это сделать.  Мы же просто для понимания будем рисовать стрелочку на место в памяти, Python сам поймёт как найти объект, который лежит в этом месте.

Рассмотрим другой пример.  Есть такой код на Python:

```python
b = [1, "Hello world"]
```

Тут есть уже понятная нам вещь: появляется имя, за именем скрывается ссылка, то есть адрес на какое-то место в оперативной памяти.  Но что будет в этом месте?  Как нам это отобразить на бумаге?

Можно было бы подумать, что в этом месте будут данные единицы, данные строки `Hello world`.  Но это не совсем так.

Дело в том, что при выполнении этой строки будет задействовано не одно место в памяти, а сразу три.  А если считать имя, то даже четыре.  В понимании Python тут есть три объекта:

{% python_state() %}
frames:
  global:
    bindings:
      - name: b
        object: c
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

Один из этих объектов является нашим списком.  Список хранит информацию о том, где находятся другие два объекта.  Иначе говоря, список хранит ссылки на свои элементы, а не сами элементы.

Вообще, когда в фрагменте кода вы видите сразу несколько кусочков, выполнив каждый из которых в принципе можно получить объект, обычно Python работает с таким кодом создавая много отдельных объектов, а не помещая всё в один.  Вот пример небольшого кода с большим количеством самостоятельных кусочков, каждый из которых будет соответствовать отдельному объекту в памяти:

```python
a = {"b": 1, "c": [2]}
```

{% python_state() %}
frames:
  global:
    bindings:
      - name: a
        object: a
objects:
  a:
    type: dict
    value:
      - key:
          object: key_b
        value:
          object: one
      - key:
          object: key_c
        value:
          object: items
  key_b:
    type: str
    value: b
  one:
    type: int
    value: 1
  key_c:
    type: str
    value: c
  items:
    type: list
    value:
      - object: two
  two:
    type: int
    value: 2
composition: '{"composition":{"v":1,"h":"ps1-1we9utz5qut","u":"1","p":{"frame:global":[121,28],"object:a":[421,24],"object:key_b":[275,109],"object:one":[719,51],"object:key_c":[274,190],"object:items":[574,110],"object:two":[717,132]}}}'
{% end %}

# Работа с данными объектов

Тип уже созданного объекта никак нельзя изменить.  Если вы создали список, вы не можете его изменить так, чтобы он стал строкой, числом, или чем-то ещё.  Физически конечно вы можете перезаписать данные о типе объекта в оперативной памяти, но через обычный Python код эту возможность сознательно ограничили.  Но значение некоторых объектов можно изменить.  Например, список поддерживает добавление новых элементов: то есть можно изменить его значение, добавив туда данные о месте нахождения ещё одного объекта:

```python
lst = []
```

{% python_state() %}
frames:
  global:
    bindings:
      - name: lst
        object: lst
objects:
  lst:
    type: list
    value: []
{% end %}

```python
lst.append(1)
```

{% python_state() %}
frames:
  global:
    bindings:
      - name: lst
        object: lst
objects:
  lst:
    type: list
    value:
      - object: one
  one:
    type: int
    value: 1
{% end %}

Однако значение некоторых объектов никак нельзя изменить, и нужно запомнить, какие объекты являются *неизменяемыми*.  Начнём с того, что нельзя изменить объекты вот с этими типами: `int`, `float`, `str`, `bool`.

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

То же самое относится к любым операциям со строками: данные объекта типа `str` не могут быть изменены.

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
2. Изменение уже известных объектов в ходе вычисления выражений (например `some_list.append(1)`)
3. Создание или изменение ссылки переменной через *присваивание* (например `a = 1`, `a = 1 + 2`, `lst = [4]`, `a = some_list`)

Обратите внимание, что каждый из механизмов происходит в соответствии с конкретным текстом в программе, и приводит к конкретным изменениям в оперативной памяти.  А то, что находится в оперативной памяти, напрямую определяет дальнейший ход выполнения программы.

В целом, эти механизмы будут нас сопровождать при разработке на Python постоянно, потому важно уметь бегло считывать использование этих механизмов при чтении кода: видеть их в коде и понимать, как именно они отражаются на состоянии программы.  Глядя на код, вы должны видеть какие из них в нём присутствуют, и понимать последствия их работы для оперативной памяти:

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

```python,hl_lines=2 4
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

# но никакое имя на него не указывает, так что он сразу
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

Указание: представляйте в уме или рисуйте промежуточные состояния кода который вы пишете.  Финальное состояние должно быть в точности таким какое нарисовано, но промежуточные могут быть очень разными, как в этом примере.

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
