+++
title = "Python, FastAPI, 3."
date = 2026-05-21
[taxonomies]
tags = ["python", "fastapi"]
+++

## Полезные ресурсы (на русском)

1. Курсы по Python на Stepik: [первый](https://stepik.org/course/58852) и [второй](https://stepik.org/course/68343/promo).  Сам я не проходил, но слышал, что там хорошо даётся база.


## Код с занятия


```python
from uvicorn import run
from pydantic import BaseModel
from fastapi import FastAPI, HTTPException


app = FastAPI()


CHATS: dict[int, dict] = dict()

# Пример данных:
# CHATS = {0: {"text": "Hello", "sender_name": "Mihail"}}


@app.post("/chats")
async def create_chat():
    pass


class Message(BaseModel):
    text: str = Field(min_length=1, max_length=2048)
    sender_name: str


@app.post("/chats/{chat_id}/messages")
async def send_message_into_chat(
    chat_id: int,
    message: Message,
    # обратите внимание, что это fastapi достаёт Message из тела запроса (request body), 
    #  не из query параметров, как это было раньше.  это изменение поведения FastAPI обусловлено
    #  именно тем, что использована структура данных объявленная через Pydantic. и это связано 
    #  именно с тем, что мы указываем Pydantic модель
):
    if chat_id not in CHATS:
        raise HTTPException(
            status_code=404,
            detail="Chat not found.  Please create chat before using it.",
        )

    CHATS[chat_id].append(message)

    return message


@app.get("/chats/{chat_id}/messages")
async def get_chat_messages(
    chat_id: int,
):
    if chat_id not in CHATS:
        raise HTTPException(
            status_code=404,
            detail="Chat not found",
        )

    return CHATS[chat_id]



run(app)
```

