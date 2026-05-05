# Phase 3 — Databases & ORMs (PostgreSQL + SQLAlchemy)

> **Duration:** 2 weeks
> **Goal:** Replace in-memory lists with a real database — and understand what's happening underneath

---

## 🧠 What You'll Learn

- Relational database fundamentals: tables, relations, indexes, constraints
- Raw SQL — before touching any ORM
- SQLAlchemy 2.0 (async) — models, sessions, relationships
- Alembic migrations — schema versioning like a professional
- One-to-many & many-to-many relationships
- Query optimization: indexes, EXPLAIN, N+1 problem

---

## ✅ Exercises

---

### Exercise 3.1 — PostgreSQL & Raw SQL
**Concept:** Database fundamentals, SQL fluency
**Difficulty:** ⭐☆☆

**Task:**
Start with raw SQL — never go straight to an ORM. You need to understand what it does for you.

1. Run PostgreSQL with Docker:
```bash
docker run --name pg-dev \
  -e POSTGRES_PASSWORD=secret \
  -e POSTGRES_DB=backendjourney \
  -p 5432:5432 -d postgres
```

2. Connect using `psql` or a GUI (TablePlus / DBeaver — both free). Write and run `schema.sql`:
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE post_tags (
    post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
    tag_id  INTEGER REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, tag_id)
);
```

3. Write `queries.sql` with these queries (each with a comment explaining what it does):
   - Insert 3 users, 6 posts assigned to those users, 4 tags
   - Assign 2 tags to each post using `post_tags`
   - `SELECT` all posts with their author name using `JOIN`
   - `SELECT` all posts that have the tag "python" (JOIN through `post_tags`)
   - Count how many posts each user has written (`GROUP BY`, include users with 0 posts using `LEFT JOIN`)
   - Find the 3 most recent posts with their author and tag list (`STRING_AGG`)
   - Find all users who have written more than 1 post

**Write `sql-notes.md`:**
- What is the difference between `INNER JOIN`, `LEFT JOIN`, and `RIGHT JOIN`?
- What does `ON DELETE CASCADE` mean? When is it dangerous?
- What is a `PRIMARY KEY` vs a `UNIQUE` constraint?

---

### Exercise 3.2 — SQLAlchemy 2.0 Async Setup
**Concept:** SQLAlchemy ORM, async sessions, models
**Difficulty:** ⭐⭐☆

**Task:**
Install and configure async SQLAlchemy in your FastAPI project from Phase 2:

```bash
pip install sqlalchemy[asyncio] asyncpg alembic python-dotenv
```

1. Create `app/database.py` with async engine and session:
```python
# Use asyncpg driver: postgresql+asyncpg://user:password@localhost/dbname
# Create async engine
# Create async session factory
# Create a get_db() dependency that yields a session and closes it properly
```

2. Create `app/models/` folder with SQLAlchemy models:
   - `User` — id, name, email, hashed_password, role, created_at
   - `Post` — id, title, content, author_id (FK), created_at
   - `Comment` — id, content, author_id (FK), post_id (FK), created_at
   - `Tag` — id, name (unique)
   - `PostTag` — association table (post_id, tag_id)

3. Set up relationships:
   - User → Posts (one-to-many)
   - Post → Comments (one-to-many)
   - Post ↔ Tags (many-to-many via `PostTag`)

4. Update your Post router to use real DB operations via `Depends(get_db)`
5. Test: create a post, retrieve it, verify it persists after server restart

**Write `sqlalchemy-notes.md`:**
- What is the difference between SQLAlchemy Core and ORM?
- What does `async with session.begin()` do? Why does it matter?
- What is lazy loading vs eager loading? Which one causes the N+1 problem?

---

### Exercise 3.3 — Alembic Migrations
**Concept:** Schema versioning, migration workflow
**Difficulty:** ⭐⭐☆

**Task:**

1. Initialize Alembic: `alembic init alembic`
2. Configure `alembic.ini` and `alembic/env.py` to use your async SQLAlchemy models
3. Generate your first migration from existing models:
   `alembic revision --autogenerate -m "create initial tables"`
4. Run it: `alembic upgrade head`
5. Verify the tables were created in your database
6. Now add a `bio` column (Text, nullable) to the `User` model
7. Generate and run a new migration: `alembic revision --autogenerate -m "add user bio"`
8. Downgrade one step: `alembic downgrade -1` — verify `bio` is gone
9. Upgrade again: `alembic upgrade head`

**Write `migrations-notes.md`:**
- Why is `synchronize: true` / creating tables directly dangerous in production?
- What does `alembic downgrade -1` do and when would you use it in real life?
- What should you always do before running migrations on a production database?

---

### Exercise 3.4 — Advanced Queries & Optimization
**Concept:** Complex queries, pagination, N+1 problem, indexes
**Difficulty:** ⭐⭐⭐

**Task:**
Implement these advanced features in your Posts API:

1. **Pagination** on `GET /posts`:
   - Accept `?page=1&size=10`
   - Return: `{ "items": [...], "total": 45, "page": 1, "size": 10, "pages": 5 }`
   - Create a reusable `PaginationParams` dependency

2. **Search + filtering:**
   - `GET /posts?search=python` — searches in title AND content using `ILIKE`
   - `GET /posts?tag=fastapi` — filter by tag name
   - `GET /posts?author_id=3` — filter by author
   - Combine: `GET /posts?search=python&tag=fastapi&page=2`

3. **Fix the N+1 problem:**
   - First, intentionally create the N+1 problem: fetch 10 posts, then loop to get each author
   - Run `echo=True` on your engine to see all SQL queries printed
   - Count how many queries fire — it's 11 (1 for posts + 10 for authors)
   - Fix it with `selectinload` or `joinedload` — now it's 2 queries
   - Write before/after in `n+1-notes.md`

4. **Add database indexes:**
```python
# In your models:
__table_args__ = (
    Index("ix_posts_title", "title"),
    Index("ix_posts_created_at", "created_at"),
)
```
   - Generate and run a migration for these indexes
   - Use `EXPLAIN ANALYZE` in psql to show the query plan before and after

5. **View count:** Every time `GET /posts/{id}` is called, increment `view_count` using a raw SQL `UPDATE posts SET view_count = view_count + 1 WHERE id = :id` — never load the post first just to increment it.

---

### Exercise 3.5 — Database Seeder (Capstone)
**Concept:** Seeding, transactions, data integrity
**Difficulty:** ⭐⭐⭐

**Task:**

1. Install `faker`: `pip install faker`
2. Create `scripts/seed.py` that populates your database:
   - 10 users (realistic names, emails, bios)
   - 50 posts (assigned randomly to users, random tags)
   - 100 comments (on random posts by random users)
   - 8 tags

3. Wrap the **entire seeding operation in a single transaction** — if any insert fails, nothing gets saved. Use SQLAlchemy's `async with session.begin()`.

4. Create `scripts/reset_db.py` that drops all tables and re-runs the seed

5. Add to your `Makefile` (create one):
```makefile
seed:
    python scripts/seed.py

reset:
    python scripts/reset_db.py

migrate:
    alembic upgrade head
```

6. After seeding, verify your pagination, search, and filter from Exercise 3.4 work correctly with real data — test at least 5 different query combinations.

**Write `transactions-notes.md`:**
- What is a database transaction? What are ACID properties?
- What happens if your seed script crashes halfway through without a transaction?
- What is the difference between `session.commit()` and `session.rollback()`?

---

## 📦 Folder Structure

```
exercises/
└── phase-3-database/
    ├── ex1-raw-sql/
    │   ├── schema.sql
    │   ├── queries.sql
    │   └── sql-notes.md
    ├── ex2-sqlalchemy-setup/       ← FastAPI project with SQLAlchemy
    │   └── sqlalchemy-notes.md
    ├── ex3-alembic-migrations/     ← updated project + alembic/ folder
    │   └── migrations-notes.md
    ├── ex4-advanced-queries/       ← updated project + notes
    │   └── n+1-notes.md
    └── ex5-seeder/                 ← final project with scripts/ + Makefile
        └── transactions-notes.md
```

---

## 🏁 Phase 3 Checklist

- [ ] Exercise 3.1 — PostgreSQL & Raw SQL
- [ ] Exercise 3.2 — SQLAlchemy 2.0 Async
- [ ] Exercise 3.3 — Alembic Migrations
- [ ] Exercise 3.4 — Advanced Queries & Optimization
- [ ] Exercise 3.5 — Seeder Capstone
- [ ] Update main `README.md` Phase 3 status to ✅
- [ ] Write LinkedIn Post #3

---

**Previous:** [← Phase 2](../phase-2-fastapi-basics/README.md) | **Next:** [Phase 4 — Auth →](../phase-4-auth/README.md)
