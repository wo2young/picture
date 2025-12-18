# app/services/upload_service.py
import os
from uuid import uuid4
from fastapi import UploadFile

UPLOAD_DIR = "uploads"


async def save_file_locally(file: UploadFile) -> str:
    ext = os.path.splitext(file.filename)[1]
    filename = f"{uuid4().hex}{ext}"

    if not os.path.exists(UPLOAD_DIR):
        os.makedirs(UPLOAD_DIR)

    filepath = os.path.join(UPLOAD_DIR, filename)

    contents = await file.read()

    with open(filepath, "wb") as f:
        f.write(contents)

    return f"/uploads/{filename}"
