"""
heatmap_engine.py — Tactical top-down heatmap generation.

Pipeline:
  1. Homography: camera perspective → top-down 2D pitch
  2. Accumulate player positions per team
  3. Gaussian smoothing + normalisation + colormap
  4. Draw clean 2D pitch and overlay heatmap

Does NOT touch detection or tracking logic.
"""

import cv2
import numpy as np
from dataclasses import dataclass, field
from typing import Optional

# ── Pitch dimensions (standard FIFA) ─────────────────────────────────────────
PITCH_W_M = 105.0   # metres
PITCH_H_M = 68.0    # metres

# Output canvas in pixels (scale keeps aspect ratio)
CANVAS_W = 1050
CANVAS_H = int(CANVAS_W * PITCH_H_M / PITCH_W_M)   # 680 px

# ── Gaussian kernel size (must be odd) ───────────────────────────────────────
BLUR_K = 51          # larger → smoother / more spread
NOISE_THRESHOLD = 15 # values below this are zeroed out


# ─────────────────────────────────────────────────────────────────────────────
# Data structures
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class PlayerDetection:
    track_id: int
    x: float   # pixel coordinate in original video frame
    y: float
    team: str  # "A" | "B"


@dataclass
class HeatmapEngine:
    """
    Stateful engine: accumulates positions across many frames,
    then renders on demand.

    Usage:
        engine = HeatmapEngine(src_points)
        for frame_detections in frames:
            engine.update(frame_detections, frame_w, frame_h)
        result = engine.render()
    """

    # 4 corners of the playing field in camera-view pixel coordinates.
    # Order: top-left, top-right, bottom-right, bottom-left.
    src_points: np.ndarray

    canvas_w: int = CANVAS_W
    canvas_h: int = CANVAS_H

    # Accumulated heatmaps (lazy-initialised in update)
    _heatmap_A: np.ndarray = field(init=False, default=None)
    _heatmap_B: np.ndarray = field(init=False, default=None)
    _H: np.ndarray         = field(init=False, default=None)

    def __post_init__(self):
        self._heatmap_A = np.zeros((self.canvas_h, self.canvas_w), dtype=np.float32)
        self._heatmap_B = np.zeros((self.canvas_h, self.canvas_w), dtype=np.float32)
        self._H = _compute_homography(self.src_points, self.canvas_w, self.canvas_h)

    # ── Public API ────────────────────────────────────────────────────────────

    def update(self, detections: list[PlayerDetection]) -> None:
        """Accumulate one frame of detections."""
        if not detections:
            return

        pts = np.array([[d.x, d.y] for d in detections], dtype=np.float32).reshape(-1, 1, 2)
        transformed = cv2.perspectiveTransform(pts, self._H).reshape(-1, 2)

        for i, det in enumerate(detections):
            tx = int(np.clip(transformed[i, 0], 0, self.canvas_w - 1))
            ty = int(np.clip(transformed[i, 1], 0, self.canvas_h - 1))
            if det.team == "A":
                self._heatmap_A[ty, tx] += 1.0
            else:
                self._heatmap_B[ty, tx] += 1.0

    def render(self) -> dict[str, np.ndarray]:
        """
        Build and return tactical heatmap images.

        Returns:
            {
                "heatmap_team_A":  BGR image,
                "heatmap_team_B":  BGR image,
                "combined_heatmap": BGR image,
            }
        """
        pitch = draw_pitch(self.canvas_w, self.canvas_h)

        hm_A = _process_heatmap(self._heatmap_A)
        hm_B = _process_heatmap(self._heatmap_B)
        hm_C = _process_heatmap(self._heatmap_A + self._heatmap_B)

        return {
            "heatmap_team_A":   _overlay(pitch, hm_A),
            "heatmap_team_B":   _overlay(pitch, hm_B),
            "combined_heatmap": _overlay(pitch, hm_C),
        }

    def reset(self) -> None:
        """Clear accumulated data (call between matches)."""
        self._heatmap_A[:] = 0
        self._heatmap_B[:] = 0

    def render_frame_heatmap(
        self,
        detections: list[PlayerDetection],
        *,
        team: Optional[str] = None,
    ) -> np.ndarray:
        """
        Stateless: render heatmap for a single batch of detections
        without modifying internal state.  Useful for per-player previews.

        Args:
            detections: player detections to visualise
            team:       "A", "B", or None (all)
        """
        canvas = np.zeros((self.canvas_h, self.canvas_w), dtype=np.float32)

        if detections:
            pts = np.array([[d.x, d.y] for d in detections], dtype=np.float32).reshape(-1, 1, 2)
            transformed = cv2.perspectiveTransform(pts, self._H).reshape(-1, 2)

            for i, det in enumerate(detections):
                if team is not None and det.team != team:
                    continue
                tx = int(np.clip(transformed[i, 0], 0, self.canvas_w - 1))
                ty = int(np.clip(transformed[i, 1], 0, self.canvas_h - 1))
                canvas[ty, tx] += 1.0

        pitch = draw_pitch(self.canvas_w, self.canvas_h)
        return _overlay(pitch, _process_heatmap(canvas))


# ─────────────────────────────────────────────────────────────────────────────
# Pure functions (reusable, stateless)
# ─────────────────────────────────────────────────────────────────────────────

def _compute_homography(
    src_points: np.ndarray,
    canvas_w: int,
    canvas_h: int,
) -> np.ndarray:
    """
    Compute the 3×3 perspective transform matrix.

    src_points: shape (4, 2) — field corners in camera-view pixels.
                Order: top-left, top-right, bottom-right, bottom-left.
    """
    dst = np.array([
        [0,        0       ],
        [canvas_w, 0       ],
        [canvas_w, canvas_h],
        [0,        canvas_h],
    ], dtype=np.float32)

    H = cv2.getPerspectiveTransform(src_points.astype(np.float32), dst)
    return H


def transform_points(
    points: np.ndarray,
    H: np.ndarray,
    canvas_w: int,
    canvas_h: int,
) -> np.ndarray:
    """
    Vectorised perspective transform for N points.

    Args:
        points:   (N, 2) float32 array of (x, y) camera-view coordinates
        H:        (3, 3) homography matrix
        canvas_w: output canvas width  (for clipping)
        canvas_h: output canvas height (for clipping)

    Returns:
        (N, 2) int32 array of top-down (tx, ty) coordinates
    """
    pts = points.reshape(-1, 1, 2).astype(np.float32)
    transformed = cv2.perspectiveTransform(pts, H).reshape(-1, 2)
    transformed[:, 0] = np.clip(transformed[:, 0], 0, canvas_w - 1)
    transformed[:, 1] = np.clip(transformed[:, 1], 0, canvas_h - 1)
    return transformed.astype(np.int32)


def build_heatmap(
    positions: np.ndarray,
    canvas_w: int,
    canvas_h: int,
    blur_k: int = BLUR_K,
    noise_threshold: int = NOISE_THRESHOLD,
) -> np.ndarray:
    """
    Accumulate positions into a smoothed, normalised uint8 heatmap.

    Args:
        positions:       (N, 2) int array of (tx, ty) top-down coords
        canvas_w/h:      output dimensions
        blur_k:          Gaussian kernel size (must be odd)
        noise_threshold: pixel values below this are zeroed

    Returns:
        uint8 single-channel heatmap (0–255)
    """
    canvas = np.zeros((canvas_h, canvas_w), dtype=np.float32)

    if positions.size > 0:
        # NumPy vectorised accumulation via advanced indexing
        np.add.at(canvas, (positions[:, 1], positions[:, 0]), 1.0)

    return _process_heatmap(canvas, blur_k=blur_k, noise_threshold=noise_threshold)


def _process_heatmap(
    raw: np.ndarray,
    blur_k: int = BLUR_K,
    noise_threshold: int = NOISE_THRESHOLD,
) -> np.ndarray:
    """Smooth → normalise → denoise → return uint8."""
    blurred = cv2.GaussianBlur(raw, (blur_k, blur_k), 0)
    norm    = blurred / (blurred.max() + 1e-6)
    uint8   = (norm * 255).astype(np.uint8)
    uint8[uint8 < noise_threshold] = 0
    return uint8


def apply_colormap(heatmap_uint8: np.ndarray) -> np.ndarray:
    """Apply TURBO colormap; zero pixels stay black."""
    colored = cv2.applyColorMap(heatmap_uint8, cv2.COLORMAP_TURBO)
    # Mask zero areas to transparent black instead of deep-blue artifact
    mask = heatmap_uint8 == 0
    colored[mask] = [0, 0, 0]
    return colored


def _overlay(
    pitch: np.ndarray,
    heatmap_uint8: np.ndarray,
    field_alpha: float = 0.65,
    heat_alpha:  float = 0.55,
) -> np.ndarray:
    """Overlay colourised heatmap on top of the pitch image."""
    colored = apply_colormap(heatmap_uint8)
    return cv2.addWeighted(pitch, field_alpha, colored, heat_alpha, 0)


# ─────────────────────────────────────────────────────────────────────────────
# Pitch drawing
# ─────────────────────────────────────────────────────────────────────────────

def draw_pitch(
    width: int  = CANVAS_W,
    height: int = CANVAS_H,
) -> np.ndarray:
    """
    Draw a clean top-down 2D football pitch with OpenCV.

    Returns a BGR image of shape (height, width, 3).
    """
    img = np.zeros((height, width, 3), dtype=np.uint8)

    # ── Background stripes ────────────────────────────────────
    n_stripes = 10
    stripe_w  = width // n_stripes
    for i in range(n_stripes):
        color = (22, 90, 22) if i % 2 == 0 else (18, 80, 18)
        img[:, i * stripe_w: (i + 1) * stripe_w] = color
    # Fill remainder
    img[:, n_stripes * stripe_w:] = (22, 90, 22)

    lc = (200, 220, 200)  # line colour
    lw = 2                # line width

    m  = int(height * 0.03)      # margin from edge

    fw = width  - 2 * m
    fh = height - 2 * m

    # ── Outer boundary ────────────────────────────────────────
    cv2.rectangle(img, (m, m), (m + fw, m + fh), lc, lw)

    # ── Halfway line ──────────────────────────────────────────
    cx = width // 2
    cv2.line(img, (cx, m), (cx, m + fh), lc, lw)

    # ── Centre circle ─────────────────────────────────────────
    cy      = height // 2
    c_rad   = int(fh * 0.146)   # ~9.15 m radius
    cv2.circle(img, (cx, cy), c_rad, lc, lw)
    cv2.circle(img, (cx, cy), 4, lc, -1)

    # ── Penalty areas (left & right) ─────────────────────────
    # Dimensions: 40.32 m wide × 16.5 m deep → proportional
    pa_w = int(fw * 0.157)   # 16.5/105
    pa_h = int(fh * 0.593)   # 40.32/68
    pa_t = (height - pa_h) // 2

    cv2.rectangle(img, (m, pa_t), (m + pa_w, pa_t + pa_h), lc, lw)
    cv2.rectangle(img, (m + fw - pa_w, pa_t), (m + fw, pa_t + pa_h), lc, lw)

    # ── Goal areas (6-yard boxes) ─────────────────────────────
    ga_w = int(fw * 0.057)   # 6/105
    ga_h = int(fh * 0.294)   # 20/68
    ga_t = (height - ga_h) // 2

    cv2.rectangle(img, (m, ga_t), (m + ga_w, ga_t + ga_h), lc, lw)
    cv2.rectangle(img, (m + fw - ga_w, ga_t), (m + fw, ga_t + ga_h), lc, lw)

    # ── Goals ─────────────────────────────────────────────────
    goal_h = int(fh * 0.118)   # 7.32/68 → ~8 m
    goal_d = int(fw * 0.019)   # ~2 m depth
    goal_t = (height - goal_h) // 2

    cv2.rectangle(img, (m - goal_d, goal_t), (m, goal_t + goal_h), lc, lw)
    cv2.rectangle(img, (m + fw, goal_t), (m + fw + goal_d, goal_t + goal_h), lc, lw)

    # ── Penalty spots ─────────────────────────────────────────
    pen_x_l = m + int(fw * 0.114)   # 12 m from goal line
    pen_x_r = m + fw - int(fw * 0.114)
    cv2.circle(img, (pen_x_l, cy), 4, lc, -1)
    cv2.circle(img, (pen_x_r, cy), 4, lc, -1)

    # ── Penalty arcs ──────────────────────────────────────────
    arc_r = int(fh * 0.134)   # 9.15 m
    cv2.ellipse(img, (pen_x_l, cy), (arc_r, arc_r), 0, -53, 53, lc, lw)
    cv2.ellipse(img, (pen_x_r, cy), (arc_r, arc_r), 0, 127, 233, lc, lw)

    # ── Corner arcs ───────────────────────────────────────────
    cr = int(fh * 0.014)   # 1 m
    cv2.ellipse(img, (m,      m),       (cr, cr), 0,   0,  90, lc, lw)
    cv2.ellipse(img, (m + fw, m),       (cr, cr), 0,  90, 180, lc, lw)
    cv2.ellipse(img, (m + fw, m + fh),  (cr, cr), 0, 180, 270, lc, lw)
    cv2.ellipse(img, (m,      m + fh),  (cr, cr), 0, 270, 360, lc, lw)

    return img


# ─────────────────────────────────────────────────────────────────────────────
# Convenience: build heatmap images from positions_sample list (JSON-friendly)
# ─────────────────────────────────────────────────────────────────────────────

def heatmap_from_positions_sample(
    players: list[dict],
    *,
    selected_rank: int | None = None,
    canvas_w: int = CANVAS_W,
    canvas_h: int = CANVAS_H,
) -> np.ndarray:
    """
    Build a heatmap image from the `positions_sample` already stored
    in the analysis result JSON (no homography needed — coords are
    already normalised 0-1).

    Args:
        players:       list of player dicts from metrics_engine output
        selected_rank: if set, only render that player
        canvas_w/h:    output canvas size

    Returns:
        BGR image ready for display or encoding
    """
    raw = np.zeros((canvas_h, canvas_w), dtype=np.float32)

    for p in players:
        if selected_rank is not None and p.get("rank") != selected_rank:
            continue
        for pos in p.get("positions_sample", []):
            tx = int(np.clip(pos["x"] * canvas_w, 0, canvas_w - 1))
            ty = int(np.clip(pos["y"] * canvas_h, 0, canvas_h - 1))
            raw[ty, tx] += 1.0

    pitch = draw_pitch(canvas_w, canvas_h)
    hm    = _process_heatmap(raw)
    return _overlay(pitch, hm)


def encode_heatmap_png(image: np.ndarray) -> bytes:
    """Encode a BGR numpy image to PNG bytes for API response."""
    ok, buf = cv2.imencode(".png", image)
    if not ok:
        raise RuntimeError("cv2.imencode failed")
    return buf.tobytes()
