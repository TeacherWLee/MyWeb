"""

"""


from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import Column


db = SQLAlchemy()


class BaseModel(db.Model):
    __abstract__ = True
    id = db.Column(db.Integer, primary_key=True)
    status = db.Column(db.Integer, nullable=False, default=0)

