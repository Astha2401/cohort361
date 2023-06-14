18-05-2023

Code:-
CREATE TABLE User (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) NOT NULL,
  phoneNo VARCHAR(20) NOT NULL
);
CREATE TABLE Book (
  book_id INT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(100) NOT NULL,
  price DECIMAL(10, 2),
  publication_year INT,
  author VARCHAR(100),
  availability BOOLEAN,
  publisher VARCHAR(100),
  category VARCHAR(100)
);
CREATE TABLE Librarian (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(100),
  email VARCHAR(100),
  phoneNo VARCHAR(20)
);
CREATE TABLE Fine (
  fine_id INT PRIMARY KEY AUTO_INCREMENT,
  borrow_date DATE,
  return_date DATE,
  user_id INT,
  amount int DEFAULT 0,
  book_id int ,
  FOREIGN KEY (user_id) REFERENCES User(id)
);
INSERT INTO User (name, email, phoneNo)
VALUES ('ROhan', 'Rohan@example.com', '1234567890'),
('Kiya', 'kiya@example.com', '1235467890'),
('goku', 'goku@example.com', '1234567089');
INSERT INTO Book (title, price, publication_year, author, availability, publisher, category)
VALUES ('harry 1', 100, 2000, 'Myself', true, 'Warner bros', 'Jaadu'),
('harry 2', 110, 2000, 'Myself', true, 'Warner bros', 'fiction'),
('gyaan', 100, 2000, 'Myself', true, 'CBSE', 'education');
INSERT INTO Librarian (name, email, phoneNo)
VALUES ('Mam', 'Mam@example.com', '9876543232');
INSERT INTO Fine (borrow_date, return_date, user_id, amount, book_id)
VALUES ('2023-05-01', '2023-05-08', 1, 20,1),
('2023-05-01', '2023-05-08', 1, 20,2);
select * from user;
select * from Librarian;
select * from book;
select * from fine;