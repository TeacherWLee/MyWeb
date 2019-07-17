"""

<<<<<<< HEAD

__author__ = Li Wei (liw@sicnu.edu.cn)
"""
from flask import render_template, request
from . import home


@home.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        form = request.form.to_dict()
        print(form)
    return render_template('auth/login.html')
