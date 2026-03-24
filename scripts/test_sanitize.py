import unicodedata

def sanitize_name(name):
    normalized = unicodedata.normalize('NFKD', name)
    ascii_name = normalized.encode('ascii', 'ignore').decode('ascii')
    for char in ['?', '*', ':', '"', '<', '>', '|', '\\', '/', '#', '%', '&', '{', '}', '$', '!', '@', '+', '=']:
        ascii_name = ascii_name.replace(char, '_')
    ascii_name = ascii_name.strip()
    return ascii_name or "_"

name = "06 ¿Por Qué Te Vas_.m4a"
print(f"Original: {name}")
print(f"Sanitized: {sanitize_name(name)}")
if name != sanitize_name(name):
    print("MATCH: Name needs renaming.")
else:
    print("NO MATCH: Name is fine.")
