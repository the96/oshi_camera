const schema = [
  '''
CREATE TABLE processed_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    bytes BLOB NOT NULL,
    created_at TEXT NOT NULL
);
''',
  '''
CREATE TABLE hoge (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL
);
'''
];
