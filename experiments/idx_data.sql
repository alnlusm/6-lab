-- idx_data.sql: lots of data for index experiments
-- (500 courses, 20,000 students, 50,000 enrollments)
INSERT INTO courses (id, title, description, credits)
SELECT 'course-' || g, 'Course ' || g, 'Test', 3
FROM generate_series(1, 500) AS g;

INSERT INTO students (name, email)
SELECT 'Student ' || g, 'student' || g || '@example.com'
FROM generate_series(1, 20000) AS g;

INSERT INTO enrollments (course_id, student_id)
SELECT 'course-' || (1 + (g + g / 20000) % 500), 1 + g % 20000
FROM generate_series(1, 50000) AS g;

-- after loading, refresh the statistics the planner relies on
ANALYZE courses;
ANALYZE students;
ANALYZE enrollments;
