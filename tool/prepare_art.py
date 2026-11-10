#!/usr/bin/env python3
"""Paints the 52 cards into assets/. The cockatiel that peeks is in psito_games_ui.

Usage: prepare_art.py <source dir>

The source dir holds figuras/{rei,dama,valete}_{paus,espadas,copas,ouros}.jpeg
ases/as_<suit>.jpeg and espacos/{poleiro,ninho}.jpeg. The cards are images, painted here at a high resolution,
so that they look smooth and the same on every system.
"""
import math
import random
import sys
from pathlib import Path

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

WIDTH, HEIGHT = 480, 672
SS = 4  # supersampling of the shapes and the text
INDEX_X = 0.105  # the centre of the corner index, as a share of the width
CREAM = (245, 236, 212)
INK = (63, 42, 34)
RED = (194, 58, 42)
BLACK = (50, 46, 56)
GOLD = (186, 150, 86)
SUITS = {"paus": "clubs", "espadas": "spades", "copas": "hearts", "ouros": "diamonds"}
COURT = {"valete": ("jack", "J"), "dama": ("queen", "Q"), "rei": ("king", "K")}
WASH = {
    "clubs": ((214, 228, 203), (188, 208, 176)),
    "spades": ((209, 222, 234), (178, 197, 216)),
    "hearts": ((246, 219, 214), (234, 190, 186)),
    "diamonds": ((248, 229, 196), (238, 206, 156)),
}
ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "assets"
FONT = ROOT / "assets" / "fonts" / "CardSerif-Bold.ttf"

ROWS = (0.28, 0.4267, 0.5733, 0.72)
L, C, R = 0.265, 0.5, 0.735
PIPS = {
    2: [(C, 0.28), (C, 0.72)],
    3: [(C, 0.28), (C, 0.5), (C, 0.72)],
    4: [(L, 0.28), (R, 0.28), (L, 0.72), (R, 0.72)],
    5: [(L, 0.28), (R, 0.28), (C, 0.5), (L, 0.72), (R, 0.72)],
    6: [(L, 0.28), (R, 0.28), (L, 0.5), (R, 0.5), (L, 0.72), (R, 0.72)],
    7: [(L, 0.28), (R, 0.28), (C, 0.39), (L, 0.5), (R, 0.5), (L, 0.72), (R, 0.72)],
    8: [
        (L, 0.28), (R, 0.28), (C, 0.39), (L, 0.5),
        (R, 0.5), (C, 0.61), (L, 0.72), (R, 0.72),
    ],
    9: [(x, y) for x in (L, R) for y in ROWS] + [(C, 0.5)],
    10: [(x, y) for x in (L, R) for y in ROWS] + [(C, 0.3533), (C, 0.6467)],
}


def cubic(p0, p1, p2, p3, n=24):
    points = []
    for i in range(1, n + 1):
        t = i / n
        u = 1 - t
        points.append(
            tuple(
                u**3 * a + 3 * u * u * t * b + 3 * u * t * t * c + t**3 * d
                for a, b, c, d in zip(p0, p1, p2, p3)
            )
        )
    return points


def heart():
    start = (0.5, 0.96)
    curves = [
        ((0.15, 0.66), (0, 0.46), (0, 0.28)),
        ((0, 0.12), (0.13, 0), (0.28, 0)),
        ((0.38, 0), (0.46, 0.05), (0.5, 0.15)),
        ((0.54, 0.05), (0.62, 0), (0.72, 0)),
        ((0.87, 0), (1, 0.12), (1, 0.28)),
        ((1, 0.46), (0.85, 0.66), (0.5, 0.96)),
    ]
    points = [start]
    for curve in curves:
        points += cubic(points[-1], *curve)
    return points


def circle(cx, cy, r):
    return [
        (cx + r * math.cos(a * math.tau / 72), cy + r * math.sin(a * math.tau / 72))
        for a in range(72)
    ]


STEM = [(0.46, 0.55), (0.43, 0.84), (0.3, 1), (0.7, 1), (0.57, 0.84), (0.54, 0.55)]


def shape(suit):
    if suit == "hearts":
        return [heart()]
    if suit == "diamonds":
        return [[(0.5, 0), (0.88, 0.5), (0.5, 1), (0.12, 0.5)]]
    if suit == "spades":
        return [[(x, 0.8 - 0.8 * y) for x, y in heart()], STEM]
    return [
        circle(0.5, 0.25, 0.24),
        circle(0.24, 0.56, 0.24),
        circle(0.76, 0.56, 0.24),
        circle(0.5, 0.46, 0.14),
        STEM,
    ]


def grain(size, sigma=30, blur=0.7):
    return Image.effect_noise(size, sigma).filter(ImageFilter.GaussianBlur(blur))


def texture(size):
    """Fine grain with soft blotches and a faint weave, around middle grey."""
    w, h = size
    blotches = Image.effect_noise((max(1, w // 10), max(1, h // 10)), 46)
    blotches = blotches.resize(size, Image.BICUBIC).filter(ImageFilter.GaussianBlur(5))
    across = Image.effect_noise((max(1, w // 30), h), 34).resize(size, Image.BICUBIC)
    down = Image.effect_noise((w, max(1, h // 30)), 34).resize(size, Image.BICUBIC)
    weave = Image.blend(across, down, 0.5)
    mix = Image.blend(Image.blend(grain(size), blotches, 0.55), weave, 0.3)
    return Image.merge("RGB", (mix, mix, mix))


def paper():
    base = Image.new("RGB", (WIDTH, HEIGHT), CREAM)
    base = ImageChops.soft_light(base, texture((WIDTH, HEIGHT)))
    # The edges a little warmer and darker, as on a real card.
    centre = Image.new("L", (WIDTH, HEIGHT), 0)
    ImageDraw.Draw(centre).rectangle((30, 30, WIDTH - 31, HEIGHT - 31), fill=255)
    centre = centre.filter(ImageFilter.GaussianBlur(26))
    edge = ImageChops.multiply(base, Image.new("RGB", base.size, (236, 222, 194)))
    return Image.composite(base, edge, centre).convert("RGBA")


def frame(card):
    """A thin printed line, inside the edge."""
    w, h = WIDTH * SS, HEIGHT * SS
    mask = Image.new("L", (w, h), 0)
    inset = int(WIDTH * 0.03) * SS
    ImageDraw.Draw(mask).rounded_rectangle(
        (inset, inset, w - inset - 1, h - inset - 1),
        radius=20 * SS,
        outline=150,
        width=int(1.6 * SS),
    )
    layer = Image.new("RGBA", card.size, GOLD + (0,))
    layer.putalpha(mask.resize(card.size, Image.LANCZOS))
    card.alpha_composite(layer)


def suit_tile(suit, size, colour):
    """The suit in watercolour with an ink outline, on a transparent tile."""
    pad = max(2, size // 12)
    big = (size + pad * 2) * SS
    mask = Image.new("L", (big, big), 0)
    draw = ImageDraw.Draw(mask)
    scale = size * SS
    off = pad * SS
    for polygon in shape(suit):
        draw.polygon([(off + x * scale, off + y * scale) for x, y in polygon], fill=255)
    edge = max(3, int(size * SS * 0.022)) * 2 + 1
    outer = mask.filter(ImageFilter.MaxFilter(edge if edge % 2 else edge + 1))

    paint = Image.new("RGB", (big, big), colour)
    paint = ImageChops.soft_light(paint, texture((big, big)))
    light = tuple(min(255, c + 62) for c in colour)
    glow = Image.linear_gradient("L").rotate(-35, expand=False).resize((big, big))
    glow = ImageChops.invert(glow).point(lambda v: int(max(0, v - 118) * 0.9))
    paint = Image.composite(Image.new("RGB", (big, big), light), paint, glow)

    tile = Image.new("RGBA", (big, big), INK + (0,))
    tile.putalpha(outer)
    fill = paint.convert("RGBA")
    fill.putalpha(mask)
    tile.alpha_composite(fill)
    return tile.resize((size + pad * 2, size + pad * 2), Image.LANCZOS)


def put(card, tile, cx, cy, flip=False):
    if flip:
        tile = tile.rotate(180)
    card.alpha_composite(tile, (int(cx - tile.width / 2), int(cy - tile.height / 2)))


def index(card, label, suit, colour):
    layer = Image.new("RGBA", card.size, (0, 0, 0, 0))
    big = Image.new("L", (WIDTH * SS, HEIGHT * SS), 0)
    size = WIDTH * (0.118 if label == "10" else 0.15) * SS
    x = WIDTH * INDEX_X * SS
    # Aligned by the baseline: the tails of the J and the Q go below it.
    ImageDraw.Draw(big).text(
        (x, WIDTH * 0.155 * SS),
        label,
        font=ImageFont.truetype(str(FONT), int(size)),
        fill=255,
        anchor="ms",
    )
    text = Image.new("RGBA", card.size, colour + (0,))
    text.putalpha(big.resize(card.size, Image.LANCZOS))
    layer.alpha_composite(text)
    put(layer, suit_tile(suit, int(WIDTH * 0.08), colour), WIDTH * INDEX_X, WIDTH * 0.25)
    card.alpha_composite(layer)
    card.alpha_composite(layer.rotate(180))


def whitened(path):
    """The art with its paper turned white, ready to be multiplied over a wash."""
    art = Image.open(path).convert("RGB")
    w, h = art.size
    corners = [art.getpixel(p) for p in ((8, 8), (w - 9, 8), (8, h - 9), (w - 9, h - 9))]
    paper_colour = tuple(sorted(c)[2] for c in zip(*corners))
    bands = [
        band.point(lambda v: min(255, int(v * 255 / max(1, base))))
        for band, base in zip(art.split(), paper_colour)
    ]
    art = Image.merge("RGB", bands)
    box = ImageChops.invert(art).convert("L").point(lambda v: 255 if v > 46 else 0).getbbox()
    margin = int(w * 0.02)
    return art.crop(
        (max(0, box[0] - margin), max(0, box[1] - margin),
         min(w, box[2] + margin), min(h, box[3] + margin))
    )


def wash(size, suit):
    """A soft watercolour background."""
    w, h = size
    top, bottom = WASH[suit]
    ramp = Image.linear_gradient("L").resize(size)
    colour = Image.composite(Image.new("RGB", size, bottom), Image.new("RGB", size, top), ramp)
    return ImageChops.soft_light(colour, texture(size))


def multiply_in(card, art, box):
    """Fits the art in the box, centred, multiplied over what is there."""
    x0, y0, x1, y1 = box
    ratio = min((x1 - x0) / art.width, (y1 - y0) / art.height)
    size = (int(art.width * ratio), int(art.height * ratio))
    fitted = art.resize(size, Image.LANCZOS)
    at = (x0 + (x1 - x0 - size[0]) // 2, y0 + (y1 - y0 - size[1]) // 2)
    area = (at[0], at[1], at[0] + size[0], at[1] + size[1])
    region = card.crop(area).convert("RGB")
    # Only the background takes the colour behind it: the bird keeps its own.
    flooded = fitted.copy()
    key = (255, 0, 255)
    for corner in ((1, 1), (size[0] - 2, 1), (1, size[1] - 2), (size[0] - 2, size[1] - 2)):
        ImageDraw.floodfill(flooded, corner, key, thresh=34)
    background = Image.new("L", size, 0)
    background.putdata([255 if p == key else 0 for p in flooded.getdata()])
    background = background.filter(ImageFilter.GaussianBlur(0.7))
    warm = ImageChops.multiply(fitted, Image.new("RGB", size, (252, 247, 234)))
    card.paste(Image.composite(ImageChops.multiply(region, fitted), warm, background), area)


def panel_mask(size, radius):
    w, h = size
    mask = Image.new("L", (w * SS, h * SS), 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, w * SS - 1, h * SS - 1), radius=radius * SS, fill=255)
    return mask.resize(size, Image.LANCZOS)


def court(path, label, suit):
    card = paper()
    frame(card)
    box = (int(WIDTH * 0.175), int(HEIGHT * 0.125), int(WIDTH * 0.825), int(HEIGHT * 0.875))
    size = (box[2] - box[0], box[3] - box[1])
    card.paste(wash(size, suit), box[:2], panel_mask(size, 16))
    multiply_in(card, whitened(path), (box[0] + 8, box[1] + 10, box[2] - 8, box[3] - 10))

    outline = Image.new("L", (size[0] * SS, size[1] * SS), 0)
    ImageDraw.Draw(outline).rounded_rectangle(
        (0, 0, size[0] * SS - 1, size[1] * SS - 1), radius=16 * SS, outline=255, width=2 * SS
    )
    line = Image.new("RGBA", size, INK + (0,))
    line.putalpha(outline.resize(size, Image.LANCZOS))
    card.alpha_composite(line, box[:2])
    index(card, label, suit, RED if suit in ("hearts", "diamonds") else BLACK)
    return card


def medallion(card, suit):
    """A round wash in the middle of an ace."""
    side = int(WIDTH * 0.56)
    area = ((WIDTH - side) // 2, (HEIGHT - side) // 2)
    mask = Image.new("L", (side * SS, side * SS), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, side * SS - 1, side * SS - 1), fill=255)
    mask = mask.resize((side, side), Image.LANCZOS)
    card.paste(wash((side, side), suit), area, mask)
    ring = Image.new("L", (side * SS, side * SS), 0)
    ImageDraw.Draw(ring).ellipse((0, 0, side * SS - 1, side * SS - 1), outline=200, width=int(1.6 * SS))
    line = Image.new("RGBA", (side, side), GOLD + (0,))
    line.putalpha(ring.resize((side, side), Image.LANCZOS))
    card.alpha_composite(line, area)


def ace(path, suit):
    colour = RED if suit in ("hearts", "diamonds") else BLACK
    card = paper()
    frame(card)
    medallion(card, suit)
    if path.exists():
        side = int(WIDTH * 0.5)
        x, y = (WIDTH - side) // 2, (HEIGHT - side) // 2
        multiply_in(card, whitened(path), (x, y, x + side, y + side))
    else:
        put(card, suit_tile(suit, int(WIDTH * 0.26), colour), WIDTH / 2, HEIGHT / 2)
    index(card, "A", suit, colour)
    return card


def number(rank, suit):
    colour = RED if suit in ("hearts", "diamonds") else BLACK
    card = paper()
    frame(card)
    tile = suit_tile(suit, int(WIDTH * (0.14 if rank >= 8 else 0.16)), colour)
    for x, y in PIPS[rank]:
        put(card, tile, x * WIDTH, y * HEIGHT, flip=y > 0.5)
    index(card, str(rank), suit, colour)
    return card


def cutout(path):
    """Removes the background by flooding it from the corners."""
    rgb = Image.open(path).convert("RGB")
    key = (255, 0, 255)
    flooded = rgb.copy()
    w, h = rgb.size
    for corner in [(2, 2), (w - 3, 2), (2, h - 3), (w - 3, h - 3)]:
        ImageDraw.floodfill(flooded, corner, key, thresh=38)
    alpha = Image.new("L", rgb.size, 255)
    alpha.putdata([0 if p == key else 255 for p in flooded.getdata()])
    alpha = alpha.filter(ImageFilter.GaussianBlur(0.9))
    rgb.putalpha(alpha)
    return rgb.crop(alpha.point(lambda v: 255 if v > 16 else 0).getbbox())


def fit_width(image, width):
    return image.resize((width, int(image.height * width / image.width)), Image.LANCZOS)


def slots(source):
    """The empty places on the table: the perch and the nest."""
    (OUT / "slots").mkdir(parents=True, exist_ok=True)
    for pt, name in (("poleiro", "perch"), ("ninho", "nest")):
        image = fit_width(cutout(source / "espacos" / f"{pt}.jpeg"), 400)
        image.save(OUT / "slots" / f"{name}.png", optimize=True)


def back(source):
    art = Image.open(source / "espacos" / "verso_azul.jpeg").convert("RGB")
    return art.resize((WIDTH, HEIGHT), Image.LANCZOS)


def save(card, name):
    card.convert("RGB").save(OUT / "cards" / f"{name}.jpg", quality=90, optimize=True)


def main(source):
    random.seed(7)
    (OUT / "cards").mkdir(parents=True, exist_ok=True)
    for pt, suit in SUITS.items():
        save(ace(source / "ases" / f"as_{pt}.jpeg", suit), f"ace_{suit}")
        for rank in range(2, 11):
            save(number(rank, suit), f"{rank}_{suit}")
        for pt_rank, (name, label) in COURT.items():
            save(court(source / "figuras" / f"{pt_rank}_{pt}.jpeg", label, suit), f"{name}_{suit}")
    slots(source)
    save(back(source), "back")


if __name__ == "__main__":
    main(Path(sys.argv[1]))
