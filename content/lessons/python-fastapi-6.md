+++
title = "Python, FastAPI, 6."
date = 2026-06-01
[taxonomies]
tags = ["python", "fastapi"]
+++

## Код с занятия

### FastAPI + PostgreSQL: создание и получение пользователей

```python
import asyncpg
from uvicorn import run
from fastapi import FastAPI
from pydantic import BaseModel


app = FastAPI()


async def create_connection():
    conn = await asyncpg.connect(
        "postgresql://postgres:42536@127.0.0.1/postgres"
    )
    return conn


async def create_users_table(conn):
    await conn.execute("""
    create table if not exists users (
        id int generated always as identity primary key,
        name varchar not null
    )
    """)


class CreateUser(BaseModel):
    name: str


@app.post("/users")
async def create_user(payload: CreateUser):
    conn = await create_connection()
    await create_users_table(conn)

    await conn.execute("""
    insert into users (name) values ($1)
    """, payload.name)

    # Оставляем max(id), как в коде с занятия.
    # В реальном коде лучше использовать insert ... returning id.
    data = await conn.fetch("""
    select max(id) as id from users
    """)

    user_id = data[0]["id"]

    await conn.close()

    return {
        "id": user_id,
        "name": payload.name
    }



@app.get("/users")
async def get_users():
    conn = await create_connection()
    await create_users_table(conn)

    # тут надо написать чтение пользователей из БД и отправление результата


if __name__ == "__main__":
    run(app)
```

### Пример на котором разбирали асинхронность

```python
import asyncio
import time


async def handle_request(request):
    pass


async def first_task():
    print("Hello from first!")
    await asyncio.sleep(1)
    print("Bye from first!")


async def second_task():
    print("Hello from second!")
    await asyncio.sleep(1)
    print("Bye from second!")


async def main():
    asyncio.create_task(first_task())
    asyncio.create_task(second_task())

    await asyncio.sleep(3)


asyncio.run(main())
```

### Псевдокод, примерно показывающий логику по кторой работают uvicorn+fastapi

```python
while True:
    request = get_next_request()
    handler = route(request)  # маршрутизируем полученный запрос
    arguments = prepare_arguments(handler, request)  # fastapi получает из запроса именно те данные что мы запросили в аргументах нашей функции
    response = handler(arguments)  # вызов нашей функции
    send_response(response)  # отправляем ответ по сети
    # и потом переходим к обработке следующего запроса
```

Но в действительности всё работает асинхронно: FastAPI асинхронно вызывает нашу функцию, и когда наша функция отдаёт управление, FastAPI может начать обрабатывать следующий запрос.  Можно представить это так

```python
import asyncio


async def process_request(request):
    handler = route(request)  # маршрутизируем полученный запрос
    arguments = prepare_arguments(handler, request)  # fastapi получает из запроса именно те данные что мы запросили в аргументах нашей функции
    response = await handler(arguments)  # асинхронный вызов нашей функции
    # если обработчик внутри, например, сделает асихнронный вызов к БД, управление может быть передано в цикл событий.  Если обработчик не делает ничего что отдаёт управление в event loop, код фактически останется синхронным: задачи просто будут поочерёдно выполняться.

    send_response(response)  # отправляем ответ по сети



async def main():
    while True:
        request = get_next_request()
        asyncio.create_task(process_request(request))


asyncio.run(main())

```



## Домашнее задание

Добавьте в код, который мы писали в классе, возможность получать список всех пользователей из базы данных.

