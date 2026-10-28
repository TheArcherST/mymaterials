#import "/typst/python-state.typ": python-state
#set page(paper: "a4", numbering: "1")
#set text(font: "New Computer Modern", lang: "ru", size: 10pt)
#set par(justify: true, first-line-indent: 1.5em)
#set heading(numbering: "1")
#set raw(theme: none)
#show raw: set text(font: "DejaVu Sans Mono", size: 9pt)

#align(center, text(size: 17pt, weight: "bold")[Состояние программы в Python])

= Присваивание и общие ссылки

Два имени могут обозначать один объект. После выполнения следующего кода
`items` и `alias` ссылаются на один список.

```python
items = [42, "Привет"]
alias = items
```

#figure(
  python-state(yaml("/typst/examples/state.yaml"),
    composition: json("composition.json")),
  caption: [Объекты и ссылки после выполнения присваиваний.],
)

Изменение списка через любое из двух имён будет видно через другое имя.
Переприсваивание имени меняет только связь этого имени с объектом.
