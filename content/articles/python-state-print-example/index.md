+++
title = "Пример печатной схемы состояния Python"
date = 2026-10-28

[extra.pdf]
source = "print/document.typ"
+++

Этот материал показывает независимую веб-страницу и PDF в академическом оформлении.
Ссылка на PDF находится в строке с датой публикации и исходным кодом.

```python
items = [42, "Привет"]
alias = items
```

{% <python_state> %}
frames:
  global:
    name: Глобальная область
    bindings:
      - name: items
        object: items
      - name: alias
        object: items
objects:
  items:
    type: list
    value:
      - object: number
      - object: greeting
  number:
    type: int
    value: 42
  greeting:
    type: str
    value: Привет
{% </python_state> %}

Для переноса расположения в PDF откройте **Full page**, переместите блоки и нажмите
**Copy composition**. Сохраните результат в `print/composition.json`, затем передайте
`composition: json("composition.json")` функции `python-state` в Typst-документе.
