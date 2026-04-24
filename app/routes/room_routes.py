from flask import Blueprint, request, jsonify
from app import db
from app.models.room import Room
import json

room_bp = Blueprint('rooms', __name__)

@room_bp.route('/save', methods=['POST'])
def save_room():
    data = request.get_json()
    room = Room(
        user_id=1,  # no login needed — save under default user
        name=data.get('name', 'My Room'),
        width=data['width'],
        length=data['length'],
        height=data['height'],
        furniture=json.dumps(data.get('furniture', []))
    )
    db.session.add(room)
    db.session.commit()
    return jsonify({'message': 'Room saved', 'room_id': room.id}), 201

@room_bp.route('/list', methods=['GET'])
def list_rooms():
    rooms = Room.query.all()
    return jsonify([{
        'id': r.id,
        'name': r.name,
        'width': r.width,
        'length': r.length,
        'height': r.height,
        'furniture': json.loads(r.furniture) if r.furniture else [],
        'created_at': r.created_at.isoformat()
    } for r in rooms]), 200

@room_bp.route('/<int:room_id>', methods=['DELETE'])
def delete_room(room_id):
    room = Room.query.filter_by(id=room_id).first()
    if not room:
        return jsonify({'error': 'Room not found'}), 404
    db.session.delete(room)
    db.session.commit()
    return jsonify({'message': 'Room deleted'}), 200