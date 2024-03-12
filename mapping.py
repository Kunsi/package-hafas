from mapping_rmv import MAPPING_RMV
from mapping_vbb import MAPPING_VBB
from mapping_tfemf import MAPPING_TFEMF

COLOUR_MAPPING = {
    "rmv": MAPPING_RMV,
    "vbb": MAPPING_VBB,
    "vbb-test": MAPPING_VBB,
    "tfemf": MAPPING_TFEMF,
}

API_MAPPING = {
    "rmv": "https://www.rmv.de/hapi/{endpoint}?id={stop}&duration={minutes}&format=json&accessId={key}",
    "vbb": "https://fahrinfo.vbb.de/fahrinfo/restproxy/2.32/{endpoint}?id={stop}&duration={minutes}&format=json&accessId={key}",
    "vbb-test": "https://vbb.demo.hafas.de/fahrinfo/restproxy/2.32/{endpoint}?id={stop}&duration={minutes}&format=json&accessId={key}",
    "tfemf": "http://172.23.152.51:8000/hafas/{endpoint}?id={stop}&duration={minutes}&format=json&lang={language}",
    # "tfemf": "https://tracking.tfemf.uk/hafas/{endpoint}?id={stop}&duration={minutes}&format=json&lang={language}",
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
    "tfemf": {
        "unadvertised_ordinary_passenger": "low_speed_rail",
        "ordinary_passenger": "low_speed_rail",
        "unadvertised_express_passenger": "high_speed_rail",
        "express_passenger": "high_speed_rail",
        "metro": "u_bahn",
        "bus": "bus",
        "replacement_bus": "bus"
    }
}
CATEGORY_MAPPING["vbb-test"] = CATEGORY_MAPPING["vbb"]

OPERATOR_LABEL_MAPPING = {
    "rmv": {
        "^(Bus )": "",
    },
}

SYMBOL_IS_GROUP = {
    "vbb": True,
    "vbb-test": True,
    "rmv": True,
    "tfemf": False,
}
