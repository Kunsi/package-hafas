import json
import pytz
from itertools import islice

from requests import get

from hafas_event import HAFASEvent
from helper import Helper, log
from hosted import CONFIG
from mapping import API_MAPPING, SYMBOL_IS_GROUP


class HAFASFetcher:
    def __init__(self):
        self.data_sources = CONFIG["data_sources"]
        self.tz = pytz.timezone(CONFIG["timezone"])
        self.departures = []
        self.arrivals = []
        self.events = []

    def fetch_and_parse(self, stop_id):
        stop_info = self._fetch(stop_id)

        departures = []
        for dep in stop_info["Departure"]:
            departures.append(HAFASEvent(dep))
        departures = sorted(departures)
        for n, dep in enumerate(departures):
            for follow in islice(departures, n + 1, None):
                if SYMBOL_IS_GROUP[CONFIG["api_provider"]]:
                    if dep.symbol == follow.symbol and (
                            (dep.platform != "" and dep.platform == follow.platform)
                        or dep.destination == follow.destination
                    ):
                        dep.follow = follow
                        break
                else:
                    if dep.category == follow.category and dep.destination == follow.destination and \
                            dep.operator == follow.operator and dep.id != follow.id:
                        dep.follow = follow
                        break
        self.departures.extend(departures)

        arrivals = []
        for arr in stop_info["Arrival"]:
            arrivals.append(HAFASEvent(arr))

        if self.data_sources == "both":
            journeys = list(map(lambda d: d.id, self.departures))
            arrivals = [arr for arr in arrivals if arr.id not in journeys]

        arrivals = sorted(arrivals)
        for n, arr in enumerate(arrivals):
            for follow in islice(arrivals, n + 1, None):
                if arr.symbol == follow.symbol and arr.origin == follow.origin:
                    arr.follow = follow
                    break
        self.arrivals.extend(arrivals)

    def _fetch_url(self, stop_id, url):
        log(
            "Requesting {stop} info from {url}".format(
                stop=stop_id,
                url=url,
            )
        )

        r = get(url)
        r.raise_for_status()
        return r.json()

    def _fetch(self, stop_id):
        key = CONFIG["api_key"].strip()
        data = {
            "Departure": [],
            "Arrival": [],
        }

        if key.startswith("http://") or key.startswith("https://"):
            key = key.rstrip("/")
            url = "{prefix}/{stop}.json".format(
                prefix=key,
                stop=stop_id,
            )

            payload = self._fetch_url(stop_id, url)
            if not self.data_sources == "arrivals":
                data["Departure"] = payload["Departure"]
            if not self.data_sources == "departures":
                data["Arrival"] = payload["Arrival"]
        else:
            url = lambda ep: API_MAPPING[CONFIG["api_provider"]].format(
                endpoint=ep,
                stop=stop_id,
                minutes=CONFIG["request_hours"] * 60,
                key=key,
                language=CONFIG["language"],
            )

            if not self.data_sources == "arrivals":
                payload = self._fetch_url(stop_id, url("departureBoard"))
                data["Departure"] = payload["Departure"]
            if not self.data_sources == "departures":
                payload = self._fetch_url(stop_id, url("arrivalBoard"))
                data["Arrival"] = payload["Arrival"]

        return data

    def _sort_and_deduplicate(self, events, locator):
        events = sorted(events)
        for n, ev in enumerate(events):
            for follow in islice(events, n + 1, None):
                if (
                    locator(ev) == locator(follow)
                    and ev.symbol == follow.symbol
                    and (
                        (
                            ev.stop != follow.stop
                            and abs(
                                Helper.to_unixtimestamp(ev.realtime)
                                - Helper.to_unixtimestamp(follow.realtime)
                            )
                            <= 120
                        )
                        or (
                            ev.stop == follow.stop
                            and abs(
                                Helper.to_unixtimestamp(ev.realtime)
                                - Helper.to_unixtimestamp(follow.realtime)
                            )
                            <= 10
                        )
                    )
                ):
                    follow.duplicate = True
                    break
        events = [ev for ev in events if not ev.duplicate]
        events = [ev for ev in events if not ev.ignore_destination]
        return events

    def sort_and_deduplicate(self):
        self.departures = self._sort_and_deduplicate(
            self.departures, lambda ev: ev.destination
        )
        self.arrivals = self._sort_and_deduplicate(self.arrivals, lambda ev: ev.origin)

        events = []
        events.extend(self.departures)
        events.extend(self.arrivals)
        self.events.extend(sorted(events))

    def write_json(self):
        log("writing {} events to json".format(len(self.events)))
        out = []
        for dep in self.events:
            departure = {
                "category": dep.category,
                "delay": dep.delay,
                "departure": dep.destination is not None,
                "direction": (
                    dep.destination if dep.destination is not None else dep.origin
                ),
                "icon": dep.category_icon,
                "id": dep.id,
                "next_time": (
                    dep.follow.realtime.astimezone(self.tz).strftime("%H:%M") if dep.follow else ""
                ),
                "next_timestamp": (
                    Helper.to_unixtimestamp(dep.follow.realtime) if dep.follow else 0
                ),
                "notes": dep.notes,
                "operator": dep.operator,
                "operator_name": dep.operatorName,
                "platform": dep.platform,
                "stop": dep.stop,
                "symbol": dep.symbol,
                "time": dep.realtime.astimezone(self.tz).strftime("%H:%M"),
                "timestamp": Helper.to_unixtimestamp(dep.realtime),
                "scheduled_time": dep.scheduled.astimezone(self.tz).strftime("%H:%M"),
                "scheduled_timestamp": Helper.to_unixtimestamp(dep.scheduled),
            }
            departure.update(dep.line_colour)
            out.append(departure)
        with file("events.json", "wb") as f:
            f.write(json.dumps(out, ensure_ascii=False).encode("utf8"))
