# MyMaterials

Zola формирует веб-страницы. Необязательные документы Typst компилируются в PDF
независимо от веб-текста. Редактор работает в Docker на `ab`, сайт остаётся статическим
и раздаётся nginx на `v`.

## Локальная работа

Требуются Python 3.12+, Git, Make, Noto Sans / Noto Serif и JetBrains Mono.
На Debian/Ubuntu шрифты: `fonts-noto-core fonts-jetbrains-mono`.

```sh
git submodule update --init --recursive
git -C themes/apollo fetch origin 31e30e27638aa68394d8625e5c49ad3b8310bf65
make tools       # закреплённые Zola/Typst в .tools/bin; Linux x86_64
make build       # готовый сайт: .build/public
make serve       # http://localhost:8000, включая черновики
make check
make pdf-example # .build/python-state.pdf
```

Версии и SHA-256 инструментов находятся в `tools/versions.json`.
Сборка берёт тему из закреплённого Git-коммита. Изменения внешнего вида надо
делать в корневых `templates/`, `static/`, `sass/`, а не внутри submodule.
Локальные исправления `header.html` и `taxonomy_list.html` перенесены туда.

Предпросмотр пересобирается при изменении файлов; страницу в браузере нужно
обновить. Ошибка оставляет предыдущую успешную сборку доступной.
Обычный `zola build` предназначен только для веб-текста: полный выпуск собирает `make build`.

## PDF у материала

В TOML front matter страницы добавьте:

```toml
[extra.pdf]
source = "print/document.typ"
```

Путь считается от каталога Markdown-файла. Исходник и его частные ресурсы
хранятся в `print/`. Несколько страниц в одном каталоге могут использовать
разные подпапки: `print/lesson-1/document.typ`.

```text
content/articles/example/
  index.md
  print/
    document.typ
    state.yaml
    composition.json
```

Сборка компилирует Typst с корнем репозитория, затем собирает Zola во временном
каталоге. `print/` и `.typ` не публикуются. Для страницы `articles/example/index.md`
PDF получает адрес `/downloads/articles/example/index/document.pdf`.
Смена публичного slug не ломает этот адрес. Ручной флаг `pdf = true` не нужен.
Общий шаблон страницы показывает «Скачать PDF» по сгенерированному
`extra.build.pdf`; пространство `extra.build` зарезервировано.

Если источник отсутствует, содержит ошибку или лежит вне `content/…/print/`,
сборка завершается ошибкой. Для черновиков PDF собираются только в предпросмотре
или с `python3 tools/build.py --drafts`. Для `_index.md` PDF пока не предусмотрен.
Готовый выпуск содержит `pdf-manifest.json` для проверки перед активацией.

## Состояние Python в печати

```typst
#import "/typst/python-state.typ": python-state
#set text(font: "Noto Serif", lang: "ru", size: 11pt)

#figure(
  python-state(yaml("state.yaml")),
  caption: [Состояние программы после присваивания.],
)
```

Используется схема данных веб-компонента: `frames`, `bindings`, `objects`,
ссылки `object`; объекты могут задаваться словарём или массивом с `id`.
Поддерживаются `int`, `float`, `bool`, `NoneType`, `str`, `list`, `dict`,
`function`, `object`, дополнительные `details`, общие ссылки и циклы.
Словарь печатается парами ссылок `0.key`, `0.value` и т. д.
По умолчанию схема чёрно-белая, наследует гарнитуру документа и использует
JetBrains Mono для имён/значений. Рабочий академический пример:
`typst/examples/python-state.typ`.

### Композиция из браузера

1. Откройте существующую схему на сайте, нажмите **Full page**.
2. Расположите блоки и нажмите **Copy composition**.
3. Сохраните буфер целиком в `print/composition.json`.
4. Подключите его:

```typst
#python-state(
  yaml("state.yaml"),
  composition: json("composition.json"),
)
```

Если `composition` уже находится внутри YAML состояния, отдельный аргумент
не нужен. Поддерживается существующая версия 1: компактный и развёрнутый
объект, обёртка `composition` и JSON-строка внутри YAML. Менять сохранённые
композиции или веб-компонент не требуется.

Относительные координаты сохраняются. За исходный масштаб принимается
0.75 pt на CSS px. Если печатные блоки пересекаются, расстояния увеличиваются
равномерно, затем вся схема вписывается в ширину текста. Это сохраняет
композицию, но не гарантирует совпадения размеров блоков и маршрутов стрелок
с браузером. Большие схемы лучше печатать на отдельной альбомной странице.

Набор ID должен точно совпадать: устаревшая/неполная композиция останавливает
сборку. Браузерные `h`/`u` сохраняются в файле, но PDF их не проверяет:
они относятся к веб-рендереру. При изменении значений размеры вычисляются заново.

Для ручной вёрстки можно вместо композиции задать
`positions: ("object:items": (150pt, 20pt))`.
`composition: none` отключает импорт из данных.
Настройки: `columns`, `node-width`, `font`, `mono-font`, `edge-color`,
`boxed`, `title`. Встроенный обход препятствий для стрелок пока упрощён:
для сложного графа следует проверить PDF после изменения композиции.

## Редактор на ab

Адрес: `https://editor.mymaterials.ru`. Compose: `infra/compose.yaml`.
Он подключается к существующему Traefik через внешнюю сеть `mylab_default`,
роутер `mymaterials-editor`, resolver `letsencrypt`. Порты 80/443 принадлежат
существующему Traefik. Docker socket в редактор не передаётся.

```sh
cp infra/.env.example infra/.env
mkdir -p infra/secrets
chmod 700 infra/secrets
python3 -c 'import secrets; print(secrets.token_urlsafe(32))' > infra/secrets/editor-password
chmod 600 infra/secrets/editor-password
docker compose -f infra/compose.yaml --env-file infra/.env up -d --build
```

Рабочие файлы, настройки редактора и Git-ключ сохраняются в volume
`mymaterials-editor_editor-home`. Пароль — файл `secrets/editor-password`
рядом с Compose на сервере. Не используйте `docker compose down -v`:
он удалит рабочие файлы. Volume нужно включить в резервное копирование.

В терминале редактора:

```sh
make serve ARGS='--base-url https://editor.mymaterials.ru/proxy/8000/'
```

Предпросмотр: `https://editor.mymaterials.ru/proxy/8000/`.
Он защищён той же авторизацией code-server. Для PDF используйте
`make pdf-example` или `typst watch --root . путь/к/document.typ /tmp/document.pdf`.
Через Source Control доступны commit/push; GitHub запускает публикацию.

## GitHub Actions и статика на v

Workflow `.github/workflows/publish.yml` проверяет push/PR. Только `master`
публикуется после успешной сборки. Устаревший коммит не может заменить более
новый. В GitHub environment `production` нужны secrets:

- `DEPLOY_SSH_KEY`: приватный Ed25519-ключ отдельного пользователя публикации;
- `DEPLOY_KNOWN_HOSTS`: проверенный ключ SSH-хоста v.

Переменная репозитория `DEPLOY_HOST`: адрес сервера v. Пользователь:
`mymaterials-deploy`, порт 22. SSH host checking включён.
Pull requests не получают deploy secrets.

Первичная настройка на v выполняется от root через `tools/provision-static.py`
с публичным ключом. Скрипт сохраняет опубликованный каталог, проверяет копию
и атомарно меняет публичный путь на симлинк без изменения nginx:

```text
/var/www/mymaterials.ru → /var/www/mymaterials-releases/current
                            current → <release-id>
                            previous → <previous-release-id>
```

Каждый выпуск загружается в новый каталог. Только после проверки index и PDF
обновляется `current`. Неудачная загрузка не меняет сайт. Старые выпуски
автоматически не удаляются; очищать их следует отдельно, сохраняя current/previous.
Старую команду `rsync` прямо в `/var/www/mymaterials.ru` использовать больше нельзя:
она обходит механизм выпуска.

Откат на v от пользователя публикации:

```sh
cd /var/www/mymaterials-releases
python3 activate.py "$(readlink previous)"
```

Для ручной публикации полного выпуска:

```sh
DEPLOY_HOST=адрес-v DEPLOY_SSH_KEY_FILE=путь-ключа \
  DEPLOY_KNOWN_HOSTS_FILE=путь-known-hosts make deploy
```

## Изменения и публикация

Рабочая копия уже содержала изменения контента и миграцию шорткодов на
компоненты до добавления этого конвейера. Для первого push нужно включить
актуальные компоненты, контент и эти файлы сборки в согласованный коммит.
Один только workflow поверх старой версии шаблонов работать не будет.
