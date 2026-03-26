# instagram-dbms-mysql
A simple MySQL database schema for Instagram — 5 core tables (users, posts, comments, likes, follows) with foreign keys, constraints, sample data, and test queries. Reverse-engineer ready for MySQL Workbench.
# instagram-dbms-mysql

A simple MySQL database schema inspired by Instagram. Built for learning and presentations — every line is commented so you can read and explain it easily.

Reverse-engineer it in **MySQL Workbench** to instantly generate a visual EER diagram.

---

## Tables

| Table | What it stores |
|-------|---------------|
| `users` | Every registered account |
| `posts` | Photos/videos uploaded by users |
| `comments` | Comments written on posts |
| `likes` | Which user liked which post |
| `follows` | Who follows whom |

---

## Schema Overview

```
users
 ├── posts        (one user → many posts)
 │    ├── comments  (one post → many comments)
 │    └── likes     (one post → many likes)
 └── follows      (one user → many followers/following)
```

---

## Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/your-username/instagram-dbms-mysql.git
```

### 2. Run the SQL in MySQL Workbench

1. Open **MySQL Workbench** and connect to your local server
2. Open `instagram_simple.sql`
3. Click the lightning bolt ⚡ to execute the full script

This will:
- Create the `instagram` database
- Create all 5 tables with constraints
- Insert sample data (3 users, 3 posts, comments, likes, follows)

### 3. Reverse Engineer the EER Diagram

1. Go to **Database → Reverse Engineer**
2. Follow the wizard and select the `instagram` database
3. MySQL Workbench will auto-generate the full entity-relationship diagram

---

## Key Design Decisions

**Passwords are hashed**
Passwords are stored using `SHA2()` — never as plain text.

**Cascade deletes**
All child tables use `ON DELETE CASCADE`. Delete a user → their posts, comments, likes, and follows are automatically removed.

**No duplicate likes**
The `likes` table has a composite `UNIQUE KEY (user_id, post_id)` — enforces one like per user per post at the database level.

**Self-follow prevention**
The `follows` table has a `CHECK (follower_id <> following_id)` constraint so a user cannot follow themselves.

---

## Sample Queries

**All posts with author name**
```sql
SELECT users.username, posts.caption, posts.created_at
FROM posts
JOIN users ON posts.user_id = users.user_id
ORDER BY posts.created_at DESC;
```

**Like count per post**
```sql
SELECT posts.caption, COUNT(likes.like_id) AS total_likes
FROM posts
LEFT JOIN likes ON posts.post_id = likes.post_id
GROUP BY posts.post_id;
```

**All followers of a user**
```sql
SELECT users.username AS follower
FROM follows
JOIN users ON follows.follower_id = users.user_id
WHERE follows.following_id = 1;
```

---

## File Structure

```
instagram-dbms-mysql/
├── instagram_simple.sql   # Main script — schema + sample data + queries
└── README.md
```

---

## Requirements

- MySQL 8.0 or higher
- MySQL Workbench 8.0 or higher

---

## License

— free to use for learning, projects, and presentations.
