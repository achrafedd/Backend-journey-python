# 🏆 Capstone Project — DevBlog API

> Build this after completing all 5 phases.
> This is the project you put on your CV and talk about in interviews.

---

## Project: **DevBlog API**

A production-grade REST API for a developer blogging platform — think a simplified Dev.to or Hashnode backend.

---

## 🎯 Features to Build

### Core (required)
- [ ] Registration, login, JWT auth, refresh token rotation
- [ ] User profiles: avatar URL, bio, social links
- [ ] Blog posts with Markdown content and slugs
- [ ] Tagging system (many-to-many)
- [ ] Comment system (comments + nested replies)
- [ ] Like / bookmark posts (toggle)
- [ ] Soft delete (posts are never hard-deleted, just flagged)

### Advanced (required for greatness)
- [ ] Full-text search across posts using PostgreSQL `tsvector`
- [ ] Email notification queue with Celery (welcome, new comment on your post)
- [ ] Redis caching with proper invalidation
- [ ] Pagination + sorting + filtering on all list endpoints
- [ ] Admin endpoints: ban user, remove post, view stats
- [ ] Rate limiting on auth routes
- [ ] Complete Swagger documentation with examples
- [ ] Docker + Docker Compose (full stack in one command)
- [ ] GitHub Actions CI/CD pipeline
- [ ] Deployed to a live URL

---

## 📋 Database Schema

```
User         → id, name, email, hashed_password, bio, avatar_url, role, is_banned, created_at
Post         → id, title, slug (unique), content, is_published, author_id FK, view_count, created_at, deleted_at
Tag          → id, name, slug (unique)
PostTag      → post_id FK, tag_id FK
Comment      → id, content, author_id FK, post_id FK, parent_id FK (nullable — for replies), created_at
Like         → user_id FK, post_id FK, created_at — UNIQUE(user_id, post_id)
Bookmark     → user_id FK, post_id FK, created_at — UNIQUE(user_id, post_id)
RefreshToken → id, token, user_id FK, expires_at, is_revoked
```

---

## 📌 API Endpoints (minimum required)

```
# Auth
POST   /auth/register
POST   /auth/login
POST   /auth/refresh
POST   /auth/logout
GET    /auth/me
PATCH  /auth/me           → update own profile

# Posts
GET    /posts             → paginated, filterable by tag/author, searchable
GET    /posts/{slug}      → single post (increments view_count)
POST   /posts             → create (auth required)
PATCH  /posts/{id}        → update (author or admin only)
DELETE /posts/{id}        → soft delete (author or admin only)
POST   /posts/{id}/like      → toggle like
POST   /posts/{id}/bookmark  → toggle bookmark

# Comments
GET    /posts/{id}/comments  → threaded (comments + replies)
POST   /posts/{id}/comments  → add comment (auth required)
POST   /posts/{id}/comments/{comment_id}/reply → reply to a comment
DELETE /comments/{id}    → author or admin only

# Tags
GET    /tags                     → all tags with post count
GET    /tags/{slug}/posts        → posts with this tag (paginated)

# Users
GET    /users/{username}         → public profile + recent posts
GET    /users/me/bookmarks       → my bookmarked posts

# Admin (admin role required)
GET    /admin/users              → paginated user list
PATCH  /admin/users/{id}/ban     → toggle ban
DELETE /admin/posts/{id}         → hard delete
GET    /admin/stats              → total users, posts, comments today
```

---

## 🚀 Project Structure

```
devblog-api/
├── app/
│   ├── main.py
│   ├── database.py
│   ├── config.py               ← all settings from .env
│   ├── auth/
│   │   ├── jwt.py
│   │   ├── security.py
│   │   └── dependencies.py
│   ├── routers/
│   │   ├── auth.py
│   │   ├── posts.py
│   │   ├── comments.py
│   │   ├── tags.py
│   │   ├── users.py
│   │   └── admin.py
│   ├── models/
│   │   └── ...
│   ├── schemas/
│   │   └── ...
│   ├── services/               ← business logic, NOT in routers
│   │   ├── post_service.py
│   │   ├── user_service.py
│   │   └── ...
│   ├── tasks/
│   │   └── ...
│   └── cache.py
├── alembic/
├── tests/
│   ├── conftest.py
│   ├── test_auth.py
│   ├── test_posts.py
│   └── test_admin.py
├── scripts/
│   └── seed.py
├── .github/
│   └── workflows/ci.yml
├── docker-compose.yml
├── Dockerfile
├── Makefile
├── requirements.txt
└── README.md
```

---

## 🧪 Testing Requirements

You must have at least:
- **20 integration tests** covering happy paths
- **10 tests** covering error cases (401, 403, 404, 422, 429)
- Test coverage ≥ 70%
- Tests run inside CI against a real PostgreSQL + Redis

---

## 📝 LinkedIn Announcement Template

```
🚀 I just shipped a production-ready backend API — and it's fully open source.

After [X] months of learning backend development with Python and FastAPI,
I've built DevBlog API — a full-featured blogging platform backend.

Tech stack:
→ FastAPI + Python 3.12
→ PostgreSQL + SQLAlchemy 2.0 (async)
→ Alembic migrations
→ JWT auth with refresh token rotation
→ Role-based access control
→ Redis caching
→ Celery + Redis background jobs
→ Structured logging with Loguru + Sentry
→ Docker + Docker Compose
→ GitHub Actions CI/CD
→ Deployed to [Platform]

The codebase includes:
→ 30+ API endpoints
→ Full Swagger documentation
→ 30+ automated tests
→ Complete README with setup instructions

Everything I built is committed publicly — every exercise,
every mistake, every refactor.

🔗 GitHub: [link]
🔗 Live API: [link]
🔗 Swagger Docs: [link]

If you're learning backend development too — follow along.
I document everything.

#Python #FastAPI #BackendDevelopment #PostgreSQL
#Docker #BuildInPublic #OpenToWork #SoftwareEngineering
```

---

## 💡 Interview Talking Points

When someone asks about this project, be ready to explain:

1. **Why FastAPI over Django/Flask?** — async-first, type safety, auto docs, faster for pure APIs
2. **How does your auth system work?** — JWT access + refresh tokens, rotation, stored in DB
3. **How did you handle the N+1 problem?** — `selectinload`, `joinedload`, `EXPLAIN ANALYZE`
4. **What happens when your cache is stale?** — invalidation strategy, what the fallback is
5. **How would you scale this to 1 million users?** — connection pooling, read replicas, CDN, horizontal scaling
6. **What would you do differently?** — always have an honest answer ready
