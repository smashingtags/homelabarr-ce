import os, re

apps = set()
for root, dirs, files in os.walk("apps"):
    parts = root.split("/")
    if len(parts) < 2:
        continue
    category = parts[1]
    if category in ("legacy", "myapps"):
        continue
    for f in files:
        if f.endswith(".yml"):
            apps.add(f.replace(".yml", ""))

icons = set()
for f in os.listdir("public/icons/apps/light"):
    if f.endswith(".png"):
        icons.add(f.replace(".png", ""))

with open("src/utils/iconMap.ts") as f:
    content = f.read()

mappings = {}
for m in re.finditer(r'"([^"]+)":\s*"([^"]+)"', content):
    mappings[m.group(1)] = m.group(2)

missing = []
for app in sorted(apps):
    normalized = app.lower().replace(" ", "-")
    mapped = mappings.get(normalized, normalized)
    if normalized not in icons and mapped not in icons:
        missing.append(app)

print(f"Total apps: {len(apps)}")
print(f"Total icons: {len(icons)}")
print(f"Missing icons ({len(missing)}):")
for m in sorted(missing):
    print(f"  {m}")
