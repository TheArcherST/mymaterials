+++
title = "Python, FastAPI, 5."
date = 2026-05-28
[taxonomies]
tags = ["python", "fastapi"]
+++

## Полезные материалы (на русском)

1. Официальная документация React, [статья про Эффекты (useEffect)](https://ru.react.dev/learn/synchronizing-with-effects)


## Код с занятия

```jsx
import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  let [notes, setNotes] = useState([]);
  let [text, setText] = useState("");

  async function addNote(e) {
    e.preventDefault();

    if (!text.trim()) {
      return;
    }

    await fetch(
      "http://127.0.0.1:8000/notes",
      {
        method: "POST",
        body: JSON.stringify({ "text": text }),
        headers: { "Content-Type": "application/json" },
      }
    );

    await syncNotes();
    setText("");
  }

  async function deleteNote(note_id) {
    await fetch(
      "http://127.0.0.1:8000/notes/" + note_id,
      { method: "DELETE" }
    );

    await syncNotes();
  }

  async function syncNotes() {
    let response = await fetch(
      "http://127.0.0.1:8000/notes",
      { method: "GET" }
    );

    let data = await response.json();
    setNotes(data);
  }

  useEffect(() => {
    syncNotes();
  }, []);

  return (
    <div>
      <ul>
        {notes.map(note => {
          return (
            <li key={note.id}>
              {note.text}
              <button onClick={() => deleteNote(note.id)}>
                Delete
              </button>
            </li>
          );
        })}
      </ul>

      <form onSubmit={addNote}>
        <input
          value={text}
          onChange={(e) => setText(e.target.value)}
          placeholder="Введите текст..."
        />

        <button type="submit">
          Add Note
        </button>
      </form>
    </div>
  );
}

export default App;
```


```python
from uvicorn import run
from fastapi import FastAPI, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel


app = FastAPI()

# Разрешаем frontend-приложению отправлять запросы на backend.  Потом скажу про это подробнее.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ],
    allow_methods=["*"],
    allow_headers=["*"],
)


NOTES = []
NEXT_NOTE_ID = 1


class CreateNote(BaseModel):
    text: str


@app.get("/notes")
def get_notes():
    return NOTES


@app.post("/notes")
def create_note(note: CreateNote):
    global NEXT_NOTE_ID

    new_note = {
        "id": NEXT_NOTE_ID,
        "text": note.text,
    }

    NOTES.append(new_note)
    NEXT_NOTE_ID += 1

    return new_note


@app.delete("/notes/{note_id}")
def delete_note(note_id: int):
    for note in NOTES:
        if note["id"] == note_id:
            NOTES.remove(note)
            return Response(status_code=204)

    raise HTTPException(status_code=404, detail="Note not found")


run(app)
```


## Домашнее задание

Два варианта на выбор:
1. В своём проекте реализуйте от начала до конца один или несколько задуманных эндпоинтов. Нужно определить, в каком месте фронтенд должен отправлять HTTP-запрос через fetch, написать этот запрос, сделать соответствующий эндпоинт на бэкенде и проверить, что всё работает. Важно, чтобы у результата был проверяемый эффект: например, что-то создаётся, удаляется или меняется, либо можно создать что-то вручную через запрос на бэкенд, и увидеть результат на фронтенде.
2. Запустите дома проект, который мы делали на занятии, и убедитесь, что всё работает. Добавьте к заметкам заголовок: (1) на бэкенде у заметки должно появиться поле title, (2) на фронтенде должна появиться форма для ввода заголовка, (3) при создании заметки нужно отправлять и title, и text, (4) в списке заметок нужно отображать и заголовок, и текст.

