#!/usr/bin/env python3

import logging
from json import JSONDecodeError, dump, load
from os.path import abspath, dirname, join
from sys import exit, stderr, stdout
from time import sleep

from requests import get
from requests.exceptions import RequestException

from mapping import API_MAPPING

logging.basicConfig(
    format="[[%(levelname)s]] %(message)s",
    stream=stdout,
    level=logging.INFO,
)

try:
    with open("config.json", "r") as f:
        CONFIG = load(f)
except (FileNotFoundError, JSONDecodeError):
    logging.error("Please provide a config.json file in the current working directory")
    exit(1)

STOPS = CONFIG["stop_ids"].split(",")
KEY = CONFIG["api_key"]
LIMIT = int(CONFIG.get("requests_max_per_day", 4900))
MINUTES = CONFIG.get("request_hours", 6) * 60
OUTDIR = CONFIG.get("output_directory", abspath(dirname(__file__)))
PROVIDER = CONFIG["api_provider"]
DATASOURCES = CONFIG.get("data_sources", "departures")

fetch_departures = not (DATASOURCES == "arrivals")
fetch_arrivals = not (DATASOURCES == "departures")


def fetch_stop(stop, endpoint):
    r = get(
        API_MAPPING[PROVIDER].format(
            endpoint=endpoint,
            stop=stop,
            minutes=MINUTES,
            key=KEY,
            language=CONFIG["language"],
        )
    )
    r.raise_for_status()
    return r.json()


while True:
    for stop in STOPS:
        data = {}

        try:
            if fetch_departures:
                payload = fetch_stop(stop, "departureBoard")
                data["Departure"] = payload["Departure"]
            if fetch_arrivals:
                payload = fetch_stop(stop, "arrivalBoard")
                data["Arrival"] = payload["Arrival"]
        except RequestException as e:
            logging.exception("[{}] {}".format(stop, repr(e)))
        else:
            logging.info("[{}] fetched successfully".format(stop))

            with open(join(OUTDIR, "{}.json".format(stop)), "w") as f:
                dump(data, f, indent=4)

    number_of_requests = len(STOPS) * (int(fetch_departures) + int(fetch_arrivals))
    sleep_time = 86400 / (LIMIT / number_of_requests)

    if sleep_time < 30:
        sleep_time = 30

    logging.info("waiting {} seconds before fetching again".format(sleep_time))
    sleep(sleep_time)
