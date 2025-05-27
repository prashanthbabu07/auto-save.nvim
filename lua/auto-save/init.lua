local M = {}
local autosave_timer = nil
local config = {
    delay = 500, -- default delay
    delay_events = { "InsertLeave", "TextChanged" },
    instant_events = {},
}

local function save_with_delay()
    if vim.bo.modified then
        if autosave_timer then
            autosave_timer:stop()
        end
        autosave_timer = vim.defer_fn(function()
            vim.cmd("silent! write")
            vim.api.nvim_echo({ { "Auto-saved!", "None" } }, false, {})
        end, config.delay)
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
    config.delay = opts.delay or config.delay
    config.delay_events = opts.delay_events or config.delay_events
    config.instant_events = opts.instant_events or config.instant_events

    vim.api.nvim_create_autocmd(config.delay_events, {
        pattern = "*",
        callback = save_with_delay,
        desc = "Auto-save with delay",
    })

    vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*",
        callback = clear_timer,
        desc = "Clear autosave timer before manual save",
    })

    for _, evt in ipairs(config.instant_events) do
        vim.api.nvim_create_autocmd(evt, {
            pattern = "*",
            callback = auto_save,
            desc = "Instant auto-save event",
        })
    end
end

return M
