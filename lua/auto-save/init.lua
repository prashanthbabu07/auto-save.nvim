local M = {}
local autosave_timer = nil
local config = {
    delay = 500, -- default delay
    delay_events = { "InsertLeave", "TextChanged" },
    instant_events = {},
}
local last_saved_tick = {}

local function is_real_buffer(bufnr)
    return vim.api.nvim_buf_is_valid(bufnr)
        and vim.api.nvim_buf_is_loaded(bufnr)
        and vim.bo[bufnr].modifiable
        and vim.bo[bufnr].buftype == ""
end

local function perform_save(bufnr)
    if not is_real_buffer(bufnr) then
        return
    end

    local current_tick = vim.api.nvim_buf_get_changedtick(bufnr)
    if vim.bo[bufnr].modified and last_saved_tick[bufnr] ~= current_tick then
        vim.cmd("silent! write")
        last_saved_tick[bufnr] = current_tick
        vim.api.nvim_echo({ { "Auto-saved!", "None" } }, false, {})
    end
end

local function save_with_delay()
    local bufnr = vim.api.nvim_get_current_buf()

    if not is_real_buffer(bufnr) then
        return
    end

    local current_tick = vim.api.nvim_buf_get_changedtick(bufnr)
    if vim.bo.modified and last_saved_tick[bufnr] ~= current_tick then
        if autosave_timer then
            autosave_timer:stop()
        end

        autosave_timer = vim.defer_fn(function()
            perform_save(bufnr)
        end, config.delay)
    end
end

local function clear_timer()
    if autosave_timer then
        autosave_timer:stop()
        autosave_timer = nil
    end
end

local function auto_save()
    local bufnr = vim.api.nvim_get_current_buf()
    perform_save(bufnr)
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
