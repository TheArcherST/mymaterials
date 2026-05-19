+++
title = "Python, FastAPI, 2."
date = 2026-05-01
[taxonomies]
tags = ["python", "fastapi"]
+++

## Полезные ресурсы (на русском)

1. [Официальный ресурс по изучению FastAPI](https://fastapi.tiangolo.com/ru/learn/)
2. [Хороший (но не самый простой) материал по HTTP](https://developer.mozilla.org/ru/docs/Web/HTTP/Guides/Overview).  На том же сайте ещё много смежных материалов.  Некоторые на русском, некоторые только на англ.


## Пример HTTP API с которым работали:

### Эндпоинт для получения всех айтемов

Запрос:

```http
GET /items HTTP/1.1
```

Ответ:

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
 
[{"id":0,"name":"Тёплая куртка"},{"id":1,"name":"Обычные носки"},{"id":2,"name":"Перчатки"}]
```

### Эндпоинт для получения одного айтема по айди

Запрос:

```http
GET /items/0 HTTP/1.1
```

Ответ:

```http
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
 
{"id":0,"name":"Тёплая куртка"}
```

## Реализация без использования веб-фреймворка

```python
from waitress import serve
 
import json
 
 
ITEMS = [
    {
        "id": 0,
        "name": "Тёплая куртка",
    },
    {
        "id": 1,
        "name": "Обычные носки",
    },
    {
        "id": 2,
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
 
    # Получение всех айтемов
    if method == "GET" and path == "/items":
        result_data = ITEMS
 
    # Получение одного по айди
    elif method == "GET" and path.startswith("/items/"):
        without_prefix = path.removeprefix("/items/")
 
        try:
            item_id = int(without_prefix)
        except ValueError:
            # FastAPI в похожей ситуации вернёт более длинный текст ошибки, но логика работы такая же
            headers = [("Content-Type", "application/json; charset=utf-8")]
            start_response("422 Unprocessable Entity", headers)
            return ['{"detail":"item_id must be an integer"}'.encode("utf-8")]

        for item in ITEMS:
            if item_id == item["id"]:
                result_data = item
                break
        else:  # если цикл закончился без break: всё обошли и ничего не нашли
            headers = [("Content-Type", "application/json; charset=utf-8")]
            start_response("404 Not Found", headers)
            return ['{"detail":"Item not found"}'.encode("utf-8")]
 
    # ... если никакой из маршрутов не подошёл
    if result_data is None:
        headers = [("Content-Type", "application/json; charset=utf-8")]
        start_response("404 Not Found", headers)
        return ['{"detail":"Not found"}'.encode("utf-8")]
 
    # ... иначе формируем успешный ответ
    headers = [("Content-Type", "application/json; charset=utf-8")]
    start_response("200 OK", headers)
    return [json.dumps(result_data, ensure_ascii=False).encode("utf-8")]
 
 
serve(app) 
```

## Реализация с использованием FastAPI (поведение, формирующее из HTTP запроса HTTP ответ то же самое, что в примере выше)

```python
from uvicorn import run
from fastapi import FastAPI, HTTPException

ITEMS = [
    {"id": 0, "name": "Тёплая куртка"},
    {"id": 1, "name": "Обычные носки"},
    {"id": 2, "name": "Перчатки"},
]
 
 
app = FastAPI()
 
 
@app.get("/items")
def get_items():
    return ITEMS
 

@app.get("/items/{item_id}")
def get_item_by_id(item_id: int):
    for item in ITEMS:
        if item["id"] == item_id:
            return item

    # забыл сказать про это.  так в fastapi формируют HTTP ответ с ошибкой.  на след. занятии разберём.
    raise HTTPException(status_code=404, detail="Item not found")
 
 
run(app)
```

## Код с занятия


```python
from uvicorn import run
from fastapi import FastAPI, HTTPException

app = FastAPI()

ITEMS = [
    {"id": 0, "name": "Тёплая куртка"},
    {"id": 1, "name": "Обычные носки"},
    {"id": 2, "name": "Перчатки", "verbose_name": "Резиновые перчатки"},
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

    # забыл сказать про это.  так в fastapi формируют HTTP ответ с ошибкой.  на след. занятии разберём.
    raise HTTPException(status_code=404, detail="Item not found")


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

