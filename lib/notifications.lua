local chat = require('chat');

local notifications = {};

-- Cached sound file list
local sound_files = nil;
local sound_labels = nil;

-- Scan the sounds directory for .wav files
-- Returns ordered table of filenames
function notifications.get_sound_list()
    if (sound_files) then return sound_files; end

    sound_files = {};
    sound_labels = {};

    T(ashita.fs.get_dir(addon.path:append('\\sounds\\'), '.*.wav', true)):each(function(v)
        if (v and #v > 0) then
            table.insert(sound_files, v);
        end
    end);

    table.sort(sound_files);
    for _, f in ipairs(sound_files) do
        local label = f:gsub('%.wav$', '');
        table.insert(sound_labels, label);
    end

    return sound_files;
end

-- Build ImGui combo string from sound list
function notifications.get_sound_combo_str()
    notifications.get_sound_list();
    if (#sound_labels == 0) then return 'No sounds found\0'; end
    return table.concat(sound_labels, '\0') .. '\0';
end

-- Get the index of a filename in the sound list (0-based for ImGui)
function notifications.get_sound_index(filename)
    local files = notifications.get_sound_list();
    for i, f in ipairs(files) do
        if (f == filename) then
            return i - 1;
        end
    end
    return 0;
end

-- Get filename from a 0-based index
function notifications.get_sound_filename(index)
    local files = notifications.get_sound_list();
    if (files[index + 1]) then
        return files[index + 1];
    end
    return files[1] or 'tell.wav';
end

-- Force rescan (if user adds new files)
function notifications.rescan_sounds()
    sound_files = nil;
    sound_labels = nil;
end

-- Play a specific sound file by name
function notifications.play_sound_file(filename)
    local sound_path = ('%ssounds\\%s'):fmt(addon.path, filename);
    if (ashita.fs.exists(sound_path)) then
        ashita.misc.play_sound(sound_path);
    end
end

-- Play notification sound
function notifications.play_sound(config)
    if (not config.notifications.sound) then return; end
    notifications.play_sound_file(config.notifications.sound_file);
end

-- Check if we should block the default chatlog tell
function notifications.should_block_chatlog(config)
    return (not config.notifications.chatlog_echo);
end

-- Trigger all notifications for an incoming tell
function notifications.on_incoming_tell(convo, config)
    notifications.play_sound(config);
    -- Flash is handled via convo.flash_until set in conversations.add_message
end

return notifications;
