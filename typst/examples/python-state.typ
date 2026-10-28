#import "/typst/python-state.typ": python-state
#set page(paper: "a4", margin: (x: 25mm, y: 25mm), numbering: "1")
#set text(font: "Noto Serif", lang: "ru", size: 11pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")
#show raw: set text(font: "JetBrains Mono", size: 9pt)
#show figure.caption: set text(size: 10pt)

#align(center, text(size: 17pt)[Состояние программы в Python])
#v(12pt)

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
