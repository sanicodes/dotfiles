-- ============================================================================
-- launchpad: custom Neovim startup dashboard
-- Replaces nvimdev/dashboard-nvim. Built incrementally — see
-- docs/superpowers/plans/2026-04-13-launchpad-dashboard.md
--
-- During the build (Tasks 1–13), launchpad runs side-by-side with the
-- existing dashboard-nvim plugin (whose spec is still returned at the bottom
-- of this file). Task 14 removes the old plugin entry.
-- ============================================================================

--  CONFIG (populated in Task 2)
-- Quick actions for the left column. Each entry becomes a clickable row.
-- `action` is a function (not a command string) so it can be invoked directly.
local M_actions = {
  { key = 'f', icon = ' ', desc = 'Find File',     action = function() vim.cmd('Telescope find_files') end },
  { key = 'r', icon = ' ', desc = 'Recent Files',  action = function() vim.cmd('Telescope oldfiles') end },
  { key = 'g', icon = ' ', desc = 'Live Grep',     action = function() vim.cmd('Telescope live_grep') end },
  { key = 'e', icon = ' ', desc = 'File Browser',  action = function() vim.cmd('NvimTreeToggle') end },
  { key = 's', icon = ' ', desc = 'Git Status',    action = function() vim.cmd('Telescope git_status') end },
  { key = 'c', icon = ' ', desc = 'Configuration', action = function()
      require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })
    end },
  { key = 'l', icon = '󰒲 ', desc = 'Lazy',          action = function() vim.cmd('Lazy') end },
  { key = 'q', icon = ' ', desc = 'Quit',          action = function() vim.cmd('quit') end },
}
-- Day-of-week banners. Index 1 = Sunday, 7 = Saturday (matches os.date('%w') + 1).
-- Each banner is an array of strings, one per line. Keep each banner 5 lines tall
-- so the layout doesn't jump between days. Simple framed labels — swap these out
-- for fancier ASCII art by editing this table.
local M_banners = {
  { -- Sunday
    '  ╭────────────────────────────╮  ',
    '  │                            │  ',
    '  │         ✦  SUNDAY  ✦       │  ',
    '  │                            │  ',
    '  ╰────────────────────────────╯  ',
  },
  { -- Monday
    '  ╭────────────────────────────╮  ',
    '  │                            │  ',
    '  │         ◆  MONDAY  ◆       │  ',
    '  │                            │  ',
    '  ╰────────────────────────────╯  ',
  },
  { -- Tuesday
    '  ╭────────────────────────────╮  ',
    '  │                            │  ',
    '  │         ◇  TUESDAY  ◇      │  ',
    '  │                            │  ',
    '  ╰────────────────────────────╯  ',
  },
  { -- Wednesday
    '  ╭────────────────────────────╮  ',
    '  │                            │  ',
    '  │       ●  WEDNESDAY  ●      │  ',
    '  │                            │  ',
    '  ╰────────────────────────────╯  ',
  },
  { -- Thursday
    '  ╭────────────────────────────╮  ',
    '  │                            │  ',
    '  │        ○  THURSDAY  ○      │  ',
    '  │                            │  ',
    '  ╰────────────────────────────╯  ',
  },
  { -- Friday
    '  ╭────────────────────────────╮  ',
    '  │                            │  ',
    '  │         ★  FRIDAY  ★       │  ',
    '  │                            │  ',
    '  ╰────────────────────────────╯  ',
  },
  { -- Saturday
    '  ╭────────────────────────────╮  ',
    '  │                            │  ',
    '  │        ☆  SATURDAY  ☆      │  ',
    '  │                            │  ',
    '  ╰────────────────────────────╯  ',
  },
}
local M_quotes = {
  'stay hungry, stay foolish',
  'the best way to predict the future is to invent it',
  'simplicity is the ultimate sophistication',
  'make it work, make it right, make it fast',
  'perfection is achieved when there is nothing left to take away',
  'premature optimization is the root of all evil',
  'the code you write makes you a programmer; the code you delete makes you a good one',
  'weeks of coding can save you hours of planning',
  'walking on water and developing software from a spec are easy if both are frozen',
  'any fool can write code a computer can understand; good programmers write code humans understand',
  'first, solve the problem. then, write the code',
  'talk is cheap. show me the code',
  'controlling complexity is the essence of computer programming',
  'the only way to go fast is to go well',
  'make each program do one thing well',
}
local M_cfg = {
  max_projects = 5,
  max_files    = 5,
  min_width    = 60,
  max_width    = 100,
  col_gap      = 4,
}

--  STATE
local state = {
  buf       = nil,
  win       = nil,
  items     = {},
  item_rows = {},
  layout    = {},
  last_row  = nil,
}

--  DATA FUNCTIONS

-- Pick a quote deterministically per calendar day so it's stable all day
-- and changes at midnight.
local function pick_quote()
  local day_seed = tonumber(os.date('%Y%m%d'))
  return M_quotes[(day_seed % #M_quotes) + 1]
end

-- Pick a banner based on the current day of week. os.date('%w') returns
-- 0 for Sunday, so +1 makes it 1-indexed for Lua tables.
local function pick_banner()
  local wday = tonumber(os.date('%w')) + 1
  return M_banners[wday]
end

-- Return up to M_cfg.max_files unique readable paths from vim.v.oldfiles,
-- in most-recent-first order.
local function get_recent_files()
  local seen, results = {}, {}
  for _, file in ipairs(vim.v.oldfiles or {}) do
    if #results >= M_cfg.max_files then break end
    if not seen[file] and vim.fn.filereadable(file) == 1 then
      seen[file] = true
      table.insert(results, file)
    end
  end
  return results
end

-- Return up to M_cfg.max_projects unique git repo roots derived from
-- vim.v.oldfiles. Walks upward from each file's directory looking for .git.
local function get_recent_projects()
  local seen, results = {}, {}
  for _, file in ipairs(vim.v.oldfiles or {}) do
    if #results >= M_cfg.max_projects then break end
    if vim.fn.filereadable(file) == 1 then
      local dir = vim.fn.fnamemodify(file, ':h')
      local git_dir = vim.fs.find('.git', { path = dir, upward = true, limit = 1 })[1]
      if git_dir then
        local root = vim.fn.fnamemodify(git_dir, ':h')
        if not seen[root] then
          seen[root] = true
          table.insert(results, root)
        end
      end
    end
  end
  return results
end

-- Fetch lightweight git info about the current working directory.
-- Returns nil if cwd is not a git repo or git is unavailable.
local function get_git_info()
  local function shell(cmd)
    local h = io.popen(cmd .. ' 2>/dev/null')
    if not h then return '' end
    local out = h:read('*a') or ''
    h:close()
    return out
  end

  local branch = shell('git branch --show-current'):gsub('\n', '')
  if branch == '' then return nil end

  local modified = tonumber(shell('git diff --shortstat'):match('(%d+) file')) or 0
  local added    = tonumber(shell('git status --porcelain | grep "^?" | wc -l'):match('%d+')) or 0
  local ahead    = tonumber(shell('git rev-list --count @{u}..HEAD'):match('%d+')) or 0

  return { branch = branch, modified = modified, added = added, ahead = ahead }
end

--  RENDER FUNCTIONS

-- Given the current window width, return a layout descriptor:
--   total_w  — total dashboard content width (clamped to [min_width, max_width])
--   col_w    — width of each of the two columns
--   left_pad — horizontal offset where the content block starts
--   left_x   — buffer column where the left content column starts
--   right_x  — buffer column where the right content column starts
--   col_gap  — gap between the two columns (from M_cfg)
local function compute_layout(win_w)
  local total_w  = math.min(M_cfg.max_width, math.max(M_cfg.min_width, win_w - 8))
  local col_gap  = M_cfg.col_gap
  local col_w    = math.floor((total_w - col_gap) / 2)
  local left_pad = math.max(0, math.floor((win_w - total_w) / 2))
  return {
    total_w  = total_w,
    col_w    = col_w,
    left_pad = left_pad,
    left_x   = left_pad,
    right_x  = left_pad + col_w + col_gap,
    col_gap  = col_gap,
  }
end

-- Helper: produce a horizontally-padded line at `left_pad` with given text.
local function padded(left_pad, text)
  return string.rep(' ', left_pad) .. text
end

-- Build the full set of buffer lines plus metadata.
-- Returns { lines, items, item_rows, highlights } where:
--   lines      = array of strings to set on the buffer
--   items      = array of { row, col_side, key, action }
--   item_rows  = sorted unique list of item rows (1-indexed)
--   highlights = array of { row (0-indexed), col_start, col_end, group }
local function build_lines(layout)
  local lines      = {}
  local items      = {}
  local highlights = {}

  local function add(text)
    table.insert(lines, text)
  end

  local function add_hl(row0, col_start, col_end, group)
    table.insert(highlights, {
      row       = row0,
      col_start = col_start,
      col_end   = col_end,
      group     = group,
    })
  end

  -- Top margin
  add('')

  -- Header banner
  local banner = pick_banner()
  local banner_w = vim.fn.strdisplaywidth(banner[1])
  local banner_pad = layout.left_pad + math.max(0, math.floor((layout.total_w - banner_w) / 2))
  for _, line in ipairs(banner) do
    add(padded(banner_pad, line))
    add_hl(#lines - 1, banner_pad, banner_pad + #line, 'LaunchpadHeader')
  end

  -- Quote
  add('')
  local quote = pick_quote()
  local quote_w = vim.fn.strdisplaywidth('"' .. quote .. '"')
  local quote_pad = layout.left_pad + math.max(0, math.floor((layout.total_w - quote_w) / 2))
  add(padded(quote_pad, '"' .. quote .. '"'))
  add_hl(#lines - 1, quote_pad, quote_pad + #quote + 2, 'LaunchpadQuote')

  add('')
  add('')

  -- Body columns start here
  local left_x  = layout.left_x
  local right_x = layout.right_x

  -- Build left items (Quick Actions)
  local left_rows = {}
  table.insert(left_rows, { label = 'Quick Actions' })
  for _, a in ipairs(M_actions) do
    local prefix = '  ' .. a.key .. '  ' .. a.icon .. ' '
    local text = prefix .. a.desc
    table.insert(left_rows, {
      text           = text,
      key            = a.key,
      action         = a.action,
      key_col_start  = 2,
      key_col_end    = 3,
      desc_col_start = #prefix,
      desc_col_end   = #text,
    })
  end

  -- Build right items (Recent Projects then Recent Files)
  local right_rows = {}

  local function shorten_path(path)
    local home = vim.env.HOME or ''
    local shown = path
    if home ~= '' and shown:sub(1, #home) == home then
      shown = '~' .. shown:sub(#home + 1)
    end
    local max_w = layout.col_w - 4
    if vim.fn.strdisplaywidth(shown) > max_w then
      shown = vim.fn.pathshorten(shown)
    end
    -- If still too long, hard-truncate with ellipsis
    if vim.fn.strdisplaywidth(shown) > max_w then
      shown = shown:sub(1, math.max(1, max_w - 1)) .. '…'
    end
    return shown
  end

  table.insert(right_rows, { label = 'Recent Projects' })
  local projects = get_recent_projects()
  if #projects == 0 then
    table.insert(right_rows, { text = '  (no recent projects)', placeholder = true })
  else
    for _, p in ipairs(projects) do
      local shown = shorten_path(p)
      table.insert(right_rows, {
        text           = '  ' .. shown,
        kind           = 'project',
        absolute       = p,
        action         = function()
          vim.cmd('cd ' .. vim.fn.fnameescape(p))
          pcall(vim.cmd, 'NvimTreeOpen')
        end,
        text_col_start = 2,
        text_col_end   = 2 + #shown,
      })
    end
  end

  table.insert(right_rows, { blank = true })
  table.insert(right_rows, { label = 'Recent Files' })
  local files = get_recent_files()
  if #files == 0 then
    table.insert(right_rows, { text = '  (no recent files)', placeholder = true })
  else
    for _, f in ipairs(files) do
      local shown = shorten_path(f)
      table.insert(right_rows, {
        text           = '  ' .. shown,
        kind           = 'file',
        absolute       = f,
        action         = function() vim.cmd('edit ' .. vim.fn.fnameescape(f)) end,
        text_col_start = 2,
        text_col_end   = 2 + #shown,
      })
    end
  end

  -- Zip left and right rows into buffer lines. The longer column dictates
  -- total row count; shorter column is padded with blanks.
  local max_rows = math.max(#left_rows, #right_rows)
  for i = 1, max_rows do
    local lr = left_rows[i]
    local rr = right_rows[i]

    -- Compose the line text. Note: use display width (not #byte) for the
    -- padding calculation because action icons are multi-byte Nerd Font glyphs.
    local left_text = ''
    if lr then
      left_text = lr.label or lr.text or ''
    end
    local left_w = vim.fn.strdisplaywidth(left_text)
    local padding_to_right = right_x - (left_x + left_w)
    if padding_to_right < 1 then padding_to_right = 1 end
    local right_text = ''
    if rr and not rr.blank then
      right_text = rr.label or rr.text or ''
    end
    local left_prefix = padded(left_x, left_text)
    local line_text = left_prefix .. string.rep(' ', padding_to_right) .. right_text
    add(line_text)
    local row1 = #lines  -- 1-indexed row

    -- Byte-offset anchors for highlights. `left_x` happens to equal the byte
    -- offset of the left content (since padded() uses ASCII spaces), but the
    -- right content's byte offset differs from `right_x` when left_text has
    -- multi-byte glyphs.
    local right_byte_start = #left_prefix + padding_to_right

    -- Left highlights + item registration
    if lr then
      if lr.label then
        add_hl(row1 - 1, left_x, left_x + #lr.label, 'LaunchpadSection')
      elseif lr.text then
        add_hl(row1 - 1, left_x + lr.key_col_start, left_x + lr.key_col_end, 'LaunchpadKey')
        add_hl(row1 - 1, left_x + lr.desc_col_start, left_x + lr.desc_col_end, 'LaunchpadAction')
        table.insert(items, {
          row      = row1,
          col_side = 'left',
          key      = lr.key,
          action   = lr.action,
        })
      end
    end

    -- Right highlights + item registration (using byte offset, not display col)
    if rr and not rr.blank then
      if rr.label then
        add_hl(row1 - 1, right_byte_start, right_byte_start + #rr.label, 'LaunchpadSection')
      elseif rr.placeholder then
        add_hl(row1 - 1, right_byte_start, right_byte_start + #rr.text, 'LaunchpadFooter')
      elseif rr.text then
        local group = rr.kind == 'project' and 'LaunchpadProject' or 'LaunchpadFile'
        add_hl(row1 - 1, right_byte_start + rr.text_col_start, right_byte_start + rr.text_col_end, group)
        table.insert(items, {
          row      = row1,
          col_side = 'right',
          key      = nil,
          action   = rr.action,
        })
      end
    end
  end

  -- Footer: two blank lines of separation, then git line + system line
  add('')
  add('')

  local function footer_line(text)
    local text_w = vim.fn.strdisplaywidth(text)
    local pad = layout.left_pad + math.max(0, math.floor((layout.total_w - text_w) / 2))
    add(padded(pad, text))
    return #lines - 1, pad  -- 0-indexed row, pad col
  end

  local git = get_git_info()
  if git then
    local branch_display = #git.branch > 30 and (git.branch:sub(1, 30) .. '…') or git.branch
    local icon_prefix = ' '  -- nerd font git branch icon + space
    local dirty_mod = git.modified > 0 and ('  ~' .. git.modified) or ''
    local dirty_add = git.added > 0 and (' +' .. git.added) or ''
    local ahead     = git.ahead > 0 and (' ↑' .. git.ahead) or ''
    local git_text  = icon_prefix .. branch_display .. dirty_mod .. dirty_add .. ahead
    local row0, pad = footer_line(git_text)
    -- All offsets below are BYTE offsets into the rendered line.
    -- The line starts with `pad` ASCII spaces followed by `git_text`.
    local cursor = pad + #icon_prefix
    add_hl(row0, cursor, cursor + #branch_display, 'LaunchpadGitBranch')
    cursor = cursor + #branch_display
    if dirty_mod ~= '' then
      add_hl(row0, cursor, cursor + #dirty_mod, 'LaunchpadGitDirty')
      cursor = cursor + #dirty_mod
    end
    if dirty_add ~= '' then
      add_hl(row0, cursor, cursor + #dirty_add, 'LaunchpadGitDirty')
      cursor = cursor + #dirty_add
    end
    if ahead ~= '' then
      add_hl(row0, cursor, cursor + #ahead, 'LaunchpadGitAhead')
    end
  end

  -- System line: plugin stats + nvim version + date
  local ok, lazy = pcall(require, 'lazy')
  local stats_str = ''
  if ok then
    local stats = lazy.stats()
    local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
    stats_str = string.format('󱐋 %d/%d plugins in %sms', stats.loaded, stats.count, ms)
  end
  local version = vim.version()
  local nvim_str = string.format('󱓞 v%d.%d.%d', version.major, version.minor, version.patch)
  local date_str = os.date('%Y-%m-%d %A')
  local system_text = (stats_str ~= '' and (stats_str .. '    ') or '')
                    .. nvim_str .. '    ' .. date_str
  local sys_row0, _ = footer_line(system_text)
  add_hl(sys_row0, 0, #lines[sys_row0 + 1], 'LaunchpadFooter')

  -- Sort unique item rows
  local row_set = {}
  for _, it in ipairs(items) do row_set[it.row] = true end
  local item_rows = {}
  for r, _ in pairs(row_set) do table.insert(item_rows, r) end
  table.sort(item_rows)

  return {
    lines      = lines,
    items      = items,
    item_rows  = item_rows,
    highlights = highlights,
  }
end

local ns = vim.api.nvim_create_namespace('launchpad')

-- Apply a list of { row (0-indexed), col_start, col_end, group } to the buffer.
local function apply_highlights(buf, highlights)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, hl in ipairs(highlights) do
    pcall(vim.api.nvim_buf_set_extmark, buf, ns, hl.row, hl.col_start, {
      end_col  = hl.col_end,
      hl_group = hl.group,
    })
  end
end

-- Main render entry point. Recomputes layout, rebuilds lines, writes to the
-- buffer, and updates state.items / state.item_rows / state.layout.
local function render()
  if not state.buf or not vim.api.nvim_buf_is_valid(state.buf) then return end
  local win_w = vim.api.nvim_win_get_width(state.win)
  local layout = compute_layout(win_w)

  local built = build_lines(layout)

  -- Vertically center by prepending blank lines
  local win_h = vim.api.nvim_win_get_height(state.win)
  local top_pad = math.max(0, math.floor((win_h - #built.lines) / 2))
  local padded_lines = {}
  for _ = 1, top_pad do table.insert(padded_lines, '') end
  for _, line in ipairs(built.lines) do table.insert(padded_lines, line) end

  -- Shift highlights down by top_pad to match
  local shifted_highlights = {}
  for _, hl in ipairs(built.highlights) do
    table.insert(shifted_highlights, {
      row       = hl.row + top_pad,
      col_start = hl.col_start,
      col_end   = hl.col_end,
      group     = hl.group,
    })
  end

  -- Shift item rows down too (they are 1-indexed)
  local shifted_items, shifted_item_rows = {}, {}
  for _, it in ipairs(built.items) do
    table.insert(shifted_items, {
      row      = it.row + top_pad,
      col_side = it.col_side,
      key      = it.key,
      action   = it.action,
    })
  end
  for _, r in ipairs(built.item_rows) do
    table.insert(shifted_item_rows, r + top_pad)
  end

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, padded_lines)
  vim.bo[state.buf].modifiable = false
  apply_highlights(state.buf, shifted_highlights)

  state.items     = shifted_items
  state.item_rows = shifted_item_rows
  state.layout    = layout
end

--  INTERACTION FUNCTIONS

-- Install Launchpad* highlight groups as links to stock groups.
-- `default = true` so user-defined overrides win.
local function setup_highlights()
  local links = {
    LaunchpadHeader    = 'Title',
    LaunchpadQuote     = 'Comment',
    LaunchpadSection   = 'Special',
    LaunchpadKey       = 'Constant',
    LaunchpadAction    = 'Normal',
    LaunchpadProject   = 'Directory',
    LaunchpadFile      = 'String',
    LaunchpadFooter    = 'Comment',
    LaunchpadGitBranch = 'Constant',
    LaunchpadGitDirty  = 'WarningMsg',
    LaunchpadGitAhead  = 'DiffAdd',
    LaunchpadIcon      = 'NonText',
  }
  for name, target in pairs(links) do
    vim.api.nvim_set_hl(0, name, { link = target, default = true })
  end
end

-- Snap the cursor to the nearest item row in the direction of movement.
-- Uses state.last_row as a direction hint so `k` walks backward cleanly.
local function snap_cursor()
  if not state.buf or state.buf ~= vim.api.nvim_get_current_buf() then return end
  if #state.item_rows == 0 then return end
  local row = vim.api.nvim_win_get_cursor(state.win)[1]
  if row == state.last_row then return end
  local direction = (state.last_row and row > state.last_row) and 1 or -1
  local target
  if direction == 1 then
    for _, r in ipairs(state.item_rows) do
      if r >= row then target = r; break end
    end
    target = target or state.item_rows[#state.item_rows]
  else
    for i = #state.item_rows, 1, -1 do
      if state.item_rows[i] <= row then target = state.item_rows[i]; break end
    end
    target = target or state.item_rows[1]
  end
  if target ~= row then
    local col = vim.api.nvim_win_get_cursor(state.win)[2]
    vim.api.nvim_win_set_cursor(state.win, { target, col })
  end
  state.last_row = target
end

-- Activate the item at the current cursor position. If multiple items share
-- the row (left + right column), pick by cursor column.
local function on_enter()
  if not state.buf or state.buf ~= vim.api.nvim_get_current_buf() then return end
  local row, col = unpack(vim.api.nvim_win_get_cursor(state.win))
  local candidates = {}
  for _, item in ipairs(state.items) do
    if item.row == row then table.insert(candidates, item) end
  end
  if #candidates == 0 then return end
  if #candidates == 1 then candidates[1].action(); return end
  local split_col = state.layout.left_x + state.layout.col_w
                    + math.floor(state.layout.col_gap / 2)
  local chosen = col < split_col and candidates[1] or candidates[2]
  chosen.action()
end

-- Install letter keybinds + <CR> + q + no-op editing keys. All buffer-local.
local function setup_keymaps(buf)
  local opts = { buffer = buf, nowait = true, silent = true }
  for _, item in ipairs(state.items) do
    if item.key then
      vim.keymap.set('n', item.key, item.action, opts)
    end
  end
  vim.keymap.set('n', '<CR>', on_enter, opts)
  vim.keymap.set('n', 'q', function() vim.cmd('quit') end, opts)
  for _, k in ipairs({ 'i', 'a', 'o', 'O', 'I', 'A', 'p', 'P', 'x', 'd' }) do
    vim.keymap.set('n', k, '<Nop>', opts)
  end
end

-- Install CursorMoved/VimResized/BufWipeout autocmds scoped to the dashboard buffer.
-- Uses a unique augroup per buffer so repeated open/close cycles don't leak.
local function setup_autocmds(buf)
  local group = vim.api.nvim_create_augroup('Launchpad_' .. buf, { clear = true })

  vim.api.nvim_create_autocmd('CursorMoved', {
    group = group, buffer = buf, callback = snap_cursor,
  })
  vim.api.nvim_create_autocmd('VimResized', {
    group = group, buffer = buf,
    callback = function()
      if state.buf == vim.api.nvim_get_current_buf() then render() end
    end,
  })
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group, buffer = buf,
    callback = function()
      pcall(vim.api.nvim_del_augroup_by_id, group)
      state.buf = nil
      state.win = nil
      state.last_row = nil
    end,
  })
end

--  ENTRY POINTS
local function open()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buftype   = 'nofile'
  vim.bo[buf].swapfile  = false
  vim.bo[buf].filetype  = 'launchpad'
  vim.api.nvim_buf_set_name(buf, 'Launchpad')

  vim.api.nvim_set_current_buf(buf)
  state.buf = buf
  state.win = vim.api.nvim_get_current_win()

  vim.wo[state.win].number         = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].cursorline     = false
  vim.wo[state.win].cursorcolumn   = false
  vim.wo[state.win].signcolumn     = 'no'
  vim.wo[state.win].foldcolumn     = '0'
  vim.wo[state.win].list           = false
  vim.wo[state.win].wrap           = false

  render()
  setup_keymaps(buf)
  setup_autocmds(buf)

  -- Park cursor on first item row if we have any
  if state.item_rows[1] then
    vim.api.nvim_win_set_cursor(state.win, { state.item_rows[1], 0 })
    state.last_row = state.item_rows[1]
  end
end

-- VimEnter startup gate: open the dashboard only when nvim was invoked with
-- no filename arguments and no stdin content.
local function maybe_open()
  if vim.fn.argc() > 0 then return end
  if vim.fn.line2byte('$') ~= -1 then return end
  open()
end

--  TEST EXPORTS (gated by LAUNCHPAD_TEST env var)
if vim.env.LAUNCHPAD_TEST then
  _G._LAUNCHPAD_TEST = {
    M_actions   = M_actions,
    M_cfg       = M_cfg,
    M_quotes    = M_quotes,
    M_banners   = M_banners,
    pick_quote        = pick_quote,
    pick_banner       = pick_banner,
    get_recent_files     = get_recent_files,
    get_recent_projects  = get_recent_projects,
    get_git_info         = get_git_info,
    compute_layout       = compute_layout,
    build_lines          = build_lines,
  }
end

--  MODULE-LOAD INITIALIZATION
setup_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('LaunchpadHighlights', { clear = true }),
  callback = setup_highlights,
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = maybe_open,
})

vim.api.nvim_create_user_command('Launchpad', open, {
  desc = 'Open the launchpad dashboard',
})

-- ============================================================================
--  LAZY.NVIM SPEC
-- launchpad is a local file, not a plugin. Return an empty spec table so
-- lazy.nvim sees this file as "no plugins declared" — the file's side effects
-- (autocmds, user command, highlight links) have already run at module load.
-- ============================================================================
return {}
