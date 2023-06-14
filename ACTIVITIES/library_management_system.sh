14-06-2023

#!/bin/bash


library_file="library.txt"
temp_file="temp.txt"

#display the menu
display_menu() {
  clear
  echo "Library Management System"
  echo "------------------------"
  echo "1. Add New Book"
  echo "2. View Book Details"
  echo "3. Update Book Details"
  echo "4. Delete Book"
  echo "5. Search Books"
  echo "0. Exit"
  echo
}

# add a new book
add_book() {
  echo "Add New Book"
  echo "------------"
  echo
  read -p "Enter Book ID: " book_id
  read -p "Enter Book Title: " book_title
  read -p "Enter Book Author: " book_author
  read -p "Enter Book Genre: " book_genre
  echo "$book_id|$book_title|$book_author|$book_genre" >> "$library_file"
  echo
  echo "Book added successfully!"
  echo
  read -n 1 -s -r -p "Press any key to continue..."
}

#view book details
view_book() {
  echo "View Book Details"
  echo "-----------------"
  echo
  read -p "Enter Book ID: " book_id
  echo
  grep "^$book_id|" "$library_file" > "$temp_file"
  if [ -s "$temp_file" ]; then
    echo "Book Details:"
    echo
    cat "$temp_file"
  else
    echo "Book not found!"
  fi
  echo
  read -n 1 -s -r -p "Press any key to continue..."
}

# update book details
update_book() {
  echo "Update Book Details"
  echo "-------------------"
  echo
  read -p "Enter Book ID: " book_id
  echo
  grep "^$book_id|" "$library_file" > "$temp_file"
  if [ -s "$temp_file" ]; then
    echo "Existing Book Details:"
    echo
    cat "$temp_file"
    echo
    read -p "Enter New Book Title: " new_title
    read -p "Enter New Book Author: " new_author
    read -p "Enter New Book Genre: " new_genre
    sed -i "s/^$book_id|.*$/$book_id|$new_title|$new_author|$new_genre/" "$library_file"
    echo
    echo "Book details updated successfully!"
  else
    echo "Book not found!"
  fi
  echo
  read -n 1 -s -r -p "Press any key to continue..."
}

#  delete a book
delete_book() {
  echo "Delete Book"
  echo "-----------"
  echo
  read -p "Enter Book ID: " book_id
  echo
  grep -v "^$book_id|" "$library_file" > "$temp_file"
  if [ -s "$temp_file" ]; then
    mv "$temp_file" "$library_file"
    echo "Book deleted successfully!"
  else
    echo "Book not found!"
  fi
  echo
  read -n 1 -s -r -p "Press any key to continue..."
}

# search books
search_books() {
  echo "Search Books"
  echo "------------"
  echo
  read -p "Enter search keyword: " keyword
  echo
  grep -i "$keyword" "$library_file" > "$temp_file"
  if [ -s "$temp_file" ]; then
    echo "Search Results:"
    echo
    cat "$temp_file"
  else
    echo "No results found!"
  fi
  echo
  read -n 1 -s -r -p "Press any key to continue..."
}

 loop
while true; do
  display_menu
  read -n 1 -s -r choice
  echo
  case "$choice" in
    1) add_book;;
    2) view_book;;
    3) update_book;;
    4) delete_book;;
    5) search_books;;
    0) break;;
    *) echo "Invalid choice!" ;;
  esac
done


rm -f "$temp_file"