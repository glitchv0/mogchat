local ffi = require('ffi');
ffi.cdef[[
    int MultiByteToWideChar(uint32_t CodePage, uint32_t dwFlags, char* lpMultiByteStr, int cbMultiByte, wchar_t* lpMultiByteStr, int32_t cchWideChar);
    int WideCharToMultiByte(uint32_t CodePage, uint32_t dwFlags, wchar_t* lpWideCharStr, int32_t cchWideChar, char* lpMultiByteStr, int32_t cbMultiByte, const char* lpDefaultChar, bool* lpUsedDefaultChar);
]]

local exports = {};

local code_page = {
    utf8 = 65001,
    shiftjis = 932,
};

local cache = {};

local function convert(input, from, to)
    input = tostring(input or '');
    if #input == 0 then return input; end

    local key = input .. '|' .. from .. '>' .. to;
    local hit = cache[key];
    if hit ~= nil then return hit; end

    local cbuffer = ffi.new('char[?]', #input + 1);
    ffi.copy(cbuffer, input);

    local wlen = ffi.C.MultiByteToWideChar(from, 0, cbuffer, -1, nil, 0);
    local wbuffer = ffi.new('wchar_t[?]', wlen);
    ffi.C.MultiByteToWideChar(from, 0, cbuffer, -1, wbuffer, wlen);

    local clen = ffi.C.WideCharToMultiByte(to, 0, wbuffer, -1, nil, 0, nil, nil);
    cbuffer = ffi.new('char[?]', clen);
    ffi.C.WideCharToMultiByte(to, 0, wbuffer, -1, cbuffer, clen, nil, nil);

    local result = ffi.string(cbuffer);
    cache[key] = result;
    return result;
end

function exports.sjis_to_utf8(input)
    return convert(input, code_page.shiftjis, code_page.utf8);
end

function exports.utf8_to_sjis(input)
    return convert(input, code_page.utf8, code_page.shiftjis);
end

return exports;
