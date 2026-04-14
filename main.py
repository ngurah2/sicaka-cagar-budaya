import os
import shutil
from fastapi import FastAPI, Depends, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from sqlalchemy import create_engine, Column, Integer, String, Text
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from pydantic import BaseModel

# ==========================================
# 1. SETUP DATABASE & FOLDER UPLOAD
# ==========================================
SQLALCHEMY_DATABASE_URL = "sqlite:///./kalender.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Membuat folder 'uploads' jika belum ada
os.makedirs("uploads", exist_ok=True)

# ==========================================
# 2. MEMBUAT TABEL DATABASE
# ==========================================
class EventDB(Base):
    __tablename__ = "events"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(Text)
    month_year = Column(String)
    status = Column(String)
    location = Column(String) 
    image_url = Column(String) # Kolom penyimpan nama/link gambar

Base.metadata.create_all(bind=engine)

app = FastAPI(title="API SI-CAKA")

# Mendaftarkan folder 'uploads' agar gambarnya bisa diakses oleh Flutter
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
# 3. SCHEMA & ENDPOINTS 
# ==========================================
class EventCreate(BaseModel):
    title: str
    description: str
    month_year: str
    status: str
    location: str 
    image_url: str

@app.post("/api/events")
def create_event(event: EventCreate, db: Session = Depends(get_db)):
    new_event = EventDB(**event.dict())
    db.add(new_event)
    db.commit()
    db.refresh(new_event)
    return {"message": "Sukses!", "data": new_event}

@app.get("/api/events")
def get_all_events(db: Session = Depends(get_db)):
    return db.query(EventDB).all()

@app.put("/api/events/{event_id}")
def update_event(event_id: int, event: EventCreate, db: Session = Depends(get_db)):
    db_event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if db_event:
        db_event.title = event.title
        db_event.description = event.description
        db_event.month_year = event.month_year
        db_event.status = event.status
        db_event.location = event.location
        db_event.image_url = event.image_url # Memastikan gambar ikut ter-update
        db.commit()
        return {"message": "Sukses Update"}
    return {"message": "Gagal"}

@app.delete("/api/events/{event_id}")
def delete_event(event_id: int, db: Session = Depends(get_db)):
    db_event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if db_event:
        db.delete(db_event)
        db.commit()
        return {"message": "Kegiatan berhasil dihapus"}
    return {"message": "Kegiatan tidak ditemukan"}

# FITUR BARU: ENDPOINT UNTUK MENERIMA FILE GAMBAR
@app.post("/api/upload")
def upload_image(file: UploadFile = File(...)):
    # Menyimpan file asli ke dalam folder uploads
    file_location = f"uploads/{file.filename}"
    with open(file_location, "wb+") as file_object:
        shutil.copyfileobj(file.file, file_object)
    
    # Mengembalikan link gambar tersebut agar bisa disimpan ke database oleh Flutter
    return {"image_url": f"http://127.0.0.1:8000/uploads/{file.filename}"}