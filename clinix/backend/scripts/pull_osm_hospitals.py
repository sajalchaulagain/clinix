import json
import urllib.parse
import urllib.request


def pull_osm_hospitals():
    query = """[out:json];
node["amenity"="hospital"](27.6,85.2,27.8,85.5);
out 15;"""
    url = "https://overpass-api.de/api/interpreter?data=" + urllib.parse.quote(query)
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "CliniX/1.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
            elements = data.get("elements", [])
            print(f"Found {len(elements)} OSM hospital nodes in Kathmandu Valley bbox:")
            for elem in elements:
                tags = elem.get("tags", {})
                name = tags.get("name") or tags.get("name:en")
                if name:
                    lat, lon = elem.get("lat"), elem.get("lon")
                    print(f" • {name} ({lat}, {lon})")
    except Exception as exc:
        print("OSM Overpass query skipped:", exc)


if __name__ == "__main__":
    pull_osm_hospitals()
