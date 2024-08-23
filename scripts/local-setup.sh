#!/bin/sh
set -e

ATLANTIS_VERSION=v0.19.4
ATLANTIS_PACKAGE=atlantis_windows_amd64.zip  # Change to 'atlantis_windows_386.zip' for 32-bit

echo "Generate random secret string"
openssl rand -base64 16 | head -c 20; echo;

echo "Download atlantis lib"
wget https://github.com/runatlantis/atlantis/releases/download/${ATLANTIS_VERSION}/${ATLANTIS_PACKAGE}
unzip $ATLANTIS_PACKAGE

echo "Download ngrok"
wget -c https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip -O ngrok.zip  # Update to 386 if necessary
tar -xz

echo "Generate random secret string"
openssl rand -base64 16 | head -c 20; echo;






# # Enable error handling
# $ErrorActionPreference = "Stop"

# $ATLANTIS_VERSION = "v0.19.4"
# $ATLANTIS_PACKAGE = "atlantis_windows_386.zip"

# Write-Host "Download atlantis lib"
# $atlantisUrl = "https://github.com/runatlantis/releases/download/$ATLANTIS_VERSION/$ATLANTIS_PACKAGE"
# Invoke-WebRequest -Uri $atlantisUrl -OutFile $ATLANTIS_PACKAGE
# Expand-Archive -Path $ATLANTIS_PACKAGE -DestinationPath . -Force

# Write-Host "Download ngrok"
# $ngrokUrl = "https://bin.equinox.io/c/bnyj1mQVY4c/ngrok-v3-stable-windows-386.zip"
# Invoke-WebRequest -Uri $ngrokUrl -OutFile "ngrok.zip"
# Expand-Archive -Path "ngrok.zip" -DestinationPath . -Force

# Write-Host "Generate random secret string"
# $randomString = (Get-Random).ToString("X") | Get-FileHash -Algorithm MD5 | ForEach-Object { $_.Hash.Substring(0, 20) }
# Write-Host $randomString
