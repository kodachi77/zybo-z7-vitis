#!/bin/bash

BUILD_FILE=".build"

# Ordered list of step names
ORDERED_STEPS=("hw" "rootfs" "kernel" "u-boot" "build" "sdk" "boot" "sysroot")

# Define step commands
declare -A STEP_MAP=(
    ["hw"]="petalinux-config --get-hw-description=../hw/hw_handoff/"
    ["rootfs"]="petalinux-config -c rootfs"
    ["kernel"]="petalinux-config -c kernel"
    ["u-boot"]="petalinux-config -c u-boot"
    ["build"]="petalinux-build"
    ["sdk"]="petalinux-build --sdk"
    ["boot"]="petalinux-package --boot --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot --force"
    ["sysroot"]="petalinux-package --sysroot"
)

# Display names for selection menu
declare -A STEP_DISPLAY=(
    ["hw"]="HW"
    ["rootfs"]="RootFS config"
    ["kernel"]="Kernel config"
    ["u-boot"]="U-Boot config"
    ["build"]="Build Petalinux"
    ["sdk"]="Build SDK"
    ["boot"]="Build boot image"
    ["sysroot"]="Unpack Sysroot"
)

show_menu() {
    echo "Select steps to run (use space to toggle, Enter to confirm):"
    local choices=()
    for key in "${ORDERED_STEPS[@]}"; do
        choices+=("$key" "${STEP_DISPLAY[$key]}" "OFF")
    done
    selected_steps=($(dialog --checklist "Select steps" 15 45 8 "${choices[@]}" 3>&1 1>&2 2>&3))
    clear
    [[ $? -ne 0 ]] && exit 1 # Exit if user cancels
}

validate_steps() {
    for step in "$@"; do
        if [[ -z "${STEP_MAP[$step]}" ]]; then
            echo "Error: Invalid step '$step'."
            echo "Valid steps are: ${ORDERED_STEPS[@]}"
            exit 1
        fi
    done
}

run_steps() {
    clear  # Clear screen before running steps
    for step in "${ORDERED_STEPS[@]}"; do
        if [[ " ${selected_steps[@]} " =~ " $step " ]]; then
            command="${STEP_MAP[$step]}"
            echo "Running: $command"
            eval "$command"
            if [[ $? -ne 0 ]]; then
                echo "Error in step: $step. Exiting."
                exit 1
            fi
        fi
    done
}

if [[ $# -eq 0 ]]; then
    if [[ -f "$BUILD_FILE" ]]; then
        selected_steps=($(cat "$BUILD_FILE"))
    else
        show_menu
        echo "${selected_steps[@]}" > "$BUILD_FILE"
    fi
    clear
    run_steps
elif [[ $1 == "menuconfig" ]]; then
    show_menu
    echo "${selected_steps[@]}" > "$BUILD_FILE"
    run_steps
else
    validate_steps "$@"
    selected_steps=("$@")
    run_steps
fi
