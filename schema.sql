-- schema.sql: the course catalog database schema
-- The file can be run repeatedly: it first drops the old tables.
-- A teaching shortcut: real projects manage the schema with migrations.
DROP TABLE IF EXISTS enrollments, students, courses;

CREATE TABLE courses (
    id          text PRIMARY KEY,
    title       text NOT NULL,
    description text NOT NULL,
    credits     integer NOT NULL CHECK (credits > 0),
    is_elective boolean NOT NULL DEFAULT false,
    likes       integer NOT NULL DEFAULT 0 CHECK (likes >= 0)
);

CREATE TABLE students (
    id    bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  text NOT NULL CHECK (length(name) >= 2),
    email text NOT NULL UNIQUE
);

CREATE TABLE enrollments (
    id          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    course_id   text NOT NULL REFERENCES courses (id) ON DELETE RESTRICT,
    student_id  bigint NOT NULL REFERENCES students (id) ON DELETE CASCADE,
    enrolled_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (course_id, student_id)
);

-- Index on the foreign key student_id (step 6): PostgreSQL doesn't create one.
CREATE INDEX enrollments_student_id_idx ON enrollments (student_id);
