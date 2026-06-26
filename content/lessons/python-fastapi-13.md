+++
title = "Python, FastAPI, 13."
date = 2026-06-25
[taxonomies]
tags = ["python", "fastapi"]
+++

# Репозиторий с проектом который писали на занятии

https://github.com/top-academy-rnd/fastapi-reference-backend

Скорее всего будем дальше там работать


# Полезные ресурсы

1. Можете сами нагуглить материал про идентификацию, аутентификацию и авторизацию, чего-то вводного будет достаточно.
2. [Статья про зависимости в FastAPI](https://fastapi.tiangolo.com/ru/tutorial/dependencies/).  Однако тут они используются не для того, для чего использовали мы.  Если хотите можете сами разобрать представленные сценарии использования, мы их будем разбирать позже.  Мы же использовали зависимости так, как рассматривается [в последней статье по зависимостям](https://fastapi.tiangolo.com/ru/tutorial/dependencies/dependencies-with-yield/) на этом ресурсе.


# Домашнее задание

Реализуйте идентификацию, аутентифицацию пользователя и авторизацию запроса пользователя для эндпоинта 

```http
GET /users/{user_id}/cart/items HTTP/1.1
Login: some-login
Password: some-password
```

И затем реализуйте сами действия, которые должны произойти если запрос авторизован.

И полностью реализуйте эндпоинт


```http
POST /users/{user_id}/cart/items HTTP/1.1
Login: some-login
Password: some-password

{"product_id": some_number}
```


Кстати, можно сделать на гитхабе форк репозитория fastapi-reference-backend, и работать в нём.

