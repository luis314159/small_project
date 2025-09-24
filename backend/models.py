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