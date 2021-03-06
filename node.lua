gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

local loader = require "loader"
local font = resource.load_font('Roboto-Medium.ttf')
local active_module = 'slideshow'
local current_track = ''
local current_track_width = 0
local current_track_x = 20
local current_track_y = 20
local current_track_size = 25

local track_overlay = resource.create_colored_texture(0, 0, 0, 1)
local track_overlay_alpha = 0.5
local track_overlay_padding = 10

local clock_str = '00:00'
local clock_overlay = resource.create_colored_texture(0, 0, 0, 1)
local note = resource.load_image('note.png', true)
local note_w, note_h = note:size()

-- Listen for external triggers
util.data_mapper {
    swap = function(module)
        active_module = module
    end;
    clock = function(time_str)
        clock_str = time_str
    end;
}

util.json_watch('config.json', function(config)
    current_track = config.playing
    current_track_width = font:width(current_track, current_track_size)
    current_track_x = config.trackx
    current_track_y = config.tracky
    current_track_size = config.fontsize
    track_overlay_alpha = config.alpha
    -- font = resource.load_font(config.trackfont)
    -- current_track_x = NATIVE_WIDTH / 2 - current_track_width / 2
end)

local function draw_track()
    local img_scale_factor = note_h / current_track_size
    local img_scaled_w = 22.5 -- note_w / img_scale_factor

    local p = track_overlay_padding
    local overlay_x1, overlay_y1 = current_track_x - p, current_track_y - p
    local overlay_x2 = current_track_x + img_scaled_w + p + current_track_width + p
    local overlay_y2 = current_track_y + current_track_size + p

    local overlay2_x1, overlay2_y1 = NATIVE_WIDTH - p - 100, current_track_y - p
    local overlay2_x2 = NATIVE_WIDTH - p
    local overlay2_y2 = current_track_y + current_track_size + p

    -- Draw clock
    -- clock_overlay:draw(overlay2_x1, overlay2_y1, overlay2_x2, overlay2_y2, track_overlay_alpha)
    -- clock_width = font:width(clock_str, current_track_size)
    -- font:write(NATIVE_WIDTH - clock_width, current_track_y, clock_str, current_track_size, 1, 1, 1, 0.9)

    -- Draw overlay
    track_overlay:draw(overlay_x1, overlay_y1, overlay_x2, overlay_y2, track_overlay_alpha)
    -- Draw note
    note:draw(current_track_x, current_track_y, current_track_x + img_scaled_w, current_track_y + current_track_size, 0.9)
    -- Draw track
    font:write(current_track_x + img_scaled_w + p, current_track_y, current_track, current_track_size, 1, 1, 1, 0.9)
end

local function isempty(s)
    return s == nil or s == ''
end

function node.render()
    gl.clear(0, 0, 0, 1)
    for name, module in pairs(loader.modules) do
        if name == active_module then
            module.draw()
        else
            module.unload()
        end
    end
    if current_track ~= '' then
        draw_track()
    end
end
