"""


__author__ = Li Wei (liw@sicnu.edu.cn)
"""
from flask import render_template, request
from . import home


@home.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        print("POST Method")
    return render_template('auth/login.html')
