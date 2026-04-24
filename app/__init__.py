from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS
from config import Config

db = SQLAlchemy()
jwt = JWTManager()

def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    jwt.init_app(app)
    CORS(app)

    from app.routes.auth_routes import auth_bp
    from app.routes.room_routes import room_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(room_bp, url_prefix='/rooms')

    with app.app_context():
        db.create_all()
        # Create a default user so rooms can be saved without login
        from app.models.user import User
        from werkzeug.security import generate_password_hash
        if not User.query.filter_by(id=1).first():
            default_user = User(
                name='Default',
                email='default@room3d.com',
                password=generate_password_hash('default123')
            )
            db.session.add(default_user)
            db.session.commit()

    return app