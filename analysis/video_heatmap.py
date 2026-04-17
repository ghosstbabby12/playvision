"""
video_heatmap.py — Dynamic heatmap overlay on real video frames.

Pipeline per frame:
  detections → accumulate positions (with temporal decay) →
  Gaussian blur → normalise → colormap → alpha-blend on frame

Does NOT touch detection or tracking logic.
"""

import cv2
import numpy as np


# ── Tuneable defaults ─────────────────────────────────────────────────────────
_BLUR_K          = 61      # Gaussian kernel (must be odd) — larger = more spread
_DECAY           = 0.96    # per-frame exponential decay (1.0 = no decay, 0.0 = instant)
_HEAT_ALPHA      = 0.45    # heatmap opacity over the video frame
_NOISE_CUT       = 20      # uint8 values below this become 0 (removes cold-blue noise)
_PLAYER_RADIUS   = 18      # pixels added as a filled circle per detection (pre-blur)


class VideoHeatmapOverlay:
    """
    Stateful accumulator: call `update()` each analysed frame,
    then `apply()` to get the blended frame ready for the writer.

    Designed to run inside the existing analysis loop with zero
    changes to detection or tracking code.
    """

    def __init__(
        self,
        width:   int,
        height:  int,
        decay:   float = _DECAY,
        blur_k:  int   = _BLUR_K,
        alpha:   float = _HEAT_ALPHA,
    ):
        self.w      = width
        self.h      = height
        self.decay  = decay
        self.blur_k = blur_k if blur_k % 2 == 1 else blur_k + 1
        self.alpha  = alpha

        # Accumulated heat buffer — float32 for smooth decay
        self._raw = np.zeros((height, width), dtype=np.float32)

    # ── Public API ────────────────────────────────────────────────────────────

    def update(self, frame_players: dict[int, tuple]) -> None:
        """
        Call once per analysed frame.

        Args:
            frame_players: dict[track_id → (cx, cy)]  — same object
                           returned by detector.detect_frame()
        """
        # Exponential decay — old heat fades
        if self.decay < 1.0:
            self._raw *= self.decay

        if not frame_players:
            return

        # Vectorised position accumulation — draw filled circles on the buffer
        for cx, cy in frame_players.values():
            ix = int(np.clip(cx, 0, self.w - 1))
            iy = int(np.clip(cy, 0, self.h - 1))
            # cv2.circle is faster than Python loops for small radii
            cv2.circle(self._raw, (ix, iy), _PLAYER_RADIUS, 1.0, -1)

    def apply(self, frame: np.ndarray) -> np.ndarray:
        """
        Blend the current accumulated heatmap onto `frame`.

        Args:
            frame: BGR frame from the video (will NOT be modified in-place)

        Returns:
            New BGR frame with heatmap overlay.
        """
        colored = self._build_colored()
        if colored is None:
            return frame

        # Alpha blend: result = frame * (1 - alpha) + colored * alpha
        return cv2.addWeighted(frame, 1.0 - self.alpha, colored, self.alpha, 0)

    def reset(self) -> None:
        """Clear accumulated heat (call between match segments if needed)."""
        self._raw[:] = 0.0

    # ── Internal helpers ──────────────────────────────────────────────────────

    def _build_colored(self) -> np.ndarray | None:
        """Blur → normalise → threshold → colormap → 3-channel BGR."""
        blurred = cv2.GaussianBlur(self._raw, (self.blur_k, self.blur_k), 0)

        max_val = blurred.max()
        if max_val < 1e-6:
            return None  # nothing accumulated yet

        norm  = blurred / max_val
        u8    = (norm * 255).astype(np.uint8)
        u8[u8 < _NOISE_CUT] = 0  # remove cold-blue noise at low-density areas

        colored = cv2.applyColorMap(u8, cv2.COLORMAP_TURBO)

        # Zero-heat areas → transparent (copy original pixel via mask)
        mask = u8 == 0
        colored[mask] = 0  # will be invisible after addWeighted with frame

        return colored


# ─────────────────────────────────────────────────────────────────────────────
# Standalone helper — useful for testing or generating a single heatmap frame
# ─────────────────────────────────────────────────────────────────────────────

def overlay_positions_on_frame(
    frame:        np.ndarray,
    positions:    list[tuple[float, float]],
    blur_k:       int   = _BLUR_K,
    alpha:        float = _HEAT_ALPHA,
    noise_cut:    int   = _NOISE_CUT,
    player_radius: int  = _PLAYER_RADIUS,
) -> np.ndarray:
    """
    Stateless single-frame heatmap overlay.

    Args:
        frame:     BGR video frame
        positions: list of (cx, cy) pixel coordinates for this frame
        ...tuning params

    Returns:
        BGR frame with heatmap overlay.
    """
    h, w = frame.shape[:2]
    raw  = np.zeros((h, w), dtype=np.float32)

    for cx, cy in positions:
        ix = int(np.clip(cx, 0, w - 1))
        iy = int(np.clip(cy, 0, h - 1))
        cv2.circle(raw, (ix, iy), player_radius, 1.0, -1)

    k       = blur_k if blur_k % 2 == 1 else blur_k + 1
    blurred = cv2.GaussianBlur(raw, (k, k), 0)
    max_val = blurred.max()
    if max_val < 1e-6:
        return frame

    u8 = (blurred / max_val * 255).astype(np.uint8)
    u8[u8 < noise_cut] = 0

    colored       = cv2.applyColorMap(u8, cv2.COLORMAP_TURBO)
    colored[u8 == 0] = 0

    return cv2.addWeighted(frame, 1.0 - alpha, colored, alpha, 0)
