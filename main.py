from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import create_engine, Column, Integer, String, Text
from sqlalchemy.orm import declarative_base, sessionmaker, Session
from pydantic import BaseModel

# ==========================================
# 1. SETUP DATABASE
# ==========================================
SQLALCHEMY_DATABASE_URL = "sqlite:///./kalender.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ==========================================
# 2. MEMBUAT TABEL DATABASE (DITAMBAH LOKASI)
# ==========================================
class EventDB(Base):
    __tablename__ = "events"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(Text)
    month_year = Column(String)
    status = Column(String)
    location = Column(String) # <--- TAMBAHAN LOKASI
    image_url = Column(String)

Base.metadata.create_all(bind=engine)

app = FastAPI(title="API SI-CAKA")

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
# 3. SCHEMA & ENDPOINTS (DITAMBAH FITUR EDIT)
# ==========================================
class EventCreate(BaseModel):
    title: str
    description: str
    month_year: str
    status: str
    location: str # <--- TAMBAHAN LOKASI
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

# FITUR BARU: UPDATE / EDIT KEGIATAN
@app.put("/api/events/{event_id}")
def update_event(event_id: int, event: EventCreate, db: Session = Depends(get_db)):
    db_event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if db_event:
        db_event.title = event.title
        db_event.description = event.description
        db_event.month_year = event.month_year
        db_event.status = event.status
        db_event.location = event.location
        db.commit()
        return {"message": "Sukses Update"}
    return {"message": "Gagal"}

# FITUR BARU: DELETE / HAPUS KEGIATAN
@app.delete("/api/events/{event_id}")
def delete_event(event_id: int, db: Session = Depends(get_db)):
    db_event = db.query(EventDB).filter(EventDB.id == event_id).first()
    if db_event:
        db.delete(db_event)
        db.commit()
        return {"message": "Kegiatan berhasil dihapus"}
    return {"message": "Kegiatan tidak ditemukan"}