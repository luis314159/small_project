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