# Phase 4 — Authentication & Security

> **Duration:** 1.5 weeks
> **Goal:** Secure your APIs like a professional — understand every layer, not just how to copy it

---

## 🧠 What You'll Learn

- Password hashing with bcrypt (and why everything else is wrong)
- JWT: access tokens + refresh tokens with rotation
- FastAPI's OAuth2PasswordBearer — how it actually works
- Role-based access control (RBAC) with custom dependencies
- Security hardening: rate limiting, CORS, trusted headers, input sanitization
- Common attack vectors: brute force, token theft, injection

---

## ✅ Exercises

---

### Exercise 4.1 — Password Hashing & Registration
**Concept:** bcrypt, secure user storage, response filtering
**Difficulty:** ⭐⭐☆

**Task:**

1. Install: `pip install passlib[bcrypt] python-jose[cryptography] python-multipart`
2. Create `app/auth/security.py`:
```python
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str: ...
def verify_password(plain: str, hashed: str) -> bool: ...
```

3. Add `hashed_password` to your `User` model (nullable initially for existing rows)
4. Create `POST /auth/register` that:
   - Accepts `name`, `email`, `password` (min 8 chars, must contain a number)
   - Checks for duplicate email — returns `409 Conflict` if taken
   - **Never** stores the plain password — hash it before saving
   - Returns `UserResponse` — a schema that **excludes** `hashed_password`

5. Write `security-notes.md`:
   - What is bcrypt? What is a salt and why does bcrypt generate one automatically?
   - Why is MD5 catastrophically bad for passwords? What about SHA-256?
   - What is `CryptContext(deprecated="auto")` and why is it important?

---

### Exercise 4.2 — JWT Login & Protected Routes
**Concept:** JWT, OAuth2PasswordBearer, current user dependency
**Difficulty:** ⭐⭐⭐

**Task:**

1. Create `app/auth/jwt.py`:
```python
SECRET_KEY = os.getenv("SECRET_KEY")  # load from .env
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 15
REFRESH_TOKEN_EXPIRE_DAYS = 7

def create_access_token(data: dict) -> str: ...
def create_refresh_token(data: dict) -> str: ...
def decode_token(token: str) -> dict: ...  # raises HTTPException on invalid/expired
```

2. Implement `POST /auth/login`:
   - Use FastAPI's `OAuth2PasswordRequestForm` (this is the standard)
   - Verify email + password with bcrypt
   - Return `{ "access_token": "...", "refresh_token": "...", "token_type": "bearer" }`

3. Create the `get_current_user` dependency:
```python
async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db)
) -> User:
    # decode token → get user_id → fetch from DB → return user
    # raise 401 if anything is wrong
```

4. Create `GET /auth/me` — protected, returns the logged-in user's profile
5. Protect these routes (require a valid JWT):
   - `POST /posts` — must be logged in
   - `PATCH /posts/{id}` — must be logged in AND be the post author
   - `DELETE /posts/{id}` — must be logged in AND be the author or an admin

**Write `jwt-notes.md`:**
- What are the 3 parts of a JWT? What is in each part?
- Why does the access token expire in 15 minutes?
- What does `Depends(oauth2_scheme)` actually do under the hood?

---

### Exercise 4.3 — Refresh Tokens & Logout
**Concept:** Token rotation, refresh token storage, logout
**Difficulty:** ⭐⭐⭐

**Task:**

1. Add a `RefreshToken` model to your database:
```python
class RefreshToken(Base):
    id: int
    token: str (unique, indexed)
    user_id: int (FK)
    expires_at: datetime
    is_revoked: bool (default False)
```

2. When a user logs in, save the refresh token to the DB

3. Implement `POST /auth/refresh`:
   - Accept `{ "refresh_token": "..." }` in the request body
   - Verify: token exists in DB, not revoked, not expired
   - Delete the old refresh token from DB (rotation — prevent reuse)
   - Issue a new access token AND a new refresh token
   - Return both

4. Implement `POST /auth/logout`:
   - Requires a valid access token (protected route)
   - Marks the user's refresh token as `is_revoked = True` in the DB

5. Write a test sequence:
   - Register → Login → get tokens
   - Use refresh token → get new tokens
   - Try to use the OLD refresh token → should get `401`
   - Logout → try to refresh again → should get `401`

**Write `refresh-token-notes.md`:**
- Why do we store refresh tokens in the DB but not access tokens?
- What is refresh token rotation and why does it prevent token theft?
- What is the correct way to store tokens on the client side (cookie vs localStorage)?

---

### Exercise 4.4 — Role-Based Access Control (RBAC)
**Concept:** Custom auth dependencies, authorization vs authentication
**Difficulty:** ⭐⭐⭐

**Task:**

1. Add `role` field to `User` model: `admin`, `editor`, `viewer` (use Python `Enum`)

2. Create a `require_roles` dependency factory:
```python
def require_roles(*roles: str):
    async def dependency(current_user: User = Depends(get_current_user)):
        if current_user.role not in roles:
            raise HTTPException(status_code=403, detail="Insufficient permissions")
        return current_user
    return dependency

# Usage:
@router.get("/admin/users", dependencies=[Depends(require_roles("admin"))])
```

3. Apply role protection:
   - `GET /admin/users` — admin only, returns paginated user list
   - `PATCH /admin/users/{id}/role` — admin only, change a user's role
   - `PATCH /admin/users/{id}/ban` — admin only, adds `is_banned: bool` field
   - `POST /posts` — any logged-in user (`viewer`, `editor`, `admin`)
   - `PATCH /posts/{id}` — only the post author OR admin
   - `DELETE /posts/{id}` — only the post author OR admin

4. Write tests:
   - Regular user hitting `/admin/users` → `403`
   - Admin hitting `/admin/users` → `200`
   - Author editing own post → `200`
   - Different user editing someone else's post → `403`

**Write `rbac-notes.md`:**
- What is the difference between Authentication and Authorization?
- What is the principle of least privilege? How did you apply it here?
- What is a more advanced RBAC system? Look up ABAC (Attribute-Based Access Control) and explain when you'd use it instead.

---

### Exercise 4.5 — Security Hardening (Capstone)
**Concept:** Rate limiting, CORS, input validation, security headers
**Difficulty:** ⭐⭐⭐

**Task:**
Add production-grade security layers:

1. **Rate limiting** with `slowapi`:
```bash
pip install slowapi
```
   - `POST /auth/login` → max 5 requests per minute per IP (brute force protection)
   - `POST /auth/register` → max 3 requests per minute per IP
   - Global fallback: 100 requests per minute per IP

2. **CORS** — configure for specific origins only:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],  # your frontend
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

3. **Security headers** with `secure` library or manually:
   - `X-Content-Type-Options: nosniff`
   - `X-Frame-Options: DENY`
   - `Strict-Transport-Security: max-age=31536000`

4. **Input sanitization:**
   - Strip leading/trailing whitespace from all string inputs using Pydantic validators
   - Reject any input that contains `<script` (basic XSS check — write a Pydantic validator)

5. **Test your hardening:**
   - Hit `/auth/login` 6 times in a loop with a Python script → verify you get `429` on the 6th
   - Send a POST body with `"title": "<script>alert(1)</script>"` → verify it's rejected

6. Write `security-checklist.md` documenting each layer and what attack it prevents.

---

## 🏁 Phase 4 Checklist

- [ ] Exercise 4.1 — Password Hashing & Registration
- [ ] Exercise 4.2 — JWT Login & Protected Routes
- [ ] Exercise 4.3 — Refresh Tokens & Logout
- [ ] Exercise 4.4 — RBAC
- [ ] Exercise 4.5 — Security Hardening (Capstone)
- [ ] Update main `README.md` Phase 4 status to ✅
- [ ] Write LinkedIn Post #4

---

**Previous:** [← Phase 3](../phase-3-database/README.md) | **Next:** [Phase 5 — Advanced →](../phase-5-advanced/README.md)
