python
# main.py
from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy import create_engine, Column, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import uuid

DATABASE_URL = "sqlite:///./keys.db"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class APIKey(Base):
    __tablename__ = "api_keys"
    key = Column(String, primary_key=True, index=True)
    active = Column(String, default="true")

Base.metadata.create_all(bind=engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/api/generate_key/")
def generate_key(db: Session = Depends(get_db)):
    new_key = f"sk-custom-{uuid.uuid4().hex}"
    db.add(APIKey(key=new_key))
    db.commit()
    return {"api_key": new_key}

@app.get("/api/keys/")
def get_keys(db: Session = Depends(get_db)):
    keys = db.query(APIKey).filter(APIKey.active == "true").all()
    return keys

@app.post("/api/use_model/")
def use_model(api_key: str, model_input: dict):
    # تحقق من صحة المفتاح
    # توجيه الطلب إلى Ollama
    pass