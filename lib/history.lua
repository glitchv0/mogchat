local history = {};

-- Build path for a conversation's history file
-- Uses addon config directory which is per-character via settings lib
local function get_history_dir()
    local player = AshitaCore:GetMemoryManager():GetParty():GetMemberName(0);
    if (not player or #player == 0) then
        return nil;
    end
    local dir = ('%s\\config\\addons\\mogchat\\%s\\history'):fmt(AshitaCore:GetInstallPath(), player);
    ashita.fs.create_dir(dir);
    return dir;
end

local function get_history_path(name)
    local dir = get_history_dir();
    if (not dir) then return nil; end
    return ('%s\\%s.lua'):fmt(dir, name:lower());
end

-- Save conversation messages to file
-- messages: table of { time, sender, text }
-- max_lines: max messages to keep
function history.save(name, messages, max_lines)
    local path = get_history_path(name);
    if (not path) then return; end

    -- Trim to max_lines (keep newest)
    local start_idx = 1;
    if (#messages > max_lines) then
        start_idx = #messages - max_lines + 1;
    end

    local f = io.open(path, 'w');
    if (not f) then return; end

    f:write('return {\n');
    for i = start_idx, #messages do
        local m = messages[i];
        -- Escape quotes in text
        local safe_text = m.text:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r');
        local safe_sender = m.sender:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', ''):gsub('\r', '');
        f:write(('  { time=%d, sender="%s", text="%s" },\n'):fmt(
            m.time, safe_sender, safe_text
        ));
    end
    f:write('}\n');
    f:close();
end

-- Load conversation history from file
-- Returns table of { time, sender, text } or empty table
-- load_recent: how many recent messages to load
function history.load(name, load_recent)
    local path = get_history_path(name);
    if (not path) then return {}; end

    if (not ashita.fs.exists(path)) then
        return {};
    end

    local ok, loader = pcall(loadfile, path);
    if (not ok or not loader) then return {}; end

    local ok2, data = pcall(loader);
    if (not ok2 or type(data) ~= 'table') then return {}; end

    -- Return only the most recent N messages
    if (#data > load_recent) then
        local trimmed = {};
        for i = #data - load_recent + 1, #data do
            table.insert(trimmed, data[i]);
        end
        return trimmed;
    end

    return data;
end

-- Delete history for a conversation
function history.delete(name)
    local path = get_history_path(name);
    if (path and ashita.fs.exists(path)) then
        os.remove(path);
    end
end

-- Delete all history files
function history.delete_all()
    local dir = get_history_dir();
    if (not dir) then return; end

    T(ashita.fs.get_dir(dir .. '\\', '.*.lua', true)):each(function(v)
        if (v and #v > 0) then
            os.remove(('%s\\%s'):fmt(dir, v));
        end
    end);
end

-- List all saved conversation names for the current character
-- Returns: sorted table of display names (derived from filenames)
function history.list()
    local dir = get_history_dir();
    if (not dir) then return {}; end

    local files = ashita.fs.get_dir(dir .. '\\', '.*.lua', true);
    if (not files) then return {}; end

    local names = {};
    T(files):each(function(v)
        if (v and #v > 0) then
            -- Strip .lua extension
            local name = v:gsub('%.lua$', '');
            if (#name > 0) then
                table.insert(names, name);
            end
        end
    end);

    table.sort(names, function(a, b) return a:lower() < b:lower(); end);
    return names;
end

-- Save all active conversations
function history.save_all(conversations_active, max_lines)
    for _, convo in pairs(conversations_active) do
        history.save(convo.name, convo.messages, max_lines);
    end
end

return history;
