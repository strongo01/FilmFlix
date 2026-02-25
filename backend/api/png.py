import os
import requests
import cairosvg

API_KEY = "c5a42ef630mshcaffd191848843dp10b349jsn05e243a6526b"

url = "https://streaming-availability.p.rapidapi.com/countries/nl"
querystring = {"output_language": "en"}

headers = {
    "x-rapidapi-key": API_KEY,
    "x-rapidapi-host": "streaming-availability.p.rapidapi.com"
}

# Map aanmaken
os.makedirs("logos/light", exist_ok=True)
os.makedirs("logos/dark", exist_ok=True)

response = requests.get(url, headers=headers, params=querystring)
data = response.json()

services = data.get("services", [])

for service in services:
    name = service.get("name")
    image_set = service.get("imageSet", {})
    light_svg_url = image_set.get("lightThemeImage")
    dark_svg_url = image_set.get("darkThemeImage")

    # Process light theme
    if light_svg_url:
        print(f"Downloading {name} light SVG...")
        svg_response = requests.get(light_svg_url)
        if svg_response.status_code == 200:
            svg_data = svg_response.content
            png_path = f"logos/light/{name.lower().replace(' ', '_')}.png"
            print(f"Converting {name} to PNG...")
            try:
                cairosvg.svg2png(bytestring=svg_data, write_to=png_path)
                print(f"Saved: {png_path}")
            except Exception as e:
                print(f"Error converting {name} (light): {e}")

    # Process dark theme
    if dark_svg_url:
        print(f"Downloading {name} dark SVG...")
        svg_response = requests.get(dark_svg_url)
        if svg_response.status_code == 200:
            svg_data = svg_response.content
            png_path = f"logos/dark/{name.lower().replace(' ', '_')}.png"
            print(f"Converting {name} to PNG...")
            try:
                cairosvg.svg2png(bytestring=svg_data, write_to=png_path)
                print(f"Saved: {png_path}")
            except Exception as e:
                print(f"Error converting {name} (dark): {e}")

print("Done 🎉")