"""
ar_renderer.py — Tactical AR overlay.

Visual focus:
  1. Ball holder — glowing ring at feet
  2. Pass recommendations — gold dashed arrows to 2-3 best targets
  3. Recent passes — blue arrow with glow fade
  4. Player labels — small ID tag above each player
  5. Pass counter — bottom-right
  6. Commentary — top-left
"""
import cv2
import numpy as np
import math

# -- Colors (BGR) ---------------------------------------------------------------
_HOLD_RING_OUTER = (0, 255, 128)    # green glow ring
_HOLD_RING_INNER = (255, 255, 255)  # white inner ring
_PASS_REC_COLOR  = (0, 215, 255)    # gold — recommended pass
_ARROW_BLUE      = (210,  70,  10)  # recent pass arrow
_ARROW_GLOW      = (  0, 185, 255)  # glow layer

# -- Tuning ---------------------------------------------------------------------
_FEET_OFFSET_Y    = 18   # shift circle/arrow to player feet
_PASS_MIN_DIST    = 80   # px — too close to recommend
_PASS_MAX_DIST    = 450  # px — too far to recommend
_MAX_REC_TARGETS  = 3    # max recommended pass targets
_SPREAD_MIN_DEG   = 40   # minimum angular spread between recommendations


# -- Public entry ---------------------------------------------------------------

def render_frame(
    frame,
    players:       dict[int, tuple],
    ball:          tuple | None,
    recent_passes: list[dict],
    ball_holder:   int | None,
    team_classifier,
    commentary:    list[str] | None = None,
    total_passes:  int = 0,
    id_map:        dict[int, int] | None = None,
) -> np.ndarray:
    out = frame.copy()

    # Pass recommendations (bottom layer)
    if ball_holder is not None and ball_holder in players:
        _draw_pass_recommendations(out, ball_holder, players)

    # Ball holder ring
    if ball_holder is not None and ball_holder in players:
        cx, cy = players[ball_holder]
        _draw_holder_ring(out, int(cx), int(cy))

    # Recent pass arrows
    _draw_pass_arrows(out, recent_passes)

    # Ball
    if ball:
        _draw_ball(out, ball)

    # Player labels
    for pid, (cx, cy) in players.items():
        display_id = id_map.get(pid, pid) if id_map else pid
        _draw_player_label(out, display_id, int(cx), int(cy), pid == ball_holder)

    # HUD elements
    _draw_pass_counter(out, total_passes)
    if commentary:
        _draw_commentary(out, commentary)

    return out


# -- Ball holder ----------------------------------------------------------------

def _draw_holder_ring(frame, cx: int, cy: int) -> None:
    fy = cy + _FEET_OFFSET_Y
    cv2.circle(frame, (cx, fy), 24, _HOLD_RING_OUTER, 3, cv2.LINE_AA)
    cv2.circle(frame, (cx, fy), 17, _HOLD_RING_INNER, 1, cv2.LINE_AA)


# -- Pass recommendations -------------------------------------------------------

def _draw_pass_recommendations(frame, holder_id: int, players: dict) -> None:
    hx, hy = players[holder_id]

    candidates = [
        (math.dist((hx, hy), (cx, cy)), pid, cx, cy)
        for pid, (cx, cy) in players.items()
        if pid != holder_id and _PASS_MIN_DIST <= math.dist((hx, hy), (cx, cy)) <= _PASS_MAX_DIST
    ]
    if not candidates:
        return

    candidates.sort()
    targets = _pick_spread_targets(hx, hy, candidates)

    for rank, (_, pid, cx, cy) in enumerate(targets):
        alpha = max(0.45, 1.0 - rank * 0.22)
        color = tuple(int(c * alpha) for c in _PASS_REC_COLOR)
        _draw_dashed_arrow(
            frame,
            (int(hx), int(hy) + _FEET_OFFSET_Y),
            (int(cx), int(cy) + _FEET_OFFSET_Y),
            color=color,
            thickness=2,
        )
        cv2.circle(frame, (int(cx), int(cy) + _FEET_OFFSET_Y),
                   8, color, 2, cv2.LINE_AA)


def _pick_spread_targets(hx, hy, candidates: list) -> list:
    selected = [candidates[0]]
    for cand in candidates[1:]:
        if len(selected) >= _MAX_REC_TARGETS:
            break
        angle = math.atan2(cand[3] - hy, cand[2] - hx)
        too_close_angle = any(
            abs(math.atan2(s[3] - hy, s[2] - hx) - angle) < math.radians(_SPREAD_MIN_DEG)
            for s in selected
        )
        if not too_close_angle:
            selected.append(cand)
    return selected


def _draw_dashed_arrow(
    frame, p1: tuple, p2: tuple, color: tuple,
    thickness: int = 2, dash: int = 12, gap: int = 7,
) -> None:
    x1, y1 = p1
    x2, y2 = p2
    length = math.dist(p1, p2)
    if length < 1:
        return
    dx, dy = (x2 - x1) / length, (y2 - y1) / length
    pos, drawing = 0.0, True
    while pos < length:
        seg = dash if drawing else gap
        end = min(pos + seg, length)
        if drawing:
            sx, sy = int(x1 + dx * pos), int(y1 + dy * pos)
            ex, ey = int(x1 + dx * end), int(y1 + dy * end)
            cv2.line(frame, (sx, sy), (ex, ey), color, thickness, cv2.LINE_AA)
        pos += seg
        drawing = not drawing
    # Arrowhead
    tip_start = (int(x2 - dx * 18), int(y2 - dy * 18))
    cv2.arrowedLine(frame, tip_start, (x2, y2), color, thickness, cv2.LINE_AA, tipLength=0.6)


# -- Recent pass arrows ---------------------------------------------------------

def _draw_pass_arrows(frame, recent_passes: list) -> None:
    for p in recent_passes:
        alpha = max(0.0, 1.0 - p.get("age", 0) / 50)
        if alpha < 0.05:
            continue
        fx = int(p["from_pos"][0]);  fy = int(p["from_pos"][1]) + _FEET_OFFSET_Y
        tx = int(p["to_pos"][0]);    ty = int(p["to_pos"][1])   + _FEET_OFFSET_Y
        cv2.arrowedLine(frame, (fx, fy), (tx, ty),
                        tuple(int(c * alpha) for c in _ARROW_GLOW),
                        max(1, int(8 * alpha)), cv2.LINE_AA, tipLength=0.22)
        cv2.arrowedLine(frame, (fx, fy), (tx, ty),
                        tuple(int(c * alpha) for c in _ARROW_BLUE),
                        max(1, int(3 * alpha)), cv2.LINE_AA, tipLength=0.22)


# -- Ball -----------------------------------------------------------------------

def _draw_ball(frame, center: tuple) -> None:
    bx, by = int(center[0]), int(center[1])
    cv2.circle(frame, (bx, by),  9, (0, 195, 255), -1, cv2.LINE_AA)
    cv2.circle(frame, (bx, by),  9, (255, 255, 255), 1, cv2.LINE_AA)
    cv2.circle(frame, (bx, by), 15, (0, 195, 255),   1, cv2.LINE_AA)


# -- Player label ---------------------------------------------------------------

def _draw_player_label(frame, display_id: int, cx: int, cy: int, is_holder: bool) -> None:
    font, scale, thick = cv2.FONT_HERSHEY_SIMPLEX, 0.40, 1
    label = f"{display_id}"
    (tw, th), _ = cv2.getTextSize(label, font, scale, thick)
    lx, ly = cx - tw // 2, cy - 22
    bg = (0, 150, 80) if is_holder else (20, 20, 20)
    cv2.rectangle(frame, (lx - 4, ly - th - 3), (lx + tw + 4, ly + 3), bg, -1)
    cv2.putText(frame, label, (lx, ly), font, scale, (255, 255, 255), thick, cv2.LINE_AA)


# -- HUD -----------------------------------------------------------------------

def _draw_pass_counter(frame, count: int) -> None:
    h, w = frame.shape[:2]
    label = f"Passes : {count}"
    font, scale, thick = cv2.FONT_HERSHEY_SIMPLEX, 0.75, 2
    (tw, th), _ = cv2.getTextSize(label, font, scale, thick)
    pad = 10
    x, y = w - tw - pad * 2 - 4, h - pad - 4
    cv2.rectangle(frame, (x - pad, y - th - pad), (x + tw + pad, y + pad), (0, 0, 0), -1)
    cv2.putText(frame, label, (x, y), font, scale, (255, 255, 255), thick, cv2.LINE_AA)


def _draw_commentary(frame, insights: list[str]) -> None:
    font, scale, thick = cv2.FONT_HERSHEY_SIMPLEX, 0.58, 2
    y = 38
    for text in insights:
        text = text.encode("ascii", errors="replace").decode("ascii").replace("?", " ").strip()
        (tw, th), _ = cv2.getTextSize(text, font, scale, thick)
        cv2.rectangle(frame, (8, y - th - 6), (18 + tw, y + 6), (0, 0, 0), -1)
        cv2.putText(frame, text, (12, y), font, scale, (0, 0, 0),     thick + 1, cv2.LINE_AA)
        cv2.putText(frame, text, (12, y), font, scale, (60, 220, 80), thick,     cv2.LINE_AA)
        y += th + 14


# -- Zone helper (used by heatmap_engine) ---------------------------------------

def draw_zone(
    frame,
    top_left:     tuple,
    bottom_right: tuple,
    color:        tuple = (60, 200, 60),
    alpha:        float = 0.20,
    label:        str   = "",
) -> None:
    overlay = frame.copy()
    cv2.rectangle(overlay, top_left, bottom_right, color, -1)
    cv2.addWeighted(overlay, alpha, frame, 1 - alpha, 0, frame)
    cv2.rectangle(frame, top_left, bottom_right, color, 2, cv2.LINE_AA)
    if label:
        cv2.putText(frame, label, (top_left[0] + 6, top_left[1] + 22),
                    cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2, cv2.LINE_AA)
