"""


__author__ = Li Wei (liw@sicnu.edu.cn)
"""

from web.app import create_app


app = create_app()


if __name__ == '__main__':
    print(app.url_map)
    app.run()
