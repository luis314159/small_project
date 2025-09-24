# small_project
Small Project for Software Engineering Class at La Salle Chihuahua

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

**main.py**
```python
from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, select
from models import User, Post, Follow
from database import get_session
from typing import List

app = FastAPI(title="Social Network API")

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/users", response_model=List[User])
def get_users(session: Session = Depends(get_session)):
    """Get all users"""
    users = session.exec(select(User)).all()
    return users

@app.post("/users", response_model=User)
def create_user(user: User, session: Session = Depends(get_session)):
    """Create a new user"""
    session.add(user)
    session.commit()
    session.refresh(user)
    return user

@app.get("/posts", response_model=List[Post])
def get_posts(session: Session = Depends(get_session)):
    """Get all posts"""
    posts = session.exec(select(Post)).all()
    return posts

@app.post("/posts", response_model=Post)
def create_post(post: Post, session: Session = Depends(get_session)):
    """Create a new post"""
    session.add(post)
    session.commit()
    session.refresh(post)
    return post

@app.post("/follow")
def follow_user(follow: Follow, session: Session = Depends(get_session)):
    """Follow a user"""
    session.add(follow)
    session.commit()
    return {"message": "User followed successfully"}
```

**models.py**
```python
from sqlmodel import SQLModel, Field
from datetime import datetime
from typing import Optional

class User(SQLModel, table=True):
    """User model"""
    id: Optional[int] = Field(default=None, primary_key=True)
    username: str = Field(max_length=50)
    role: str = Field(default="user")
    created_at: datetime = Field(default_factory=datetime.now)

class Post(SQLModel, table=True):
    """Post model"""
    id: Optional[int] = Field(default=None, primary_key=True)
    title: str = Field(max_length=100)
    body: str
    user_id: int = Field(foreign_key="user.id")
    status: str = Field(default="published")
    created_at: datetime = Field(default_factory=datetime.now)

class Follow(SQLModel, table=True):
    """Follow relationship model"""
    following_user_id: int = Field(foreign_key="user.id", primary_key=True)
    followed_user_id: int = Field(foreign_key="user.id", primary_key=True)
    created_at: datetime = Field(default_factory=datetime.now)
```

### Frontend (HTML + JavaScript)

**index.html**
```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Social Network</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <header>
        <h1>Social Network</h1>
        <nav>
            <a href="index.html">Home</a>
            <a href="profile.html">Profile</a>
            <a href="login.html">Login</a>
        </nav>
    </header>

    <main>
        <section id="create-post">
            <h2>Create New Post</h2>
            <form id="post-form">
                <input type="text" id="title" placeholder="Post title" required>
                <textarea id="body" placeholder="Write your post..." required></textarea>
                <button type="submit">Post</button>
            </form>
        </section>

        <section id="posts">
            <h2>Recent Posts</h2>
            <div id="posts-container">
                <!-- Posts will be loaded here -->
            </div>
        </section>
    </main>

    <script src="app.js"></script>
</body>
</html>
```

**app.js**
```javascript
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
    }
}

function displayPosts(posts) {
    const container = document.getElementById('posts-container');
    container.innerHTML = posts.map(post => `
        <div class="post">
            <h3>${post.title}</h3>
            <p>${post.body}</p>
            <small>Posted by User ${post.user_id}</small>
        </div>
    `).join('');
}

async function createPost(event) {
    event.preventDefault();
    
    const title = document.getElementById('title').value;
    const body = document.getElementById('body').value;
    
    try {
        await fetch(`${API_BASE}/posts`, {
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
        
        // Clear form and reload posts
        document.getElementById('post-form').reset();
        loadPosts();
    } catch (error) {
        console.error('Error creating post:', error);
    }
}
```

### Database

**schema.sql**
```sql
-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    role VARCHAR(20) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Posts table  
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    body TEXT NOT NULL,
    user_id INTEGER NOT NULL REFERENCES users(id),
    status VARCHAR(20) DEFAULT 'published',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Follow relationships
CREATE TABLE follows (
    following_user_id INTEGER REFERENCES users(id),
    followed_user_id INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (following_user_id, followed_user_id)
);
```

---

# 📝 ENTREGABLES POR ROL

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
