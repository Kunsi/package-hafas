from mapping_rmv import MAPPING_RMV
from mapping_vbb import MAPPING_VBB

COLOUR_MAPPING = {
    "rmv": MAPPING_RMV,
    "vbb": MAPPING_VBB,
    "vbb-test": MAPPING_VBB,
}

API_MAPPING = {
    "rmv": "https://www.rmv.de/hapi/{endpoint}?id={stop}&duration={minutes}&format=json&accessId={key}",
    "vbb": "https://fahrinfo.vbb.de/restproxy/2.32/{endpoint}?id={stop}&duration={minutes}&format=json&accessId={key}",
    "vbb-test": "https://vbb-demo.demo2.hafas.cloud/api/fahrinfo/latest/{endpoint}?id={stop}&duration={minutes}&format=json&accessId={key}",
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
    "vbb": {
        "0": "s_bahn",
        "1": "u_bahn",
        "2": "tram",
        "3": "bus",
        "5": "high_speed_rail",
        "6": "low_speed_rail",
    },
}
CATEGORY_MAPPING["vbb-test"] = CATEGORY_MAPPING["vbb"]

OPERATOR_LABEL_MAPPING = {
    "rmv": {
        "^(Bus )": "",
    },
}
