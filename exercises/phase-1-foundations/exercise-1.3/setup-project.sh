#!/bin/bash

root="my-api"

dirs=(
    "${root}/app/routers"
    "${root}/app/models"
    "${root}/app/schemas"
    "${root}/tests"
    "${root}/alembic"
    "${root}/docs"
)
declare -a dirs
for i in "${dirs[@]}"; do mkdir -p "$i"; done
echo 'print("FastAPI project ready!")' > "${root}/app/main.py"
echo -e '__pycache__/\n.env\nvenv/\n*.pyc' > .gitignore
echo "# My FastAPI Project" > README.md
git add .
git commit -m "chore: initial project structure"

echo "✅ Project ready!"
