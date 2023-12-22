from mapping_rmv import MAPPING_RMV

COLOUR_MAPPING = {
    "rmv": MAPPING_RMV,
}

API_MAPPING = {
    "rmv": "https://www.rmv.de/hapi/departureBoard?id={stop}&duration={minutes}&format=json&accessId={key}",
    "vbb-test": "https://vbb.demo.hafas.de/fahrinfo/restproxy/2.32/departureBoard?id={stop}&duration={minutes}&format=json&accessId={key}",
}

CATEGORY_MAPPING = {
    "rmv": {
        "0": "high_speed_rail",
        "1": "high_speed_rail",
        "2": "low_speed_rail",
        "3": "s_bahn",
        "4": "u_bahn",
        "5": "tram",
        "6": "bus",
    },
    "vbb-test": {
        "0": "s_bahn",
        "2": "tram",
        "3": "bus",
        "6": "low_speed_rail",
    },
}
