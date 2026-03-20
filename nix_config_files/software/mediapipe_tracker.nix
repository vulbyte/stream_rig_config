# mediapipe_tracker.nix
# NixOS configuration for real-time face + pose tracking via MediaPipe,
# streaming landmark data to Godot over OSC (UDP).
#
# Stack:
#   Webcam -> MediaPipe (Python venv) -> OSC UDP -> Godot
#   Kinect v2 -> libfreenect2 -> OSC UDP -> Godot  [see kinect_v2.nix]
#
# mediapipe and python-osc are not in nixpkgs, so this file:
#   1. Installs a base Python with pip via systemPackages
#   2. Deploys face_tracker.py to ~/tracker/ automatically
#   3. Runs a one-shot systemd user service on login that creates the venv
#      and pip-installs mediapipe + python-osc automatically
#
# After a fresh install, log in and the venv will be ready within ~1 minute.
# Run the tracker with (close OBS first — it holds the camera exclusively):
#   ~/tracker/run_tracker.sh --camera /dev/video1
#
# To force a venv reinstall (e.g. after a mediapipe update):
#   rm ~/tracker/venv/.nix-setup-done
#   systemctl --user restart tracker-venv-setup
#
# Import this in your configuration.nix:
#   imports = [ ./mediapipe_tracker.nix ];

{ config, pkgs, lib, ... }:

let
  # ── Tracker script ─────────────────────────────────────────────────────────
  # Deployed automatically to ~/tracker/face_tracker.py by the systemd service.
  faceTrackerScript = pkgs.writeText "face_tracker.py" ''
    #!/usr/bin/env python3
    """
    MediaPipe -> OSC face + pose tracker for Godot.
    Uses the modern MediaPipe Tasks API (0.10+).

    OSC addresses emitted:
      /face/landmarks  -- 1434 floats: x,y,z per face mesh landmark (478 pts)
      /pose/landmarks  -- 99 floats:   x,y,z per pose landmark (33 joints)
      /pose/world      -- 99 floats:   world-space pose landmarks (metres)
      /tracker/fps     -- float: current tracker frame rate

    Usage:
      python3 face_tracker.py [--camera 1] [--ip 127.0.0.1] [--port 9000] [--preview]
    """

    import argparse
    import time
    import urllib.request
    import os
    import cv2
    import mediapipe as mp
    from mediapipe.tasks import python as mp_python
    from mediapipe.tasks.python import vision as mp_vision
    from pythonosc import udp_client

    parser = argparse.ArgumentParser(description="MediaPipe -> OSC tracker")
    parser.add_argument("--camera",  type=str,  default="/dev/video1", help="camera device path (default: /dev/video1)")
    parser.add_argument("--width",   type=int,  default=1280,        help="capture width")
    parser.add_argument("--height",  type=int,  default=720,         help="capture height")
    parser.add_argument("--ip",      type=str,  default="127.0.0.1", help="OSC target IP")
    parser.add_argument("--port",    type=int,  default=9000,        help="OSC target port")
    parser.add_argument("--preview", action="store_true",            help="show preview window")
    args = parser.parse_args()

    client = udp_client.SimpleUDPClient(args.ip, args.port)
    print(f"Streaming OSC -> {args.ip}:{args.port}")

    # ── Download model files if not present ───────────────────────────────────
    MODEL_DIR = os.path.expanduser("~/tracker/models")
    os.makedirs(MODEL_DIR, exist_ok=True)

    FACE_MODEL = os.path.join(MODEL_DIR, "face_landmarker.task")
    POSE_MODEL = os.path.join(MODEL_DIR, "pose_landmarker_full.task")

    if not os.path.exists(FACE_MODEL):
        print("Downloading face landmarker model...")
        urllib.request.urlretrieve(
            "https://storage.googleapis.com/mediapipe-models/face_landmarker/face_landmarker/float16/latest/face_landmarker.task",
            FACE_MODEL
        )
        print("Face model downloaded.")

    if not os.path.exists(POSE_MODEL):
        print("Downloading pose landmarker model...")
        urllib.request.urlretrieve(
            "https://storage.googleapis.com/mediapipe-models/pose_landmarker/pose_landmarker_full/float16/latest/pose_landmarker_full.task",
            POSE_MODEL
        )
        print("Pose model downloaded.")

    # ── MediaPipe Tasks setup ─────────────────────────────────────────────────
    BaseOptions = mp_python.BaseOptions
    FaceLandmarker = mp_vision.FaceLandmarker
    FaceLandmarkerOptions = mp_vision.FaceLandmarkerOptions
    PoseLandmarker = mp_vision.PoseLandmarker
    PoseLandmarkerOptions = mp_vision.PoseLandmarkerOptions
    VisionRunningMode = mp_vision.RunningMode

    face_options = FaceLandmarkerOptions(
        base_options=BaseOptions(model_asset_path=FACE_MODEL),
        running_mode=VisionRunningMode.IMAGE,
        num_faces=1,
        min_face_detection_confidence=0.5,
        min_face_presence_confidence=0.5,
        min_tracking_confidence=0.5,
        output_face_blendshapes=False,
    )
    pose_options = PoseLandmarkerOptions(
        base_options=BaseOptions(model_asset_path=POSE_MODEL),
        running_mode=VisionRunningMode.IMAGE,
        min_pose_detection_confidence=0.5,
        min_pose_presence_confidence=0.5,
        min_tracking_confidence=0.5,
    )

    face_landmarker = FaceLandmarker.create_from_options(face_options)
    pose_landmarker = PoseLandmarker.create_from_options(pose_options)

    # ── Camera ────────────────────────────────────────────────────────────────
    cap = cv2.VideoCapture(args.camera, cv2.CAP_V4L2)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH,  args.width)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, args.height)
    cap.set(cv2.CAP_PROP_FPS, 30)

    if not cap.isOpened():
        raise RuntimeError(
            f"Could not open {args.camera}. "
            f"Run `v4l2-ctl --list-devices` to find the right device, "
            f"then rerun with --camera /dev/videoN."
        )

    print(f"Camera {args.camera} opened at {args.width}x{args.height}")
    print("Press Ctrl+C to stop.")

    prev_time = time.time()

    try:
        while True:
            ret, frame = cap.read()
            if not ret:
                continue

            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)

            # ── Face landmarks ────────────────────────────────────────────────
            face_result = face_landmarker.detect(mp_image)
            if face_result.face_landmarks:
                coords = []
                for lm in face_result.face_landmarks[0]:
                    coords.extend([lm.x, lm.y, lm.z])
                client.send_message("/face/landmarks", coords)

            # ── Pose landmarks ────────────────────────────────────────────────
            pose_result = pose_landmarker.detect(mp_image)
            if pose_result.pose_landmarks:
                coords = []
                for lm in pose_result.pose_landmarks[0]:
                    coords.extend([lm.x, lm.y, lm.z])
                client.send_message("/pose/landmarks", coords)

            if pose_result.pose_world_landmarks:
                coords = []
                for lm in pose_result.pose_world_landmarks[0]:
                    coords.extend([lm.x, lm.y, lm.z])
                client.send_message("/pose/world", coords)

            # ── FPS heartbeat ─────────────────────────────────────────────────
            now = time.time()
            fps = 1.0 / (now - prev_time + 1e-9)
            prev_time = now
            client.send_message("/tracker/fps", float(fps))

            if args.preview:
                cv2.putText(frame, f"FPS: {fps:.1f}", (10, 30),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, (0, 255, 0), 2)
                cv2.imshow("Tracker preview", frame)
                if cv2.waitKey(1) & 0xFF == ord("q"):
                    break

    except KeyboardInterrupt:
        print("\nTracker stopped.")
    finally:
        cap.release()
        face_landmarker.close()
        pose_landmarker.close()
        if args.preview:
            cv2.destroyAllWindows()
  '';

  # ── venv bootstrap script ──────────────────────────────────────────────────
  trackerSetupScript = pkgs.writeShellScript "tracker-venv-setup" ''
    set -euo pipefail

    TRACKER_DIR="$HOME/tracker"
    VENV="$TRACKER_DIR/venv"
    MARKER="$VENV/.nix-setup-done"

    mkdir -p "$TRACKER_DIR"

    # Always keep the tracker script up to date with what's in the nix store
    cp --no-preserve=mode ${faceTrackerScript} "$TRACKER_DIR/face_tracker.py"
    chmod +x "$TRACKER_DIR/face_tracker.py"

    # Write a launcher wrapper that sets NIX_LD_LIBRARY_PATH before running
    # the tracker. This ensures pip-installed native libs (numpy, mediapipe)
    # can find libstdc++.so.6 and friends at runtime.
    cat > "$TRACKER_DIR/run_tracker.sh" << 'EOF'
#!/usr/bin/env bash
export NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib
export LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib
exec "$HOME/tracker/venv/bin/python3" "$HOME/tracker/face_tracker.py" "''${@:---camera /dev/video1}"
EOF
    chmod +x "$TRACKER_DIR/run_tracker.sh"

    # Only reinstall packages if the marker is missing
    if [ ! -f "$MARKER" ]; then
      echo "tracker-venv-setup: creating venv..."
      rm -rf "$VENV"
      NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib \
      LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib \
      ${pkgs.python3}/bin/python3 -m venv "$VENV"
      "$VENV/bin/pip" install --upgrade pip
      NIX_LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib \
      LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib \
      "$VENV/bin/pip" install mediapipe python-osc
      touch "$MARKER"
      echo "tracker-venv-setup: done. Run with:"
      echo "  ~/tracker/run_tracker.sh --camera /dev/video1"
      echo "NOTE: Close OBS before running — OBS holds /dev/video1 exclusively."
    else
      echo "tracker-venv-setup: venv already ready, skipping pip install."
    fi
  '';

in
{
  # ── System packages ────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Base Python — the venv setup service uses this to bootstrap
    (python3.withPackages (ps: with ps; [
      pip
      virtualenv
      opencv4       # camera capture (already in nixpkgs)
      numpy
      pillow
    ]))

    # GStreamer — required for OpenCV V4L2 camera access on NixOS
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good    # provides v4l2src

    # Useful tools
    git
    v4l-utils                     # v4l2-ctl --list-devices
  ];

  # ── nix-ld library path ────────────────────────────────────────────────────
  # Makes pip-installed native extensions (mediapipe) find system libs.
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib    # libstdc++.so.6
    gcc-unwrapped.lib
    zlib
    libGL
    libGLU
    glib
    # X11 / xcb — needed by OpenCV and mediapipe GUI
    xorg.libX11
    xorg.libXext
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilwm
    # GStreamer
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    # Other common deps
    libffi
    expat
    fontconfig
    freetype
  ];

  # ── Automated venv setup ───────────────────────────────────────────────────
  # Runs once per user session on login. Creates ~/tracker/venv and
  # pip-installs mediapipe + python-osc. Skips if already done.
  systemd.user.services.tracker-venv-setup = {
    description = "Set up MediaPipe tracker Python venv";
    wantedBy = [ "default.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${trackerSetupScript}";
      RemainAfterExit = true;
    };
  };

  # ── Graphics ───────────────────────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # ── udev: webcam access ────────────────────────────────────────────────────
  # UVC webcams (Logitech C920 etc.) are handled automatically by uvcvideo.
  # Ensure your user is in the "video" group:
  #   users.users.yourUsername.extraGroups = [ "video" ];
}

