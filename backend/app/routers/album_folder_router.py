from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.database import get_db
from app.schemas.album_folder_schema import (
    AlbumFolderCreate,
    AlbumFolderResponse,
)
from app.services import album_folder_service

router = APIRouter(
    prefix="/album-folders",
    tags=["AlbumFolder"],
)


# =========================
# 폴더 생성
# =========================
@router.post("", response_model=AlbumFolderResponse)
def create_folder(
    data: AlbumFolderCreate,
    db: Session = Depends(get_db),
):
    return album_folder_service.create_folder(db, data)


# =========================
# 폴더 목록 조회
# =========================
@router.get("", response_model=list[AlbumFolderResponse])
def get_folders(
    family_id: int = Query(...),
    db: Session = Depends(get_db),
):
    return album_folder_service.get_folders(db, family_id)


# =========================
# 폴더 단건 조회
# =========================
@router.get("/{folder_id}", response_model=AlbumFolderResponse)
def get_folder(
    folder_id: int,
    db: Session = Depends(get_db),
):
    folder = album_folder_service.get_folder(db, folder_id)
    if not folder:
        raise HTTPException(status_code=404, detail="Folder not found")
    return folder


# =========================
# 폴더 삭제
# =========================
@router.delete("/{folder_id}")
def delete_folder(
    folder_id: int,
    db: Session = Depends(get_db),
):
    ok = album_folder_service.delete_folder(db, folder_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Folder not found")
    return {"result": "ok"}
