util.init_hosted()

local json = require "json"
local events = {}
local rotate_before = nil
local transform = nil

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.file_watch("events.json", function(content)
    events = json.decode(content)
end)

local white = resource.create_colored_texture(1,1,1,1)
local base_time = N.base_time or 0

util.data_mapper{
    ["time"] = function(time)
        base_time = tonumber(time) - sys.now()
        N.base_time = base_time
    end;
}

local function unixnow()
    return base_time + sys.now()
end

local colored = resource.create_shader[[
    uniform vec4 color;
    void main() {
        gl_FragColor = color;
    }
]]

local fadeout = 5
local categories = {}
categories["high_speed_rail"] = resource.load_image("high_speed_rail.png")
categories["low_speed_rail"] = resource.load_image("low_speed_rail.png")
categories["s_bahn"] = resource.load_image("s_bahn.png")
categories["u_bahn"] = resource.load_image("u_bahn.png")
categories["tram"] = resource.load_image("tram.png")
categories["bus"] = resource.load_image("bus.png")

local function draw(real_width, real_height)
    CONFIG.background_color.clear()
    local now = unixnow()
    local y = 0
    local now_for_fade = now + (CONFIG.offset * 60)

    local line_height = CONFIG.line_height
    local margin_bottom = CONFIG.line_height * 0.2

    for idx, dep in ipairs(events) do
        if dep.timestamp > now_for_fade - fadeout then
            if now_for_fade > dep.timestamp then
                y = (y - line_height - margin_bottom) / fadeout * (now_for_fade - dep.timestamp)
            end
        end
    end

    for idx, dep in ipairs(events) do
        if dep.timestamp > now_for_fade - fadeout then
            if y < 0 and dep.timestamp >= now_for_fade then
                y = 0
            end

            local time = dep.time

            local remaining = math.floor((dep.timestamp - now) / 60)
            local append = ""
            local platform = ""
            local x = 0

            if remaining < 0 then
                time = "In der Vergangenheit"
                if dep.next_timestamp > 10 then
                    append = string.format("und in %d min", math.floor((dep.next_timestamp - now)/60))
                end
            elseif remaining < 1 then
                if now % 2 < 1 then
                    time = "*jetzt"
                else
                    time = "jetzt*"
                end
                if dep.next_timestamp > 10 then
                    append = string.format("und in %d min", math.floor((dep.next_timestamp - now)/60))
                end
            elseif remaining < 11 then
                time = string.format("in %d min", ((dep.timestamp - now)/60))
                if dep.next_timestamp > 10 then
                    append = "und wieder " .. math.floor((dep.next_timestamp - dep.timestamp)/60) .. " min später"
                end
            else
                time = time -- .. " +" .. remaining
                if dep.next_time and dep.next_timestamp > 10 then
                    append = "und wieder " .. dep.next_time
                end
            end

            if string.match(CONFIG.stop_ids, ',') then
                platform = "von " .. dep.stop
                if dep.platform ~= "" then
                    platform = platform .. ", " .. dep.platform
                end
            else
                if dep.platform ~= "" then
                    platform = "von " .. dep.platform
                end
            end
            if remaining < 11 then
                icon_size = line_height * 0.66
                text_upper_size = line_height * 0.5
                text_lower_size = line_height * 0.3
                symbol_height = text_upper_size + text_lower_size + margin_bottom

                if CONFIG.show_vehicle_type then
                    if categories[dep.icon] then
                        icon_y = y + ( symbol_height - icon_size ) / 2
                        categories[dep.icon]:draw(
                            0, icon_y,
                            icon_size, icon_y+icon_size
                        )
                    end
                    x = icon_size + 20
                end

                colored:use{color = {
                    dep.background_colour.r,
                    dep.background_colour.g,
                    dep.background_colour.b,
                    1,
                }}
                white:draw(
                    x, y,
                    x + 150, y + symbol_height
                )
                colored:deactivate()

                local symbol_width = CONFIG.font:width(dep.symbol, icon_size)
                if symbol_width < 150 then
                    symbol_margin_top = (symbol_height - icon_size) / 2
                    CONFIG.font:write(
                        x + 75 - symbol_width/2,
                        y + symbol_margin_top,
                        dep.symbol,
                        icon_size,
                        dep.font_colour.r, dep.font_colour.g, dep.font_colour.b, 1
                    )
                else
                    size = icon_size
                    while CONFIG.font:width(dep.symbol, size) > 145 do
                        size = size - 2
                    end
                    symbol_margin_top = (symbol_height - size) / 2
                    symbol_width = CONFIG.font:width(dep.symbol, size)
                    CONFIG.font:write(
                        x + 75 - symbol_width/2,
                        y + symbol_margin_top,
                        dep.symbol,
                        size,
                        dep.font_colour.r, dep.font_colour.g, dep.font_colour.b,1)
                end

                text_y = y + (margin_bottom * 0.5)
                CONFIG.font:write(
                    x + 170,
                    text_y,
                    dep.direction,
                    text_upper_size,
                    1, 1, 1, 1
                )
                if CONFIG.large_minutes then
                    local time_width = CONFIG.font:width(time, text_upper_size)
                    local text_width = CONFIG.font:width(platform .. " " .. append, text_lower_size)

                    CONFIG.font:write(
                        real_width - time_width,
                        text_y, time, text_upper_size,
                        1, 1, 1, 1
                    )
                    text_y = text_y + text_upper_size
                    CONFIG.font:write(
                        real_width - text_width,
                        text_y,
                        platform .. " " .. append,
                        text_lower_size,
                        1,1,1,1
                    )
                else
                    text_y = text_y + text_upper_size
                    CONFIG.font:write(
                        x + 170,
                        text_y,
                        time .. " " .. platform .. " " .. append,
                        text_lower_size,
                        1,1,1,1
                    )
                end
            else
                this_line_height = line_height * 0.8
                icon_size = this_line_height * 0.66
                text_upper_size = this_line_height * 0.5
                text_lower_size = this_line_height * 0.3
                symbol_height = text_upper_size + text_lower_size + margin_bottom

                x = 0

                -- vehicle type
                if CONFIG.show_vehicle_type then
                    if categories[dep.icon] then
                        icon_y = y + ( symbol_height - icon_size ) / 2
                        categories[dep.icon]:draw(
                            0, icon_y,
                            icon_size, icon_y+icon_size
                        )
                    end
                    x = x + icon_size + 20
                end

                -- line number
                colored:use{color = {
                    dep.background_colour.r,
                    dep.background_colour.g,
                    dep.background_colour.b,
                    1
                }}
                white:draw(
                    x, y,
                    x + 100,y + symbol_height
                )
                colored:deactivate()

                local symbol_width = CONFIG.font:width(dep.symbol, icon_size)
                if symbol_width < 100 then
                    symbol_margin_top = (symbol_height - icon_size) / 2
                    CONFIG.font:write(
                        x + 50 - symbol_width/2,
                        y + symbol_margin_top,
                        dep.symbol,
                        icon_size,
                        dep.font_colour.r, dep.font_colour.g, dep.font_colour.b, 1
                    )
                else
                    size = icon_size
                    while CONFIG.font:width(dep.symbol, size) > 95 do
                        size = size - 2
                    end
                    symbol_margin_top = (symbol_height - size) / 2
                    symbol_width = CONFIG.font:width(dep.symbol, size)
                    CONFIG.font:write(
                        x + 50 - symbol_width/2,
                        y+symbol_margin_top,
                        dep.symbol,
                        size,
                        dep.font_colour.r, dep.font_colour.g, dep.font_colour.b, 1
                    )
                end
                x = x + 110

                -- time of event
                local space_for_time = icon_size * 3.5
                local time_width = CONFIG.font:width(time, icon_size)
                CONFIG.font:write(
                    x + (space_for_time - time_width) / 2,
                    y + ((symbol_height - icon_size) / 2),
                    time,
                    icon_size,
                    1,1,1,1
                )
                x = x + space_for_time + 10

                -- destination and follow-up information
                text_y = y + (margin_bottom * 0.5)
                CONFIG.font:write(
                    x,
                    text_y,
                    dep.direction,
                    text_upper_size,
                    1, 1, 1,1
                )

                text_y = text_y + text_upper_size
                CONFIG.font:write(
                    x,
                    text_y,
                    platform .. " " .. append,
                    text_lower_size,
                    1, 1, 1, 1
                )
            end

            y = y + symbol_height + margin_bottom

            if y > real_height then
                break
            end
        end
    end
end

function node.render()
    if rotate_before ~= CONFIG.screen_rotation then
        transform = util.screen_transform(CONFIG.screen_rotation)
        rotate_before = CONFIG.screen_rotation
    end

    if rotate_before == 90 or rotate_before == 270 then
        real_width = NATIVE_HEIGHT
        real_height = NATIVE_WIDTH
    else
        real_width = NATIVE_WIDTH
        real_height = NATIVE_HEIGHT
    end
    transform()
    draw(real_width, real_height)
end
