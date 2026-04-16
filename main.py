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

os.makedirs("uploads", exist_ok=True)

# ==========================================
# 2. MEMBUAT TABEL DATABASE
# ==========================================
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
# FITUR 9: SISTEM CACHING INTERNAL (PENGGANTI REDIS)
# ==========================================
# Ini adalah "Papan Tulis" RAM kita
APP_CACHE = {
    "data_kegiatan": None,
    "apakah_valid": False
}

def bersihkan_cache():
    """Fungsi untuk menghapus papan tulis saat ada data baru/dihapus"""
    APP_CACHE["apakah_valid"] = False
    APP_CACHE["data_kegiatan"] = None
    print("🧹 CACHE DIBERSIHKAN: Ada perubahan data!")

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
    bersihkan_cache() # Hapus cache karena ada data baru
    return {"message": "Sukses!", "data": new_event}

@app.get("/api/events")
def get_all_events(db: Session = Depends(get_db)):
    # CEK CACHE: Jika data masih valid, ambil dari RAM (Super Cepat!)
    if APP_CACHE["apakah_valid"] and APP_CACHE["data_kegiatan"] is not None:
        print("⚡ NGEBUT: Mengambil data dari CACHE (RAM)!")
        return APP_CACHE["data_kegiatan"]
    
    # Jika cache kosong/tidak valid, ambil dari Database (Hardisk)
    print("💽 LAMBAT: Mengambil data dari DATABASE (Hardisk)!")
    events = db.query(EventDB).all()
    
    # Simpan ke Cache untuk permintaan selanjutnya
    APP_CACHE["data_kegiatan"] = events
    APP_CACHE["apakah_valid"] = True
    return events

@app.put("/api/events/{event_id}")
def update_event(event_id: int, event: EventCreate, db: Session = Depends(get_db)):
    db_event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if db_event:
        db_event.title = event.title
        db_event.description = event.description
        db_event.month_year = event.month_year
        db_event.status = event.status
        db_event.location = event.location
        db_event.image_url = event.image_url
        db.commit()
        bersihkan_cache() # Hapus cache karena data diubah
        return {"message": "Sukses Update"}
    return {"message": "Gagal"}

@app.delete("/api/events/{event_id}")
def delete_event(event_id: int, db: Session = Depends(get_db)):
    db_event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if db_event:
        db.delete(db_event)
        db.commit()
        bersihkan_cache() # Hapus cache karena data dihapus
        return {"message": "Kegiatan berhasil dihapus"}
    return {"message": "Kegiatan tidak ditemukan"}

@app.post("/api/upload")
def upload_image(file: UploadFile = File(...)):
    file_location = f"uploads/{file.filename}"
    with open(file_location, "wb+") as file_object:
        shutil.copyfileobj(file.file, file_object)
    return {"image_url": f"http://127.0.0.1:8000/uploads/{file.filename}"}