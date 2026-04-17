addon.name      = 'MogChat';
addon.author    = 'CatsEyeXI';
addon.version   = '0.4.0';
addon.desc      = 'Instant messenger for FFXI tells';
addon.link      = '';

require('common');
local chat      = require('chat');
local settings  = require('settings');
local imgui     = require('imgui');
local packets       = require('lib/packets');
local conversations = require('lib/conversations');
local history_lib   = require('lib/history');
local notifications = require('lib/notifications');
local windows       = require('lib/windows');
local themes        = require('lib/themes');

local default_settings = T{
    display_mode = 'floating',
    notifications = T{
        sound = true,
        sound_file = 'ding.wav',
        flash = true,
        chatlog_echo = true,
    },
    history = T{
        max_lines = 500,
        load_recent = 100,
    },
    window = T{
        default_width = 350,
        default_height = 300,
    },
    theme_name = 'FFXI Gold',
    opacity = 0.92,
};

local config = settings.load(default_settings);

settings.register('settings', 'settings_update', function(s)
    config = s;
end);

-- Track whether history has been loaded for a conversation
local history_loaded = {};

-- Active theme (deep copy so edits don't mutate presets)
local active_theme = themes.copy(themes.presets[config.theme_name] or themes.presets['FFXI Gold']);

-- Apply opacity from settings
active_theme.window_bg[4] = config.opacity;

-- Config window state
local config_open = { false };

-- ImGui refs for settings (single-element tables that ImGui can modify)
local ui = {
    display_mode = { 0 },          -- 0 = floating, 1 = tabbed
    sound = { true },
    sound_index = { 0 },           -- index into sound file list
    flash = { true },
    chatlog_echo = { true },
    max_lines = { 500 },
    load_recent = { 100 },
    window_width = { 350 },
    window_height = { 300 },
    theme_index = { 0 },
    opacity = { 0.92 },
};

-- Sync UI refs from config
local function sync_ui_from_config()
    ui.display_mode[1] = (config.display_mode == 'tabbed') and 1 or 0;
    ui.sound[1] = config.notifications.sound;
    ui.sound_index[1] = notifications.get_sound_index(config.notifications.sound_file);
    ui.flash[1] = config.notifications.flash;
    ui.chatlog_echo[1] = config.notifications.chatlog_echo;
    ui.max_lines[1] = config.history.max_lines;
    ui.load_recent[1] = config.history.load_recent;
    ui.window_width[1] = config.window.default_width;
    ui.window_height[1] = config.window.default_height;
    ui.theme_index[1] = themes.get_preset_index(config.theme_name or 'FFXI Gold');
    ui.opacity[1] = config.opacity or 0.92;
end

sync_ui_from_config();

-- Render the config window. Returns true if settings changed.
local function render_config_window()
    if (not config_open[1]) then return false; end

    local changed = false;

    -- Apply theme to settings window too
    themes.apply(active_theme);

    imgui.SetNextWindowSize({ 360, 580 }, ImGuiCond_FirstUseEver);
    if (imgui.Begin('MogChat Settings###mogchat_config', config_open)) then

        -- Display Mode
        imgui.Text('Display Mode');
        imgui.SameLine();
        if (imgui.Combo('##display_mode', ui.display_mode, 'Floating\0Tabbed\0', 2)) then
            config.display_mode = (ui.display_mode[1] == 1) and 'tabbed' or 'floating';
            changed = true;
        end

        imgui.Separator();
        imgui.Text('Theme');

        local preset_str = themes.get_preset_combo_str();
        imgui.PushItemWidth(160);
        if (imgui.Combo('##theme', ui.theme_index, preset_str, #themes.preset_names)) then
            config.theme_name = themes.get_preset_name(ui.theme_index[1]);
            active_theme = themes.copy(themes.presets[config.theme_name]);
            active_theme.window_bg[4] = ui.opacity[1];
            changed = true;
        end
        imgui.PopItemWidth();

        imgui.PushItemWidth(160);
        if (imgui.SliderFloat('Opacity', ui.opacity, 0.3, 1.0, '%.2f')) then
            config.opacity = ui.opacity[1];
            active_theme.window_bg[4] = ui.opacity[1];
            changed = true;
        end
        imgui.PopItemWidth();

        -- Live preview panel
        imgui.Spacing();
        imgui.BeginChild('##theme_preview', { 0, 80 }, true);
        imgui.TextColored(active_theme.msg_timestamp, '[14:32]');
        imgui.SameLine();
        imgui.TextColored(active_theme.msg_incoming, 'Kupostein: Hey, are you free for Dynamis?');
        imgui.TextColored(active_theme.msg_timestamp, '[14:32]');
        imgui.SameLine();
        imgui.TextColored(active_theme.msg_outgoing, 'You: Sure, let me grab my gear!');
        imgui.TextColored(active_theme.msg_timestamp, '[14:33]');
        imgui.SameLine();
        imgui.TextColored(active_theme.msg_incoming, 'Kupostein: Great, meet at Whitegate');
        imgui.EndChild();

        imgui.Separator();
        imgui.Text('Notifications');

        if (imgui.Checkbox('Sound alert', ui.sound)) then
            config.notifications.sound = ui.sound[1];
            changed = true;
        end

        -- Sound picker (only show when sound is enabled)
        if (ui.sound[1]) then
            imgui.Indent(20);
            local sound_list = notifications.get_sound_list();
            local combo_str = notifications.get_sound_combo_str();
            imgui.PushItemWidth(160);
            if (imgui.Combo('##sound_file', ui.sound_index, combo_str, #sound_list)) then
                config.notifications.sound_file = notifications.get_sound_filename(ui.sound_index[1]);
                changed = true;
            end
            imgui.PopItemWidth();
            imgui.SameLine();
            if (imgui.Button('Preview##sound')) then
                notifications.play_sound_file(notifications.get_sound_filename(ui.sound_index[1]));
            end
            imgui.SameLine();
            if (imgui.Button('Rescan##sound')) then
                notifications.rescan_sounds();
                ui.sound_index[1] = notifications.get_sound_index(config.notifications.sound_file);
            end
            imgui.Unindent(20);
        end

        if (imgui.Checkbox('Window flash', ui.flash)) then
            config.notifications.flash = ui.flash[1];
            changed = true;
        end

        if (imgui.Checkbox('Show in chatlog', ui.chatlog_echo)) then
            config.notifications.chatlog_echo = ui.chatlog_echo[1];
            changed = true;
        end

        imgui.Separator();
        imgui.Text('History');

        imgui.PushItemWidth(120);
        if (imgui.InputInt('Max lines stored', ui.max_lines)) then
            if (ui.max_lines[1] < 10) then ui.max_lines[1] = 10; end
            if (ui.max_lines[1] > 10000) then ui.max_lines[1] = 10000; end
            config.history.max_lines = ui.max_lines[1];
            changed = true;
        end

        if (imgui.InputInt('Lines to load', ui.load_recent)) then
            if (ui.load_recent[1] < 10) then ui.load_recent[1] = 10; end
            if (ui.load_recent[1] > 1000) then ui.load_recent[1] = 1000; end
            config.history.load_recent = ui.load_recent[1];
            changed = true;
        end
        imgui.PopItemWidth();

        imgui.Separator();
        imgui.Text('Window Defaults');

        imgui.PushItemWidth(120);
        if (imgui.InputInt('Width', ui.window_width)) then
            if (ui.window_width[1] < 200) then ui.window_width[1] = 200; end
            if (ui.window_width[1] > 800) then ui.window_width[1] = 800; end
            config.window.default_width = ui.window_width[1];
            changed = true;
        end

        if (imgui.InputInt('Height', ui.window_height)) then
            if (ui.window_height[1] < 150) then ui.window_height[1] = 150; end
            if (ui.window_height[1] > 800) then ui.window_height[1] = 800; end
            config.window.default_height = ui.window_height[1];
            changed = true;
        end
        imgui.PopItemWidth();

    end
    imgui.End();

    themes.remove();

    return changed;
end

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    if (#args == 0 or args[1] ~= '/mogchat') then
        return;
    end

    e.blocked = true;

    if (#args == 1) then
        config_open[1] = not config_open[1];
        if (config_open[1]) then
            sync_ui_from_config();
        end
        return;
    end

    local cmd = args[2]:lower();

    if (cmd == 'mode') then
        if (#args >= 3) then
            local mode = args[3]:lower();
            if (mode == 'floating' or mode == 'tabbed') then
                config.display_mode = mode;
                settings.save();
                print(chat.header('MogChat') .. chat.message('Display mode: ' .. mode));
            end
        end
    elseif (cmd == 'sound') then
        if (#args >= 3) then
            config.notifications.sound = (args[3]:lower() == 'on');
            settings.save();
            print(chat.header('MogChat') .. chat.message('Sound: ' .. tostring(config.notifications.sound)));
        end
    elseif (cmd == 'flash') then
        if (#args >= 3) then
            config.notifications.flash = (args[3]:lower() == 'on');
            settings.save();
            print(chat.header('MogChat') .. chat.message('Flash: ' .. tostring(config.notifications.flash)));
        end
    elseif (cmd == 'echo') then
        if (#args >= 3) then
            config.notifications.chatlog_echo = (args[3]:lower() == 'on');
            settings.save();
            print(chat.header('MogChat') .. chat.message('Chatlog echo: ' .. tostring(config.notifications.chatlog_echo)));
        end
    elseif (cmd == 'clear') then
        if (#args >= 3) then
            local name = args[3];
            conversations.clear(name);
            history_lib.delete(name);
            print(chat.header('MogChat') .. chat.message('Cleared history for ' .. name));
        end
    elseif (cmd == 'clearall') then
        conversations.clear_all();
        history_lib.delete_all();
        history_loaded = {};
        print(chat.header('MogChat') .. chat.message('All history cleared'));
    elseif (cmd == 'close') then
        conversations.close_all();
        print(chat.header('MogChat') .. chat.message('All windows closed'));
    elseif (cmd == 'help') then
        print(chat.header('MogChat') .. chat.message('/mogchat mode [floating|tabbed]'));
        print(chat.header('MogChat') .. chat.message('/mogchat sound [on|off]'));
        print(chat.header('MogChat') .. chat.message('/mogchat flash [on|off]'));
        print(chat.header('MogChat') .. chat.message('/mogchat echo [on|off]'));
        print(chat.header('MogChat') .. chat.message('/mogchat clear <name>'));
        print(chat.header('MogChat') .. chat.message('/mogchat clearall'));
        print(chat.header('MogChat') .. chat.message('/mogchat close'));
    end
end);

-- Handle incoming tells
ashita.events.register('packet_in', 'mogchat_packet_in_cb', function(e)
    local tell = packets.parse_incoming_tell(e);
    if (not tell) then return; end

    -- Load history on first message from this person
    local key = tell.sender:lower();
    if (not history_loaded[key]) then
        local msgs = history_lib.load(tell.sender, config.history.load_recent);
        if (#msgs > 0) then
            conversations.load_history(tell.sender, msgs);
        end
        history_loaded[key] = true;
    end

    -- Add message and trigger notifications
    local convo = conversations.add_message(tell.sender, tell.message, 'in');
    notifications.on_incoming_tell(convo, config);

    -- Save history
    history_lib.save(tell.sender, convo.messages, config.history.max_lines);

    -- Block chatlog display if echo is off
    if (notifications.should_block_chatlog(config)) then
        e.blocked = true;
    end
end);

-- Capture outgoing tells
ashita.events.register('command', 'mogchat_outgoing_cb', function(e)
    local tell = packets.parse_outgoing_tell(e.command);
    if (not tell) then return; end

    -- Load history on first message to this person
    local key = tell.target:lower();
    if (not history_loaded[key]) then
        local msgs = history_lib.load(tell.target, config.history.load_recent);
        if (#msgs > 0) then
            conversations.load_history(tell.target, msgs);
        end
        history_loaded[key] = true;
    end

    -- Add message to conversation
    local convo = conversations.add_message(tell.target, tell.message, 'out');

    -- Save history
    history_lib.save(tell.target, convo.messages, config.history.max_lines);
end);

ashita.events.register('d3d_present', 'mogchat_render_cb', function()
    -- Render config window (unthemed so it uses default ImGui style)
    if (render_config_window()) then
        settings.save();
    end

    -- Apply theme to conversation windows
    windows.set_msg_colors(active_theme);
    themes.apply(active_theme);

    -- Render conversation windows
    local to_send;

    if (config.display_mode == 'tabbed') then
        to_send = windows.render_tabbed(conversations, config);
    else
        to_send = windows.render_floating(conversations, config);
    end

    -- Remove theme
    themes.remove();

    -- Send any tells from input boxes
    for _, item in ipairs(to_send) do
        local cmd = ('/tell %s %s'):fmt(item.name, item.message);
        AshitaCore:GetChatManager():QueueCommand(1, cmd);
    end
end);

-- Save history on zone change
ashita.events.register('packet_in', 'mogchat_zone_cb', function(e)
    if (e.id == 0x000A) then
        history_lib.save_all(conversations.get_all(), config.history.max_lines);
    end
end);

-- Save everything on unload
ashita.events.register('unload', 'mogchat_unload_cb', function()
    history_lib.save_all(conversations.get_all(), config.history.max_lines);
    settings.save();
end);
