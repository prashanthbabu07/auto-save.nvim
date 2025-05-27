local M = {}
local autosave_timer = nil

local function save_with_delay()
    if vim.bo.modified then
        if autosave_timer then
            autosave_timer:stop()
        end
        autosave_timer = vim.defer_fn(function()
            vim.cmd("silent! write")
            vim.api.nvim_echo({ { "Auto-saved!", "None" } }, false, {})
        end, 500)
    end
end

local function clear_timer()
    if autosave_timer then
        autosave_timer:stop()
        autosave_timer = nil
    end
end

--- Optional: Immediate save on specific events
local function auto_save()
    if vim.bo.modifiable and vim.bo.modified then
        vim.cmd("silent! write")
        vim.api.nvim_echo({ { "Auto-saved!", "None" } }, false, {})
    end
end

--- Setup auto commands
function M.setup(opts)
    opts = opts or {}
    local delay_events = opts.delay_events or { "InsertLeave", "TextChanged" }
    local instant_events = opts.instant_events or {} -- Optional

    vim.api.nvim_create_autocmd(delay_events, {
        pattern = "*",
        callback = save_with_delay,
        desc = "Auto-save with delay",
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = clear_timer,
        desc = "Clear autosave timer before manual save",
    })

    for _, evt in ipairs(instant_events) do
        vim.api.nvim_create_autocmd(evt, {
            pattern = "*",
            callback = auto_save,
            desc = "Instant auto-save event",
        })
    end
end

return M
