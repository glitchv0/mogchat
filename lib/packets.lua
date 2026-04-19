local encoding = require('lib/encoding');

local packets = {};

-- Decode an FFXI message: expand auto-translate codes, normalize FFXI bracket
-- bytes (0xEF 0x27 / 0xEF 0x28) to ASCII so they survive SJIS->UTF-8, then
-- convert to UTF-8 for imgui.
local function decode_message(msg)
    if (not msg or #msg == 0) then return msg; end
    msg = AshitaCore:GetChatManager():ParseAutoTranslate(msg, true);
    msg = msg:strip_translate(true);
    msg = msg:strip_colors();
    msg = encoding.sjis_to_utf8(msg);
    return msg;
end

-- Parse incoming tell from packet 0x0017
-- Returns { sender = string, message = string } or nil
function packets.parse_incoming_tell(e)
    if (e.id ~= 0x0017) then
        return nil;
    end

    local mode = struct.unpack('b', e.data_modified, 0x04 + 0x01);
    if (mode ~= 0x03) then
        return nil;
    end

    local sender = struct.unpack('c15', e.data_modified, 0x08 + 0x01);
    sender = sender:trimend('\0');

    local message, _ = struct.unpack('s', e.data_modified, 0x17 + 0x01);

    if (sender and #sender > 0 and message) then
        return { sender = sender, message = decode_message(message) };
    end

    return nil;
end

-- Parse outgoing tell from text command
-- Input: command string like "/tell PlayerName Hello there"
-- Returns { target = string, message = string } or nil
function packets.parse_outgoing_tell(command)
    local args = command:args();
    if (#args < 3) then
        return nil;
    end

    if (args[1]:lower() ~= '/tell' and args[1]:lower() ~= '/t') then
        return nil;
    end

    local target = args[2];
    -- Pull message from raw command: auto-translate bytes can contain 0x20
    -- which command:args() would split on.
    local _, msg_start = command:find('^%s*%S+%s+%S+%s+');
    local message = msg_start and command:sub(msg_start + 1) or '';

    return { target = target, message = decode_message(message) };
end

return packets;
