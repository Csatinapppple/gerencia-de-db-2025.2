CREATE TABLE students (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    score INTEGER
);

-- Insert sample data
INSERT INTO students (name, score) VALUES ('Alice', 85);
INSERT INTO students (name, score) VALUES ('Bob', 92);
INSERT INTO students (name, score) VALUES ('Charlie', 78);

-- Run queries
SELECT * FROM students;
SELECT name, score FROM students WHERE score > 80;


