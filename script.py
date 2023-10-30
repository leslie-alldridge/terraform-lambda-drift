def say_hello(event, _context):
    name = event.get("name", "Unknown")
    print(f"Hello, {name}!")


if __name__ == "__main__":
    event = {"name": "World"}
    say_hello(event, None)
