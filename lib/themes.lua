local imgui = require('imgui');

local themes = {};

-- Number of style colors and vars we push (MUST match apply/remove)
themes.color_count = 22;
themes.var_count = 7;

---------------------------------------------------------------------------
-- Built-in presets
---------------------------------------------------------------------------
themes.presets = {
    ['FFXI Gold'] = {
        window_bg       = { 0.05, 0.05, 0.05, 0.92 },
        title_bg        = { 0.12, 0.10, 0.06, 1.0 },
        title_bg_active = { 0.20, 0.16, 0.08, 1.0 },
        border          = { 0.40, 0.33, 0.15, 0.50 },
        text            = { 0.96, 0.86, 0.59, 1.0 },
        text_disabled   = { 0.50, 0.45, 0.30, 1.0 },
        frame_bg        = { 0.10, 0.09, 0.06, 1.0 },
        frame_bg_hover  = { 0.15, 0.13, 0.08, 1.0 },
        frame_bg_active = { 0.20, 0.17, 0.10, 1.0 },
        button          = { 0.18, 0.15, 0.08, 1.0 },
        button_hover    = { 0.25, 0.21, 0.10, 1.0 },
        button_active   = { 0.30, 0.25, 0.12, 1.0 },
        header          = { 0.18, 0.15, 0.08, 1.0 },
        header_hover    = { 0.25, 0.21, 0.10, 1.0 },
        header_active   = { 0.30, 0.25, 0.12, 1.0 },
        tab             = { 0.12, 0.10, 0.06, 1.0 },
        tab_active      = { 0.22, 0.18, 0.10, 1.0 },
        tab_hover       = { 0.28, 0.23, 0.12, 1.0 },
        scrollbar_bg    = { 0.05, 0.05, 0.05, 0.50 },
        scrollbar_grab  = { 0.30, 0.25, 0.12, 1.0 },
        popup_bg        = { 0.08, 0.07, 0.05, 0.96 },
        check_mark      = { 0.96, 0.86, 0.59, 1.0 },
        window_rounding = 6.0,
        frame_rounding  = 4.0,
        grab_rounding   = 4.0,
        tab_rounding    = 4.0,
        window_padding  = { 10, 10 },
        frame_padding   = { 6, 4 },
        item_spacing    = { 8, 5 },
        -- Message colors
        msg_incoming    = { 0.96, 0.86, 0.59, 1.0 },
        msg_outgoing    = { 0.70, 0.82, 0.96, 1.0 },
        msg_timestamp   = { 0.50, 0.45, 0.30, 1.0 },
    },

    ['Dark Blue'] = {
        window_bg       = { 0.04, 0.06, 0.12, 0.94 },
        title_bg        = { 0.06, 0.08, 0.16, 1.0 },
        title_bg_active = { 0.08, 0.12, 0.24, 1.0 },
        border          = { 0.15, 0.25, 0.50, 0.50 },
        text            = { 0.85, 0.90, 0.98, 1.0 },
        text_disabled   = { 0.40, 0.45, 0.55, 1.0 },
        frame_bg        = { 0.06, 0.08, 0.16, 1.0 },
        frame_bg_hover  = { 0.08, 0.12, 0.24, 1.0 },
        frame_bg_active = { 0.10, 0.15, 0.30, 1.0 },
        button          = { 0.10, 0.15, 0.30, 1.0 },
        button_hover    = { 0.15, 0.22, 0.40, 1.0 },
        button_active   = { 0.20, 0.30, 0.50, 1.0 },
        header          = { 0.10, 0.15, 0.30, 1.0 },
        header_hover    = { 0.15, 0.22, 0.40, 1.0 },
        header_active   = { 0.20, 0.30, 0.50, 1.0 },
        tab             = { 0.06, 0.08, 0.16, 1.0 },
        tab_active      = { 0.12, 0.18, 0.35, 1.0 },
        tab_hover       = { 0.18, 0.25, 0.45, 1.0 },
        scrollbar_bg    = { 0.04, 0.06, 0.12, 0.50 },
        scrollbar_grab  = { 0.15, 0.25, 0.50, 1.0 },
        popup_bg        = { 0.05, 0.07, 0.14, 0.96 },
        check_mark      = { 0.30, 0.60, 1.00, 1.0 },
        window_rounding = 6.0,
        frame_rounding  = 4.0,
        grab_rounding   = 4.0,
        tab_rounding    = 4.0,
        window_padding  = { 10, 10 },
        frame_padding   = { 6, 4 },
        item_spacing    = { 8, 5 },
        msg_incoming    = { 0.85, 0.90, 0.98, 1.0 },
        msg_outgoing    = { 0.40, 0.75, 1.00, 1.0 },
        msg_timestamp   = { 0.35, 0.40, 0.55, 1.0 },
    },

    ['Mog Green'] = {
        window_bg       = { 0.04, 0.08, 0.04, 0.92 },
        title_bg        = { 0.06, 0.12, 0.06, 1.0 },
        title_bg_active = { 0.10, 0.20, 0.10, 1.0 },
        border          = { 0.20, 0.45, 0.20, 0.50 },
        text            = { 0.82, 0.95, 0.82, 1.0 },
        text_disabled   = { 0.40, 0.55, 0.40, 1.0 },
        frame_bg        = { 0.06, 0.12, 0.06, 1.0 },
        frame_bg_hover  = { 0.08, 0.18, 0.08, 1.0 },
        frame_bg_active = { 0.10, 0.22, 0.10, 1.0 },
        button          = { 0.10, 0.22, 0.10, 1.0 },
        button_hover    = { 0.15, 0.30, 0.15, 1.0 },
        button_active   = { 0.20, 0.38, 0.20, 1.0 },
        header          = { 0.10, 0.22, 0.10, 1.0 },
        header_hover    = { 0.15, 0.30, 0.15, 1.0 },
        header_active   = { 0.20, 0.38, 0.20, 1.0 },
        tab             = { 0.06, 0.12, 0.06, 1.0 },
        tab_active      = { 0.12, 0.25, 0.12, 1.0 },
        tab_hover       = { 0.18, 0.32, 0.18, 1.0 },
        scrollbar_bg    = { 0.04, 0.08, 0.04, 0.50 },
        scrollbar_grab  = { 0.20, 0.40, 0.20, 1.0 },
        popup_bg        = { 0.05, 0.10, 0.05, 0.96 },
        check_mark      = { 0.40, 0.90, 0.40, 1.0 },
        window_rounding = 6.0,
        frame_rounding  = 4.0,
        grab_rounding   = 4.0,
        tab_rounding    = 4.0,
        window_padding  = { 10, 10 },
        frame_padding   = { 6, 4 },
        item_spacing    = { 8, 5 },
        msg_incoming    = { 0.82, 0.95, 0.82, 1.0 },
        msg_outgoing    = { 0.55, 0.85, 1.00, 1.0 },
        msg_timestamp   = { 0.40, 0.55, 0.40, 1.0 },
    },

    ['Clean Light'] = {
        window_bg       = { 0.94, 0.94, 0.94, 0.96 },
        title_bg        = { 0.80, 0.80, 0.82, 1.0 },
        title_bg_active = { 0.65, 0.65, 0.70, 1.0 },
        border          = { 0.60, 0.60, 0.65, 0.50 },
        text            = { 0.10, 0.10, 0.10, 1.0 },
        text_disabled   = { 0.50, 0.50, 0.50, 1.0 },
        frame_bg        = { 0.86, 0.86, 0.88, 1.0 },
        frame_bg_hover  = { 0.78, 0.78, 0.82, 1.0 },
        frame_bg_active = { 0.70, 0.70, 0.76, 1.0 },
        button          = { 0.75, 0.75, 0.80, 1.0 },
        button_hover    = { 0.65, 0.65, 0.72, 1.0 },
        button_active   = { 0.55, 0.55, 0.65, 1.0 },
        header          = { 0.75, 0.75, 0.80, 1.0 },
        header_hover    = { 0.65, 0.65, 0.72, 1.0 },
        header_active   = { 0.55, 0.55, 0.65, 1.0 },
        tab             = { 0.80, 0.80, 0.82, 1.0 },
        tab_active      = { 0.94, 0.94, 0.94, 1.0 },
        tab_hover       = { 0.88, 0.88, 0.90, 1.0 },
        scrollbar_bg    = { 0.90, 0.90, 0.90, 0.50 },
        scrollbar_grab  = { 0.65, 0.65, 0.70, 1.0 },
        popup_bg        = { 0.92, 0.92, 0.93, 0.98 },
        check_mark      = { 0.20, 0.45, 0.80, 1.0 },
        window_rounding = 8.0,
        frame_rounding  = 5.0,
        grab_rounding   = 5.0,
        tab_rounding    = 5.0,
        window_padding  = { 12, 12 },
        frame_padding   = { 8, 5 },
        item_spacing    = { 8, 6 },
        msg_incoming    = { 0.10, 0.10, 0.10, 1.0 },
        msg_outgoing    = { 0.15, 0.40, 0.75, 1.0 },
        msg_timestamp   = { 0.45, 0.45, 0.50, 1.0 },
    },

    ['Dark Mode'] = {
        window_bg       = { 0.08, 0.08, 0.08, 0.95 },
        title_bg        = { 0.10, 0.10, 0.10, 1.0 },
        title_bg_active = { 0.18, 0.18, 0.18, 1.0 },
        border          = { 0.25, 0.25, 0.25, 0.40 },
        text            = { 0.90, 0.90, 0.90, 1.0 },
        text_disabled   = { 0.45, 0.45, 0.45, 1.0 },
        frame_bg        = { 0.12, 0.12, 0.12, 1.0 },
        frame_bg_hover  = { 0.18, 0.18, 0.18, 1.0 },
        frame_bg_active = { 0.22, 0.22, 0.22, 1.0 },
        button          = { 0.16, 0.16, 0.16, 1.0 },
        button_hover    = { 0.22, 0.22, 0.22, 1.0 },
        button_active   = { 0.28, 0.28, 0.28, 1.0 },
        header          = { 0.16, 0.16, 0.16, 1.0 },
        header_hover    = { 0.22, 0.22, 0.22, 1.0 },
        header_active   = { 0.28, 0.28, 0.28, 1.0 },
        tab             = { 0.10, 0.10, 0.10, 1.0 },
        tab_active      = { 0.20, 0.20, 0.20, 1.0 },
        tab_hover       = { 0.25, 0.25, 0.25, 1.0 },
        scrollbar_bg    = { 0.06, 0.06, 0.06, 0.50 },
        scrollbar_grab  = { 0.30, 0.30, 0.30, 1.0 },
        popup_bg        = { 0.10, 0.10, 0.10, 0.96 },
        check_mark      = { 0.75, 0.75, 0.75, 1.0 },
        window_rounding = 4.0,
        frame_rounding  = 3.0,
        grab_rounding   = 3.0,
        tab_rounding    = 3.0,
        window_padding  = { 10, 10 },
        frame_padding   = { 6, 4 },
        item_spacing    = { 8, 5 },
        msg_incoming    = { 0.90, 0.90, 0.90, 1.0 },
        msg_outgoing    = { 0.55, 0.75, 0.95, 1.0 },
        msg_timestamp   = { 0.42, 0.42, 0.42, 1.0 },
    },

    ['Default'] = {
        window_bg       = { 0.06, 0.06, 0.06, 0.94 },
        title_bg        = { 0.04, 0.04, 0.04, 1.0 },
        title_bg_active = { 0.16, 0.16, 0.16, 1.0 },
        border          = { 0.43, 0.43, 0.50, 0.50 },
        text            = { 1.00, 1.00, 1.00, 1.0 },
        text_disabled   = { 0.50, 0.50, 0.50, 1.0 },
        frame_bg        = { 0.16, 0.16, 0.16, 1.0 },
        frame_bg_hover  = { 0.24, 0.24, 0.24, 1.0 },
        frame_bg_active = { 0.30, 0.30, 0.30, 1.0 },
        button          = { 0.20, 0.20, 0.20, 1.0 },
        button_hover    = { 0.28, 0.28, 0.28, 1.0 },
        button_active   = { 0.35, 0.35, 0.35, 1.0 },
        header          = { 0.20, 0.20, 0.20, 1.0 },
        header_hover    = { 0.28, 0.28, 0.28, 1.0 },
        header_active   = { 0.35, 0.35, 0.35, 1.0 },
        tab             = { 0.10, 0.10, 0.10, 1.0 },
        tab_active      = { 0.20, 0.20, 0.20, 1.0 },
        tab_hover       = { 0.28, 0.28, 0.28, 1.0 },
        scrollbar_bg    = { 0.06, 0.06, 0.06, 0.50 },
        scrollbar_grab  = { 0.30, 0.30, 0.30, 1.0 },
        popup_bg        = { 0.08, 0.08, 0.08, 0.96 },
        check_mark      = { 0.90, 0.90, 0.90, 1.0 },
        window_rounding = 4.0,
        frame_rounding  = 3.0,
        grab_rounding   = 3.0,
        tab_rounding    = 3.0,
        window_padding  = { 8, 8 },
        frame_padding   = { 5, 3 },
        item_spacing    = { 8, 4 },
        msg_incoming    = { 1.00, 1.00, 1.00, 1.0 },
        msg_outgoing    = { 0.60, 0.80, 1.00, 1.0 },
        msg_timestamp   = { 0.50, 0.50, 0.50, 1.0 },
    },
};

-- Ordered list for combo box
themes.preset_names = { 'FFXI Gold', 'Dark Blue', 'Dark Mode', 'Mog Green', 'Clean Light', 'Default' };

---------------------------------------------------------------------------
-- Build combo string
---------------------------------------------------------------------------
function themes.get_preset_combo_str()
    return table.concat(themes.preset_names, '\0') .. '\0';
end

function themes.get_preset_index(name)
    for i, n in ipairs(themes.preset_names) do
        if (n == name) then return i - 1; end
    end
    return 0;
end

function themes.get_preset_name(index)
    return themes.preset_names[index + 1] or 'FFXI Gold';
end

---------------------------------------------------------------------------
-- Deep copy a theme table so user edits don't mutate presets
---------------------------------------------------------------------------
function themes.copy(src)
    local dst = {};
    for k, v in pairs(src) do
        if (type(v) == 'table') then
            dst[k] = {};
            for i, c in ipairs(v) do dst[k][i] = c; end
        else
            dst[k] = v;
        end
    end
    return dst;
end

---------------------------------------------------------------------------
-- Apply theme: push all style colors and vars
-- Call before imgui.Begin for MogChat windows
---------------------------------------------------------------------------
function themes.apply(t)
    imgui.PushStyleColor(ImGuiCol_WindowBg,        t.window_bg);
    imgui.PushStyleColor(ImGuiCol_TitleBg,         t.title_bg);
    imgui.PushStyleColor(ImGuiCol_TitleBgActive,   t.title_bg_active);
    imgui.PushStyleColor(ImGuiCol_Border,          t.border);
    imgui.PushStyleColor(ImGuiCol_Text,            t.text);
    imgui.PushStyleColor(ImGuiCol_TextDisabled,    t.text_disabled);
    imgui.PushStyleColor(ImGuiCol_FrameBg,         t.frame_bg);
    imgui.PushStyleColor(ImGuiCol_FrameBgHovered,  t.frame_bg_hover);
    imgui.PushStyleColor(ImGuiCol_FrameBgActive,   t.frame_bg_active);
    imgui.PushStyleColor(ImGuiCol_Button,          t.button);
    imgui.PushStyleColor(ImGuiCol_ButtonHovered,   t.button_hover);
    imgui.PushStyleColor(ImGuiCol_ButtonActive,    t.button_active);
    imgui.PushStyleColor(ImGuiCol_Header,          t.header);
    imgui.PushStyleColor(ImGuiCol_HeaderHovered,   t.header_hover);
    imgui.PushStyleColor(ImGuiCol_HeaderActive,    t.header_active);
    imgui.PushStyleColor(ImGuiCol_Tab,             t.tab);
    imgui.PushStyleColor(ImGuiCol_TabActive,       t.tab_active);
    imgui.PushStyleColor(ImGuiCol_TabHovered,      t.tab_hover);
    imgui.PushStyleColor(ImGuiCol_ScrollbarBg,     t.scrollbar_bg);
    imgui.PushStyleColor(ImGuiCol_ScrollbarGrab,   t.scrollbar_grab);
    imgui.PushStyleColor(ImGuiCol_PopupBg,         t.popup_bg);
    imgui.PushStyleColor(ImGuiCol_CheckMark,       t.check_mark);

    imgui.PushStyleVar(ImGuiStyleVar_WindowRounding, t.window_rounding);
    imgui.PushStyleVar(ImGuiStyleVar_FrameRounding,  t.frame_rounding);
    imgui.PushStyleVar(ImGuiStyleVar_GrabRounding,   t.grab_rounding);
    imgui.PushStyleVar(ImGuiStyleVar_TabRounding,    t.tab_rounding);
    imgui.PushStyleVar(ImGuiStyleVar_WindowPadding,  t.window_padding);
    imgui.PushStyleVar(ImGuiStyleVar_FramePadding,   t.frame_padding);
    imgui.PushStyleVar(ImGuiStyleVar_ItemSpacing,    t.item_spacing);
end

---------------------------------------------------------------------------
-- Remove theme: pop all pushed styles
-- Call after imgui.End for MogChat windows
---------------------------------------------------------------------------
function themes.remove()
    imgui.PopStyleVar(themes.var_count);
    imgui.PopStyleColor(themes.color_count);
end

---------------------------------------------------------------------------
-- Get message colors from theme
---------------------------------------------------------------------------
function themes.get_msg_colors(t)
    return t.msg_incoming, t.msg_outgoing, t.msg_timestamp;
end

return themes;
