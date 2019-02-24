"""

"""
from flask import render_template, request

from . import home


@home.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        return 'login'
    return render_template('auth/login.html')
