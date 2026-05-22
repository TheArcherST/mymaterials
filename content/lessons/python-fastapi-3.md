+++
title = "Python, FastAPI, 3."
date = 2026-05-21
[taxonomies]
tags = ["python", "fastapi"]
+++

## Полезные ресурсы (на русском)

1. Курсы по Python на Stepik: [первый](https://stepik.org/course/58852/promo) и [второй](https://stepik.org/course/68343/promo).  Сам я не проходил, но слышал, что там хорошо даётся база.


## Код с занятия


```python
from uvicorn import run
from pydantic import BaseModel, Field
from fastapi import FastAPI, HTTPException


app = FastAPI()


CHATS: dict[int, dict] = dict()

# Пример данных:
# CHATS = {0: [{"text": "Hello", "sender_name": "Mihail"}]}


@app.post("/chats")
async def create_chat():
    new_chat_id = len(CHATS)
    CHATS[new_chat_id] = []
    return {"id": new_chat_id, "messages": []}


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
    
    # преобразуем экземпляр класса Message в обычный словарь
    CHATS[chat_id].append({"text": message.text, "sender_name": message.sender_name})

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

    result = []
    for i in CHATS[chat_id]:
        # преобразуем словари в экземпляры класса Message через валидацию
        message = Message.model_validate(i)
        result.append(message)
    return result


run(app)
```

{% tbox(id="note-1", header="Примечание") %}

Можно было бы хранить в глобальной переменной CHATS сразу экземпляры класса Message. Тогда не надо было бы приводить Message к словарю, а потом обратно.  Однако нам понадобиться делать подобные конвертации когда мы начём использовать базы данных: там нельзя будет сохранить целый экземпляр класса Pydantic модели.

{% end %}

