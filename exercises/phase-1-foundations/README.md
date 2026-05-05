# Phase 1 — Internet, HTTP & Python Foundations

> **Duration:** 1 week
> **Goal:** Understand how the web works and sharpen your Python before writing a single line of FastAPI

---

## 🧠 What You'll Learn

- How the internet works: DNS, TCP/IP, HTTP/HTTPS
- HTTP methods, status codes, headers, request/response cycle
- Terminal & bash fundamentals
- Git branching workflow used in real teams
- Python type hints, Pydantic models, virtual environments

---

## ✅ Exercises

---

### Exercise 1.1 — HTTP Inspector
**Concept:** HTTP methods, status codes, headers
**Difficulty:** ⭐☆☆

**Task:**
Using only `curl` in your terminal (no browser, no Postman), do all of the following:

1. `GET` request to `https://jsonplaceholder.typicode.com/posts/1`
   — save the full response (headers + body) to `get-response.txt` using `curl -i`
2. `POST` request to `https://jsonplaceholder.typicode.com/posts` with JSON body:
   `{"title": "My first post", "body": "Learning backend!", "userId": 1}`
   — save output to `post-response.txt`
3. `PATCH` request to `https://jsonplaceholder.typicode.com/posts/1` updating only the title
4. `DELETE` request to `https://jsonplaceholder.typicode.com/posts/1`

Then write `answers.md` answering:
- What status code did each request return? What does each mean?
- What is the difference between `PUT` and `PATCH`?
- What does the `Content-Type: application/json` header tell the server?
- What is the difference between a request header and a response header? Give 2 examples of each.

**Expected files:** `get-response.txt`, `post-response.txt`, `answers.md`

---

### Exercise 1.2 — DNS Detective
**Concept:** How DNS works, network fundamentals
**Difficulty:** ⭐☆☆

**Task:**
Using terminal tools (`dig`, `nslookup`, or `host`), investigate 3 websites of your choice:

1. Find their IPv4 address (`A` record)
2. Find their nameservers (`NS` record)
3. Find their mail servers (`MX` record)
4. Use `traceroute` (or `tracert` on Windows) on one of them and count the hops

Write `dns-report.md` with your findings and a step-by-step explanation of what happens — from the moment you type a URL in a browser to the moment the server sends back HTML. Write it like you're explaining to someone who has never heard of DNS.

**Bonus:** What is the difference between HTTP and HTTPS? What does the `S` actually do?

---

### Exercise 1.3 — Terminal & Bash Scripting
**Concept:** Terminal navigation, bash scripts, file system
**Difficulty:** ⭐☆☆

**Task:**
Write a bash script `setup-project.sh` that:

1. Creates this folder structure automatically:
```
my-api/
├── app/
│   ├── routers/
│   ├── models/
│   └── schemas/
├── tests/
├── alembic/
└── docs/
```
2. Creates a `main.py` file inside `app/` with content: `print("FastAPI project ready!")`
3. Creates a `.gitignore` file in the root with: `__pycache__/`, `.env`, `venv/`, `*.pyc`
4. Creates a `README.md` with the title `# My FastAPI Project`
5. Initializes a git repository and makes the first commit with message `"chore: initial project structure"`
6. Prints `"✅ Project ready!"` when done

Run it and verify it works. Commit both the script and the generated structure.

---

### Exercise 1.4 — Git Workflow Like a Real Team
**Concept:** Git branching, pull requests, commit messages
**Difficulty:** ⭐⭐☆

**Task:**
Simulate a real-team Git workflow on this repository:

1. Create branch `feature/phase1-exercises` and add your exercise solutions
2. Create branch `fix/readme-typo` and fix something small in the README
3. Merge `fix/readme-typo` into `main` first (it's a hotfix)
4. Open a Pull Request for `feature/phase1-exercises` — write a real PR description:
   - **What:** what did you change?
   - **Why:** what did you learn?
   - **How to test:** how should a reviewer verify this works?
5. Merge it into `main` using **squash merge**

Then write `git-notes.md` answering:
- What is the difference between `git merge` and `git rebase`?
- What is a squash merge and why do teams use it?
- What makes a good commit message? Write the rule you'll follow.

---

### Exercise 1.5 — Python Type System Deep Dive
**Concept:** Python type hints, Pydantic v2, dataclasses
**Difficulty:** ⭐⭐☆

**Task:**
Create `type_system.py` and build the following — **no FastAPI yet, pure Python + Pydantic:**

```python
# 1. An Enum for user roles
class Role(str, Enum):
    admin = "admin"
    editor = "editor"
    viewer = "viewer"

# 2. A Pydantic model for User
class User(BaseModel):
    id: int
    name: str
    email: str           # must be valid email format
    role: Role
    age: int             # must be between 18 and 120
    created_at: datetime

# 3. CreateUserSchema — no id, no created_at, password required (min 8 chars)
# 4. UpdateUserSchema — all fields optional
# 5. A function that creates a User from CreateUserSchema
# 6. A function that formats a user as: "[admin] John Doe <john@example.com>"
```

Requirements:
- Use Pydantic validators (`@field_validator`) to enforce the age range and email format
- Show that sending invalid data raises a `ValidationError` with a clear message
- Demonstrate `model_dump()` and `model_dump(exclude={"password"})` 

Run it: `python type_system.py` — show valid and invalid cases both.

**Write `pydantic-notes.md`:** What is Pydantic? Why does FastAPI use it instead of plain Python classes? What is the difference between Pydantic v1 and v2?

---

### Exercise 1.6 — Virtual Environments & Dependency Management
**Concept:** Python environments, pip, requirements
**Difficulty:** ⭐☆☆

**Task:**
This one is short but critical — many beginners skip it and regret it later.

1. Create a virtual environment: `python -m venv venv`
2. Activate it and install: `fastapi`, `uvicorn[standard]`, `pydantic[email]`, `python-dotenv`
3. Freeze dependencies: `pip freeze > requirements.txt`
4. Deactivate, delete `venv/`, recreate it from scratch using `requirements.txt` — verify it works
5. Create a `.env` file with `APP_NAME=MyAPI` and `DEBUG=true`
6. Write a Python script `config.py` that loads these with `python-dotenv` and prints them

Write `environments-notes.md`:
- Why should `venv/` never be committed to Git?
- What is the difference between `requirements.txt` and `pyproject.toml`?
- What does `uvicorn[standard]` mean — what does `[standard]` add?

---

## 📦 Folder Structure

```
exercises/
└── phase-1-foundations/
    ├── ex1-http-inspector/
    │   ├── get-response.txt
    │   ├── post-response.txt
    │   └── answers.md
    ├── ex2-dns-detective/
    │   └── dns-report.md
    ├── ex3-bash-scripting/
    │   └── setup-project.sh
    ├── ex4-git-workflow/
    │   └── git-notes.md
    ├── ex5-python-types/
    │   ├── type_system.py
    │   └── pydantic-notes.md
    └── ex6-virtual-environments/
        ├── config.py
        ├── .env.example
        ├── requirements.txt
        └── environments-notes.md
```

---

## 🏁 Phase 1 Checklist

- [ ] Exercise 1.1 — HTTP Inspector
- [ ] Exercise 1.2 — DNS Detective
- [ ] Exercise 1.3 — Bash Scripting
- [ ] Exercise 1.4 — Git Workflow
- [ ] Exercise 1.5 — Python Type System
- [ ] Exercise 1.6 — Virtual Environments
- [ ] Update main `README.md` Phase 1 status to ✅
- [ ] Write LinkedIn Post #1

---

**Next:** [Phase 2 — FastAPI Basics →](../phase-2-fastapi-basics/README.md)
