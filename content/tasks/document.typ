#import "/typst/python-state.typ": python-state
#set page(paper: "a4", margin: 25mm, numbering: "1")
#set text(font: "Noto Serif", lang: "ru", size: 11pt)
#set par(justify: true, leading: 0.65em)
#set heading(numbering: "1.1")
#show raw: set text(font: "JetBrains Mono", size: 9pt)

#align(center, text(size: 17pt)[Состояние программы в Python])

= Присваивание и общие ссылки

Два имени могут обозначать один объект. После выполнения следующего кода
`items` и `alias` ссылаются на один список.

```python
items = [42, "Привет"]
alias = items
```

#figure(
  python-state(yaml("/typst/examples/state.yaml")),
  caption: [Объекты и ссылки после выполнения присваиваний.],
)

Изменение списка через любое из двух имён будет видно через другое имя.
Переприсваивание имени меняет только связь этого имени с объектом.
