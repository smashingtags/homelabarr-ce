#!/bin/bash

cd ../local-mode-apps
env_file="../.config/.env"

echo "Checking for missing environment variables..."

# Extract all variables used in YAML files
missing_vars=()

for file in *.yml; do
    # Find variables like ${VAR} 
    vars=$(grep -o '\${[^}]*}' "$file" 2>/dev/null | sed 's/[{}$]//g' | sort -u)
    
    for var in $vars; do
        if ! grep -q "^${var}=" "$env_file" 2>/dev/null; then
            missing_vars+=("$var")
        fi
    done
done

# Remove duplicates and sort
printf '%s\n' "${missing_vars[@]}" | sort -u > missing_vars.txt

echo "Found $(wc -l < missing_vars.txt) missing environment variables:"
head -20 missing_vars.txt

echo ""
echo "Adding missing variables to .env file..."

while read -r var; do
    case "$var" in
        *IMAGE) echo "${var}=ghcr.io/linuxserver/$(echo $var | sed 's/IMAGE$//' | tr '[:upper:]' '[:lower:]'):latest" >> "$env_file" ;;
        *THEME) echo "${var}=dark" >> "$env_file" ;;
        ID) echo "ID=1000" >> "$env_file" ;;
        TZ) echo "TZ=America/New_York" >> "$env_file" ;;
        UMASK) echo "UMASK=002" >> "$env_file" ;;
        *) echo "${var}=" >> "$env_file" ;;
    esac
done < missing_vars.txt

echo "Added $(wc -l < missing_vars.txt) missing variables to .env file"
rm missing_vars.txt
