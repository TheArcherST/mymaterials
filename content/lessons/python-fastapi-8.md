+++
title = "Python, FastAPI, 8."
date = 2026-06-09
[taxonomies]
tags = ["python", "fastapi"]
+++


# Полезные ресурсы

1. У постгреса есть официальная документация, доступная и на английском и на русском.  Причём документация эта написана достаточно доступно.  В частности, там есть раздел про транзакции: [на английском](https://www.postgresql.org/docs/18/tutorial-transactions.html) и [на русском](https://postgrespro.ru/docs/postgresql/18/tutorial-transactions?lang=ru).


# Код с занятия

Обратите внимание, что перед запуском надо установить и asyncpg, и sqlalchemy.


```python
import asyncio

from sqlalchemy import select, insert
from sqlalchemy.orm import Mapped, mapped_column, DeclarativeBase
from sqlalchemy.ext.asyncio import create_async_engine


class Base(DeclarativeBase):
    pass


class Users(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(nullable=False)
    age: Mapped[int]
    passport: Mapped[int]


class Tasks(Base):
    __tablename__ = "tasks"

    id: Mapped[int] = mapped_column(primary_key=True)
    title: Mapped[str]


async def main():
    engine = create_async_engine(
        "postgresql+asyncpg://postgres:postgres@127.0.0.1/postgres",
        echo=True,  # SQLAlchemy воспринимает это как указание писать в консоль все SQL запросы которые он отправляет в базу данных через asyncpg
    )
    conn = await engine.connect()

    # эта строчка вызывает через проверку того что есть в БД и затем создание таблиц (привязанных к Base) которых там ещё нет
    await conn.run_sync(Base.metadata.create_all)
    
    stmt = insert(Users).values(name="Mihail", age=19, passport=123123)
    await conn.execute(stmt)

    stmt = select(Users)
    result = await conn.execute(stmt)
    print(result.all())
    
    # коммитим текущую транзакцию (по-простому "сохраняем изменения")
    await conn.commit()

    await conn.rollback()
    await conn.close()


asyncio.run(main())
```

# Домашнее задание

Попробуйте переписать код из прошлого домашнего задания с asyncpg на asyncpg+SQLAlchemy.

