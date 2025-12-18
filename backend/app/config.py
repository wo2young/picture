from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    PROJECT_NAME: str = "FastAPI Project"

    # DB
    DATABASE_URL: str

    # Azure Blob Storage
    AZURE_STORAGE_CONNECTION_STRING: str
    AZURE_STORAGE_CONTAINER_NAME: str

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"  # UTF-8 강제


settings = Settings()
