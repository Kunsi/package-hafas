from helper import Helper

MAPPING_TFEMF = {
    "AW": (Helper.int2rgb(255, 1, 0), (1, 1, 1)), # Transport for Wales
    "CC": (Helper.int2rgb(188, 0, 135), (1, 1, 1)), # c2c
    "CH": (Helper.int2rgb(13, 155, 213), Helper.int2rgb(28, 45, 71)), # Chiltern Railways
    "CS": (Helper.int2rgb(0, 57, 65), (1, 1, 1)), # Caledonian Sleeper
    "EM": (Helper.int2rgb(43, 12, 35), (1, 1, 1)), # East Midlands Railway
    "ES": (Helper.int2rgb(0, 40, 106), (1, 1, 1)), # Eurostar
    "GC": (Helper.int2rgb(51, 49, 50), (1, 1, 1)), # Grand Central
    "GN": (Helper.int2rgb(67, 22, 92), (1, 1, 1)), # Great Northern
    "GR": (Helper.int2rgb(206, 14, 45), (1, 1, 1)), # London North Eastern Railway
    "GW": (Helper.int2rgb(10, 73, 62), (1, 1, 1)), # Great Western Railway
    "GX": (Helper.int2rgb(200, 40, 40), (1, 1, 1)), # Gatwick Express
    "HC": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # Heathrow Connect
    "HT": (Helper.int2rgb(0, 0, 51), (1, 1, 1)), # Hull Trains
    "HX": (Helper.int2rgb(93, 34, 108), (1, 1, 1)), # Heathrow Express
    "IL": (Helper.int2rgb(0, 146, 203), (1, 1, 1)), # Island Line
    "LD": (Helper.int2rgb(29, 0, 250), (1, 1, 1)), # Lumo
    "LE": (Helper.int2rgb(218, 26, 53), (1, 1, 1)), # Greater Anglia
    "LM": (Helper.int2rgb(255, 130, 0), (1, 1, 1)), # West Midlands Trains
    "LO": (Helper.int2rgb(2380, 118, 35), (1, 1, 1)), # London Overground
    "LT": (Helper.int2rgb(225, 37, 31), (1, 1, 1)), # London Underground
    "ME": (Helper.int2rgb(255, 235, 55), (0, 0, 0)), # Merseyrail
    "NT": (Helper.int2rgb(38, 34, 98), (1, 1, 1)), # Northern Trains
    "NY": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # North Yorkshire Moors Railway
    "PC": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # Private Charter
    "RT": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # Network Rail
    "SE": (Helper.int2rgb(50, 190, 240), Helper.int2rgb(30, 30, 80)), # Southeastern
    "SJ": (Helper.int2rgb(0, 155, 119), (1, 1, 1)), # Sheffield Supertram
    "SN": (Helper.int2rgb(0, 63, 46), (1, 1, 1)), # Southern
    "SP": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # Swanage
    "SR": (Helper.int2rgb(0, 38, 100), (1, 1, 1)), # ScotRail
    "SW": (Helper.int2rgb(0, 146, 203), (1, 1, 1)), # South Western Railway
    "TL": (Helper.int2rgb(226, 17, 133), (1, 1, 1)), # Thameslink
    "TP": (Helper.int2rgb(32, 35, 78), (1, 1, 1)), # TransPennine Express
    "TW": (Helper.int2rgb(255, 201, 73), (0, 0, 0)), # Tyne and Wear Metro
    "VT": (Helper.int2rgb(19, 30, 41), (1, 1, 1)), # Avanti West Coast
    "WR": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # West Coast Railway Company
    "XC": (Helper.int2rgb(202, 18, 63), (1, 1, 1)), # CrossCountry
    "XR": (Helper.int2rgb(119, 61, 189), (1, 1, 1)), # Elizabeth Line
    "ZB": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # Bus Operator
    "ZF": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # Ferry Operator
    "ZM": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # West Somerset Railway
    "ZZ": (Helper.int2rgb(0, 0, 0), (1, 1, 1)), # Unknown
}
