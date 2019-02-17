"""


__author__ = Li Wei (liw@sicnu.edu.cn)
"""


from flask import Flask


def create_app():
    app = Flask(__name__)       # 创建Flask核心对象

    app.config.from_object('app.secure')        # 加载配置文件
    app.config.from_object('app.setting')

    register_blueprint(app)     # 注册蓝图

    return app


def register_blueprint(app):
    from app.home import home
    app.register_blueprint(home)
