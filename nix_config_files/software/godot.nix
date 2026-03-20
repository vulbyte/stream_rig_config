# godot.nix
# NixOS configuration for Godot 4 development and VTubing/streaming.
# Includes Godot 4, OBS Studio, and supporting tools.
#
# Import this in your configuration.nix:
#   imports = [ ./godot.nix ];

{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    # ── Game engine ────────────────────────────────────────────────────────
    godot_4
  ];
}

# ── Godot OSC setup ────────────────────────────────────────────────────────
#
# To receive tracker data from face_tracker.py in Godot 4:
#
# OPTION A — GodotOSC plugin (recommended):
#   1. Open Godot → AssetLib → search "OSC" → install "GodotOSC"
#   2. Add an OscReceiver node to your scene
#   3. Set Port to 9000
#   4. Connect the osc_msg_received(address, args) signal:
#
#      func _on_osc_msg_received(address: String, args: Array):
#          if address == "/face/landmarks":
#              # args is a flat array of floats: x0,y0,z0, x1,y1,z1, ...
#              # 478 landmarks × 3 = 1434 floats
#              var i = 0
#              for landmark_idx in range(478):
#                  var x = args[i];   var y = args[i+1];   var z = args[i+2]
#                  i += 3
#                  # use x,y,z to drive blend shapes or bone transforms
#
#          elif address == "/pose/world":
#              # 33 pose joints × 3 = 99 floats (world space, metres)
#              # Joint indices follow MediaPipe Pose landmark map:
#              # 0=nose 11=left_shoulder 12=right_shoulder
#              # 13=left_elbow 14=right_elbow 15=left_wrist 16=right_wrist
#              # 23=left_hip 24=right_hip 25=left_knee 26=right_knee
#              var i = 0
#              for joint_idx in range(33):
#                  var x = args[i];   var y = args[i+1];   var z = args[i+2]
#                  i += 3
#
# OPTION B — no plugin, raw UDP:
#   extends Node
#   var udp := PacketPeerUDP.new()
#   func _ready():
#       udp.bind(9000)
#   func _process(_delta):
#       while udp.get_available_packet_count() > 0:
#           var pkt = udp.get_packet()
#           # parse OSC packet manually or use a GDScript OSC library
#
# ── MediaPipe pose landmark indices (for Godot skeleton mapping) ────────────
#
#  0  nose              11 left_shoulder    12 right_shoulder
#  13 left_elbow        14 right_elbow      15 left_wrist
#  16 right_wrist       23 left_hip         24 right_hip
#  25 left_knee         26 right_knee       27 left_ankle
#  28 right_ankle
#
# Map these to your Godot Skeleton3D bones to drive body posture from the
# Kinect/webcam data streamed by face_tracker.py.
#
# ── OBS setup for streaming ────────────────────────────────────────────────
#
# 1. Add a "Window Capture (PipeWire)" source → select the Godot window
# 2. Add your mic as an "Audio Input Capture (PipeWire)" source
# 3. No ALSA/PulseAudio needed — PipeWire handles everything natively
# 4. If the Godot window doesn't appear in the list, make sure
#    xdg-desktop-portal is running:
#      systemctl --user status xdg-desktop-portal

