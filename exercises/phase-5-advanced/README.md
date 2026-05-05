# Phase 5 — Advanced: Caching, Queues & Deployment

> **Duration:** 2 weeks
> **Goal:** Make your API production-ready — observable, scalable, and deployable

---

## 🧠 What You'll Learn

- Redis for caching with proper invalidation strategies
- Celery + Redis for async background job queues
- Structured logging with `loguru`
- Docker & Docker Compose for containerization
- GitHub Actions CI/CD pipeline
- Deploying to the cloud (Railway / Render)

---

## ✅ Exercises

---

### Exercise 5.1 — Redis Caching
**Concept:** Caching strategies, cache invalidation, Redis
**Difficulty:** ⭐⭐☆

**Task:**

1. Run Redis with Docker:
```bash
docker run --name redis-dev -p 6379:6379 -d redis
```

2. Install: `pip install redis[asyncio] hiredis`

3. Create `app/cache.py`:
```python
import redis.asyncio as redis

redis_client = redis.from_url("redis://localhost:6379")

async def get_cache(key: str) -> str | None: ...
async def set_cache(key: str, value: str, ttl: int = 60): ...
async def delete_cache(key: str): ...
async def delete_pattern(pattern: str): ...  # e.g. "posts:*"
```

4. Apply caching:
   - `GET /posts` (with filters) → cache for 60 seconds, key = `"posts:{page}:{size}:{search}:{tag}"`
   - `GET /posts/{id}` → cache for 5 minutes, key = `"post:{id}"`
   - When a post is **created, updated, or deleted** → invalidate `"posts:*"` and `"post:{id}"`

5. Add a `X-Cache: HIT` or `X-Cache: MISS` response header so you can see if data came from cache or DB

6. Write a test that:
   - Hits `GET /posts` twice — verify second call has `X-Cache: HIT`
   - Creates a post — verify next `GET /posts` has `X-Cache: MISS`

**Write `caching-notes.md`:**
- What is the difference between cache-aside and write-through caching?
- Why is cache invalidation considered one of the hardest problems in computer science?
- What happens if your Redis server goes down? How should your app handle it?

---

### Exercise 5.2 — Celery Background Jobs
**Concept:** Task queues, async processing, scheduled tasks
**Difficulty:** ⭐⭐⭐

**Task:**

1. Install: `pip install celery flower`

2. Create `app/worker.py` — Celery app using Redis as broker and backend:
```python
from celery import Celery

celery_app = Celery(
    "worker",
    broker="redis://localhost:6379/0",
    backend="redis://localhost:6379/1",
)
```

3. Create these tasks in `app/tasks/`:

   **`email_tasks.py`:**
   - `send_welcome_email(user_id: int)` — fetch user from DB, log: `"Sending welcome email to {email}"`
   - `send_password_reset_email(email: str, reset_token: str)` — log the email

   **`post_tasks.py`:**
   - `generate_post_summary(post_id: int)` — fetch the post, log first 100 chars as "summary"
   - `weekly_digest()` — a periodic task: collects all posts from the last 7 days, logs their titles

4. Trigger tasks from your API:
   - After `POST /auth/register` → fire `send_welcome_email.delay(user.id)`
   - After `POST /posts` → fire `generate_post_summary.delay(post.id)`

5. Configure the weekly digest to run every Monday at 9am using Celery Beat:
```python
celery_app.conf.beat_schedule = {
    "weekly-digest": {
        "task": "app.tasks.post_tasks.weekly_digest",
        "schedule": crontab(day_of_week=1, hour=9, minute=0),
    }
}
```

6. Add retry logic: if `send_welcome_email` fails, retry up to 3 times with 60-second delays

7. Run Flower to monitor tasks: `celery -A app.worker flower`
   — open `http://localhost:5555` and watch your tasks run

**Write `queues-notes.md`:**
- What is the difference between FastAPI's `BackgroundTasks` (Phase 2) and Celery?
- When would you use one vs the other?
- What is a dead letter queue and why does it matter?

---

### Exercise 5.3 — Structured Logging & Observability
**Concept:** Structured logging, request tracing, error tracking
**Difficulty:** ⭐⭐⭐

**Task:**

1. Install: `pip install loguru sentry-sdk[fastapi]`

2. Replace all `print()` statements with structured `loguru` logging:
```python
from loguru import logger

logger.info("User {user_id} created post {post_id}", user_id=1, post_id=42)
logger.warning("Cache miss for key: {key}", key="posts:1:10")
logger.error("Database connection failed: {error}", error=str(e))
```

3. Configure logging to:
   - Write to `logs/app.log` (rotating, max 10MB, keep 5 files)
   - Output JSON format in production, pretty format in development
   - Include: timestamp, level, message, module, function, line number

4. Create a **request ID middleware** that:
   - Generates a unique `request_id` (UUID) for every request
   - Adds it to every log line within that request's context
   - Returns it as a `X-Request-ID` response header
   - So when a bug is reported, you can trace the exact request in logs

5. Set up Sentry (free tier): create a project at `sentry.io`, add your DSN to `.env`:
```python
import sentry_sdk
sentry_sdk.init(dsn=os.getenv("SENTRY_DSN"), traces_sample_rate=0.1)
```

6. Trigger a deliberate error: `raise ValueError("test sentry")` in a route — verify it appears in your Sentry dashboard

**Write `observability-notes.md`:**
- What is the difference between logging and monitoring?
- What is a distributed trace and why does `request_id` help?
- What should you log? What should you NOT log (hint: think about sensitive data)?

---

### Exercise 5.4 — Docker & Docker Compose
**Concept:** Containerization, multi-stage builds, compose
**Difficulty:** ⭐⭐⭐

**Task:**

1. Write a production `Dockerfile` using multi-stage build:
```dockerfile
# Stage 1: builder — install dependencies
FROM python:3.12-slim as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: production — only what's needed to run
FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY ./app ./app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

2. Write `docker-compose.yml` that starts the full stack:
```yaml
services:
  api:        # your FastAPI app
  db:         # PostgreSQL
  redis:      # Redis
  worker:     # Celery worker
  beat:       # Celery beat (scheduler)
  flower:     # Task monitor (port 5555)
```

3. Use a `.env` file for all secrets — Docker Compose reads it automatically

4. Add a `healthcheck` to your API container:
```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
  interval: 30s
  retries: 3
```

5. Add `GET /health` endpoint to your API that returns:
```json
{ "status": "ok", "db": "connected", "redis": "connected", "version": "1.0.0" }
```

6. Test: `docker compose up --build` → hit `http://localhost:8000/docs` → everything works from scratch with no manual steps

**Write `docker-notes.md`:**
- What is the difference between a Docker image and a container?
- What problem does multi-stage build solve? What would happen without it?
- What does `--host 0.0.0.0` do? Why is it required inside Docker?

---

### Exercise 5.5 — CI/CD & Cloud Deployment (Capstone)
**Concept:** GitHub Actions, automated testing, cloud deployment
**Difficulty:** ⭐⭐⭐

**Task:**

1. Create `.github/workflows/ci.yml` — runs on every push and PR:
```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env: { POSTGRES_PASSWORD: secret, POSTGRES_DB: testdb }
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-retries 5
      redis:
        image: redis:7
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: "3.12" }
      - run: pip install -r requirements.txt
      - run: alembic upgrade head
      - run: pytest tests/ -v --cov=app --cov-report=xml
      - run: mypy app/          # type checking
```

2. Fail the pipeline if test coverage drops below 70%

3. Deploy to **Railway** or **Render** (both free):
   - Connect your GitHub repo
   - Add environment variables in their dashboard
   - Set up managed PostgreSQL and Redis on the same platform
   - Configure auto-deploy on push to `main`

4. After deployment:
   - Your API is live at a public URL
   - `/docs` is accessible with full Swagger UI
   - `/health` returns all green

5. Update your main `README.md`:
   - Add live API URL badge
   - Add CI status badge: `![CI](https://github.com/{username}/{repo}/actions/workflows/ci.yml/badge.svg)`

**Write `deployment-notes.md`:**
- What environment variables does your app need to run? Document all of them.
- What is the difference between `requirements.txt` for dev and prod? Should they be the same?
- What would you do differently if this needed to handle 100,000 users?

---

## 🏁 Phase 5 Checklist

- [ ] Exercise 5.1 — Redis Caching
- [ ] Exercise 5.2 — Celery Background Jobs
- [ ] Exercise 5.3 — Structured Logging & Observability
- [ ] Exercise 5.4 — Docker & Docker Compose
- [ ] Exercise 5.5 — CI/CD & Cloud Deployment (Capstone)
- [ ] Update main `README.md` Phase 5 status to ✅
- [ ] Write LinkedIn Post #5

---

**Previous:** [← Phase 4](../phase-4-auth/README.md) | **Next:** [Capstone Project →](../../projects/README.md)
