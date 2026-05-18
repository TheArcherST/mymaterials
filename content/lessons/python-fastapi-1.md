+++
title = "Python, FastAPI, 1."
date = 2026-05-01
[taxonomies]
tags = ["python", "fastapi"]
+++

Дизайн API.

Request:

```http
GET /cards HTTP/1.1
```

Response:

```http
HTTP/1.1 200 OK
Host: example.com
Content-Type: application/json; charset=utf-8
Content-Length: 50
 
[{"id": 1,"name":"Шапка","image":"https://example.com/b.png"},{"id":2,"name":"Куртка","image":"https://example.com/a.png"}]
```

Request:

```http
GET /cards/1 HTTP/1.1
```

Response:

```http
HTTP/1.1 200 OK
Host: example.com
Content-Type: application/json; charset=utf-8
Content-Length: 20
 
{"id": 1,"name":"Шапка","image":"https://example.com/b.png"}
```

Реализация

```python
from waitress import serve

import json


ITEMS = [
    {
        "id": 1,
        "name": "Тёплая куртка",
    },
    {
        "id": 2,
        "name": "Обычные носки",
    },
    {
        "id": 3,
        "name": "Перчатки",
    },
]


def app(environ, start_response):
    # Метод запроса: GET, POST, PUT, DELETE и т.д.
    method = environ["REQUEST_METHOD"]

    # Путь запроса: /items, /items/1 и т.д.
    path = environ["PATH_INFO"]

    # тут будут лежать данные, которые мы хотим вернуть в зависимости от запроса
    result_data = None

    # Получение списка
    if method == "GET" and path == "/items":
        result_data = ITEMS

    # Получение одного элемента
    elif method == "GET" and path.startswith("/items/"):
        without_prefix = path.removeprefix("/items/")

        try:
            item_id = int(without_prefix)
        except ValueError:
            # возвращаем HTTP-ответ с ошибкой: id должен быть числом
            start_response("400 Bad Request", [("Content-Type", "text/plain; charset=utf-8")])
            return ["Item id must be a number".encode("utf-8")]

        for item in ITEMS:
            if item_id == item["id"]:
                result_data = item
                break
        else:  # если цикл закончился без break: всё обошли и ничего не нашли
            # возвращаем HTTP-ответ с ошибкой: элемента с таким id у нас нет
            start_response("404 Not Found", [("Content-Type", "text/plain; charset=utf-8")])
            return ["Item not found".encode("utf-8")]

    # ... если никакой из вариантов не подошёл
    if result_data is None:
        # по желанию можно делать страницы с ошибками, чтобы пользователю было понятнее,
        # что произошло без знаний HTTP
        headers = [
            # этот HTTP-заголовок в ответе нужен, чтобы браузер правильно декодировал русский текст из тела ответа
            ("Content-Type", "text/html; charset=utf-8")
        ]
        start_response("404 Not Found", headers)
        page = "Ничего не нашли! Попробуйте другой путь"
        page_bytes = page.encode("utf-8")
        return [page_bytes]

    # ... иначе формируем успешный ответ

    # начало ответа: версия протокола подставляется автоматически;
    # мы указываем статус, сообщение и заголовки
    headers = [
        ("Content-Type", "application/json; charset=utf-8")
    ]
    start_response("200 OK", headers)

    # формируем и отправляем тело ответа
    result_string = json.dumps(result_data)
    result_bytes = result_string.encode("utf-8")
    return [result_bytes]


serve(app) 
```

Обработка мокового запроса:

```python
# ------------------------------
# Данные
# ------------------------------
ITEMS = [
    {"id": 1, "name": "Шапка"},
    {"id": 2, "name": "Куртка"},
    {"id": 3, "name": "Перчатки"},
]

# ------------------------------
# Мок start_response
# ------------------------------
start_response_calls = []

def start_response(status, headers):
    start_response_calls.append((status, headers))

# ------------------------------
# WSGI-обработчик
# ------------------------------
def app(environ, start_response):
    method = environ["REQUEST_METHOD"]
    path = environ["PATH_INFO"]
    result_data = None

    # Получение всех items
    if method == "GET" and path == "/items":
        result_data = ITEMS

    # Получение одного item по id
    elif method == "GET" and path.startswith("/items/"):
        without_prefix = path.removeprefix("/items/")
        try:
            item_id = int(without_prefix)
        except ValueError:
            start_response("400 Bad Request", [("Content-Type", "text/plain; charset=utf-8")])
            return [b"Item id must be a number"]

        for item in ITEMS:
            if item["id"] == item_id:
                result_data = item
                break
        else:
            start_response("404 Not Found", [("Content-Type", "text/plain; charset=utf-8")])
            return [b"Item not found"]

    if result_data is None:
        start_response("404 Not Found", [("Content-Type", "text/plain; charset=utf-8")])
        return [b"Not Found"]

    start_response("200 OK", [("Content-Type", "application/json; charset=utf-8")])
    return [str(result_data).encode()]

# ------------------------------
# Мок запроса
# ------------------------------
mock_request = {
    "REQUEST_METHOD": "GET",
    "PATH_INFO": "/items/2"
}

# ------------------------------
# Вызов WSGI обработчика с моком
# ------------------------------
response_body = app(mock_request, start_response)

# ------------------------------
# Вывод результата
# ------------------------------
print("Status & Headers:", start_response_calls)
print("Body:", response_body[0].decode())
```


```python
from uvicorn import run
from fastapi import FastAPI

ITEMS = ...


app = FastAPI()


@app.get("/items")
def get_items():
    return ITEMS


@app.get("/items/{item_id}")
def get_item_by_id(item_id: int):
    pass


run(app)
```

