vim.wo.number = true          -- Показывать абсолютные номера строк в текущем окне
vim.wo.relativenumber = true  -- Показывать относительные номера строк в текущем окне

vim.g.did_load_filetypes = 1  -- Отключает встроенную систему filetype.lua
vim.g.formatoptions = "qrn1"  -- Настройки автоматического форматирования:
                             -- q - разрешить форматирование комментариев
                             -- r - автоматически вставлять * в комментариях
                             -- n - распознавать списки
                             -- 1 - не разрывать строки после однобуквенных слов
vim.opt.showmode = false      -- Не показывать текущий режим (INSERT, VISUAL и т.д.)
vim.opt.updatetime = 300	  -- Частота обновления (мс) для CursorHold событий
vim.opt.timeoutlen = 500
vim.wo.signcolumn = "yes"     -- Всегда показывать колонку знаков (для диагностики)
vim.opt.scrolloff = 8         -- Минимальное количество строк выше/ниже курсора
vim.opt.wrap = false          -- Не переносить длинные строки
vim.wo.linebreak = true       -- Переносить строки только в местах переноса слов
vim.opt.virtualedit = "block" -- Разрешить курсору перемещаться в несуществующие позиции в visual block mode
vim.opt.undofile = true       -- Сохранять историю изменений между сессиями
vim.opt.shell = "/bin/zsh"    -- Использовать zsh как оболочку по умолчанию

-- Mouse
vim.opt.mouse = "a"           -- Включить мышь во всех режимах
vim.opt.mousefocus = true     -- Фокус на окно при наведении мыши

-- Line Numbers
vim.opt.number = true         -- Абсолютные номера строк для всех окон
vim.opt.relativenumber = true -- Относительные номера строк для всех окон

-- Splits
vim.opt.splitbelow = true     -- Новые горизонтальные split'ы открываются снизу
vim.opt.splitright = true     -- Новые вертикальные split'ы открываются справа

-- Clipboard
vim.opt.clipboard = "unnamedplus" -- Использовать системный буфер обмена

-- Shorter messages
vim.opt.shortmess:append("c") -- Сокращать сообщения (c - не показывать доп. сообщения при завершении)

-- Indent Settings
vim.opt.expandtab = false      -- Использовать пробелы вместо табов
vim.opt.shiftwidth = 4        -- Размер отступа для операторов >>, <<, ==
vim.opt.tabstop = 4           -- Количество пробелов, которое отображает таб
vim.opt.softtabstop = 4       -- Количество пробелов при нажатии Tab в insert mode
vim.opt.smartindent = true    -- Умное автоматическое выравнивание

-- Fillchars
vim.opt.fillchars = {
    vert = "│",              -- Вертикальные разделители
    fold = "⠀",             -- Символы свертки (неразрывный пробел)
    eob = " ",               -- Пустой символ вместо ~ в конце буфера
    msgsep = "‾",            -- Разделитель сообщений
    foldopen = "▾",          -- Открытая свертка
    foldsep = "│",           -- Разделитель свертки  
    foldclose = "▸"          -- Закрытая свертка
}

vim.cmd([[highlight clear LineNr]])     -- Сбросить highlighting для номеров строк
vim.cmd([[highlight clear SignColumn]]) -- Сбросить highlighting для колонки знаков
