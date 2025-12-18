# app/services/feed_service.py
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text


# ---------------------------------------------------------
# 1) 최신순 Feed (사진 + 일기)
# ---------------------------------------------------------
async def get_feed_latest(db: AsyncSession, user_id: int):
    sql = text("""
        WITH related AS (
            SELECT id FROM app_user WHERE id = :user_id
            UNION
            SELECT father_id FROM app_user WHERE id = :user_id AND father_id IS NOT NULL
            UNION
            SELECT mother_id FROM app_user WHERE id = :user_id AND mother_id IS NOT NULL
            UNION
            SELECT spouse_id FROM app_user WHERE id = :user_id AND spouse_id IS NOT NULL
        ),
        families AS (
            SELECT DISTINCT family_id
            FROM family_member
            WHERE user_id IN (SELECT id FROM related)
        ),
        album_ids AS (
            SELECT a.id
            FROM album a
            JOIN album_folder f ON a.folder_id = f.id
            WHERE f.family_id IN (SELECT family_id FROM families)
        ),
        photos AS (
            SELECT 
                'photo' AS type,
                p.id AS content_id,
                p.created_at AS sort_date,
                p.original_url AS value
            FROM photo p
            WHERE p.album_id IN (SELECT id FROM album_ids)
        ),
        diaries AS (
            SELECT
                'diary' AS type,
                d.id AS content_id,
                d.created_at AS sort_date,
                d.title AS value
            FROM diary d
            WHERE d.family_id IN (SELECT family_id FROM families)
        )
        SELECT *
        FROM (
            SELECT * FROM photos
            UNION ALL
            SELECT * FROM diaries
        ) x
        ORDER BY sort_date DESC
        LIMIT 50;
    """)

    result = await db.execute(sql, {"user_id": user_id})
    return result.mappings().all()


# ---------------------------------------------------------
# 2) 랜덤 피드 (사진만)
# ---------------------------------------------------------
async def get_feed_random(db: AsyncSession, user_id: int):
    sql = text("""
        WITH related AS (
            SELECT id FROM app_user WHERE id = :user_id
            UNION
            SELECT father_id FROM app_user WHERE id = :user_id AND father_id IS NOT NULL
            UNION
            SELECT mother_id FROM app_user WHERE id = :user_id AND mother_id IS NOT NULL
            UNION
            SELECT spouse_id FROM app_user WHERE id = :user_id AND spouse_id IS NOT NULL
        ),
        families AS (
            SELECT DISTINCT family_id
            FROM family_member
            WHERE user_id IN (SELECT id FROM related)
        ),
        album_ids AS (
            SELECT a.id
            FROM album a
            JOIN album_folder f ON a.folder_id = f.id
            WHERE f.family_id IN (SELECT family_id FROM families)
        )
        SELECT *
        FROM photo
        WHERE album_id IN (SELECT id FROM album_ids)
          AND deleted_at IS NULL
        ORDER BY RANDOM()
        LIMIT 20;
    """)

    result = await db.execute(sql, {"user_id": user_id})
    return result.mappings().all()


# ---------------------------------------------------------
# 3) 통합 Feed
# ---------------------------------------------------------
async def get_feed_all(db: AsyncSession, user_id: int):
    sql = text("""
        WITH related AS (
            SELECT id FROM app_user WHERE id = :user_id
            UNION
            SELECT father_id FROM app_user WHERE id = :user_id AND father_id IS NOT NULL
            UNION
            SELECT mother_id FROM app_user WHERE id = :user_id AND mother_id IS NOT NULL
            UNION
            SELECT spouse_id FROM app_user WHERE id = :user_id AND spouse_id IS NOT NULL
        ),
        families AS (
            SELECT DISTINCT family_id
            FROM family_member
            WHERE user_id IN (SELECT id FROM related)
        ),
        album_ids AS (
            SELECT a.id
            FROM album a
            JOIN album_folder f ON a.folder_id = f.id
            WHERE f.family_id IN (SELECT family_id FROM families)
        ),
        photos AS (
            SELECT 
                'photo' AS type,
                p.id AS content_id,
                p.created_at AS sort_date,
                p.original_url AS value
            FROM photo p
            WHERE p.album_id IN (SELECT id FROM album_ids)
        ),
        diaries AS (
            SELECT
                'diary' AS type,
                d.id AS content_id,
                d.created_at AS sort_date,
                d.title AS value
            FROM diary d
            WHERE d.family_id IN (SELECT family_id FROM families)
        )
        SELECT *
        FROM (
            SELECT * FROM photos
            UNION ALL
            SELECT * FROM diaries
        ) x;
    """)

    result = await db.execute(sql, {"user_id": user_id})
    return result.mappings().all()
