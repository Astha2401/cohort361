#!/bin/bash


convert_to_ascii() {
  text="$1"
  length=${#text}

  echo "ASCII Codes:"
  for ((i = 0; i < length; i++)); do
    char="${text:$i:1}"
    ascii=$(printf "%d" "'$char")
    echo "$char: $ascii"
  done
}

# input from the user
read -p "Enter text: " input_text

convert_to_ascii "$input_text"
