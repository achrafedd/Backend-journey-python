# Phase 2 — FastAPI Basics & REST APIs

> **Duration:** 2 weeks
> **Goal:** Build real REST APIs with FastAPI — understand every layer deeply

---

## 🧠 What You'll Learn

- FastAPI project structure and architecture
- Path parameters, query parameters, request bodies
- Pydantic schemas for validation and serialization
- Dependency Injection — FastAPI's most important concept
- Response models, status codes, error handling
- Middleware and background tasks
- API Router for modular code organization

---

## ✅ Exercises

---

### Exercise 2.1 — Your First FastAPI App
**Concept:** FastAPI setup, routers, basic endpoints
**Difficulty:** ⭐☆☆

**Task:**
Bootstrap a FastAPI project for a bookstore API. Use this structure:

```
bookstore-api/
├── app/
│   ├── main.py
│   ├── routers/
│   │   └── books.py
│   └── schemas/
│       └── book.py
├── requirements.txt
└── .env
```

1. Define a `BookSchema` with Pydantic: `id`, `title`, `author`, `price` (float, positive), `available` (bool, default True), `genre` (optional string)
2. Store books in an **in-memory list** (no database yet)
3. Implement these endpoints in `routers/books.py`:
   - `GET /books` — return all books, support `?available=true` filter
   - `GET /books/{book_id}` — return one book or 404
   - `POST /books` — create a book, return 201
   - `PUT /books/{book_id}` — full update
   - `PATCH /books/{book_id}` — partial update
   - `DELETE /books/{book_id}` — delete, return 204

4. Run with: `uvicorn app.main:app --reload`
5. Open `http://127.0.0.1:8000/docs` — your Swagger UI is **already there for free**

Test every endpoint in the Swagger UI. Screenshot it and commit the screenshot.

**Write `fastapi-first-impressions.md`:** What surprised you about FastAPI compared to what you expected? What does the `--reload` flag do?

---

### Exercise 2.2 — Pydantic Schemas & Response Models
**Concept:** Input vs output schemas, response_model, field validation
**Difficulty:** ⭐⭐☆

**Task:**
In real APIs, what you accept (input) is different from what you return (output). Refactor your bookstore:

1. Create separate schemas:
   - `BookCreate` — fields required to create (no `id`)
   - `BookUpdate` — all fields optional for PATCH
   - `BookResponse` — what the API returns (includes `id`, excludes internal fields)
   - `BookListResponse` — wraps a list with `total` count

2. Use `response_model=BookResponse` on your endpoints so FastAPI automatically filters the output

3. Add these validators directly in your Pydantic schemas:
   - `price` must be > 0
   - `title` min 2 chars, max 200 chars
   - `author` cannot be an empty string
   - `genre` if provided, must be one of: `fiction`, `non-fiction`, `science`, `biography`, `other`

4. Add a `GET /books/search` endpoint accepting `?q=` that searches by title or author (case-insensitive)

5. Verify: sending `{"price": -10}` returns a clean `422 Unprocessable Entity` with a descriptive error — not a crash.

**Write `schemas-notes.md`:** What is the difference between `BookCreate`, `BookUpdate`, and `BookResponse`? Why is it bad practice to use the same schema for input and output?

---

### Exercise 2.3 — Dependency Injection
**Concept:** FastAPI's `Depends()`, reusable dependencies, layered DI
**Difficulty:** ⭐⭐⭐

This is FastAPI's **most important concept**. Take your time here.

**Task:**

1. Create a `dependencies.py` file and build these reusable dependencies:

```python
# Pagination — reused across any list endpoint
def get_pagination(page: int = 1, limit: int = Query(default=10, le=100)):
    return {"skip": (page - 1) * limit, "limit": limit}

# Common filters
def get_book_filters(available: bool | None = None, genre: str | None = None):
    return {"available": available, "genre": genre}
```

2. Apply `get_pagination` and `get_book_filters` to `GET /books` using `Depends()`
3. Create a `verify_api_key` dependency that reads an `X-API-Key` header and raises `401` if it's missing or wrong (hardcode the key for now — we'll do real auth in Phase 4)
4. Apply `verify_api_key` to all `POST`, `PUT`, `PATCH`, `DELETE` endpoints
5. Create a `get_book_or_404` dependency that accepts `book_id: int` and returns the book or raises `HTTPException(404)` — use it in all single-book endpoints to eliminate repeated 404 logic

**Write `dependency-injection-notes.md`:** Explain Dependency Injection in your own words. Why is it better than calling functions directly inside route handlers? Draw a simple ASCII diagram showing how dependencies chain together.

---

### Exercise 2.4 — Exception Handling & Middleware
**Concept:** Custom exceptions, exception handlers, middleware
**Difficulty:** ⭐⭐⭐

**Task:**

1. Create `exceptions.py` with custom exception classes:
```python
class BookNotFoundError(Exception):
    def __init__(self, book_id: int):
        self.book_id = book_id

class BookNotAvailableError(Exception):
    def __init__(self, book_id: int):
        self.book_id = book_id
```

2. Register exception handlers in `main.py` that convert these into clean JSON responses:
```json
{
  "error": "BookNotFound",
  "message": "Book with id 42 was not found",
  "timestamp": "2025-04-20T10:30:00Z",
  "path": "/books/42"
}
```

3. Create a `POST /books/{book_id}/order` endpoint that raises `BookNotAvailableError` if `available=False`

4. Add a **logging middleware** that prints every request:
   `[2025-04-20 10:30:00] POST /books/5/order — 200 — 12ms`

5. Add a **process time header middleware** that adds `X-Process-Time: 0.012s` to every response

6. Create `GET /books/slow` that sleeps 2 seconds (use `asyncio.sleep`) — verify your middleware logs the time correctly

**Write `middleware-notes.md`:** What is the difference between FastAPI Middleware and a Dependency? When would you use one vs the other? What is the request lifecycle in FastAPI — draw it step by step.

---

### Exercise 2.5 — Background Tasks & APIRouter
**Concept:** Background tasks, router organization, tags
**Difficulty:** ⭐⭐⭐

**Task:**

1. Reorganize your project with proper `APIRouter`:
```
app/
├── main.py               ← only mounts routers and middleware
├── routers/
│   ├── books.py          ← /books prefix
│   └── orders.py         ← /orders prefix
├── schemas/
│   ├── book.py
│   └── order.py
├── dependencies.py
└── exceptions.py
```

2. Create an `Order` system: `POST /orders` creates an order with `book_id` and `quantity`
3. When an order is created, use FastAPI `BackgroundTasks` to:
   - Log: `"Processing order #{id} for book #{book_id}"` (simulated async task)
   - Simulate sending a confirmation email: `"Sending email to {user_email}"` (just print it)
4. The endpoint should return `201` **immediately** — the background task runs after the response is sent
5. Add `tags=["Books"]` and `tags=["Orders"]` to your routers so Swagger UI groups them properly

**Write a test:** Use Python's `TestClient` from `fastapi.testclient` to write at least 5 tests:
- Test that creating a book returns 201 with the correct body
- Test that getting a non-existent book returns 404
- Test that creating a book with negative price returns 422
- Test that ordering an unavailable book returns the right error
- Test that the book list supports filtering by `available`

**This is your Phase 2 capstone — commit it as a complete, working FastAPI project.**

---

## 📦 Folder Structure

```
exercises/
└── phase-2-fastapi-basics/
    ├── ex1-first-fastapi/        ← complete FastAPI project
    ├── ex2-schemas/              ← updated with schema separation
    ├── ex3-dependencies/         ← updated + notes
    ├── ex4-exceptions/           ← updated + notes
    └── ex5-background-tasks/     ← final capstone project + tests
```

---

## 🏁 Phase 2 Checklist

- [ ] Exercise 2.1 — First FastAPI App
- [ ] Exercise 2.2 — Schemas & Response Models
- [ ] Exercise 2.3 — Dependency Injection
- [ ] Exercise 2.4 — Exception Handling & Middleware
- [ ] Exercise 2.5 — Background Tasks & APIRouter (Capstone)
- [ ] Update main `README.md` Phase 2 status to ✅
- [ ] Write LinkedIn Post #2

---

**Previous:** [← Phase 1](../phase-1-foundations/README.md) | **Next:** [Phase 3 — Database →](../phase-3-database/README.md)
