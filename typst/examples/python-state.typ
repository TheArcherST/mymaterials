#import "/typst/python-state.typ": python-state
#set page(paper: "a4", numbering: "1")
#set text(font: "New Computer Modern", lang: "ru", size: 10pt)
#set par(justify: true, first-line-indent: 1.5em)
#set heading(numbering: "1")
#set raw(theme: none)
#show raw: set text(font: "DejaVu Sans Mono", size: 9pt)

#align(center, text(size: 17pt, weight: "bold")[Состояние программы в Python])

= Используемая предметная модель

/ Объект в Python: Место в оперативной памяти, где хранится значение и его тип.
/ Имя в Python: Имя может быть связано с объектом и используется для его обозначения.

= Объекты и ссылки

Два имени ссылаются на один список. Его элементы — ссылки на отдельные объекты.
Связи показаны на @fig-state.

```python
items = [42, "Привет"]
alias = items
```

#figure(
  python-state(yaml("state.yaml"), columns: 2,
    positions: ("object:greeting": (322pt, 80pt))),
  caption: [Состояние программы после выполнения присваиваний.],
) <fig-state>

Переприсваивание имени `alias` изменит его связь с объектом, но само по себе
не изменит список, на который продолжает ссылаться `items`.
