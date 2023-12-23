import json
from itertools import islice

from requests import get

from hafas_event import HAFASEvent
from helper import Helper, log
from hosted import CONFIG
from mapping import API_MAPPING


class HAFASFetcher:
    def __init__(self):
        self.departures = []

    def fetch_and_parse(self, stop_id):
        stop_info = self._fetch(stop_id)
        departures = []
        for dep in stop_info["Departure"]:
            departures.append(HAFASEvent(dep))
        departures = sorted(departures)
        for n, dep in enumerate(departures):
            for follow in islice(departures, n + 1, None):
                if dep.symbol == follow.symbol and (
                    (dep.platform != "" and dep.platform == follow.platform)
                    or (dep.platform == "" and dep.destination == follow.destination)
                ):
                    dep.follow = follow
                    break
        self.departures.extend(departures)

    def _fetch(self, stop_id):
        key = CONFIG["api_key"].strip()

        if key.startswith("http://") or key.startswith("https://"):
            key = key.rstrip("/")
            url = "{prefix}/{stop}.json".format(
                prefix=key,
                stop=stop_id,
            )
        else:
            url = API_MAPPING[CONFIG["api_provider"]].format(
                stop=stop_id,
                minutes=CONFIG["request_hours"] * 60,
                key=key,
            )
        log(
            "Requesting {stop} info from {url}".format(
                stop=stop_id,
                url=url,
            )
        )
        r = get(url)
        r.raise_for_status()
        return r.json()

    def sort_and_deduplicate(self):
        departures = sorted(self.departures)
        for n, dep in enumerate(departures):
            for follow in islice(departures, n + 1, None):
                if (
                    dep.destination == follow.destination
                    and dep.symbol == follow.symbol
                    and (
                        (
                            dep.stop != follow.stop
                            and abs(
                                Helper.to_unixtimestamp(dep.realtime)
                                - Helper.to_unixtimestamp(follow.realtime)
                            )
                            < 120
                        )
                        or (
                            dep.stop == follow.stop
                            and abs(
                                Helper.to_unixtimestamp(dep.realtime)
                                - Helper.to_unixtimestamp(follow.realtime)
                            )
                            < 10
                        )
                    )
                ):
                    dep.duplicate = True
                    break
        self.departures = [dep for dep in departures if not dep.duplicate]

    def write_json(self):
        log("writing {} departures to json".format(len(self.departures)))
        out = []
        for dep in self.departures:
            departure = {
                "category": dep.category,
                "direction": dep.destination,
                "icon": dep.category_icon,
                "operator": dep.operator,
                "platform": dep.platform,
                "stop": dep.stop,
                "symbol": dep.symbol,
                "time": dep.realtime.strftime("%H:%M"),
                "timestamp": Helper.to_unixtimestamp(dep.realtime),
                "next_timestamp": Helper.to_unixtimestamp(dep.follow.realtime)
                if dep.follow
                else 0,
                "next_time": dep.follow.realtime.strftime("%H:%M")
                if dep.follow
                else "",
            }
            departure.update(dep.line_colour)
            out.append(departure)
        with file("events.json", "wb") as f:
            f.write(json.dumps(out, ensure_ascii=False).encode("utf8"))
