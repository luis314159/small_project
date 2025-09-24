# Social Network Project - Ejemplo de Código

## 📋 Estructura del Proyecto

```
social_network/
├── backend/
│   ├── main.py
│   ├── models.py
│   ├── database.py
│   └── requirements.txt
├── frontend/
│   ├── index.html
│   ├── login.html
│   ├── profile.html
│   └── style.css
└── database/
    ├── schema.sql
    ├── seed_data.sql
    └── database_design.md
```

## 🛠️ Código de Ejemplo

### Backend (FastAPI + SQLModel)

**main.py** (Database-First con SQLite)
```python
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import sqlite3
import json

app = FastAPI(title="Social Network API")

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
    cur.execute(
        "INSERT INTO users (username, role) VALUES (?, ?) RETURNING *",
        (user_data['username'], user_data.get('role', 'user'))
    )
    user = dict(cur.fetchone())
    conn.commit()
    conn.close()
    return user

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
        "INSERT INTO posts (title, body, user_id) VALUES (?, ?, ?) RETURNING *",
        (post_data['title'], post_data['body'], post_data['user_id'])
    )
    post = dict(cur.fetchone())
    conn.commit()
    conn.close()
    return post

@app.get("/")
def home():
    """Simple health check"""
    return {"message": "Social Network API is running!"}
```

**requirements.txt**
```
fastapi==0.104.1
uvicorn==0.24.0
```

### Frontend (HTML + JavaScript)

**index.html** (con Tailwind CSS)
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Social Network</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen">
    <!-- Header -->
    <header class="bg-white shadow-md">
        <div class="max-w-6xl mx-auto px-4 py-4">
            <nav class="flex justify-between items-center">
                <h1 class="text-2xl font-bold text-blue-600">Social Network</h1>
                <div class="space-x-4">
                    <a href="index.html" class="text-gray-600 hover:text-blue-600 font-medium">Home</a>
                    <a href="profile.html" class="text-gray-600 hover:text-blue-600 font-medium">Profile</a>
                    <a href="login.html" class="text-gray-600 hover:text-blue-600 font-medium">Login</a>
                </div>
            </nav>
        </div>
    </header>

    <main class="max-w-4xl mx-auto px-4 py-8">
        <!-- Create Post Section -->
        <div class="bg-white rounded-lg shadow-md p-6 mb-8">
            <h2 class="text-xl font-semibold mb-4 text-gray-800">Create New Post</h2>
            <form id="post-form" class="space-y-4">
                <div>
                    <input 
                        type="text" 
                        id="title" 
                        placeholder="Post title" 
                        required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    >
                </div>
                <div>
                    <textarea 
                        id="body" 
                        placeholder="Write your post..." 
                        required
                        rows="4"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent resize-none"
                    ></textarea>
                </div>
                <button 
                    type="submit"
                    class="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 transition-colors font-medium"
                >
                    Post
                </button>
            </form>
        </div>

        <!-- Posts Section -->
        <div class="bg-white rounded-lg shadow-md p-6">
            <h2 class="text-xl font-semibold mb-6 text-gray-800">Recent Posts</h2>
            <div id="posts-container" class="space-y-4">
                <!-- Posts will be loaded here -->
            </div>
            <div id="loading" class="text-center py-8">
                <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                <p class="mt-2 text-gray-600">Loading posts...</p>
            </div>
        </div>
    </main>

    <script>
        const API_BASE = 'http://localhost:8000';

        // Load posts when page loads
        document.addEventListener('DOMContentLoaded', loadPosts);

        // Handle post creation
        document.getElementById('post-form').addEventListener('submit', createPost);

        async function loadPosts() {
            try {
                const response = await fetch(`${API_BASE}/posts`);
                const posts = await response.json();
                displayPosts(posts);
            } catch (error) {
                console.error('Error loading posts:', error);
                document.getElementById('posts-container').innerHTML = `
                    <div class="text-center py-8 text-red-600">
                        <p>Error loading posts. Make sure the API is running!</p>
                    </div>
                `;
            } finally {
                document.getElementById('loading').style.display = 'none';
            }
        }

        function displayPosts(posts) {
            const container = document.getElementById('posts-container');
            
            if (posts.length === 0) {
                container.innerHTML = `
                    <div class="text-center py-8 text-gray-500">
                        <p>No posts yet. Be the first to post!</p>
                    </div>
                `;
                return;
            }

            container.innerHTML = posts.map(post => `
                <div class="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow">
                    <h3 class="text-lg font-semibold text-gray-800 mb-2">${post.title}</h3>
                    <p class="text-gray-600 mb-3">${post.body}</p>
                    <div class="flex justify-between items-center text-sm text-gray-500">
                        <span class="bg-blue-100 text-blue-800 px-2 py-1 rounded-full">@${post.username}</span>
                        <span>${new Date(post.created_at).toLocaleDateString()}</span>
                    </div>
                </div>
            `).join('');
        }

        async function createPost(event) {
            event.preventDefault();
            
            const title = document.getElementById('title').value;
            const body = document.getElementById('body').value;
            const submitButton = event.target.querySelector('button[type="submit"]');
            
            // Disable button while posting
            submitButton.disabled = true;
            submitButton.textContent = 'Posting...';
            
            try {
                const response = await fetch(`${API_BASE}/posts`, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({
                        title,
                        body,
                        user_id: 1 // Hardcoded for simplicity
                    })
                });
                
                if (response.ok) {
                    // Clear form and reload posts
                    document.getElementById('post-form').reset();
                    loadPosts();
                    
                    // Show success message
                    showNotification('Post created successfully!', 'success');
                } else {
                    throw new Error('Failed to create post');
                }
            } catch (error) {
                console.error('Error creating post:', error);
                showNotification('Error creating post. Please try again.', 'error');
            } finally {
                submitButton.disabled = false;
                submitButton.textContent = 'Post';
            }
        }

        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.className = `fixed top-4 right-4 p-4 rounded-md shadow-lg z-50 ${
                type === 'success' ? 'bg-green-500' : 'bg-red-500'
            } text-white`;
            notification.textContent = message;
            
            document.body.appendChild(notification);
            
            setTimeout(() => {
                notification.remove();
            }, 3000);
        }
    </script>
</body>
</html>
```

### Database

**schema.sql** (SQLite)
```sql
-- Users table
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    role VARCHAR(20) DEFAULT 'user',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Posts table  
CREATE TABLE posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title VARCHAR(100) NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL,
    status VARCHAR(20) DEFAULT 'published',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Follow relationships
CREATE TABLE follows (
    following_user_id INTEGER,
    followed_user_id INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (following_user_id, followed_user_id),
    FOREIGN KEY (following_user_id) REFERENCES users(id),
    FOREIGN KEY (followed_user_id) REFERENCES users(id)
);
```

**seed_data.sql** (SQLite)
```sql
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
```

---

# 🚀 DEMO SÚPER SIMPLE

## Para mostrar en 5 minutos:

**1. Crear la base de datos SQLite:**
```bash
# Crear base de datos
sqlite3 social_network.db

-- Crear tablas
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

-- Datos de ejemplo
INSERT INTO users (username, role) VALUES 
('juan_dev', 'user'),
('maria_admin', 'admin');

INSERT INTO posts (title, body, user_id) VALUES 
('Mi primer post', 'Hola mundo desde la API!', 1),
('Segundo post', 'Este proyecto está genial', 2);

.exit
```

**2. Ejecutar el backend:**
```bash
# Instalar dependencias (solo 2!)
pip install fastapi uvicorn

# Ejecutar servidor
uvicorn main:app --reload
```

**3. Probar en el navegador:**
- `http://localhost:8000/` → Ver mensaje de bienvenida
- `http://localhost:8000/docs` → Documentación automática
- `http://localhost:8000/users` → Ver usuarios
- `http://localhost:8000/posts` → Ver posts

**4. Abrir el HTML** → Interfaz bonita con Tailwind que funciona inmediatamente

## ✨ **Lo que verán tus estudiantes:**
- 🎨 **UI moderna** con Tailwind (sin escribir CSS)
- 📱 **Responsive** automáticamente 
- ⚡ **Loading states** y notificaciones
- 🔄 **Interacciones fluidas**
- 🗃️ **SQLite** (archivo local, súper simple)

**¡Solo 2 dependencias Python y listo!** 🎉

## 👨‍💼 Manager/Coordinador (25% del proyecto)

### Actividades:
1. **Setup inicial del repositorio**
   - Crear estructura de carpetas
   - README con instrucciones de instalación
   - Gitignore apropiado

2. **Documentación del proyecto**
   - Definir requirements y funcionalidades
   - Documentar APIs endpoints
   - Manual de usuario básico

3. **Coordinación del equipo**
   - Organizar reuniones semanales (2-3)
   - Hacer seguimiento de tareas
   - Integrar componentes finales

### Entregables:
- [ ] README.md completo
- [ ] Documentación de la API
- [ ] Manual de instalación
- [ ] Presentación final (5-10 slides)

---

## ⚙️ Backend Developer (25% del proyecto)

### Actividades:
1. **API Development**
   - Implementar endpoints básicos (users, posts, follows)
   - Validación de datos
   - Manejo de errores

2. **Integración con base de datos**
   - Conectar con la base de datos
   - Implementar modelos
   - Testing básico de endpoints

### Entregables:
- [ ] API funcional con FastAPI
- [ ] Modelos de datos implementados
- [ ] Documentación automática (Swagger)
- [ ] Al menos 5 endpoints funcionando
- [ ] Archivo requirements.txt

**Endpoints mínimos:**
- GET /users
- POST /users  
- GET /posts
- POST /posts
- POST /follow

---

## 🗄️ Database Developer (25% del proyecto)

### Actividades:
1. **Diseño de base de datos**
   - Crear esquema normalizado
   - Definir relaciones y constraints
   - Scripts de creación

2. **Datos de prueba**
   - Crear datos de ejemplo
   - Scripts de inserción
   - Backup y restore procedures

### Entregables:
- [ ] Script de creación de tablas (schema.sql)
- [ ] Script con datos de prueba (seed_data.sql)
- [ ] Diagrama ER de la base de datos
- [ ] Documentación de la estructura
- [ ] Instrucciones de setup de DB

**Tablas requeridas:**
- users (id, username, role, created_at)
- posts (id, title, body, user_id, status, created_at)
- follows (following_user_id, followed_user_id, created_at)

---

## 🎨 Frontend Developer (25% del proyecto)

### Actividades:
1. **Páginas principales**
   - Página de inicio con posts
   - Formulario de crear posts
   - Página de perfil básica

2. **Integración con API**
   - Conectar con endpoints del backend
   - Mostrar datos dinámicos
   - Manejo básico de errores

### Entregables:
- [ ] 3-4 páginas HTML funcionando
- [ ] CSS básico para styling
- [ ] JavaScript para conectar con API
- [ ] Formularios funcionales
- [ ] Navegación entre páginas

**Páginas mínimas:**
- index.html (feed de posts)
- create-post.html (crear nuevo post)
- profile.html (perfil de usuario)
- login.html (formulario de login)

---

# ⏰ Timeline Sugerido (3-4 semanas)

**Semana 1**: Setup y definición
- Manager: Crear estructura del proyecto
- Database: Diseñar esquema
- Backend: Setup FastAPI
- Frontend: Crear páginas básicas

**Semana 2**: Desarrollo core
- Database: Implementar tablas y datos
- Backend: Desarrollar endpoints
- Frontend: Conectar con API
- Manager: Documentar progreso

**Semana 3**: Integración
- Conectar todos los componentes
- Testing básico
- Resolver bugs de integración

**Semana 4**: Pulir y presentar
- Documentación final
- Preparar demo
- Presentación grupal

---

# 🎯 Criterios de Evaluación

- **Funcionalidad** (40%): El proyecto funciona correctamente
- **Integración** (25%): Los componentes trabajan juntos
- **Documentación** (20%): Código y proyecto bien documentado
- **Trabajo en equipo** (15%): Colaboración efectiva y distribución de tareas

**Funcionalidades mínimas para aprobar:**
- ✅ Crear usuarios
- ✅ Crear y mostrar posts
- ✅ Seguir usuarios
- ✅ Frontend conectado con backend
- ✅ Base de datos funcionando