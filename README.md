# IxlworkOS (Android-based, iOS-style) VM Profile

This project creates a **premium Android-based VM** called **IxlworkOS**.
It is intentionally **not lightweight** and tuned for smooth UX and strong performance.

## What changed (better build)

- Base platform: **Android-x86 / BlissOS ISO**
- Visual goal: **iOS-like look** (via launcher + icon/theme setup after install)
- Heavy profile by default:
  - 20 vCPUs
  - 48 GB RAM
  - 350 GB disk
- Better device config for UI fluidity:
  - `virtio` disk/network/video
  - 3D accelerated virtio video
  - USB tablet input (better touch-like pointer feel)
  - UEFI + q35 machine type

## Quick start

```bash
./create_ixlworkos_vm.sh /path/to/android-x86-or-blissos.iso
```

Default ISO path if omitted:

`/var/lib/libvirt/boot/blissos-16.iso`

## Requirements

- Linux host with KVM/libvirt
- `virt-install` and `qemu-img`
- sudo/root privileges
- A bridge network named `br0` (or set `BRIDGE_IFACE`)

## Optional tuning via environment variables

```bash
VM_NAME=IxlworkOS \
RAM_MB=65536 \
VCPUS=24 \
DISK_GB=500 \
BRIDGE_IFACE=br0 \
./create_ixlworkos_vm.sh /isos/blissos.iso
```

## Make Android look like iOS (sort of)

After first boot and setup in Android:

1. Install an iOS-style launcher (example: "Launcher iOS 18").
2. Install an iOS icon pack and control-center style app.
3. Enable gestures, animation scale, and icon rounding in launcher settings.
4. Use a high-refresh host display and (if possible) GPU passthrough for smoother animations.

## Notes

- This is not a true iOS system; it is Android configured to feel iOS-like.
- For best results, use a recent BlissOS/Android-x86 build and host GPU acceleration.
