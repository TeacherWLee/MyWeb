"""


__author__ = Li Wei (liw@sicnu.edu.cn)
"""
from flask import render_template

from . import home


@home.route('/')
def index():
    return render_template('index.html')
