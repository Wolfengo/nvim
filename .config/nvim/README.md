# Конфиг Neovim

Минимально необходимое о текущей сборке: как установить, что нужно скачать и какими хоткеями пользоваться.

`Leader` в этом конфиге: `Space`

## Установка

Этот пакет рассчитан на использование через `GNU Stow`.

Ожидаемая структура:

- `~/dotfiles` - каталог с dotfiles
- `~/dotfiles/nvim` - пакет `nvim`
- `~/.config/nvim` - итоговый путь конфига после `stow`

Если `~/.config` уже существует, `stow` добавит только `~/.config/nvim`.

### Автоматическая установка

Рекомендуемый способ:

```bash
cd ~/dotfiles
stow nvim
./nvim/.config/nvim/install.sh
```

Установщик можно запускать повторно. Он пропускает уже установленные зависимости и дозагружает только недостающее.

Доступные режимы:

```bash
./nvim/.config/nvim/install.sh --base
./nvim/.config/nvim/install.sh --python
./nvim/.config/nvim/install.sh --web
./nvim/.config/nvim/install.sh --nvim
./nvim/.config/nvim/install.sh --all
```

Что делают режимы:

| Команда | Что ставится |
| --- | --- |
| `--base` | базовые системные зависимости |
| `--python` | `mypy`, `black` |
| `--web` | `pyright`, `typescript-language-server`, `typescript`, `vscode-langservers-extracted`, `@prisma/language-server`, `prettierd` |
| `--nvim` | `Neovim 0.11.5` |
| `--all` | всё сразу |

### Ручная установка

Если не хочешь использовать `stow`, можно подключить конфиг вручную:

```bash
mkdir -p ~/.config
ln -s ~/dotfiles/nvim/.config/nvim ~/.config/nvim
```

Ниже перечислены зависимости, которые нужно поставить вручную.

## Базовые зависимости

| Что нужно | Зачем |
| --- | --- |
| `stow` | подключение пакета в `~/.config/nvim` |
| `git` | плагины и git-функции |
| `curl` | bootstrap и загрузка релизов |
| `tar` | распаковка архивов |
| `Neovim 0.11+` | текущая версия конфига |
| `ripgrep` | поиск по проекту |
| `xclip` | clipboard в X11 |
| `wl-clipboard` | clipboard в Wayland |
| `nodejs` + `npm` | LSP и форматтеры из npm |
| `python3` | Python-инструменты и venv |
| `Nerd Font` | иконки в интерфейсе |

Примеры базовой установки:

```bash
# Debian / Ubuntu
sudo apt install stow git curl tar ripgrep xclip wl-clipboard nodejs npm python3

# Arch Linux
sudo pacman -Sy --needed stow git curl tar ripgrep xclip wl-clipboard nodejs npm python

# macOS
brew install stow git curl ripgrep node npm python
```

## Языки и инструменты

Сам Neovim-конфиг не делает диагностику и форматирование в одиночку. Для разных языков нужны внешние программы.

| Язык / файлы | Что работает | Что нужно установить | Пример установки |
| --- | --- | --- | --- |
| Python `.py` | ошибки, переходы, hover | `pyright` | `npm install -g pyright` |
| Python `.py` | type-check | `mypy` | `apt install mypy` / `pacman -S mypy` / `brew install mypy` |
| Python `.py` | форматирование | `black` | `apt install black` / `pacman -S black` / `brew install black` |
| JavaScript / TypeScript / JSX / TSX | ошибки, переходы, hover | `typescript-language-server`, `typescript` | `npm install -g typescript typescript-language-server` |
| Prisma `.prisma` | ошибки | `@prisma/language-server` | `npm install -g @prisma/language-server` |
| CSS / SCSS / LESS | ошибки | `vscode-langservers-extracted` | `npm install -g vscode-langservers-extracted` |
| JS / TS / JSON / YAML / HTML / CSS / Markdown | форматирование | `prettierd` | `npm install -g @fsouza/prettierd` |
| Lua | форматирование | `stylua` | установить `stylua` и добавить в `PATH` |
| Go | ошибки | `golangci-lint-langserver`, `golangci-lint` | `go install github.com/nametake/golangci-lint-langserver@latest` и `go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest` |
| Rust | ошибки, переходы, hover | `rust-analyzer` | установить `rust-analyzer` и добавить в `PATH` |

## Python `.venv`

Если у проектов разные окружения, конфиг ищет ближайшие:

1. `.venv/bin/python`
2. `venv/bin/python`
3. `.venv/bin/mypy`
4. `venv/bin/mypy`

Это позволяет работать с несколькими проектами, где у каждого свой `dir/.venv`.

## Clipboard

В конфиге включён:

```lua
vim.opt.clipboard = "unnamedplus"
```

Как это работает:

- локально с GUI используется системный clipboard
- по SSH без графики включается fallback через `OSC52`

Что нужно установить локально:

| Среда | Что нужно |
| --- | --- |
| X11 | `xclip` |
| Wayland | `wl-clipboard` |

## Горячие клавиши

### Общие

| Клавиши | Что делают |
| --- | --- |
| `Space e` | открыть / сфокусировать файловый менеджер |
| `Space o` | открыть git-статус в `neo-tree` |
| `Tab` | следующий буфер |
| `Shift-Tab` | предыдущий буфер |
| `Ctrl-h` | окно слева |
| `Ctrl-j` | окно снизу |
| `Ctrl-k` | окно сверху |
| `Ctrl-l` | окно справа |
| `Space w` | сохранить файл |
| `ww` | быстро сохранить файл |
| `qq` | закрыть текущий буфер и перейти на соседний |
| `Space x` | выбрать и закрыть буфер |
| `Space X` | закрыть буферы справа |
| `Space s` | отсортировать буферы |
| `Space h` | убрать подсветку поиска |
| `Alt-j` | следующий блок кода |
| `Alt-k` | предыдущий блок кода |
| `jj` | выйти из insert mode |

### Буферы

| Клавиши | Что делают |
| --- | --- |
| `Tab` / `Shift-Tab` | переключение между буферами |
| `Space x` | закрыть выбранный буфер |
| `Space X` | закрыть буферы справа |
| `qq` | закрыть текущий буфер без схлопывания окна |
| `:bd` | закрыть текущий буфер командой |

### LSP и диагностика

| Клавиши | Что делают |
| --- | --- |
| `K` | hover по символу |
| `gd` | перейти к определению |
| `gD` | перейти к объявлению |
| `gi` | перейти к реализации |
| `gr` | найти использования |
| `[d` | предыдущая ошибка |
| `]d` | следующая ошибка |
| `Space lD` | показать ошибку под курсором |
| `Space ld` | открыть список диагностик |
| `Space le` | показать ошибку под курсором |
| `Space ln` | следующая ошибка |
| `Space lp` | предыдущая ошибка |
| `Space lr` | переименовать символ |
| `Space la` | code action |
| `Space ls` | символы файла |

### Поиск

| Клавиши | Что делают |
| --- | --- |
| `Space ff` | найти файл |
| `Space fw` | поиск по тексту во всём проекте |
| `Space fb` | список буферов |
| `Space fh` | help |
| `Space gb` | git branches |
| `Space gc` | git commits |
| `Space gs` | git status |

### Терминал

| Клавиши | Что делают |
| --- | --- |
| `Space tt` | показать / скрыть основной терминал |
| `Space th` | нижний терминал |
| `Space tf` | плавающий терминал |
| `Space tv` | терминал справа |
| `Ctrl-\` | показать / скрыть основной терминал |
| `Space 1` | терминал 1 |
| `Space 2` | терминал 2 |
| `Space 3` | терминал 3 |
| `Space 4` | терминал 4 |
| `Space c` | перейти в предыдущее окно |

### Внутри терминала

Чтобы выйти из режима ввода терминала в `NORMAL`, можно использовать:

- `Esc`
- `jk`
- стандартный способ Neovim: `Ctrl-\`, затем `Ctrl-n`

| Клавиши | Что делают |
| --- | --- |
| `Esc` | выйти в normal mode терминала |
| `jk` | выйти в normal mode терминала |
| `Ctrl-h` | окно слева |
| `Ctrl-j` | окно снизу |
| `Ctrl-k` | окно сверху |
| `Ctrl-l` | окно справа |
| `Ctrl-w` | перейти к оконным командам Neovim |
| `Ctrl-\` | показать / скрыть основной терминал |
| `Space tt` | показать / скрыть основной терминал |
| `Space th` | нижний терминал |
| `Space tf` | плавающий терминал |
| `Space tv` | терминал справа |
| `Space 1` | терминал 1 |
| `Space 2` | терминал 2 |
| `Space 3` | терминал 3 |
| `Space 4` | терминал 4 |
| `Space c` | перейти в предыдущее окно |
| `gf` | открыть путь `path:line[:col]` под курсором |

### Комментарии

| Клавиши | Что делают |
| --- | --- |
| `Space /` | закомментировать строку |
| `Space ?` | комментарий как оператор |

## Если что-то не работает

Проверь:

1. установлен ли нужный бинарник
2. доступен ли он в `PATH`
3. перезапущен ли `nvim`

Полезные команды:

```bash
command -v pyright-langserver
command -v mypy
command -v black
command -v typescript-language-server
command -v prettierd
command -v stylua
command -v rg
```
