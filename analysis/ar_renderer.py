"""
ar_renderer.py — Broadcast-quality AR tactical overlay.

Visual style (ref: tactical-cam broadcast):
  1. Formation lines — structured row-based mesh (not random nearest-neighbor)
  2. Pass arrows    — blue arrow + gold glow underneath
  3. Ball           — gold/yellow circle at ground level
  4. Player marker  — circle drawn at FEET (below player center), not covering body
  5. Player label   — small name tag ABOVE the player
  6. Pass counter   — bottom-right
  7. Commentary     — top-left
"""
import cv2
import numpy as np

# ── Constants ──────────────────────────────────────────────────────────────────
_FORMATION_COLOR = (60, 200, 60)    # bright green
_ARROW_BLUE      = (210,  70,  10)  # BGR ≈ bright blue
_ARROW_GLOW      = (  0, 185, 255)  # BGR ≈ gold/yellow glow

# Pixel offset to place the circle indicator at the player's feet
# (positive = shift down in image → at feet in top-down view)
_FEET_OFFSET_Y   = 18
# Row-clustering tolerance: players within this many pixels on Y
# are grouped into the same formation row
_ROW_TOLERANCE_Y = 55


# ── Main entry ─────────────────────────────────────────────────────────────────

def render_frame(
    frame:         "np.ndarray",
    players:       dict[int, tuple],
    ball:          tuple | None,
    recent_passes: list[dict],
    ball_holder:   int | None,
    team_classifier,
    commentary:    list[str] | None = None,
    total_passes:  int = 0,
    id_map:        dict[int, int] | None = None,
) -> "np.ndarray":
    out = frame.copy()

    # 1. Formation lines (bottom layer — drawn before markers)
    _draw_formation_lines(out, players)

    # 2. Pass arrows with glow
    _draw_pass_arrows(out, recent_passes)

    # 3. Ball
    if ball:
        _draw_ball(out, ball)

    # 4. Player labels only (no circles)
    for pid, (cx, cy) in players.items():
        is_holder  = (pid == ball_holder)
        display_id = id_map.get(pid, pid) if id_map else pid
        _draw_player_label(out, display_id, int(cx), int(cy), is_holder)

    # 5. Pass counter (bottom-right) — uses cumulative total
    _draw_pass_counter(out, total_passes)

    # 6. Commentary (top-left)
    if commentary:
        _draw_commentary(out, commentary)

    return out


# ── Player label (no circle) ───────────────────────────────────────────────────

def _draw_player_label(frame, display_id, cx, cy, is_holder):
    """
    Only a small ID tag above the player — no circle overlapping the body.
    Ball holder gets a green accent on the tag.
    display_id is already remapped (1-11), not the raw ByteTrack track ID.
    """
    label = f"{display_id}"
    font, scale, thick = cv2.FONT_HERSHEY_SIMPLEX, 0.40, 1
    (tw, th), _ = cv2.getTextSize(label, font, scale, thick)

    lx = cx - tw // 2
    ly = cy - 22          # above the player body

    bg_color   = (0, 150, 80) if is_holder else (20, 20, 20)
    text_color = (255, 255, 255)

    # Rounded-ish background pill
    cv2.rectangle(frame, (lx - 4, ly - th - 3), (lx + tw + 4, ly + 3),
                  bg_color, -1)
    cv2.putText(frame, label, (lx, ly), font, scale,
                text_color, thick, cv2.LINE_AA)


# ── Ball ───────────────────────────────────────────────────────────────────────

def _draw_ball(frame, center):
    bx, by = int(center[0]), int(center[1])
    cv2.circle(frame, (bx, by),  9, (0, 195, 255), -1, cv2.LINE_AA)   # gold fill
    cv2.circle(frame, (bx, by),  9, (255, 255, 255), 1, cv2.LINE_AA)  # white border
    cv2.circle(frame, (bx, by), 15, (0, 195, 255),   1, cv2.LINE_AA)  # pulse ring


# ── Pass arrows ────────────────────────────────────────────────────────────────

def _draw_pass_arrows(frame, recent_passes):
    """
    Glowing arrow: thick gold glow layer + thinner blue arrow on top.
    """
    for p in recent_passes:
        age   = p.get("age", 0)
        alpha = max(0.0, 1.0 - age / 50)
        if alpha < 0.05:
            continue

        fx, fy = int(p["from_pos"][0]), int(p["from_pos"][1])
        tx, ty = int(p["to_pos"][0]),   int(p["to_pos"][1])

        # Shift arrow endpoints to feet level so it connects feet-to-feet
        fy += _FEET_OFFSET_Y
        ty += _FEET_OFFSET_Y

        glow_thick  = max(1, int(10 * alpha))
        arrow_thick = max(1, int(4  * alpha))
        glow_color  = tuple(int(c * alpha) for c in _ARROW_GLOW)
        arrow_color = tuple(int(c * alpha) for c in _ARROW_BLUE)

        cv2.arrowedLine(frame, (fx, fy), (tx, ty),
                        glow_color, glow_thick, cv2.LINE_AA, tipLength=0.22)
        cv2.arrowedLine(frame, (fx, fy), (tx, ty),
                        arrow_color, arrow_thick, cv2.LINE_AA, tipLength=0.22)


# ── Formation lines ────────────────────────────────────────────────────────────

def _draw_formation_lines(frame, players: dict[int, tuple]):
    """
    Structured formation mesh:
      1. Sort players into horizontal rows by Y (field depth).
      2. Within each row: connect players left-to-right in order (horizontal line).
      3. Between adjacent rows: connect the closest pair of players.

    This produces the clean formation shape (4-4-2, 4-3-3, etc.) instead of
    the chaotic random-nearest-neighbor web.
    """
    if len(players) < 2:
        return

    positions = list(players.values())

    # ── Step 1: cluster into rows by Y ────────────────────────────────────────
    rows = _cluster_into_rows(positions, _ROW_TOLERANCE_Y)

    color = _FORMATION_COLOR

    # ── Step 2: connect within each row (horizontal links) ────────────────────
    for row in rows:
        sorted_row = sorted(row, key=lambda p: p[0])   # left → right by X
        for i in range(len(sorted_row) - 1):
            p1, p2 = sorted_row[i], sorted_row[i + 1]
            _fline(frame,
                   (int(p1[0]), int(p1[1]) + _FEET_OFFSET_Y),
                   (int(p2[0]), int(p2[1]) + _FEET_OFFSET_Y),
                   color)

    # ── Step 3: connect adjacent rows (vertical links between nearest pair) ────
    rows_sorted = sorted(rows, key=lambda r: sum(p[1] for p in r) / len(r))
    for i in range(len(rows_sorted) - 1):
        row_a = rows_sorted[i]
        row_b = rows_sorted[i + 1]
        # Find the single closest pair between the two rows
        best = min(
            ((pa, pb) for pa in row_a for pb in row_b),
            key=lambda pair: _dist(pair[0], pair[1]),
        )
        pa, pb = best
        _fline(frame,
               (int(pa[0]), int(pa[1]) + _FEET_OFFSET_Y),
               (int(pb[0]), int(pb[1]) + _FEET_OFFSET_Y),
               color)


def _cluster_into_rows(positions: list, tolerance: float) -> list[list]:
    """
    Group positions into horizontal rows using a greedy Y-clustering.
    Returns a list of rows, each row being a list of (x, y) tuples.
    """
    sorted_pts = sorted(positions, key=lambda p: p[1])
    rows: list[list] = []
    current_row: list = [sorted_pts[0]]
    current_y = sorted_pts[0][1]

    for pt in sorted_pts[1:]:
        if abs(pt[1] - current_y) <= tolerance:
            current_row.append(pt)
        else:
            rows.append(current_row)
            current_row = [pt]
            current_y = pt[1]

    if current_row:
        rows.append(current_row)

    return rows


def _fline(frame, p1, p2, color, thickness=1):
    cv2.line(frame, p1, p2, color, thickness, cv2.LINE_AA)


# ── Pass counter ───────────────────────────────────────────────────────────────

def _draw_pass_counter(frame, count: int):
    h, w   = frame.shape[:2]
    label  = f"Passes : {count}"
    font, scale, thick = cv2.FONT_HERSHEY_SIMPLEX, 0.75, 2
    (tw, th), _ = cv2.getTextSize(label, font, scale, thick)
    pad = 10
    x = w - tw - pad * 2 - 4
    y = h - pad - 4
    cv2.rectangle(frame, (x - pad, y - th - pad), (x + tw + pad, y + pad), (0, 0, 0), -1)
    cv2.putText(frame, label, (x, y), font, scale, (255, 255, 255), thick, cv2.LINE_AA)


# ── Commentary ─────────────────────────────────────────────────────────────────

def _draw_commentary(frame, insights: list[str]):
    font, scale, thick = cv2.FONT_HERSHEY_SIMPLEX, 0.58, 2
    y = 38
    for text in insights:
        # OpenCV built-in font only supports ASCII — strip anything else
        text = text.encode("ascii", errors="replace").decode("ascii").replace("?", " ").strip()
        (tw, th), _ = cv2.getTextSize(text, font, scale, thick)
        cv2.rectangle(frame, (8, y - th - 6), (18 + tw, y + 6), (0, 0, 0), -1)
        cv2.putText(frame, text, (12, y), font, scale, (0, 0, 0),     thick + 1, cv2.LINE_AA)
        cv2.putText(frame, text, (12, y), font, scale, (60, 220, 80), thick,     cv2.LINE_AA)
        y += th + 14


# ── Public zone helper ─────────────────────────────────────────────────────────

def draw_zone(
    frame,
    top_left:     tuple,
    bottom_right: tuple,
    color:        tuple = (60, 200, 60),
    alpha:        float = 0.20,
    label:        str   = "",
):
    overlay = frame.copy()
    cv2.rectangle(overlay, top_left, bottom_right, color, -1)
    cv2.addWeighted(overlay, alpha, frame, 1 - alpha, 0, frame)
    cv2.rectangle(frame, top_left, bottom_right, color, 2, cv2.LINE_AA)
    if label:
        cv2.putText(frame, label,
                    (top_left[0] + 6, top_left[1] + 22),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2, cv2.LINE_AA)


# ── Internal ───────────────────────────────────────────────────────────────────

def _dist(a, b):
    return ((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2) ** 0.5
