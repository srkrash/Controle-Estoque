import sqlite3
import os

path = ''
dbname = 'estoque.db'

if not os.path.isfile(os.path.join(path, dbname)):
    conn = sqlite3.connect(os.path.join(path, dbname))
    conn.close()