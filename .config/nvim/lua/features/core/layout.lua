local M = {}

function M.apply()
    vim.opt.langmap =
        "рh,РH," ..
        "оj,ОJ," ..
        "лk,ЛK," ..
        "дl,ДL," ..
        "шi,ШI"
end

return M
