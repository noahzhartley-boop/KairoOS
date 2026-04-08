#!/usr/bin/env bash
set -euo pipefail

# IxlworkOS: premium Android-based VM profile with iOS-like UX guidance.
# Usage:
#   ./create_ixlworkos_vm.sh /path/to/android-x86.iso
# Optional env overrides:
#   VM_NAME, RAM_MB, VCPUS, DISK_GB, BRIDGE_IFACE, DISK_DIR

VM_NAME="${VM_NAME:-IxlworkOS}"
RAM_MB="${RAM_MB:-49152}"               # 48 GB (intentionally not lightweight)
VCPUS="${VCPUS:-20}"
DISK_GB="${DISK_GB:-350}"
BRIDGE_IFACE="${BRIDGE_IFACE:-br0}"
DISK_DIR="${DISK_DIR:-/var/lib/libvirt/images}"
DISK_PATH="${DISK_DIR}/${VM_NAME}.qcow2"
ISO_PATH="${1:-/var/lib/libvirt/boot/blissos-16.iso}"
OS_VARIANT="${OS_VARIANT:-generic}"

require_cmd() {
  local cmd="$1"
  local install_hint="$2"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    echo "$install_hint" >&2
    exit 1
  fi
}

if [[ "$(id -u)" -ne 0 ]]; then
  SUDO="sudo"
else
  SUDO=""
fi

require_cmd virt-install "Install with: sudo apt install virtinst"
require_cmd qemu-img "Install with: sudo apt install qemu-utils"

if [[ ! -f "$ISO_PATH" ]]; then
  echo "Android ISO not found at: $ISO_PATH" >&2
  echo "Pass a valid Android-x86/BlissOS ISO path as arg 1." >&2
  exit 1
fi

if [[ -e "$DISK_PATH" ]]; then
  echo "Disk already exists at $DISK_PATH; refusing to overwrite." >&2
  exit 1
fi

if [[ "$VCPUS" -lt 8 ]]; then
  echo "VCPUS must be >= 8 for this premium profile." >&2
  exit 1
fi

if [[ "$RAM_MB" -lt 16384 ]]; then
  echo "RAM_MB must be >= 16384 for this premium profile." >&2
  exit 1
fi

echo "Creating Android-based premium VM: $VM_NAME"
echo "  RAM:   ${RAM_MB} MB"
echo "  vCPU:  ${VCPUS}"
echo "  Disk:  ${DISK_GB} GB"
echo "  ISO:   ${ISO_PATH}"

$SUDO mkdir -p "$DISK_DIR"
$SUDO qemu-img create -f qcow2 "$DISK_PATH" "${DISK_GB}G"

$SUDO virt-install \
  --name "$VM_NAME" \
  --memory "$RAM_MB" \
  --vcpus "$VCPUS" \
  --cpu host-passthrough \
  --machine q35 \
  --boot uefi \
  --disk path="$DISK_PATH",format=qcow2,bus=virtio,cache=none,discard=unmap,io=native \
  --controller type=scsi,model=virtio-scsi \
  --network bridge="$BRIDGE_IFACE",model=virtio \
  --graphics spice,listen=none \
  --video virtio,accel3d=yes \
  --sound model=ich9 \
  --input type=tablet,bus=usb \
  --features smm=on,vmport=off \
  --clock offset=utc \
  --cdrom "$ISO_PATH" \
  --os-variant "$OS_VARIANT" \
  --noautoconsole

cat <<MSG

VM '$VM_NAME' created.

To make it "look like iOS" (sort of) once Android is installed:
  1) Open Play Store
  2) Install launcher: 'Launcher iOS 18' (or similar)
  3) Install iOS icon pack and control-center style app
  4) Set gesture navigation + rounded icon theme

Tip: If your host supports it, GPU passthrough will make UI animation much smoother.
MSG
