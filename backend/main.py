from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import sqlite3
import os

def init_db():
    """Initialize database if it doesn't exist"""
    if not os.path.exists('social_network.db'):
        print("Creating database...")
        conn = sqlite3.connect('social_network.db')
        cursor = conn.cursor()
        
        # Create tables
        cursor.executescript("""
            CREATE TABLE users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username VARCHAR(50) NOT NULL UNIQUE,
                role VARCHAR(20) DEFAULT 'user',
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE posts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title VARCHAR(100) NOT NULL,
                body TEXT NOT NULL,
                user_id INTEGER NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id)
            );

            CREATE TABLE follows (
                following_user_id INTEGER,
                followed_user_id INTEGER,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (following_user_id, followed_user_id),
                FOREIGN KEY (following_user_id) REFERENCES users(id),
                FOREIGN KEY (followed_user_id) REFERENCES users(id)
            );

            -- Sample data
            INSERT INTO users (username, role) VALUES 
                ('juan_dev', 'user'),
                ('maria_admin', 'admin'),
                ('carlos_student', 'user');

            INSERT INTO posts (title, body, user_id) VALUES 
                ('Mi primer post', 'Hola mundo desde la API con SQLite!', 1),
                ('Segundo post', 'Este proyecto está genial', 2),
                ('Aprendiendo FastAPI', 'Es más fácil de lo que pensé', 3);

            INSERT INTO follows (following_user_id, followed_user_id) VALUES 
                (1, 2),
                (1, 3),
                (2, 3);
        """)
        
        conn.commit()
        conn.close()
        print("Database created successfully!")

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle startup and shutdown events"""
    # Startup
    init_db()
    yield
    # Shutdown (nothing to do)

app = FastAPI(title="Social Network API", lifespan=lifespan)

# Enable CORS
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

# Database connection
def get_db():
    """Connect to existing SQLite database"""
    conn = sqlite3.connect('social_network.db')
    conn.row_factory = sqlite3.Row  # This makes rows behave like dictionaries
    return conn

@app.get("/users")
def get_users():
    """Get all users from database"""
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT * FROM users ORDER BY created_at DESC")
    users = [dict(row) for row in cur.fetchall()]
    conn.close()
    return users

@app.post("/users")
def create_user(user_data: dict):
    """Create new user"""
    conn = get_db()
    cur = conn.cursor()
    try:
        cur.execute(
            "INSERT INTO users (username, role) VALUES (?, ?)",
            (user_data['username'], user_data.get('role', 'user'))
        )
        user_id = cur.lastrowid
        conn.commit()
        
        # Get the created user
        cur.execute("SELECT * FROM users WHERE id = ?", (user_id,))
        user = dict(cur.fetchone())
        conn.close()
        return user
    except sqlite3.IntegrityError:
        conn.close()
        raise HTTPException(status_code=400, detail="Username already exists")

@app.get("/posts")
def get_posts():
    """Get all posts with user info"""
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        SELECT p.*, u.username 
        FROM posts p 
        JOIN users u ON p.user_id = u.id 
        ORDER BY p.created_at DESC
    """)
    posts = [dict(row) for row in cur.fetchall()]
    conn.close()
    return posts

@app.post("/posts")
def create_post(post_data: dict):
    """Create new post"""
    conn = get_db()
    cur = conn.cursor()
    cur.execute(
        "INSERT INTO posts (title, body, user_id) VALUES (?, ?, ?)",
        (post_data['title'], post_data['body'], post_data['user_id'])
    )
    post_id = cur.lastrowid
    conn.commit()
    
    # Get the created post with username
    cur.execute("""
        SELECT p.*, u.username 
        FROM posts p 
        JOIN users u ON p.user_id = u.id 
        WHERE p.id = ?
    """, (post_id,))
    post = dict(cur.fetchone())
    conn.close()
    return post

@app.get("/")
def home():
    """Simple health check"""
    return {"message": "Social Network API is running!", "status": "ok"}

# Entry point for running the application
if __name__ == "__main__":
    import uvicorn
    print("🚀 Starting Social Network API...")
    print("📊 Database will be created automatically if it doesn't exist")
    print("🌐 API will be available at: http://localhost:8001")  
    print("📚 API documentation at: http://localhost:8001/docs")
    
    uvicorn.run(
        "main:app", 
        host="127.0.0.1",  # Changed to localhost only for Windows
        port=8001,         # Changed port to avoid conflicts
        reload=True,
        log_level="info"
    )