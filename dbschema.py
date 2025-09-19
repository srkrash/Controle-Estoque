import sqlite3
import os

class Database:
    def __init__(self, dbname='estoque.db'):
        self.path = ''
        self.dbname = dbname
        self.schema_file = 'schema.sql'
        if not os.path.isfile(os.path.join(self.path, self.dbname)):
            conn = sqlite3.connect(os.path.join(self.path, self.dbname))
            with open(os.path.join(self.path, self.schema_file), 'r') as file:
                script_sql = file.read()
            cursor = conn.cursor()
            cursor.executescript(script_sql)
            conn.commit()
            conn.close()

if __name__ == '__main__':
    Database()