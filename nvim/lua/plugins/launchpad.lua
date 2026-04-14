-- ============================================================================
-- launchpad: custom Neovim startup dashboard
-- Local dashboard module loaded from lazy.nvim's plugin directory.
-- ============================================================================

--  CONFIG (populated in Task 2)
-- Quick actions for the left column. Each entry becomes a clickable row.
-- `action` is a function (not a command string) so it can be invoked directly.
local M_actions = {
  { key = 'f', icon = '󰈞', desc = 'Find File',     action = function() vim.cmd('Telescope find_files') end },
  { key = 'r', icon = '󰋚', desc = 'Recent Files',  action = function() vim.cmd('Telescope oldfiles') end },
  { key = 'g', icon = '󰱼', desc = 'Live Grep',     action = function() vim.cmd('Telescope live_grep') end },
  { key = 'e', icon = '󰙅', desc = 'File Browser',  action = function() vim.cmd('NvimTreeToggle') end },
  { key = 's', icon = '󰊢', desc = 'Git Status',    action = function() vim.cmd('Telescope git_status') end },
  { key = 'c', icon = '', desc = 'Configuration', action = function()
      require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })
    end },
  { key = 'l', icon = '󰒲', desc = 'Lazy',          action = function() vim.cmd('Lazy') end },
  { key = 'q', icon = '󰈆', desc = 'Quit',          action = function() vim.cmd('quit') end },
}
-- Day banners. Index 1 = Sunday, 7 = Saturday (matches os.date('%w') + 1).
local M_banners = {
  {
    '   _____                 __            ',
    '  / ___/__  ______  ____/ /___ ___  __ ',
    '  \\__ \\/ / / / __ \\/ __  / __ `/ / / / ',
    ' ___/ / /_/ / / / / /_/ / /_/ / /_/ /  ',
    '/____/\\__,_/_/ /_/\\__,_/\\__,_/\\__, /   ',
    '                             /____/    ',
  },
  {
    '    __  ___                __            ',
    '   /  |/  /___  ____  ____/ /___ ___  __ ',
    '  / /|_/ / __ \\/ __ \\/ __  / __ `/ / / / ',
    ' / /  / / /_/ / / / / /_/ / /_/ / /_/ /  ',
    '/_/  /_/\\____/_/ /_/\\__,_/\\__,_/\\__, /   ',
    '                               /____/    ',
  },
  {
    '   ______                    __            ',
    '  /_  __/_  _____  _________/ /___ ___  __ ',
    '   / / / / / / _ \\/ ___/ __  / __ `/ / / / ',
    '  / / / /_/ /  __(__  ) /_/ / /_/ / /_/ /  ',
    ' /_/  \\__,_/\\___/____/\\__,_/\\__,_/\\__, /   ',
    '                                  /____/   ',
  },
  {
    ' _       __          __                    __            ',
    '| |     / /__  ____/ /___  ___  _________/ /___ ___  __ ',
    '| | /| / / _ \\/ __  / __ \\/ _ \\/ ___/ __  / __ `/ / / / ',
    '| |/ |/ /  __/ /_/ / / / /  __(__  ) /_/ / /_/ / /_/ /  ',
    '|__/|__/\\___/\\__,_/_/ /_/\\___/____/\\__,_/\\__,_/\\__, /   ',
    '                                              /____/    ',
  },
  {
    '  ________                    __            ',
    ' /_  __/ /_  __  ____________/ /___ ___  __ ',
    '  / / / __ \\/ / / / ___/ ___/ / __ `/ / / / ',
    ' / / / / / / /_/ / /  (__  ) / /_/ / /_/ /  ',
    '/_/ /_/ /_/\\__,_/_/  /____/_/\\__,_/\\__, /   ',
    '                                   /____/   ',
  },
  {
    '    ______     _     __            ',
    '   / ____/____(_)___/ /___ ___  __ ',
    '  / /_  / ___/ / __  / __ `/ / / / ',
    ' / __/ / /  / / /_/ / /_/ / /_/ /  ',
    '/_/   /_/  /_/\\__,_/\\__,_/\\__, /   ',
    '                         /____/    ',
  },
  {
    '   _____       __                 __            ',
    '  / ___/____ _/ /___  ___________/ /___ ___  __ ',
    '  \\__ \\/ __ `/ __/ / / / ___/ __  / __ `/ / / / ',
    ' ___/ / /_/ / /_/ /_/ / /  / /_/ / /_/ / /_/ /  ',
    '/____/\\__,_/\\__/\\__,_/_/   \\__,_/\\__,_/\\__, /   ',
    '                                       /____/    ',
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
  max_folders  = 5,
  max_files    = 5,
  min_width    = 60,
  max_width    = 100,
  col_gap      = 4,
}

--  STATE
local state = {
  buf         = nil,
  win         = nil,
  items       = {},
  item_rows   = {},
  left_items  = {},
  right_items = {},
  layout      = {},
  col_side    = 'left',
}

local folder_history_path = vim.fn.stdpath('state') .. '/launchpad-folders.json'
local folder_history_cache = nil

--  DATA FUNCTIONS

-- Pick a quote deterministically per calendar day so it's stable all day
-- and changes at midnight.
local function pick_quote()
  local day_seed = tonumber(os.date('%Y%m%d'))
  return M_quotes[(day_seed % #M_quotes) + 1]
end

local function center_text(text, width)
  local pad = math.max(0, width - vim.fn.strdisplaywidth(text))
  local left = math.floor(pad / 2)
  local right = pad - left
  return string.rep(' ', left) .. text .. string.rep(' ', right)
end

-- Render the current day as a fixed doom-style banner and add a date line.
local function pick_banner()
  local wday = tonumber(os.date('%w')) + 1
  local title = vim.deepcopy(M_banners[wday])
  local width = 0
  for _, line in ipairs(title) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  table.insert(title, '')
  table.insert(title, center_text(os.date('%d %b %Y'), width))
  return title
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

local function normalize_dir(path)
  local normalized = vim.fs.normalize(vim.fn.fnamemodify(path, ':p'))
  if normalized ~= '/' then
    normalized = normalized:gsub('/+$', '')
  end
  return normalized
end

local function is_non_git_dir(path)
  if vim.fn.isdirectory(path) ~= 1 then return false end
  return vim.fs.find('.git', { path = path, upward = true, limit = 1 })[1] == nil
end

local function load_folder_history()
  if folder_history_cache ~= nil then
    return vim.deepcopy(folder_history_cache)
  end

  local ok_read, lines = pcall(vim.fn.readfile, folder_history_path)
  if not ok_read or #lines == 0 then
    folder_history_cache = {}
    return {}
  end

  local ok_decode, decoded = pcall(vim.json.decode, table.concat(lines, '\n'))
  if not ok_decode or type(decoded) ~= 'table' then
    folder_history_cache = {}
    return {}
  end

  local results, seen = {}, {}
  for _, path in ipairs(decoded) do
    if type(path) == 'string' then
      local normalized = normalize_dir(path)
      if not seen[normalized] and is_non_git_dir(normalized) then
        seen[normalized] = true
        table.insert(results, normalized)
      end
    end
  end

  folder_history_cache = results
  return vim.deepcopy(results)
end

local function save_folder_history(paths)
  folder_history_cache = vim.deepcopy(paths)
  vim.fn.mkdir(vim.fn.fnamemodify(folder_history_path, ':h'), 'p')
  vim.fn.writefile({ vim.json.encode(paths) }, folder_history_path)
end

local function remember_folder(path)
  local normalized = normalize_dir(path)
  if not is_non_git_dir(normalized) then return end

  local updated = { normalized }
  for _, existing in ipairs(load_folder_history()) do
    if existing ~= normalized then
      table.insert(updated, existing)
    end
    if #updated >= M_cfg.max_folders then break end
  end

  save_folder_history(updated)
end

local function get_recent_folders()
  local results = {}
  for _, path in ipairs(load_folder_history()) do
    if #results >= M_cfg.max_folders then break end
    if is_non_git_dir(path) then
      table.insert(results, path)
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
  local lines       = {}
  local items       = {}
  local left_items  = {}
  local right_items = {}
  local highlights  = {}

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
  for i, line in ipairs(banner) do
    add(padded(banner_pad, line))
    local group = i <= (#banner - 2) and 'LaunchpadHeaderTitle' or 'LaunchpadHeaderMeta'
    add_hl(#lines - 1, banner_pad, banner_pad + #line, group)
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
  table.insert(left_rows, { label = '󰄵  Quick Actions' })
  for _, a in ipairs(M_actions) do
    local prefix = '  ' .. a.key .. '  ' .. a.icon .. '  '
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

  -- Build right items (Recent Projects, Recent Folders, then Recent Files)
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

  table.insert(right_rows, { label = '󰉋  Recent Projects' })
  local projects = get_recent_projects()
  if #projects == 0 then
    table.insert(right_rows, { text = '  (no recent projects)', placeholder = true })
  else
    for _, p in ipairs(projects) do
      local shown = shorten_path(p)
      local prefix = '  󰉋  '
      table.insert(right_rows, {
        text           = prefix .. shown,
        kind           = 'project',
        absolute       = p,
        action         = function()
          -- Global cd so DirChanged fires for statusline / lualine / etc.
          vim.cmd('cd ' .. vim.fn.fnameescape(p))
          -- Use the nvim-tree api directly: it force-loads the plugin (so it
          -- works on the very first click even when nvim-tree is lazy-loaded
          -- by command) and `change_root` makes the tree actually re-point at
          -- the new project on every subsequent click instead of silently
          -- staying on the previous one.
          local ok, api = pcall(require, 'nvim-tree.api')
          if ok then
            pcall(api.tree.change_root, p)
            pcall(api.tree.open)
          else
            pcall(vim.cmd, 'NvimTreeOpen')
          end
        end,
        text_col_start = #prefix,
        text_col_end   = #prefix + #shown,
      })
    end
  end

  table.insert(right_rows, { blank = true })
  table.insert(right_rows, { label = '󰉖  Recent Folders' })
  local folders = get_recent_folders()
  if #folders == 0 then
    table.insert(right_rows, { text = '  (no recent folders)', placeholder = true })
  else
    for _, folder in ipairs(folders) do
      local shown = shorten_path(folder)
      local prefix = '  󰉖  '
      table.insert(right_rows, {
        text           = prefix .. shown,
        kind           = 'folder',
        absolute       = folder,
        action         = function()
          vim.cmd('cd ' .. vim.fn.fnameescape(folder))
          local ok, api = pcall(require, 'nvim-tree.api')
          if ok then
            pcall(api.tree.change_root, folder)
            pcall(api.tree.open)
          else
            pcall(vim.cmd, 'NvimTreeOpen')
          end
        end,
        text_col_start = #prefix,
        text_col_end   = #prefix + #shown,
      })
    end
  end

  table.insert(right_rows, { blank = true })
  table.insert(right_rows, { label = '󰈙  Recent Files' })
  local files = get_recent_files()
  if #files == 0 then
    table.insert(right_rows, { text = '  (no recent files)', placeholder = true })
  else
    for _, f in ipairs(files) do
      local shown = shorten_path(f)
      local prefix = '  󰈙  '
      table.insert(right_rows, {
        text           = prefix .. shown,
        kind           = 'file',
        absolute       = f,
        action         = function()
          -- cd to the file's git root (or its parent dir as a fallback) so
          -- the cwd, statusline, and DirChanged listeners follow the file.
          local dir = vim.fn.fnamemodify(f, ':h')
          local git = vim.fs.find('.git', { path = dir, upward = true, limit = 1 })[1]
          local root = git and vim.fn.fnamemodify(git, ':h') or dir
          vim.cmd('cd ' .. vim.fn.fnameescape(root))
          vim.cmd('edit ' .. vim.fn.fnameescape(f))
        end,
        text_col_start = #prefix,
        text_col_end   = #prefix + #shown,
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
        local left_item = {
          row      = row1,
          col      = left_x + lr.key_col_start,
          col_side = 'left',
          key      = lr.key,
          action   = lr.action,
        }
        table.insert(items, left_item)
        table.insert(left_items, left_item)
      end
    end

    -- Right highlights + item registration (using byte offset, not display col)
    if rr and not rr.blank then
      if rr.label then
        add_hl(row1 - 1, right_byte_start, right_byte_start + #rr.label, 'LaunchpadSection')
      elseif rr.placeholder then
        add_hl(row1 - 1, right_byte_start, right_byte_start + #rr.text, 'LaunchpadFooter')
      elseif rr.text then
        local group = rr.kind == 'project' and 'LaunchpadProject'
                   or rr.kind == 'folder' and 'LaunchpadFolder'
                   or 'LaunchpadFile'
        add_hl(row1 - 1, right_byte_start + rr.text_col_start, right_byte_start + rr.text_col_end, group)
        local right_item = {
          row      = row1,
          col      = right_byte_start + rr.text_col_start,
          col_side = 'right',
          key      = nil,
          action   = rr.action,
        }
        table.insert(items, right_item)
        table.insert(right_items, right_item)
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
    local icon_prefix = '󰊢 '
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
  local date_str = '󰃭 ' .. os.date('%Y-%m-%d %A')
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
    lines       = lines,
    items       = items,
    item_rows   = item_rows,
    left_items  = left_items,
    right_items = right_items,
    highlights  = highlights,
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
  local shifted_left_items, shifted_right_items = {}, {}
  local function shift_item(it)
    return {
      row      = it.row + top_pad,
      col      = it.col,
      col_side = it.col_side,
      key      = it.key,
      action   = it.action,
    }
  end
  for _, it in ipairs(built.items) do
    table.insert(shifted_items, shift_item(it))
  end
  for _, it in ipairs(built.left_items) do
    table.insert(shifted_left_items, shift_item(it))
  end
  for _, it in ipairs(built.right_items) do
    table.insert(shifted_right_items, shift_item(it))
  end
  for _, r in ipairs(built.item_rows) do
    table.insert(shifted_item_rows, r + top_pad)
  end

  vim.bo[state.buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, padded_lines)
  vim.bo[state.buf].modifiable = false
  apply_highlights(state.buf, shifted_highlights)

  state.items       = shifted_items
  state.item_rows   = shifted_item_rows
  state.left_items  = shifted_left_items
  state.right_items = shifted_right_items
  state.layout      = layout
end

--  INTERACTION FUNCTIONS

local function setup_highlights()
  local white = '#ffffff'
  local soft  = '#d8d8d8'
  local dim   = '#a8a8a8'
  local blue  = '#51afef'

  vim.api.nvim_set_hl(0, 'LaunchpadHeaderFrame', { fg = dim })
  vim.api.nvim_set_hl(0, 'LaunchpadHeaderTitle', { fg = white, bold = true })
  vim.api.nvim_set_hl(0, 'LaunchpadHeaderMeta',  { fg = soft })
  vim.api.nvim_set_hl(0, 'LaunchpadQuote',       { fg = dim, italic = true })
  vim.api.nvim_set_hl(0, 'LaunchpadSection',     { fg = blue, bold = true })
  vim.api.nvim_set_hl(0, 'LaunchpadKey',         { fg = white, bold = true })
  vim.api.nvim_set_hl(0, 'LaunchpadAction',      { fg = soft })
  vim.api.nvim_set_hl(0, 'LaunchpadProject',     { fg = soft })
  vim.api.nvim_set_hl(0, 'LaunchpadFolder',      { fg = soft })
  vim.api.nvim_set_hl(0, 'LaunchpadFile',        { fg = soft })
  vim.api.nvim_set_hl(0, 'LaunchpadFooter',      { fg = dim })
  vim.api.nvim_set_hl(0, 'LaunchpadGitBranch',   { fg = white, bold = true })
  vim.api.nvim_set_hl(0, 'LaunchpadGitDirty',    { fg = soft, bold = true })
  vim.api.nvim_set_hl(0, 'LaunchpadGitAhead',    { fg = soft, bold = true })
  vim.api.nvim_set_hl(0, 'LaunchpadIcon',        { fg = dim })
end

-- Return the active column's item list (left or right).
local function active_list()
  return state.col_side == 'left' and state.left_items or state.right_items
end

-- Find the index in `list` whose row is closest to `row`.
local function index_for_row(list, row)
  if #list == 0 then return 1 end
  local best_i, best_dist = 1, math.huge
  for i, item in ipairs(list) do
    local d = math.abs(item.row - row)
    if d < best_dist then best_i, best_dist = i, d end
  end
  return best_i
end

-- Move the cursor to list[idx], wrapping idx into [1, #list].
local function goto_item(list, idx)
  if #list == 0 then return end
  if idx < 1 then idx = #list end
  if idx > #list then idx = 1 end
  local item = list[idx]
  vim.api.nvim_win_set_cursor(state.win, { item.row, item.col })
end

-- Switch to the other column, landing on the item closest to the current row.
-- No-op if the target column has no items (avoids stranding the cursor).
local function switch_column(target_side)
  if state.col_side == target_side then return end
  local target_list = target_side == 'left' and state.left_items or state.right_items
  if #target_list == 0 then return end
  state.col_side = target_side
  local row = vim.api.nvim_win_get_cursor(state.win)[1]
  goto_item(target_list, index_for_row(target_list, row))
end

-- Snap the cursor onto the nearest valid item whenever it lands on empty
-- space. Re-derives the active column from the cursor's x position so that
-- arrow keys, mouse clicks, and other movement still feel natural.
local snapping = false
local function snap_to_item()
  if snapping then return end
  if not state.buf or state.buf ~= vim.api.nvim_get_current_buf() then return end
  if not state.layout or not state.layout.left_x then return end

  local row, col = unpack(vim.api.nvim_win_get_cursor(state.win))

  -- If we're already exactly on a known item, nothing to do.
  for _, item in ipairs(state.items) do
    if item.row == row and item.col == col then
      state.col_side = item.col_side
      return
    end
  end

  -- Pick the target column based on where the cursor landed.
  local split_col = state.layout.left_x + state.layout.col_w
                    + math.floor(state.layout.col_gap / 2)
  local target_side = col < split_col and 'left' or 'right'
  local target_list = target_side == 'left' and state.left_items or state.right_items

  -- Fall back to the other column if the preferred one is empty.
  if #target_list == 0 then
    target_side = target_side == 'left' and 'right' or 'left'
    target_list = target_side == 'left' and state.left_items or state.right_items
  end
  if #target_list == 0 then return end

  state.col_side = target_side
  snapping = true
  pcall(goto_item, target_list, index_for_row(target_list, row))
  snapping = false
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

-- Install letter keybinds + navigation + <CR> + q + no-op editing keys.
local function setup_keymaps(buf)
  local opts = { buffer = buf, nowait = true, silent = true }

  for _, item in ipairs(state.items) do
    if item.key then
      vim.keymap.set('n', item.key, item.action, opts)
    end
  end

  vim.keymap.set('n', '<CR>', on_enter, opts)
  vim.keymap.set('n', 'q', function() vim.cmd('quit') end, opts)

  -- Mouse: <LeftMouse> places the cursor (CursorMoved snaps to the nearest
  -- item), then <LeftRelease> activates it. <2-LeftMouse> covers double-click.
  vim.keymap.set('n', '<LeftRelease>',  on_enter, opts)
  vim.keymap.set('n', '<2-LeftMouse>',  on_enter, opts)

  -- Vertical navigation within the active column (wraps)
  local function move_down()
    local list = active_list()
    if #list == 0 then return end
    local row = vim.api.nvim_win_get_cursor(state.win)[1]
    local idx = index_for_row(list, row)
    if list[idx].row <= row then idx = idx + 1 end
    goto_item(list, idx)
  end

  local function move_up()
    local list = active_list()
    if #list == 0 then return end
    local row = vim.api.nvim_win_get_cursor(state.win)[1]
    local idx = index_for_row(list, row)
    if list[idx].row >= row then idx = idx - 1 end
    goto_item(list, idx)
  end

  vim.keymap.set('n', 'j',      move_down, opts)
  vim.keymap.set('n', 'k',      move_up,   opts)
  vim.keymap.set('n', '<Down>', move_down, opts)
  vim.keymap.set('n', '<Up>',   move_up,   opts)

  vim.keymap.set('n', 'gg', function() goto_item(active_list(), 1) end, opts)
  vim.keymap.set('n', 'G',  function() local l = active_list(); goto_item(l, #l) end, opts)

  -- Column switching: h/l, arrow keys, plus Tab/S-Tab
  local function go_left()  switch_column('left')  end
  local function go_right() switch_column('right') end
  vim.keymap.set('n', 'h',       go_left,  opts)
  vim.keymap.set('n', 'l',       go_right, opts)
  vim.keymap.set('n', '<Left>',  go_left,  opts)
  vim.keymap.set('n', '<Right>', go_right, opts)
  local function toggle_column()
    switch_column(state.col_side == 'left' and 'right' or 'left')
  end
  vim.keymap.set('n', '<Tab>',   toggle_column, opts)
  vim.keymap.set('n', '<S-Tab>', toggle_column, opts)

  for _, k in ipairs({ 'i', 'a', 'o', 'O', 'I', 'A', 'p', 'P', 'x', 'd' }) do
    vim.keymap.set('n', k, '<Nop>', opts)
  end
end

-- Install CursorMoved/VimResized/BufWipeout autocmds scoped to the dashboard buffer.
-- Uses a unique augroup per buffer so repeated open/close cycles don't leak.
local function setup_autocmds(buf)
  local group = vim.api.nvim_create_augroup('Launchpad_' .. buf, { clear = true })

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'BufEnter' }, {
    group = group, buffer = buf, callback = snap_to_item,
  })
  vim.api.nvim_create_autocmd('VimResized', {
    group = group, buffer = buf,
    callback = function()
      if state.buf == vim.api.nvim_get_current_buf() then render(); snap_to_item() end
    end,
  })
  vim.api.nvim_create_autocmd('BufWipeout', {
    group = group, buffer = buf,
    callback = function()
      pcall(vim.api.nvim_del_augroup_by_id, group)
      -- Reopening Launchpad from an existing Launchpad buffer can wipe the old
      -- scratch buffer after the new one is already active. Only clear global
      -- state when the buffer being wiped is still the live dashboard buffer.
      if state.buf == buf then
        state.buf = nil
        state.win = nil
        state.col_side = 'left'
      end
    end,
  })
end

--  ENTRY POINTS
local function is_launchpad_buf(buf)
  return buf
    and vim.api.nvim_buf_is_valid(buf)
    and vim.bo[buf].filetype == 'launchpad'
end

local function find_visible_launchpad()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if is_launchpad_buf(buf) then
      return buf, win
    end
  end
end

local function show(buf, win)
  vim.api.nvim_set_current_win(win)
  if vim.api.nvim_win_get_buf(win) ~= buf then
    vim.api.nvim_win_set_buf(win, buf)
  end

  state.buf = buf
  state.win = win

  vim.wo[state.win].number         = false
  vim.wo[state.win].relativenumber = false
  vim.wo[state.win].cursorline     = false
  vim.wo[state.win].cursorcolumn   = false
  vim.wo[state.win].signcolumn     = 'no'
  vim.wo[state.win].foldcolumn     = '0'
  vim.wo[state.win].list           = false
  vim.wo[state.win].wrap           = false

  state.col_side = 'left'
  render()
  setup_keymaps(buf)
  setup_autocmds(buf)

  -- Park cursor on the first item in the active column. If the left column
  -- is empty for some reason, fall back to the right column.
  local list = state.left_items
  if #list == 0 then
    list = state.right_items
    state.col_side = 'right'
  end
  if list[1] then
    vim.api.nvim_win_set_cursor(state.win, { list[1].row, list[1].col })
  end
end

local function open()
  local win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()
  if is_launchpad_buf(current_buf) then
    show(current_buf, win)
    return
  end

  local visible_buf = find_visible_launchpad()
  if visible_buf then
    show(visible_buf, win)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = 'wipe'
  vim.bo[buf].buftype   = 'nofile'
  vim.bo[buf].swapfile  = false
  vim.bo[buf].filetype  = 'launchpad'
  vim.api.nvim_buf_set_name(buf, 'Launchpad')

  show(buf, win)
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
    get_recent_folders   = get_recent_folders,
    remember_folder      = remember_folder,
    get_git_info         = get_git_info,
    compute_layout       = compute_layout,
    build_lines          = build_lines,
  }
end

--  MODULE-LOAD INITIALIZATION
setup_highlights()
remember_folder(vim.fn.getcwd())

vim.api.nvim_create_autocmd('ColorScheme', {
  group = vim.api.nvim_create_augroup('LaunchpadHighlights', { clear = true }),
  callback = setup_highlights,
})

vim.api.nvim_create_autocmd('DirChanged', {
  callback = function(args)
    remember_folder(args.file)
    if state.buf and state.buf == vim.api.nvim_get_current_buf() then
      render()
      snap_to_item()
    end
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  callback = maybe_open,
})

-- When the user closes the last real buffer (e.g. via bufferline's `:bdelete`),
-- fall back to the launchpad instead of being left staring at a blank `[No Name]`.
vim.api.nvim_create_autocmd('BufDelete', {
  callback = function(args)
    if vim.v.exiting ~= vim.NIL then return end
    local closing = args.buf
    vim.schedule(function()
      if vim.v.exiting ~= vim.NIL then return end
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if buf ~= closing
          and vim.api.nvim_buf_is_valid(buf)
          and vim.bo[buf].buflisted
          and not is_launchpad_buf(buf)
        then
          return
        end
      end
      open()
    end)
  end,
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
