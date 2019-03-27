"""


__author__ = Li Wei (liw@sicnu.edu.cn)
"""

from flask import Blueprint


home = Blueprint('home', __name__)


from . import index
from . import auth
