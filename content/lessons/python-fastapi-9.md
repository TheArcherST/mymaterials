+++
title = "Python, FastAPI, 9."
date = 2026-06-11
[taxonomies]
tags = ["python", "fastapi"]
+++


# Код с занятия

Немного изменённый.  На следующем занятии подбробно разберём все нюансы о которых я не сказал на этом.


```python
from sqlalchemy import select
from uvicorn import run
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

from sqlalchemy.orm import Mapped, mapped_column, DeclarativeBase
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

app = FastAPI()


class Base(DeclarativeBase):
    pass


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str]
    age: Mapped[int]
    password: Mapped[str]


class CreateUser(BaseModel):
    name: str
    age: int
    password: str


engine = create_async_engine(
    "postgresql+asyncpg://postgres:postgres@127.0.0.1/postgres",
    echo=True,
)


@app.post("/create-all")
async def create_all():
    # можно вынести создание и прогнать один раз только
    conn = await engine.connect()
    await conn.run_sync(Base.metadata.create_all)
    await conn.commit()
    await conn.close()


@app.post("/users")
async def create_user(
        data: CreateUser,
):
    conn = await engine.connect()
    session = AsyncSession(conn)

    new_user = User(
        name=data.name,
        age=data.age,
        password=data.password,
    )
    session.add(new_user)
    await session.flush()

    result = {
        "id": new_user.id,  # он тут появляется только после flush, кстати.  подумайте почему так
        "name": data.name,
        "age": data.age,
    }

    # после того как мы закоммитим, уже нельзя будет получать поля объекта user,
    #  поскольку SQLAlchemy неуверен в том, актуальные данные или нет.
    #  потом подробнее это разберём.
    await session.commit()

    await conn.close()

    return result


@app.get("/users/{user_id}")
async def get_user(user_id: int):
    conn = await engine.connect()
    session = AsyncSession(conn)

    stmt = (select(User)
            .where(User.id == user_id))
    result = await session.execute(stmt)
    users = result.all()

    if len(users) == 0:
        raise HTTPException(status_code=404)

    # обратите внимание на то, что тут тоже как-бы таблица 1 на 1 нам вернулась,
    #  где в одной и единственной клетке у нас целый пользователь, а не одно
    #  какое-то поле.  потом подробнее разберём почему именно так.
    user = users[0][0]

    result = {
        "id": user.id,
        "name": user.name,
        "age": user.age,
    }

    await conn.close()

    return result


run(app)

```

# Домашнее задание

Добавьте в код эндпоинты `GET /users` и `DELETE /users/{user_id}`.  Проверьте, всё ли работает.

