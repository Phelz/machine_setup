#!/usr/bin/env bash

# Function to format version strings as YYYY.MM
format_version() {
  printf "%04d.%02d" "$1" "$2"
}

# Initialize variables with the current year and month
current_year=$(date +%Y)
current_month=$(date +%m)

cd || exit

# Loop backwards over months to find a valid Anaconda version
while true; do
  _anaconda_version=$(format_version "$current_year" "$current_month")
  _anaconda_file="Anaconda3-${_anaconda_version}-Linux-x86_64.sh"

  # Clean up previous downloads and installations
  rm -f ${_anaconda_file}*
  rm -rf anaconda3/

  # Attempt to download the file
  wget https://repo.anaconda.com/archive/${_anaconda_file} -O ${_anaconda_file}
  if [[ -f ${_anaconda_file} ]]; then
    echo "Found and downloading Anaconda version ${_anaconda_version}"
    bash ${_anaconda_file} -b
    echo "y" | ~/anaconda3/bin/conda update --all
    rm -f ${_anaconda_file}
    break
  else
    echo "Version ${_anaconda_version} not found. Trying an earlier version..."
    rm -f ${_anaconda_file}
  fi

  # Move to the previous month
  if [[ $current_month -eq 1 ]]; then
    current_month=12
    current_year=$((current_year - 1))
  else
    current_month=$((current_month - 1))
  fi
done

# Unset variables
unset _anaconda_version _anaconda_file current_year current_month
