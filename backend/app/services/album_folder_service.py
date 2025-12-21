from sqlalchemy.orm import Session
from datetime import datetime

from app.models.album_folder import AlbumFolder
from app.schemas.album_folder_schema import AlbumFolderCreate


# =========================
# 폴더 생성
# =========================
def create_folder(db: Session, data: AlbumFolderCreate) -> AlbumFolder:
    folder = AlbumFolder(
        family_id=data.family_id,
        name=data.name,
        description=data.description,
    )

    db.add(folder)
    db.commit()
    db.refresh(folder)
    return folder


# =========================
# 폴더 목록 조회
# =========================
def get_folders(db: Session, family_id: int) -> list[AlbumFolder]:
    return (
        db.query(AlbumFolder)
        .filter(
            AlbumFolder.family_id == family_id,
            AlbumFolder.deleted_at.is_(None),
        )
        .order_by(AlbumFolder.created_at.desc())
        .all()
    )


# =========================
# 폴더 단건 조회
# =========================
def get_folder(db: Session, folder_id: int) -> AlbumFolder | None:
    return (
        db.query(AlbumFolder)
        .filter(
            AlbumFolder.id == folder_id,
            AlbumFolder.deleted_at.is_(None),
        )
        .first()
    )


# =========================
# 폴더 삭제 (Soft Delete)
# =========================
def delete_folder(db: Session, folder_id: int) -> bool:
    folder = get_folder(db, folder_id)
    if not folder:
        return False

    folder.deleted_at = datetime.utcnow()
    db.commit()
    return True
