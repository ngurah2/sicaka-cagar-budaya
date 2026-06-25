import os
import shutil
import jwt
from datetime import datetime, timedelta
from fastapi import FastAPI, Depends, UploadFile, File, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials 
from sqlalchemy import create_engine, Column, Integer, String, Text
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from pydantic import BaseModel

# ==========================================
# 1. SETUP DATABASE & FOLDER
# ==========================================
SQLALCHEMY_DATABASE_URL = "sqlite:///./kalender.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

os.makedirs("uploads", exist_ok=True)

class EventDB(Base):
    __tablename__ = "events"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(Text)
    month_year = Column(String, index=True) 
    status = Column(String, index=True)     
    location = Column(String) 
    image_url = Column(String) 

Base.metadata.create_all(bind=engine)

app = FastAPI(title="API SI-CAKA")
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"], 
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# ==========================================
# 2. FITUR CACHING INTERNAL 
# ==========================================
APP_CACHE = {
    "data_kegiatan": None,
    "apakah_valid": False
}

def bersihkan_cache():
    APP_CACHE["apakah_valid"] = False
    APP_CACHE["data_kegiatan"] = None

# ==========================================
# 3. SISTEM KEAMANAN & LOGIN (JWT)
# ==========================================
SECRET_KEY = "KunciRahasiaPuspemBadung123!" 
ALGORITHM = "HS256"
security = HTTPBearer() 

ADMIN_USERNAME = "admin.cagarbudaya"
ADMIN_PASSWORD = "password123"

class LoginRequest(BaseModel):
    username: str
    password: str

def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload["sub"]
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token sudah kedaluwarsa, silakan login ulang.")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Token tidak valid!")

@app.post("/api/login")
def login(req: LoginRequest):
    if req.username == ADMIN_USERNAME and req.password == ADMIN_PASSWORD:
        expiration = datetime.utcnow() + timedelta(days=1)
        token = jwt.encode({"sub": req.username, "exp": expiration}, SECRET_KEY, algorithm=ALGORITHM)
        return {"message": "Login Sukses", "token": token}
    else:
        raise HTTPException(status_code=401, detail="Username atau Password salah!")

# ==========================================
# 4. SCHEMA & ENDPOINTS KEGIATAN
# ==========================================
class EventCreate(BaseModel):
    title: str
    description: str
    month_year: str
    status: str
    location: str 
    image_url: str

@app.get("/api/events")
def get_all_events(db: Session = Depends(get_db)):
    if APP_CACHE["apakah_valid"] and APP_CACHE["data_kegiatan"] is not None:
        return APP_CACHE["data_kegiatan"]
    events = db.query(EventDB).all()
    APP_CACHE["data_kegiatan"] = events
    APP_CACHE["apakah_valid"] = True
    return events

@app.post("/api/events")
def create_event(event: EventCreate, db: Session = Depends(get_db), admin: str = Depends(verify_token)):
    new_event = EventDB(**event.dict())
    db.add(new_event)
    db.commit()
    db.refresh(new_event)
    bersihkan_cache()
    return {"message": "Sukses!", "data": new_event}

@app.put("/api/events/{event_id}")
def update_event(event_id: int, event: EventCreate, db: Session = Depends(get_db), admin: str = Depends(verify_token)):
    db_event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if db_event:
        db_event.title = event.title
        db_event.description = event.description
        db_event.month_year = event.month_year
        db_event.status = event.status
        db_event.location = event.location
        db_event.image_url = event.image_url
        db.commit()
        bersihkan_cache()
        return {"message": "Sukses Update"}
    return {"message": "Gagal"}

@app.delete("/api/events/{event_id}")
def delete_event(event_id: int, db: Session = Depends(get_db), admin: str = Depends(verify_token)):
    db_event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if db_event:
        db.delete(db_event)
        db.commit()
        bersihkan_cache()
        return {"message": "Kegiatan berhasil dihapus"}
    return {"message": "Kegiatan tidak ditemukan"}

@app.post("/api/upload")
def upload_image(file: UploadFile = File(...), admin: str = Depends(verify_token)):
    file_location = f"uploads/{file.filename}"
    with open(file_location, "wb+") as file_object:
        shutil.copyfileobj(file.file, file_object)
    return {"image_url": f"http://127.0.0.1:8000/uploads/{file.filename}"}