"""

<<<<<<< HEAD

__author__ = Li Wei (liw@sicnu.edu.cn)
"""
from flask import render_template, request
=======
"""
from flask import render_template, request

>>>>>>> 4a56d80e367d146572f6ae62241b89619ce5b9ca
from . import home


@home.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
<<<<<<< HEAD
        print("POST Method")
    return render_template('auth/login.html')

=======
        return 'login'
    return render_template('auth/login.html')
>>>>>>> 4a56d80e367d146572f6ae62241b89619ce5b9ca
