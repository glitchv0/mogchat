local packets = {};

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
        return { sender = sender, message = message };
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
    -- Reconstruct message from remaining args
    local parts = {};
    for i = 3, #args do
        table.insert(parts, args[i]);
    end
    local message = table.concat(parts, ' ');

    return { target = target, message = message };
end

return packets;
