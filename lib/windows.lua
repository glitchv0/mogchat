local imgui = require('imgui');
local themes = require('lib/themes');

local windows = {};

local INPUT_BUF_SIZE = 256;

-- Message colors (set by theme before rendering)
local COLOR_INCOMING = { 1.0, 1.0, 1.0, 1.0 };
local COLOR_OUTGOING = { 0.6, 0.8, 1.0, 1.0 };
local COLOR_TIMESTAMP = { 0.5, 0.5, 0.5, 1.0 };

-- Update message colors from current theme
function windows.set_msg_colors(theme)
    COLOR_INCOMING = theme.msg_incoming;
    COLOR_OUTGOING = theme.msg_outgoing;
    COLOR_TIMESTAMP = theme.msg_timestamp;
end

-- Render a single conversation's message list and input box
-- Returns: string message to send, or nil
local function render_conversation_content(convo)
    local send_msg = nil;

    -- Messages area (scrollable, takes all space except input row)
    imgui.BeginChild(('##msgs_%s'):fmt(convo.name:lower()), { 0, -imgui.GetFrameHeightWithSpacing() }, true);

    for _, msg in ipairs(convo.messages) do
        -- Timestamp
        local time_str = os.date('[%H:%M]', msg.time);
        imgui.TextColored(COLOR_TIMESTAMP, time_str);
        imgui.SameLine();

        -- Sender + message with text wrapping
        -- Use PushTextWrapPos instead of TextWrapped to avoid printf format injection
        if (msg.sender == 'You') then
            imgui.PushStyleColor(ImGuiCol_Text, COLOR_OUTGOING);
            imgui.PushTextWrapPos(0);
            imgui.Text('You: ' .. msg.text);
            imgui.PopTextWrapPos();
            imgui.PopStyleColor();
        else
            imgui.PushStyleColor(ImGuiCol_Text, COLOR_INCOMING);
            imgui.PushTextWrapPos(0);
            imgui.Text(msg.sender .. ': ' .. msg.text);
            imgui.PopTextWrapPos();
            imgui.PopStyleColor();
        end
    end

    -- Smart auto-scroll: only if user is near bottom
    if (convo.scroll_to_bottom) then
        local scroll_max = imgui.GetScrollMaxY();
        local scroll_cur = imgui.GetScrollY();
        if (scroll_max == 0 or (scroll_max - scroll_cur) < 50) then
            imgui.SetScrollHereY(1.0);
        end
        convo.scroll_to_bottom = false;
    end

    imgui.EndChild();

    -- Input row — refocus after sending
    if (convo.refocus) then
        imgui.SetKeyboardFocusHere();
        convo.refocus = false;
    end
    imgui.PushItemWidth(-65);
    local enter = imgui.InputText(('##input_%s'):fmt(convo.name:lower()), convo.input_buf, INPUT_BUF_SIZE, ImGuiInputTextFlags_EnterReturnsTrue);
    imgui.PopItemWidth();
    imgui.SameLine();
    local clicked = imgui.Button(('Send##%s'):fmt(convo.name:lower()), { 58, 0 });

    if ((enter or clicked) and convo.input_buf[1] ~= '') then
        send_msg = convo.input_buf[1];
        convo.input_buf[1] = '';
        -- Flag to refocus input on next frame
        convo.refocus = true;
    end

    return send_msg;
end

-- Render floating mode: one window per conversation
-- Returns: table of { name, message } for tells to send
function windows.render_floating(conversations, config)
    local to_send = {};

    for _, convo in pairs(conversations.get_all()) do
        if (convo.is_open[1]) then
            -- Window title with unread indicator
            local title = convo.name;
            if (convo.unread > 0 and config.notifications.flash) then
                -- Flash effect: toggle asterisk based on clock
                if (os.clock() < convo.flash_until and math.floor(os.clock() * 3) % 2 == 0) then
                    title = ('* %s *'):fmt(convo.name);
                elseif (convo.unread > 0) then
                    title = ('%s (%d)'):fmt(convo.name, convo.unread);
                end
            elseif (convo.unread > 0) then
                title = ('%s (%d)'):fmt(convo.name, convo.unread);
            end

            imgui.SetNextWindowSize({ config.window.default_width, config.window.default_height }, ImGuiCond_FirstUseEver);

            -- Center on screen for first appearance
            local display = imgui.GetIO().DisplaySize;
            if (display) then
                local cx = (display.x - config.window.default_width) / 2;
                local cy = (display.y - config.window.default_height) / 2;
                imgui.SetNextWindowPos({ cx, cy }, ImGuiCond_FirstUseEver);
            end

            if (imgui.Begin(('%s###mogchat_%s'):fmt(title, convo.name:lower()), convo.is_open)) then
                -- Mark as read when window is focused
                if (imgui.IsWindowFocused()) then
                    conversations.mark_read(convo.name);
                end

                local msg = render_conversation_content(convo);
                if (msg) then
                    table.insert(to_send, { name = convo.name, message = msg });
                end
            end
            imgui.End();
        end
    end

    return to_send;
end

-- Render tabbed mode: single window with tabs
-- Returns: table of { name, message } for tells to send
function windows.render_tabbed(conversations, config)
    local to_send = {};
    local has_any_open = false;

    for _, convo in pairs(conversations.get_all()) do
        if (convo.is_open[1]) then
            has_any_open = true;
            break;
        end
    end

    if (not has_any_open) then return to_send; end

    -- Single MogChat window
    local window_open = { true };
    local tw = config.window.default_width + 50;
    local th = config.window.default_height + 50;
    imgui.SetNextWindowSize({ tw, th }, ImGuiCond_FirstUseEver);

    local display = imgui.GetIO().DisplaySize;
    if (display) then
        imgui.SetNextWindowPos({ (display.x - tw) / 2, (display.y - th) / 2 }, ImGuiCond_FirstUseEver);
    end

    if (imgui.Begin('MogChat###mogchat_tabbed', window_open)) then
        if (imgui.BeginTabBar('##mogchat_tabs')) then
            for _, key in ipairs(conversations.get_order()) do
                local convo = conversations.get_all()[key];
                if (convo and convo.is_open[1]) then
                    -- Tab label with unread indicator
                    local label = convo.name;
                    if (convo.unread > 0) then
                        label = ('%s (%d)'):fmt(convo.name, convo.unread);
                    end

                    local tab_open = { true };
                    local flags = 0;
                    -- Auto-select tab on new message flash
                    if (convo.flash_until > 0 and os.clock() < convo.flash_until) then
                        flags = ImGuiTabItemFlags_SetSelected;
                        convo.flash_until = 0;
                    end

                    if (imgui.BeginTabItem(('%s###tab_%s'):fmt(label, convo.name:lower()), tab_open, flags)) then
                        -- Mark as read when tab is active
                        conversations.mark_read(convo.name);

                        local msg = render_conversation_content(convo);
                        if (msg) then
                            table.insert(to_send, { name = convo.name, message = msg });
                        end
                        imgui.EndTabItem();
                    end

                    -- Handle tab close
                    if (not tab_open[1]) then
                        convo.is_open[1] = false;
                    end
                end
            end
            imgui.EndTabBar();
        end
    end
    imgui.End();

    -- If main window closed, close all conversations
    if (not window_open[1]) then
        conversations.close_all();
    end

    return to_send;
end

return windows;
