from helper import Helper

MAPPING_RMV = {
    "ESW": {
        "1": (Helper.hex2rgb("f39433"), (1, 1, 1)),
        "2": (Helper.hex2rgb("00a7e7"), (1, 1, 1)),
        "3": (Helper.hex2rgb("8c5694"), (1, 1, 1)),
        "4": (Helper.hex2rgb("64b445"), (1, 1, 1)),
        "5": (Helper.hex2rgb("5da5b8"), (1, 1, 1)),
        "6": (Helper.hex2rgb("cb5e10"), (1, 1, 1)),
        "8": (Helper.hex2rgb("f39433"), (1, 1, 1)),
        "9": (Helper.hex2rgb("a94f2b"), (1, 1, 1)),
        "14": (Helper.hex2rgb("64b445"), (1, 1, 1)),
        "15": (Helper.hex2rgb("5da5b8"), (1, 1, 1)),
        "16": (Helper.hex2rgb("f0988f"), (0, 0, 0)),
        "17": (Helper.hex2rgb("5c2483"), (1, 1, 1)),
        "18": (Helper.hex2rgb("ea5b0c"), (1, 1, 1)),
        "20": (Helper.hex2rgb("acb371"), (1, 1, 1)),
        "21": (Helper.hex2rgb("d1b122"), (1, 1, 1)),
        "22": (Helper.hex2rgb("d1b122"), (1, 1, 1)),
        "23": (Helper.hex2rgb("0086cd"), (1, 1, 1)),
        "24": (Helper.hex2rgb("0086cd"), (0, 0, 0)),
        "26": (Helper.hex2rgb("adce6d"), (1, 1, 1)),
        "27": (Helper.hex2rgb("cd7bab"), (1, 1, 1)),
        "28": (Helper.hex2rgb("5bc5f2"), (1, 1, 1)),
        "30": (Helper.hex2rgb("ba0161"), (1, 1, 1)),
        "33": (Helper.hex2rgb("ddae8d"), (1, 1, 1)),
        "34": (Helper.hex2rgb("9097c3"), (1, 1, 1)),
        "37": (Helper.hex2rgb("9f4c97"), (1, 1, 1)),
        "38": (Helper.hex2rgb("009a93"), (1, 1, 1)),
        "39": (Helper.hex2rgb("e7344c"), (1, 1, 1)),
        "43": (Helper.hex2rgb("ffd500"), (1, 1, 1)),
        "45": (Helper.hex2rgb("acb371"), (0, 0, 0)),
        "46": (Helper.hex2rgb("516fb4"), (1, 1, 1)),
        "47": (Helper.hex2rgb("006f8c"), (1, 1, 1)),
        "48": (Helper.hex2rgb("fab437"), (1, 1, 1)),
        "49": (Helper.hex2rgb("8ec799"), (0, 0, 0)),
        "AST 20": (Helper.hex2rgb("fdc300"), (1, 1, 1)),
        "AST 24": (Helper.hex2rgb("fdc300"), (0, 0, 0)),
        "AST 26": (Helper.hex2rgb("fdc300"), (1, 1, 1)),
        "AST 35": (Helper.hex2rgb("fdc300"), (1, 1, 1)),
        "AST 36": (Helper.hex2rgb("fdc300"), (1, 1, 1)),
        "AST 46": (Helper.hex2rgb("fdc300"), (1, 1, 1)),
        "E": (Helper.hex2rgb("60b565"), (1, 1, 1)),
        "N2": (Helper.hex2rgb("1d327b"), (1, 1, 1)),
        "N3": (Helper.hex2rgb("1d327b"), (1, 1, 1)),
        "N4": (Helper.hex2rgb("1d327b"), (1, 1, 1)),
        "N5": (Helper.hex2rgb("1d327b"), (1, 1, 1)),
        "N7": (Helper.hex2rgb("1d327b"), (1, 1, 1)),
        "N9": (Helper.hex2rgb("1d327b"), (1, 1, 1)),
        "N10": (Helper.hex2rgb("1d327b"), (1, 1, 1)),
        "N11": (Helper.hex2rgb("1d327b"), (1, 1, 1)),
        "N12": (Helper.hex2rgb("1d327b"), (1, 1, 1)),
    },
    "DBR": {
        "S1": (Helper.hex2rgb("0994dd"), (1, 1, 1)),
        "S2": (Helper.hex2rgb("ed1c24"), (1, 1, 1)),
        "S3": (Helper.hex2rgb("00a998"), (1, 1, 1)),
        "S4": (Helper.hex2rgb("fcc707"), (0, 0, 0)),
        "S5": (Helper.hex2rgb("8d522d"), (1, 1, 1)),
        "S6": (Helper.hex2rgb("f46717"), (1, 1, 1)),
        "S8": (Helper.hex2rgb("80cc28"), (1, 1, 1)),
        "S9": (Helper.hex2rgb("8d188f"), (1, 1, 1)),
    },
    "MzM": {
        "6": (Helper.hex2rgb("cb5e10"), (1, 1, 1)),
        "9": (Helper.hex2rgb("d6d000"), (1, 1, 1)),
        "28": (Helper.hex2rgb("f7a600"), (0, 0, 0)),
        "33": (Helper.hex2rgb("232c77"), (1, 1, 1)),
        "50": (Helper.hex2rgb("41c0f0"), (1, 1, 1)),
        "51": (Helper.hex2rgb("00649c"), (1, 1, 1)),
        "52": (Helper.hex2rgb("0098cd"), (1, 1, 1)),
        "53": (Helper.hex2rgb("a1daf8"), (1, 1, 1)),
        "54": (Helper.hex2rgb("007c4e"), (1, 1, 1)),
        "55": (Helper.hex2rgb("007c4e"), (1, 1, 1)),
        "56": (Helper.hex2rgb("ea5297"), (0, 0, 0)),
        "57": (Helper.hex2rgb("ea5297"), (1, 1, 1)),
        "58": (Helper.hex2rgb("95c11f"), (0, 0, 0)),
        "59": (Helper.hex2rgb("008bd2"), (1, 1, 1)),
        "60": (Helper.hex2rgb("64569d"), (1, 1, 1)),
        "61": (Helper.hex2rgb("64569d"), (1, 1, 1)),
        "62": (Helper.hex2rgb("d190b6"), (1, 1, 1)),
        "63": (Helper.hex2rgb("d190b6"), (1, 1, 1)),
        "64": (Helper.hex2rgb("009090"), (0, 0, 0)),
        "65": (Helper.hex2rgb("009090"), (0, 0, 0)),
        "66": (Helper.hex2rgb("d67c13"), (0, 0, 0)),
        "67": (Helper.hex2rgb("d67c13"), (1, 1, 1)),
        "68": (Helper.hex2rgb("c00d0e"), (1, 1, 1)),
        "70": (Helper.hex2rgb("97b816"), (1, 1, 1)),
        "71": (Helper.hex2rgb("96b716"), (1, 1, 1)),
        "75": (Helper.hex2rgb("166c79"), (1, 1, 1)),
        "76": (Helper.hex2rgb("e30613"), (1, 1, 1)),
        "78": (Helper.hex2rgb("f3997b"), (1, 1, 1)),
        "90": (Helper.hex2rgb("203889"), (1, 1, 1)),
        "91": (Helper.hex2rgb("6e5239"), (1, 1, 1)),
        "92": (Helper.hex2rgb("a85e24"), (1, 1, 1)),
        "99": (Helper.hex2rgb("c2a47a"), (1, 1, 1)),
    },
    "VGF": {
        "U1": (Helper.hex2rgb("00309a"), (1, 1, 1)),
        "U2": (Helper.hex2rgb("00309a"), (1, 1, 1)),
        "U3": (Helper.hex2rgb("00309a"), (1, 1, 1)),
        "U4": (Helper.hex2rgb("00309a"), (1, 1, 1)),
        "U5": (Helper.hex2rgb("00309a"), (1, 1, 1)),
        "U6": (Helper.hex2rgb("00309a"), (1, 1, 1)),
        "U7": (Helper.hex2rgb("00309a"), (1, 1, 1)),
        "U8": (Helper.hex2rgb("00309a"), (1, 1, 1)),
        "U9": (Helper.hex2rgb("00309a"), (1, 1, 1)),
        "11": (Helper.hex2rgb("f90000"), (1, 1, 1)),
        "12": (Helper.hex2rgb("f90000"), (1, 1, 1)),
        "14": (Helper.hex2rgb("f90000"), (1, 1, 1)),
        "15": (Helper.hex2rgb("f90000"), (1, 1, 1)),
        "16": (Helper.hex2rgb("f90000"), (1, 1, 1)),
        "17": (Helper.hex2rgb("f90000"), (1, 1, 1)),
        "18": (Helper.hex2rgb("f90000"), (1, 1, 1)),
        "19": (Helper.hex2rgb("f90000"), (1, 1, 1)),
        "20": (Helper.hex2rgb("f90000"), (1, 1, 1)),
        "21": (Helper.hex2rgb("f90000"), (1, 1, 1)),
    },
}
