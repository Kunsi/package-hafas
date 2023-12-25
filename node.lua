util.init_hosted()

local events = {}
local rotate_before = nil
local transform = nil

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.json_watch("events.json", function(content)
    events = content
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
    local stops = {}
    local number_of_stops = 0

    local line_height = CONFIG.line_height
    local margin_bottom = CONFIG.line_height * 0.2

    for idx, dep in ipairs(events) do
        if dep.timestamp > now_for_fade - fadeout then
            if now_for_fade > dep.timestamp then
                y = (y - line_height - margin_bottom) / fadeout * (now_for_fade - dep.timestamp)
            end
        end
        if not stops[dep.stop] then
            number_of_stops = number_of_stops + 1
        end
        stops[dep.stop] = true
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

            local heading = dep.direction
            local preposition = "von"

            if not dep.departure then
               heading = "Ankunft von " .. dep.direction
               preposition = "an"
            end

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

            if number_of_stops > 1 then
                platform = preposition .. " " .. dep.stop
                if dep.platform ~= "" then
                    platform = platform .. ", " .. dep.platform
                end
            else
                if dep.platform ~= "" then
                    platform = preposition .. " " .. dep.platform
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

                local symbol_width = CONFIG.line_font:width(dep.symbol, icon_size)
                if symbol_width < 150 then
                    symbol_margin_top = (symbol_height - icon_size) / 2
                    CONFIG.line_font:write(
                        x + 75 - symbol_width/2,
                        y + symbol_margin_top,
                        dep.symbol,
                        icon_size,
                        dep.font_colour.r, dep.font_colour.g, dep.font_colour.b, 1
                    )
                else
                    size = icon_size
                    while CONFIG.line_font:width(dep.symbol, size) > 145 do
                        size = size - 2
                    end
                    symbol_margin_top = (symbol_height - size) / 2
                    symbol_width = CONFIG.line_font:width(dep.symbol, size)
                    CONFIG.line_font:write(
                        x + 75 - symbol_width/2,
                        y + symbol_margin_top,
                        dep.symbol,
                        size,
                        dep.font_colour.r, dep.font_colour.g, dep.font_colour.b,1)
                end

                text_y = y + (margin_bottom * 0.5)
                CONFIG.heading_font:write(
                    x + 170,
                    text_y,
                    heading,
                    text_upper_size,
                    CONFIG.heading_colour.r,
                    CONFIG.heading_colour.g,
                    CONFIG.heading_colour.b,
                    CONFIG.heading_colour.a
                )
                local text_width = CONFIG.second_font:width(platform .. " " .. append, text_lower_size)
                if CONFIG.large_minutes then
                    local time_width = CONFIG.time_font:width(time, text_upper_size)
                    local append_width = CONFIG.second_font:width(append, text_lower_size)

                    CONFIG.time_font:write(
                        real_width - time_width,
                        text_y, time, text_upper_size,
                        CONFIG.time_colour.r,
                        CONFIG.time_colour.g,
                        CONFIG.time_colour.b,
                        CONFIG.time_colour.a
                    )
                    text_y = text_y + text_upper_size
                    if platform ~= "" then
                        CONFIG.second_font:write(
                            x + 170,
                            text_y,
                            platform,
                            text_lower_size,
                            CONFIG.second_colour.r,
                            CONFIG.second_colour.g,
                            CONFIG.second_colour.b,
                            CONFIG.second_colour.a
                        )
                    end
                    CONFIG.second_font:write(
                        real_width - append_width,
                        text_y,
                        append,
                        text_lower_size,
                        CONFIG.second_colour.r,
                        CONFIG.second_colour.g,
                        CONFIG.second_colour.b,
                        CONFIG.second_colour.a
                    )
                else
                    local time_width = CONFIG.time_font:width(time, text_lower_size)
                    local time_after_width = CONFIG.time_font:width(" ", text_lower_size)

                    text_y = text_y + text_upper_size
                    CONFIG.time_font:write(
                        x + 170,
                        text_y, time, text_lower_size,
                        CONFIG.time_colour.r,
                        CONFIG.time_colour.g,
                        CONFIG.time_colour.b,
                        CONFIG.time_colour.a
                    )
                    CONFIG.second_font:write(
                        x + 170 + time_width + time_after_width,
                        text_y,
                        platform .. " " .. append,
                        text_lower_size,
                        CONFIG.second_colour.r,
                        CONFIG.second_colour.g,
                        CONFIG.second_colour.b,
                        CONFIG.second_colour.a
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

                local symbol_width = CONFIG.line_font:width(dep.symbol, icon_size)
                if symbol_width < 100 then
                    symbol_margin_top = (symbol_height - icon_size) / 2
                    CONFIG.line_font:write(
                        x + 50 - symbol_width/2,
                        y + symbol_margin_top,
                        dep.symbol,
                        icon_size,
                        dep.font_colour.r, dep.font_colour.g, dep.font_colour.b, 1
                    )
                else
                    size = icon_size
                    while CONFIG.line_font:width(dep.symbol, size) > 95 do
                        size = size - 2
                    end
                    symbol_margin_top = (symbol_height - size) / 2
                    symbol_width = CONFIG.line_font:width(dep.symbol, size)
                    CONFIG.line_font:write(
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
                local time_width = CONFIG.time_font:width(time, icon_size)
                CONFIG.time_font:write(
                    x + (space_for_time - time_width) / 2,
                    y + ((symbol_height - icon_size) / 2),
                    time,
                    icon_size,
                    CONFIG.time_colour.r,
                    CONFIG.time_colour.g,
                    CONFIG.time_colour.b,
                    CONFIG.time_colour.a
                )
                x = x + space_for_time + 10

                -- destination and follow-up information
                text_y = y + (margin_bottom * 0.5)
                CONFIG.heading_font:write(
                    x,
                    text_y,
                    heading,
                    text_upper_size,
                    CONFIG.heading_colour.r,
                    CONFIG.heading_colour.g,
                    CONFIG.heading_colour.b,
                    CONFIG.heading_colour.a
                )

                text_y = text_y + text_upper_size
                CONFIG.second_font:write(
                    x,
                    text_y,
                    platform .. " " .. append,
                    text_lower_size,
                    CONFIG.second_colour.r,
                    CONFIG.second_colour.g,
                    CONFIG.second_colour.b,
                    CONFIG.second_colour.a
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
