+++
title = "Python, FastAPI, 4."
date = 2026-05-25
[taxonomies]
tags = ["python", "fastapi"]
+++

## Полезные ресурсы (на русском)

1. [Интерфейс функции fetch](https://developer.mozilla.org/ru/docs/Web/API/Window/fetch)
2. [Подробно про объект Response (результат выполнения Fetch)](https://developer.mozilla.org/ru/docs/Web/API/Response)


## Домашнее задание

Ниже дан код на JS, который обращается к API, размещённому на http://127.0.0.1:8000. Вам нужно реализовать этот API на FastAPI (восстановив его интерфейс и логику из JS-кода).


```js
// 1. Сложение
response = await fetch('http://127.0.0.1:8000/calculate', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: '{"operation": "add", "a": 10, "b": 5}'
})

json_data = await response.json()
console.log(json_data) // { result: 15 }


// 2. Вычитание
response = await fetch('http://127.0.0.1:8000/calculate', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: '{"operation": "subtract", "a": 10, "b": 5}'
})

json_data = await response.json()
console.log(json_data) // { result: 5 }


// 3. Деление
response = await fetch('http://127.0.0.1:8000/calculate', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: '{"operation": "divide", "a": 10, "b": 2}'
})

json_data = await response.json()
console.log(json_data) // { result: 5 }
```

Дополнительные задания:

1. Корректно обработайте исключения, в т.ч. некорректную операцию и деление на 0. Обратите внимание на то, чтобы в HTTP-ответе код был не успешный (200), а связанный с произошедшей ошибкой.
2. Добавьте возможность получить историю операций. Решите при этом, в каком виде лучше хранить одну операцию: только результатом вычисления или объектом, где есть операция, числа и результат.

Указания:

1. Обращайте внимание на то, какой HTTP-запрос формирует `fetch`, и как должен выглядеть роут (маршрут) в FastAPI, который бы корректно отлавливал такой HTTP-запрос.
2. Чтобы логика работы калькулятора была полностью отделена от логики работы с HTTP, можно сделать отдельно функцию calculate, принимающую операцию и два числа, и уже её использовать в роуте.
3. Чтобы сохранить операции до момента, когда пользователь захочет получить историю, можно использовать глобальную переменную. Например, это может быть список, в который вы добавляете информацию о каждой операции.
4. Обратите внимание на то, что именно выводится в console.log(json_data). API должен возвращать результат именно в таком виде, не просто числом.

