#!/usr/bin/env bash

# Export environment variables for HDR support in Proton/Vulkan
export DXVK_HDR=1
export PROTON_ENABLE_HDR=1
export ENABLE_HDR_WSI=1
export ENABLE_GAMESCOPE_WSI=1

# Clone arguments array
args=("$@")

# Replace launcher with actual game binary in arguments list
for i in "${!args[@]}"; do
    if [[ "${args[i]}" == *"DoomEternalLauncher.exe"* ]]; then
        args[i]="${args[i]/DoomEternalLauncher.exe/DOOMEternalx64vk.exe}"
    fi
done

# Execute the modified command line
exec "${args[@]}"
