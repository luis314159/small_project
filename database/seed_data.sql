-- Sample users
INSERT INTO users (username, role) VALUES 
('juan_dev', 'user'),
('maria_admin', 'admin'),
('carlos_student', 'user');

-- Sample posts
INSERT INTO posts (title, body, user_id) VALUES 
('Mi primer post', 'Hola mundo desde la API con SQLite!', 1),
('Segundo post', 'Este proyecto está genial', 2),
('Aprendiendo FastAPI', 'Es más fácil de lo que pensé', 3);

-- Sample follows
INSERT INTO follows (following_user_id, followed_user_id) VALUES 
(1, 2),
(1, 3),
(2, 3);