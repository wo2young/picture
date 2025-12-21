import uuid
import os
from fastapi import UploadFile
from dotenv import load_dotenv
from azure.storage.blob import BlobServiceClient

load_dotenv()

AZURE_CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
AZURE_CONTAINER = os.getenv("AZURE_STORAGE_CONTAINER_NAME")

if not AZURE_CONNECTION_STRING or not AZURE_CONTAINER:
    raise RuntimeError("Azure Storage 환경변수가 설정되지 않았습니다.")

blob_service_client = BlobServiceClient.from_connection_string(
    AZURE_CONNECTION_STRING
)
container_client = blob_service_client.get_container_client(AZURE_CONTAINER)


async def upload_to_azure(file: UploadFile) -> str:
    """
    Azure Blob Storage에 파일 업로드 후 public URL 반환
    """
    ext = os.path.splitext(file.filename)[1]
    filename = f"{uuid.uuid4().hex}{ext}"

    blob_client = container_client.get_blob_client(filename)
    contents = await file.read()

    blob_client.upload_blob(
        contents,
        overwrite=True,
        content_type=file.content_type,
    )

    return blob_client.url
