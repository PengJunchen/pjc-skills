#!/bin/bash

echo "=== Mount Specific Directory in WSL ==="
echo ""

# Get user input
echo "Please enter the source directory path (e.g., /mnt/e/Work/202603AgentSkills/test):"
read -r SOURCE_DIR

echo "Please enter the target mount point (e.g., /home/test):"
read -r TARGET_DIR

echo "Do you want persistent mount (survives reboot)? (Y/N):"
read -r PERSISTENT

# Debug information
echo ""
echo "Debug: Source directory: $SOURCE_DIR"
echo "Debug: Target directory: $TARGET_DIR"
echo "Debug: Persistent mount: $PERSISTENT"
echo ""

# Check if source directory exists
if [ -d "$SOURCE_DIR" ]; then
    echo "Source directory exists: $SOURCE_DIR"
    
    # Create target mount point
    echo "Creating target mount point: $TARGET_DIR"
    sudo mkdir -p "$TARGET_DIR"
    
    # Mount directory
    echo "Mounting $SOURCE_DIR to $TARGET_DIR"
    sudo mount --bind "$SOURCE_DIR" "$TARGET_DIR"
    
    if [ $? -eq 0 ]; then
        echo "Successfully mounted $SOURCE_DIR to $TARGET_DIR"
        
        # Verify mount
        echo "Verifying mount..."
        mount | grep "$TARGET_DIR"
        
        # If persistent mount is requested
        if [ "$PERSISTENT" = "Y" -o "$PERSISTENT" = "y" ]; then
            # Check if mount already exists in fstab
            if ! grep -q "$TARGET_DIR" /etc/fstab; then
                echo "Adding to /etc/fstab for persistent mount"
                echo "$SOURCE_DIR $TARGET_DIR none bind 0 0" | sudo tee -a /etc/fstab
                echo "Added to /etc/fstab for persistent mount"
            else
                echo "Mount point already exists in /etc/fstab"
            fi
        fi
    else
        echo "Failed to mount directory"
        echo "Error code: $?"
    fi
else
    echo "Error: Source directory $SOURCE_DIR does not exist"
    # List available directories
    echo "Available directories in /mnt:"
    ls -la /mnt
fi

