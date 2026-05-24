local M = {}

local uv = vim.uv or vim.loop
local timer = nil
local scroll_ctx = {}
local duration = 0.3 -- seconds
local interval = 10 -- milliseconds

local function start_scroll(dir, scale)
    -- Stop existing animation
    if timer then
        timer:stop()
        if not timer:is_closing() then
            timer:close()
        end
        timer = nil
    end

    local view = vim.fn.winsaveview()
    local height = vim.fn.winheight(0)
    local dist = math.floor(height * scale)

    -- Calculate targets
    -- We want to maintain relative cursor position if possible
    local start_top = view.topline
    local start_lnum = view.lnum

    -- Calculate target topline
    local target_top = start_top + (dist * dir)

    -- Clamp target topline
    local last_line = vim.fn.line("$")
    if target_top < 1 then
        target_top = 1
    end
    if target_top > last_line then
        target_top = last_line
    end

    -- Calculate target lnum to maintain relative position
    -- rel_pos = lnum - topline
    -- new_lnum = new_topline + rel_pos
    local rel_pos = start_lnum - start_top
    local target_lnum = target_top + rel_pos

    -- Special case for scrolling up when near the top
    if dir < 0 and target_top == 1 then
        -- If we hit the top, ensure we can reach line 1
        if target_lnum > 1 and start_lnum > 1 then
            target_lnum = math.max(1, target_lnum - math.floor(dist / 2))
            if target_lnum < 1 then
                target_lnum = 1
            end
        end
    end

    -- Clamp target lnum
    if target_lnum < 1 then
        target_lnum = 1
    end
    if target_lnum > last_line then
        target_lnum = last_line
    end

    -- Special case: if we are at the bottom/top and can't scroll more
    if start_top == target_top and start_lnum == target_lnum then
        return
    end

    scroll_ctx = {
        start_top = start_top,
        start_lnum = start_lnum,
        target_top = target_top,
        target_lnum = target_lnum,
        start_time = uv.hrtime() / 1e9,
        duration = duration,
    }

    timer = uv.new_timer()
    if not timer then
        return
    end
    timer:start(
        interval,
        interval,
        vim.schedule_wrap(function()
            if not timer then
                return
            end
            local current_time = uv.hrtime() / 1e9
            local elapsed = current_time - scroll_ctx.start_time

            if elapsed >= scroll_ctx.duration then
                -- Finish
                if timer then
                    timer:stop()
                    if not timer:is_closing() then
                        timer:close()
                    end
                    timer = nil
                end
                vim.fn.winrestview({
                    topline = math.floor(scroll_ctx.target_top),
                    lnum = math.floor(scroll_ctx.target_lnum),
                })
                return
            end

            -- Ease out quad: t * (2 - t)
            local t = elapsed / scroll_ctx.duration
            local ease = t * (2.0 - t)

            local current_top = scroll_ctx.start_top
                + (scroll_ctx.target_top - scroll_ctx.start_top) * ease
            local current_lnum = scroll_ctx.start_lnum
                + (scroll_ctx.target_lnum - scroll_ctx.start_lnum) * ease

            vim.fn.winrestview({
                topline = math.floor(current_top),
                lnum = math.floor(current_lnum),
            })
            vim.cmd("redraw")
        end)
    )
end

function M.half_page_down()
    start_scroll(1, 0.5)
end

function M.half_page_up()
    start_scroll(-1, 0.5)
end

function M.page_down()
    start_scroll(1, 1.0)
end

function M.page_up()
    start_scroll(-1, 1.0)
end

function M.setup()
    -- Global variable to control enabling smooth scroll keymaps
    if vim.g.rookie_toys_smooth_scroll_enable == false then
        return
    end

    -- Register commands
    vim.api.nvim_create_user_command("RkSmoothScrollHalfPageDown", function()
        M.half_page_down()
    end, { desc = "Smooth scroll half page down" })

    vim.api.nvim_create_user_command("RkSmoothScrollHalfPageUp", function()
        M.half_page_up()
    end, { desc = "Smooth scroll half page up" })

    -- Setup keymaps
    require("rookie_smooth.keymaps").setup()
end

return M
