vim.opt.termguicolors = true
vim.cmd("syntax enable")

local jetbrains = {
    bg = "#1f1f1f",
    fg = "#a9b7c6",
    comment = "#808080",
    selection = "#214283",
    cursorline = "#323232",
    gutter = "#313335",
    string = "#6a8759",
    number = "#6897bb",
    keyword = "#cc7832",
    func = "#ffc66d",
    type = "#a9b7c6",
    class = "#a9b7c6",
    constant = "#9876aa",
    builtin = "#ffc66d",
    operator = "#a9b7c6",
    property = "#9876aa",
    parameter = "#a9b7c6",
    accent = "#bbb529",
    error = "#bc3f3c",
    warn = "#be9117",
}

local function hi(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
end

local function apply_jetbrains_highlights()
    hi("Normal", { fg = jetbrains.fg, bg = "none" })
    hi("NormalFloat", { fg = jetbrains.fg, bg = "none" })
    hi("ColorColumn", { bg = "none" })
    hi("LineNr", { fg = jetbrains.comment, bg = "none" })
    hi("CursorLineNr", { fg = jetbrains.func, bold = true })
    hi("CursorLine", { bg = jetbrains.cursorline })
    hi("SignColumn", { bg = "none" })
    hi("VertSplit", { fg = jetbrains.gutter })
    hi("WinSeparator", { fg = jetbrains.gutter })
    hi("Visual", { bg = jetbrains.selection })
    hi("Search", { fg = jetbrains.bg, bg = jetbrains.func })
    hi("IncSearch", { fg = jetbrains.bg, bg = jetbrains.accent })
    hi("Comment", { fg = jetbrains.comment, italic = true })
    hi("Constant", { fg = jetbrains.constant })
    hi("String", { fg = jetbrains.string })
    hi("Character", { fg = jetbrains.string })
    hi("Number", { fg = jetbrains.number })
    hi("Boolean", { fg = jetbrains.constant })
    hi("Float", { fg = jetbrains.number })
    hi("Identifier", { fg = jetbrains.fg })
    hi("Function", { fg = jetbrains.func })
    hi("Statement", { fg = jetbrains.keyword })
    hi("Conditional", { fg = jetbrains.keyword })
    hi("Repeat", { fg = jetbrains.keyword })
    hi("Label", { fg = jetbrains.keyword })
    hi("Operator", { fg = jetbrains.operator })
    hi("Keyword", { fg = jetbrains.keyword })
    hi("Exception", { fg = jetbrains.keyword })
    hi("PreProc", { fg = jetbrains.keyword })
    hi("Include", { fg = jetbrains.keyword })
    hi("Define", { fg = jetbrains.keyword })
    hi("Macro", { fg = jetbrains.keyword })
    hi("PreCondit", { fg = jetbrains.keyword })
    hi("Type", { fg = jetbrains.type })
    hi("StorageClass", { fg = jetbrains.keyword })
    hi("Structure", { fg = jetbrains.type })
    hi("Typedef", { fg = jetbrains.type })
    hi("Special", { fg = jetbrains.constant })
    hi("Delimiter", { fg = jetbrains.fg })
    hi("SpecialComment", { fg = jetbrains.comment, italic = true })
    hi("DiagnosticError", { fg = jetbrains.error })
    hi("DiagnosticWarn", { fg = jetbrains.warn })
    hi("@comment", { link = "Comment" })
    hi("@string", { link = "String" })
    hi("@string.escape", { fg = jetbrains.constant })
    hi("@number", { link = "Number" })
    hi("@boolean", { link = "Boolean" })
    hi("@constant", { link = "Constant" })
    hi("@constant.builtin", { fg = jetbrains.constant })
    hi("@constructor", { fg = jetbrains.class })
    hi("@function", { link = "Function" })
    hi("@function.call", { fg = jetbrains.func })
    hi("@function.builtin", { fg = jetbrains.builtin })
    hi("@method", { fg = jetbrains.func })
    hi("@method.call", { fg = jetbrains.func })
    hi("@keyword", { fg = jetbrains.keyword })
    hi("@keyword.function", { fg = jetbrains.keyword })
    hi("@keyword.operator", { fg = jetbrains.keyword })
    hi("@keyword.return", { fg = jetbrains.keyword })
    hi("@operator", { fg = jetbrains.operator })
    hi("@property", { fg = jetbrains.property })
    hi("@variable", { fg = jetbrains.fg })
    hi("@variable.builtin", { fg = jetbrains.constant })
    hi("@variable.parameter", { fg = jetbrains.parameter })
    hi("@field", { fg = jetbrains.property })
    hi("@type", { fg = jetbrains.type })
    hi("@type.builtin", { fg = jetbrains.keyword })
    hi("@type.definition", { fg = jetbrains.class })
    hi("@module", { fg = jetbrains.class })
    hi("@namespace", { fg = jetbrains.class })
    hi("@tag", { fg = jetbrains.keyword })
    hi("@tag.attribute", { fg = jetbrains.property })
    hi("@tag.delimiter", { fg = jetbrains.fg })
    hi("@punctuation.delimiter", { fg = jetbrains.fg })
    hi("@punctuation.bracket", { fg = jetbrains.fg })
    hi("@punctuation.special", { fg = jetbrains.keyword })
    hi("@markup.heading", { fg = jetbrains.func, bold = true })
    hi("@markup.list", { fg = jetbrains.keyword })
    hi("@markup.raw", { fg = jetbrains.string })
    hi("@markup.link", { fg = jetbrains.number, underline = true })
    hi("@attribute", { fg = jetbrains.accent })
    hi("@decorator", { fg = jetbrains.accent })
    hi("@lsp.type.class", { fg = jetbrains.class })
    hi("@lsp.type.decorator", { fg = jetbrains.accent })
    hi("@lsp.type.enum", { fg = jetbrains.class })
    hi("@lsp.type.enumMember", { fg = jetbrains.constant })
    hi("@lsp.type.function", { fg = jetbrains.func })
    hi("@lsp.type.interface", { fg = jetbrains.class })
    hi("@lsp.type.keyword", { fg = jetbrains.keyword })
    hi("@lsp.type.method", { fg = jetbrains.func })
    hi("@lsp.type.namespace", { fg = jetbrains.class })
    hi("@lsp.type.parameter", { fg = jetbrains.parameter })
    hi("@lsp.type.property", { fg = jetbrains.property })
    hi("@lsp.type.type", { fg = jetbrains.type })
    hi("@lsp.type.variable", { fg = jetbrains.fg })
    hi("pythonStatement", { fg = jetbrains.keyword })
    hi("pythonConditional", { fg = jetbrains.keyword })
    hi("pythonRepeat", { fg = jetbrains.keyword })
    hi("pythonException", { fg = jetbrains.keyword })
    hi("pythonInclude", { fg = jetbrains.keyword })
    hi("pythonDecorator", { fg = jetbrains.accent })
    hi("pythonFunction", { fg = jetbrains.func })
    hi("pythonBuiltin", { fg = jetbrains.constant })
    hi("pythonBuiltinObj", { fg = jetbrains.constant })
    hi("pythonBuiltinType", { fg = jetbrains.keyword })
    hi("pythonClass", { fg = jetbrains.class })
    hi("pythonType", { fg = jetbrains.type })
    hi("pythonString", { fg = jetbrains.string })
    hi("pythonNumber", { fg = jetbrains.number })
    hi("pythonOperator", { fg = jetbrains.keyword })
    hi("jsFunction", { fg = jetbrains.func })
    hi("jsFuncName", { fg = jetbrains.func })
    hi("jsThis", { fg = jetbrains.constant })
    hi("jsClassKeyword", { fg = jetbrains.keyword })
    hi("jsClassDefinition", { fg = jetbrains.class })
    hi("jsGlobalObjects", { fg = jetbrains.constant })
    hi("jsGlobalNodeObjects", { fg = jetbrains.constant })
    hi("jsStorageClass", { fg = jetbrains.keyword })
    hi("jsOperator", { fg = jetbrains.keyword })
    hi("jsString", { fg = jetbrains.string })
    hi("jsNumber", { fg = jetbrains.number })
    hi("typescriptReserved", { fg = jetbrains.keyword })
    hi("typescriptStatement", { fg = jetbrains.keyword })
    hi("typescriptFuncKeyword", { fg = jetbrains.keyword })
    hi("typescriptIdentifier", { fg = jetbrains.fg })
    hi("typescriptTypeReference", { fg = jetbrains.type })
    hi("typescriptGlobalObjects", { fg = jetbrains.constant })
    hi("typescriptString", { fg = jetbrains.string })
    hi("typescriptNumber", { fg = jetbrains.number })
end

function SetColor(color)
    color = color or "onedark"
    vim.cmd.colorscheme(color)

    apply_jetbrains_highlights()
    vim.api.nvim_set_hl(0, "Normal", { fg = jetbrains.fg, bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { fg = jetbrains.fg, bg = "none" })
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { fg = jetbrains.comment, bg = "none" })
end

SetColor()

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("UserSyntaxByFiletype", { clear = true }),
    callback = function(args)
        if vim.bo[args.buf].syntax == "" then
            vim.bo[args.buf].syntax = args.match
        end
    end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
    group = vim.api.nvim_create_augroup("UserSyntaxFallback", { clear = true }),
    callback = function(args)
        local ft = vim.bo[args.buf].filetype
        if ft ~= "" and vim.bo[args.buf].syntax == "" then
            vim.bo[args.buf].syntax = ft
        end
    end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("UserJetBrainsColors", { clear = true }),
    callback = apply_jetbrains_highlights,
})
