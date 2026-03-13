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
./nvim/.config/nvim/install-remote.sh
```

Если Neovim запускается на удалённой машине, а терминал и шрифты живут локально, локальные зависимости ставятся отдельно на локальной машине:

```bash
cd ~/dotfiles
./nvim/.config/nvim/install-local.sh
```

Установщик можно запускать повторно. Он пропускает уже установленные зависимости и дозагружает только недостающее.

Доступные режимы:

```bash
./nvim/.config/nvim/install-remote.sh --base
./nvim/.config/nvim/install-remote.sh --python
./nvim/.config/nvim/install-remote.sh --web
./nvim/.config/nvim/install-remote.sh --images
./nvim/.config/nvim/install-remote.sh --nvim
./nvim/.config/nvim/install-remote.sh --all
```

Для локальной машины:

```bash
./nvim/.config/nvim/install-local.sh --font
./nvim/.config/nvim/install-local.sh --clipboard
./nvim/.config/nvim/install-local.sh --images
./nvim/.config/nvim/install-local.sh --all
```

Что делают режимы:

| Команда | Что ставится |
| --- | --- |
| `--base` | базовые системные зависимости |
| `--python` | `mypy`, `black` |
| `--web` | `pyright`, `tree-sitter-cli`, `typescript-language-server`, `typescript`, `vscode-langservers-extracted`, `@prisma/language-server`, `prettierd` |
| `--images` | `imagemagick` для просмотра картинок в `kitty` |
| `--nvim` | `Neovim 0.11.5` |
| `--all` | всё сразу |

Локальные режимы:

| Команда | Что ставится |
| --- | --- |
| `--font` | `JetBrainsMono Nerd Font` для локального терминала |
| `--clipboard` | локальный clipboard provider |
| `--images` | `imagemagick` для локального preview картинок |
| `--all` | все локальные зависимости |

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
| C compiler | сборка parser'ов для `nvim-treesitter` |
| `tree-sitter-cli` | установка parser'ов для `nvim-treesitter` |
| `Nerd Font` | иконки в интерфейсе |

Если вместо иконок, git-символов или разделителей в статуслайне видны квадраты, вопросики или пустые символы, значит на локальной машине в терминале не выбран `Nerd Font`.

Рекомендуемый вариант:

- `JetBrainsMono Nerd Font`

Важно:

- шрифт нужен именно на локальной машине, где открыт терминал
- по SSH ставить его на удалённый сервер бессмысленно

Команды установки:

```bash
# Arch Linux
sudo pacman -S ttf-jetbrains-mono-nerd

# macOS
brew install --cask font-jetbrains-mono-nerd-font

# Debian / Ubuntu (ручная установка Nerd Font)
mkdir -p ~/.local/share/fonts
cd /tmp
curl -fLo JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/JetBrainsMonoNerd
fc-cache -fv
```

Если у тебя `kitty`, одного факта установки шрифта недостаточно: его ещё нужно выбрать в настройках терминала.

Самый простой способ:

```bash
kitten choose-fonts
```

Либо прописать вручную в `~/.config/kitty/kitty.conf`:

```conf
font_family JetBrainsMono Nerd Font
bold_font auto
italic_font auto
bold_italic_font auto
```

`fish` на это не влияет. Важен именно локальный терминал и выбранный в нём шрифт.

Примеры базовой установки:

```bash
# Debian / Ubuntu
sudo apt install stow git curl tar ripgrep xclip wl-clipboard nodejs npm python3 build-essential

# Arch Linux
sudo pacman -Sy --needed stow git curl tar ripgrep xclip wl-clipboard nodejs npm python gcc make

# macOS
brew install stow git curl ripgrep node python
xcode-select --install
```

## Языки и инструменты

Сам Neovim-конфиг не делает диагностику и форматирование в одиночку. Для разных языков нужны внешние программы.

| Язык / файлы | Что работает | Что нужно установить | Пример установки |
| --- | --- | --- | --- |
| Python `.py` | ошибки, переходы, hover | `pyright` | `npm install -g pyright` |
| Python `.py` | type-check | `mypy` | `apt install mypy` / `pacman -S mypy` / `brew install mypy` |
| Python `.py` | форматирование | `black` | `apt install black` / `pacman -S black` / `brew install black` |
| Treesitter parsers | подсветка и навигация по синтаксису | `tree-sitter-cli` | `npm install -g tree-sitter-cli` |
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

## Раскладка

Для normal-mode включён `langmap`, поэтому основные команды движения и входа в insert работают и в русской раскладке:

| Английская | Русская |
| --- | --- |
| `h` | `р` |
| `j` | `о` |
| `k` | `л` |
| `l` | `д` |
| `i` | `ш` |

В статуслайне есть best-effort индикатор текущей раскладки. Он работает только если Neovim может получить её у системы. В терминале по SSH без локального GUI такой индикатор обычно недоступен.

## Горячие клавиши

### Общие

| Клавиши | Что делают |
| --- | --- |
| `Space e` | открыть / сфокусировать файловый менеджер |
| `Space o` | открыть git-статус в `neo-tree` |
| `:Neotree close` | закрыть файловый менеджер |
| `Tab` | следующий буфер |
| `Shift-Tab` | предыдущий буфер |
| `Ctrl-h` | окно слева |
| `Ctrl-j` | окно снизу |
| `Ctrl-k` | окно сверху |
| `Ctrl-l` | окно справа |
| `Ctrl-стрелки` | переход между окнами |
| `Shift-стрелки` | изменить размер текущего окна |
| `Space w` | сохранить файл |
| `ww / цц` | быстро сохранить файл |
| `qq / йй` | закрыть текущий буфер и перейти на соседний |
| `Space x` | выбрать и закрыть буфер |
| `Space X` | закрыть буферы справа |
| `Space s` | отсортировать буферы |
| `Space h` | убрать подсветку поиска |
| `Alt-j` | следующий блок кода |
| `Alt-k` | предыдущий блок кода |
| `Alt-Down` | следующий блок кода |
| `Alt-Up` | предыдущий блок кода |
| `Alt-Left` | перейти к предыдущему фрагменту строки |
| `Alt-Right` | перейти к следующему фрагменту строки |
| `jj / оо` | выйти из insert mode |
| `Space jp` | сделать текущий JSON читаемым |

Основные хоткеи продублированы для русской раскладки, чтобы не переключать язык постоянно.

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
| `Space 4` | терминал 4, плавающий |

## JSON и картинки

Для `json` автопереформатирования при открытии нет.

Что есть:

- `Space jp` - вручную сделать текущий `json` читаемым
- после этого файл остаётся обычным редактируемым буфером

Для картинок:

- если открыт `png`, `jpg`, `jpeg`, `gif`, `webp` или `avif`, `nvim` попытается показать изображение прямо в буфере
- это включается только в `kitty`
- для работы нужен локальный `kitty` и установленный `imagemagick` на машине, где запущен `nvim`

Установка `imagemagick`:

```bash
# через установщик
./nvim/.config/nvim/install-remote.sh --images

# Debian / Ubuntu
sudo apt install imagemagick

# Arch Linux
sudo pacman -S imagemagick

# macOS
brew install imagemagick
```

### Внутри терминала

Чтобы выйти из режима ввода терминала в `NORMAL`, можно использовать:

- двойное `Esc`
- `jk`
- стандартный способ Neovim: `Ctrl-\`, затем `Ctrl-n`

| Клавиши | Что делают |
| --- | --- |
| `Esc Esc` | выйти в normal mode терминала |
| `jk` | выйти в normal mode терминала |
| `Ctrl-h` | окно слева |
| `Ctrl-j` | окно снизу |
| `Ctrl-k` | окно сверху |
| `Ctrl-l` | окно справа |
| `Ctrl-стрелки` | переход между окнами |
| `Shift-стрелки` | изменить размер текущего окна |
| `Ctrl-w` | перейти к оконным командам Neovim |
| `Ctrl-\` | показать / скрыть основной терминал |
| `Space tt` | показать / скрыть основной терминал |
| `Space th` | нижний терминал |
| `Space tf` | плавающий терминал |
| `Space tv` | терминал справа |
| `Space 1` | терминал 1 |
| `Space 2` | терминал 2 |
| `Space 3` | терминал 3 |
| `Space 4` | терминал 4, плавающий |
| `gf` | открыть путь `path:line[:col]` под курсором |
| `Enter` | открыть путь `path:line[:col]` под курсором |

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
