+++
title = "Python, FastAPI, 1."
date = 2026-05-01
[taxonomies]
tags = ["python", "fastapi"]
+++

Дизайн API.

Запрос:

```http
GET /items HTTP/1.1
```

Ответ:

```http
HTTP/1.1 200 OK
Host: example.com
Content-Type: application/json; charset=utf-8
Content-Length: 50
 
[{"id": 1,"name":"Тёплая куртка","image":"https://example.com/b.png"},{"id":2,"name":"Куртка","image":"https://example.com/a.png"}]
```

Запрос:

```http
GET /items/1 HTTP/1.1
```

Response:

```http
HTTP/1.1 200 OK
Host: example.com
Content-Type: application/json; charset=utf-8
Content-Length: 20
 
{"id": 1,"name":"Шапка","image":"https://example.com/b.png"}
```

Реализация без использования веб-фреймворка

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

Реализация с использованием FastAPI (поведение, формирующее из запроса ответ то же самое, что в примере выше)

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

Код с занятия


```python
from uvicorn import run
from fastapi import FastAPI

app = FastAPI()

ITEMS = [
    {"id": 0, "name": "Тёплая куртка"},
    {"id": 1, "name": "Тёплая куртка"},
    {"id": 2, "name": "Обычные носки"},
    {"id": 3, "name": "Перчатки", "verbose_name": "Резиновые перчатки"},
    {"id": 4, "name": "Холодная куртка"},
]


@app.get("/items")
async def get_all_items():
    return ITEMS


@app.get("/items/{item_id}")
async def get_item_by_id(
        item_id: int,
        verbose_name: bool,
):
    for item in ITEMS:
        if item_id == item["id"]:
            if verbose_name and "verbose_name" in item:
                return {"id": item["id"], "name": item["verbose_name"]}
            return {"id": item["id"], "name": item["name"]}


"""
POST /items?name=Сапоги&verbose_name=Тёплые сапоги HTTP/1.1
Content-Length: 100

request_body
"""


def plus(a, b):
    """
    Функция складывает два числа
    """


# POST, PUT, PATCH

@app.post("/items")
async def create_new_item(
        name: str,
        verbose_name: str,
):
    """
    Создаёт новый айтем
    """

    new_item = {
        "id": len(ITEMS),
        "name": name,
        "verbose_name": verbose_name,
    }

    ITEMS.append(new_item)
    return new_item


run(app)
```

