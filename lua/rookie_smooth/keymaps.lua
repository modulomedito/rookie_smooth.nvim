local M = {}

function M.setup()
    -- Normal mode mappings
    vim.keymap.set("n", "<C-d>", "<cmd>RkSmoothScrollHalfPageDown<CR>", {
        silent = true,
        desc = "Smooth scroll half page down",
    })
    vim.keymap.set("n", "<C-f>", "<cmd>RkSmoothScrollHalfPageUp<CR>", {
        silent = true,
        desc = "Smooth scroll half page up",
    })
    vim.keymap.set("n", "<C-u>", "<cmd>RkSmoothScrollHalfPageUp<CR>", {
        silent = true,
        desc = "Smooth scroll half page up",
    })

    -- Visual mode mappings
    vim.keymap.set("v", "<C-d>", "<cmd>RkSmoothScrollHalfPageDown<CR>", {
        silent = true,
        desc = "Smooth scroll half page down",
    })
    vim.keymap.set("v", "<C-f>", "<cmd>RkSmoothScrollHalfPageUp<CR>", {
        silent = true,
        desc = "Smooth scroll half page up",
    })
    vim.keymap.set("v", "<C-u>", "<cmd>RkSmoothScrollHalfPageUp<CR>", {
        silent = true,
        desc = "Smooth scroll half page up",
    })
end

return M
