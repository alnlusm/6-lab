# course-catalog-db

PostgreSQL schema for the course catalog (Lab 6, "Advanced Web Technologies").

## Constraint violation log

Commands were run with `\set VERBOSITY verbose` on clean data (6 courses, 3 students, 6 enrollments).

| # | What we violate | SQLSTATE | Constraint | API response |
|---|-----------------|----------|------------|--------------|
| 1 | NULL in courses.title | 23502 | NOT NULL has no name: the error names the column `title` (COLUMN NAME) | 422; if Pydantic let an empty title through, it is a bug in the code (500) |
| 2 | courses.credits = 0 | 23514 | `courses_credits_check` | 422 |
| 3 | courses.likes = -1 | 23514 | `courses_likes_check` | 500: only our code changes likes (`likes + 1`), so a negative value means a bug |
| 4 | a one-letter student name | 23514 | `students_name_check` | 422 |
| 5 | a duplicate student email | 23505 | `students_email_key` | 409 Conflict |
| 6 | a duplicate course id | 23505 | `courses_pkey` | 409 Conflict |
| 7 | a repeated enrollment in a course | 23505 | `enrollments_course_id_student_id_key` | 409 Conflict |
| 8 | enrolling in a nonexistent course | 23503 | `enrollments_course_id_fkey` | 404 Course not found |
| 9 | enrolling a nonexistent student | 23503 | `enrollments_student_id_fkey` | 404 Student not found |
| 10 | deleting a course that has enrollments | 23503 on PostgreSQL 16–17, 23001 on 18 | `enrollments_course_id_fkey` | 409 Conflict: a course with enrollments can't be deleted |
| 11 | deleting a student (ON DELETE CASCADE) | no error | `enrollments_student_id_fkey` | the enrollments were deleted by cascade: 6 → 3, back to 6 after ROLLBACK |

Extra check: `INSERT INTO students (id, ...) VALUES (100, ...)` gives `428C9: cannot insert a non-DEFAULT value into column "id"` — the column is `GENERATED ALWAYS`; for the API this is a bug in the code (500).

None of the commands changed the data: after the experiments the tables still hold 6, 3 and 6 rows. The student numbers have gaps (experiment 4 used up number 4): identity guarantees unique numbers, not consecutive ones.

**Why check in the database if Pydantic already checks the name length?** Pydantic protects only requests that go through our API. The database is also written to by other code: migrations, `seed.sql`, admin scripts, psql sessions, a future second service. The CHECK in the database is the last line of defense that holds for every writer, and it keeps the data correct even if someone removes or breaks the check in the code.
