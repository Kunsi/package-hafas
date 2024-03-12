local json = require "json"

util.init_hosted()

local events = {}
local rotate_before = nil
local transform = nil
local scroll_position = {}

local translations = json.decode(resource.load_file "translations.json")

gl.setup(NATIVE_WIDTH, NATIVE_HEIGHT)

util.json_watch("events.json", function(content)
    events = content
end)

local white = resource.create_colored_texture(1,1,1,1)
local bg = resource.create_colored_texture(
    CONFIG.background_colour.r,
    CONFIG.background_colour.g,
    CONFIG.background_colour.b,
    1
)
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

local function scrolling_text(id, x1, y1, x2, y2, text, font, r, g, b, a)
    local font_size = y2 - y1
    local text_width = font:width(text, font_size)
    if x2 - x1 > text_width then
        font:write(x1, y1, text, font_size, r, g, b, a)
        return
    end
    if not scroll_position[id] then
        -- start all the way to the right
        scroll_position[id] = sys.now()
    end
    local scroll_position_by_time = math.floor((sys.now() - scroll_position[id])*25)
    if x1 - text_width > x2 - scroll_position_by_time then
        -- text scrolled out to the left. restart at the right then.
        scroll_position[id] = sys.now()
        scroll_position_by_time = 0
    end
    font:write(x2 - scroll_position_by_time, y1, text, font_size, r, g, b, a)
    bg:draw(x1 - text_width, y1-2, x1, y2+2)
    bg:draw(x2, y1-2, x2 + text_width, y2+2)
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

nre_powered_logo = resource.load_image{
  file = "NRE_Powered_logo.png";
  mimap = true;
  nearest = true;
}

local function format_seconds(seconds)
    local minutes = math.floor(seconds / 60)
    if minutes >= 60 then
      local hours = minutes / 60
      if minutes % 60 == 0 then
        return string.format(translations[CONFIG.language].time_hour, math.floor(hours))
      else
        return string.format(translations[CONFIG.language].time_hour_min, math.floor(hours), minutes % 60)
      end
    else
      return string.format(translations[CONFIG.language].time_min, minutes)
    end
end

local function draw(real_width, real_height)
    gl.clear(
        CONFIG.background_colour.r,
        CONFIG.background_colour.g,
        CONFIG.background_colour.b,
        1
    )
    local now = unixnow()
    local y = CONFIG.margin
    local now_for_fade = now + (CONFIG.offset * 60)
    local stops = {}
    local number_of_stops = 0

    local line_height = CONFIG.line_height
    local margin_bottom = CONFIG.line_height * 0.2

    local available_height = real_height - (2 * CONFIG.margin)
    if CONFIG.nre_powered then
      available_height = available_height - 100
    end

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
            local time_font = CONFIG.time_font

            local remaining = math.floor((dep.timestamp - now) / 60)
            local append = ""
            local platform = ""

            local heading = dep.direction
            local preposition = translations[CONFIG.language].from

            if not dep.departure then
               heading = string.format(translations[CONFIG.language].arrival_from, dep.direction)
               preposition = translations[CONFIG.language].at
            end

            if remaining < 0 then
                time = translations[CONFIG.language].in_the_past
                if dep.next_timestamp > 10 then
                    append = string.format(translations[CONFIG.language].next_min, format_seconds(dep.next_timestamp - now))
                end
            elseif remaining < 1 then
                if now % 2 < 1 then
                    time = "*" .. translations[CONFIG.language].now
                else
                    time = translations[CONFIG.language].now .. "*"
                end
                if dep.next_timestamp > 10 then
                    append = string.format(translations[CONFIG.language].next_min, format_seconds(dep.next_timestamp - now))
                end
            elseif remaining < (11 + CONFIG.offset) then
                time = string.format(translations[CONFIG.language].in_min, format_seconds(dep.timestamp - now))
                if remaining < (1 + CONFIG.offset) then
                    if now % 2 < 1 then
                        time = "*" .. time
                    else
                        time = time .. "*"
                    end
                end
                if dep.next_timestamp > 10 then
                    append = string.format(translations[CONFIG.language].next_after_min, format_seconds(dep.next_timestamp - dep.timestamp))
                end
            else
                if dep.next_time and dep.next_timestamp > 10 then
                    append = string.format(translations[CONFIG.language].next_timestamp, dep.next_time)
                end
            end

            if number_of_stops > 1 then
                platform = preposition .. " " .. dep.stop
                if dep.platform ~= json.null then
                    platform = platform .. ", " ..
                      translations[CONFIG.language].platform_types[dep.platform.type] ..
                      " " .. dep.platform.value
                end
            else
                if dep.platform ~= json.null then
                    platform = preposition .. " " ..
                      translations[CONFIG.language].platform_types[dep.platform.type] ..
                      " " .. dep.platform.value
                end
            end

            local ir, ig, ib  = 0.3,0.3,0.3
            local ifr,ifg,ifb = 1,  1,  1
            if CONFIG.coloured_lines then
                ir, ig, ib  = dep.background_colour.r, dep.background_colour.g, dep.background_colour.b
                ifr,ifg,ifb = dep.font_colour.r, dep.font_colour.g, dep.font_colour.b
            end

            local time_colour = CONFIG.time_colour
            if dep.delay >= 0 then
               time_font = CONFIG.realtime_font
               time_colour = CONFIG.realtime_punctual_colour
               if dep.delay > 0 then
                  time_colour = CONFIG.realtime_delayed_colour
               end
            end
            local tr, tg, tb = time_colour.r, time_colour.g, time_colour.b

            local icon_size = line_height * 0.66
            local text_upper_size = line_height * 0.5
            local text_lower_size = line_height * 0.3
            local symbol_height = text_upper_size + text_lower_size + margin_bottom
            local symbol_width = 150

            if remaining > (10 + CONFIG.offset) then
                icon_size = icon_size * 0.8
                text_upper_size = text_upper_size * 0.8
                text_lower_size = text_lower_size * 0.8
                symbol_height = symbol_height * 0.8
                symbol_width = 100
            end

            local x = 0
            local text_x = symbol_width + 20 + CONFIG.margin
            local text_y = y + (margin_bottom * 0.5)

            if CONFIG.show_vehicle_type then
                text_x = text_x + icon_size + 20
            end

            local text_y_start = text_y
            text_y = text_y + text_upper_size

            -- operator name
            if CONFIG.show_operator_name then
              if dep.operator_name ~= json.null then
                if platform ~= "" or not CONFIG.large_minutes then
                  symbol_height = symbol_height + text_lower_size
                  text_y = text_y + text_lower_size
                end
                CONFIG.second_font:write(
                    text_x,
                    text_y,
                    string.format(translations[CONFIG.language].operator_name, dep.operator_name),
                    text_lower_size,
                    CONFIG.second_colour.r,
                    CONFIG.second_colour.g,
                    CONFIG.second_colour.b,
                    CONFIG.second_colour.a
                )
              end
            end

            -- third line (if exists)
            -- needs to go first, because we use the background colour
            -- to hide the text outside the view area
            if dep.notes ~= json.null then
                -- scroller position
                local max_scroller_width = math.min(
                    real_width,
                    text_x + (real_width/2)
                )

                if platform == "" and CONFIG.large_minutes then
                    --[[
                        If there's no platform information and we're using
                        large minutes, we can display the scrolling text
                        directly below the heading, saving some space.

                        In this case, ensure we're not drawing over the
                        "append" part of the line.
                    ]]--
                    max_scroller_width = math.min(
                        max_scroller_width,
                        real_width - CONFIG.second_font:width(append, text_lower_size) - 20
                    )
                else
                    -- increase symbol height to account for scrolling text
                    symbol_height = symbol_height + text_lower_size
                    text_y = text_y + text_lower_size
                end

                -- place text
                scrolling_text(
                    dep.id,
                    text_x, text_y,
                    max_scroller_width, text_y + text_lower_size,
                    dep.notes,
                    CONFIG.second_font,
                    CONFIG.second_colour.r,
                    CONFIG.second_colour.g,
                    CONFIG.second_colour.b,
                    CONFIG.second_colour.a
                )
            end

            -- vehicle type
            if CONFIG.show_vehicle_type then
                if categories[dep.icon] then
                    local icon_y = y + ( symbol_height - icon_size ) / 2
                    categories[dep.icon]:draw(
                        CONFIG.margin, icon_y,
                        icon_size+CONFIG.margin, icon_y+icon_size
                    )
                end
                x = icon_size + 20
            end

            -- line number
            colored:use{color = {
                ir,
                ig,
                ib,
                1,
            }}
            white:draw(
                x + CONFIG.margin, y,
                x + symbol_width + CONFIG.margin, y + symbol_height
            )
            colored:deactivate()
            local actual_symbol_width = CONFIG.line_font:width(dep.symbol, icon_size)
            local symbol_font_size = icon_size
            if actual_symbol_width > symbol_width then
                while CONFIG.line_font:width(dep.symbol, symbol_font_size) > symbol_width do
                    symbol_font_size = symbol_font_size - 1
                end
                actual_symbol_width = CONFIG.line_font:width(dep.symbol, symbol_font_size)
            end
            local symbol_margin_top = (symbol_height - symbol_font_size) / 2
            CONFIG.line_font:write(
                x + symbol_width/2 - actual_symbol_width/2 + CONFIG.margin,
                y + symbol_margin_top,
                dep.symbol,
                symbol_font_size,
                ifr,ifg,ifb,1
            )
            x = x + symbol_width + 20

            -- first line
            CONFIG.heading_font:write(
                text_x,
                text_y_start,
                heading,
                text_upper_size,
                CONFIG.heading_colour.r,
                CONFIG.heading_colour.g,
                CONFIG.heading_colour.b,
                CONFIG.heading_colour.a
            )

            -- second line
            if CONFIG.large_minutes then
                local time_width = time_font:width(time, text_upper_size)
                local append_width = CONFIG.second_font:width(append, text_lower_size)

                time_font:write(
                    real_width - time_width - CONFIG.margin,
                    text_y_start, time, text_upper_size,
                    tr, tg, tb, 1
                )

                text_y_start = text_y_start + text_upper_size
                if platform ~= "" then
                    CONFIG.second_font:write(
                        text_x,
                        text_y_start,
                        platform,
                        text_lower_size,
                        CONFIG.second_colour.r,
                        CONFIG.second_colour.g,
                        CONFIG.second_colour.b,
                        CONFIG.second_colour.a
                    )
                end
                CONFIG.second_font:write(
                    real_width - append_width - CONFIG.margin,
                    text_y_start,
                    append,
                    text_lower_size,
                    CONFIG.second_colour.r,
                    CONFIG.second_colour.g,
                    CONFIG.second_colour.b,
                    CONFIG.second_colour.a
                )
            else
                local time_width = time_font:width(time, text_lower_size)
                local time_after_width = CONFIG.time_font:width(" ", text_lower_size)

                text_y_start = text_y_start + text_upper_size
                time_font:write(
                    text_x,
                    text_y_start, time, text_lower_size,
                    tr, tg, tb, 1
                )
                CONFIG.second_font:write(
                    text_x + time_width + time_after_width,
                    text_y_start,
                    platform .. " " .. append,
                    text_lower_size,
                    CONFIG.second_colour.r,
                    CONFIG.second_colour.g,
                    CONFIG.second_colour.b,
                    CONFIG.second_colour.a
                )
            end

            y = y + symbol_height + margin_bottom

            if y > available_height then
                break
            end
        end
    end

    if CONFIG.nre_powered then
      local nre_width, nre_height = nre_powered_logo:size()
      local nre_height_scaled = 75
      local nre_width_scaled = nre_width * (nre_height_scaled / nre_height)
      nre_powered_logo:draw(
        real_width - nre_width_scaled - CONFIG.margin,
        real_height - nre_height_scaled - CONFIG.margin,
        real_width - CONFIG.margin, real_height - CONFIG.margin
      )
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
