local conversations = {
    active = {},     -- [name_lower] = conversation table
    order = {},      -- ordered list of conversation names (for tabbed mode tab order)
};

-- Create or get a conversation for a player
function conversations.get(name)
    local key = name:lower();
    if (not conversations.active[key]) then
        conversations.active[key] = {
            name = name,                -- Display name (original casing)
            messages = {},              -- { { time=os.time(), sender=string, text=string }, ... }
            unread = 0,                 -- Unread message count
            is_open = { true },         -- ImGui window open state (single-element table)
            flash_until = 0,            -- os.clock() timestamp to flash until
            input_buf = { '' },         -- ImGui input buffer
            scroll_to_bottom = false,   -- Flag to auto-scroll on next frame
        };
        table.insert(conversations.order, key);
    end
    return conversations.active[key];
end

-- Add a message to a conversation
-- direction: 'in' for received, 'out' for sent
-- Max messages to keep in memory per conversation
local MAX_MEMORY_MESSAGES = 1000;

function conversations.add_message(name, text, direction)
    local convo = conversations.get(name);
    table.insert(convo.messages, {
        time = os.time(),
        sender = (direction == 'in') and name or 'You',
        text = text,
    });
    convo.scroll_to_bottom = true;

    -- Trim oldest messages if over cap
    while (#convo.messages > MAX_MEMORY_MESSAGES) do
        table.remove(convo.messages, 1);
    end

    if (direction == 'in') then
        convo.unread = convo.unread + 1;
        convo.flash_until = os.clock() + 3.0;
    end

    return convo;
end

-- Mark conversation as read
function conversations.mark_read(name)
    local key = name:lower();
    if (conversations.active[key]) then
        conversations.active[key].unread = 0;
        conversations.active[key].flash_until = 0;
    end
end

-- Close a conversation (hide window, keep data)
function conversations.close(name)
    local key = name:lower();
    if (conversations.active[key]) then
        conversations.active[key].is_open[1] = false;
    end
end

-- Close all conversations
function conversations.close_all()
    for _, convo in pairs(conversations.active) do
        convo.is_open[1] = false;
    end
end

-- Get all active conversations (for rendering)
function conversations.get_all()
    return conversations.active;
end

-- Get ordered list of conversation keys (for tabbed mode)
function conversations.get_order()
    return conversations.order;
end

-- Check if any conversation has unread messages
function conversations.has_unread()
    for _, convo in pairs(conversations.active) do
        if (convo.unread > 0) then
            return true;
        end
    end
    return false;
end

-- Load messages into a conversation (from history)
function conversations.load_history(name, messages)
    local convo = conversations.get(name);
    for i = 1, #messages do
        table.insert(convo.messages, i, messages[i]);
    end
end

-- Clear messages for a conversation
function conversations.clear(name)
    local key = name:lower();
    if (conversations.active[key]) then
        conversations.active[key].messages = {};
        conversations.active[key].unread = 0;
    end
end

-- Clear all conversations
function conversations.clear_all()
    conversations.active = {};
    conversations.order = {};
end

return conversations;
