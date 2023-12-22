from time import mktime


class Helper:
    @staticmethod
    def rgb2hsv(r, g, b):
        r, g, b = r / 255.0, g / 255.0, b / 255.0
        mx = max(r, g, b)
        mn = min(r, g, b)
        df = mx - mn
        if mx == mn:
            h = 0
        elif mx == r:
            h = (60 * ((g - b) / df) + 360) % 360
        elif mx == g:
            h = (60 * ((b - r) / df) + 120) % 360
        elif mx == b:
            h = (60 * ((r - g) / df) + 240) % 360
        if mx == 0:
            s = 0
        else:
            s = df / mx
            v = mx
        return h, s, v

    @staticmethod
    def hex2rgb(h):
        r = round(1.0 / 255 * int(h[0:2], 16), 2)
        g = round(1.0 / 255 * int(h[2:4], 16), 2)
        b = round(1.0 / 255 * int(h[4:6], 16), 2)
        return r, g, b

    @staticmethod
    def int2rgb(ri, gi, bi):
        rf = round(1.0 / 255 * ri, 2)
        gf = round(1.0 / 255 * gi, 2)
        bf = round(1.0 / 255 * bi, 2)
        return rf, gf, bf

    @staticmethod
    def to_unixtimestamp(dt):
        return int(mktime(dt.timetuple()))
