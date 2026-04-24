from app import db
from datetime import datetime

class Room(db.Model):
    __tablename__ = 'rooms'
    id          = db.Column(db.Integer, primary_key=True)
    user_id     = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    name        = db.Column(db.String(100), nullable=False)
    width       = db.Column(db.Float, nullable=False)
    length      = db.Column(db.Float, nullable=False)
    height      = db.Column(db.Float, nullable=False)
    furniture   = db.Column(db.Text)  # JSON string of furniture positions
    created_at  = db.Column(db.DateTime, default=datetime.utcnow)