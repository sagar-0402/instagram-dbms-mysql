-- ================================================
--  INSTAGRAM DATABASE 
--  Author: Sagar Devraj Sankhla
-- ================================================
DROP DATABASE IF EXISTS Instagram;
-- Step 1: Create and select the database
CREATE DATABASE IF NOT EXISTS Instagram;
USE Instagram;

-- ================================================
-- TABLE 1: USERS
-- Every person who signs up is stored here
-- ================================================
CREATE TABLE users (
    user_id       INT          NOT NULL AUTO_INCREMENT,  -- unique ID for each user
    username      VARCHAR(30)  NOT NULL UNIQUE,          -- must be unique, like @john
    email         VARCHAR(100) NOT NULL UNIQUE,          -- must be unique
    password_hash VARCHAR(255) NOT NULL,                 -- we never store plain passwords
    bio           TEXT,                                  -- optional, profile description
    created_at    TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,-- auto-set when row is inserted

    PRIMARY KEY (user_id)
);

-- ================================================
-- TABLE 2: POSTS
-- Each photo/video a user uploads
-- ================================================
CREATE TABLE posts (
    post_id    INT          NOT NULL AUTO_INCREMENT,
    user_id    INT          NOT NULL,                    -- who made this post
    image_url  VARCHAR(255) NOT NULL,                    -- link to the stored image/video
    caption    TEXT,                                     -- optional text under the post
    created_at TIMESTAMP    DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (post_id),

    -- This links posts.user_id back to users.user_id
    -- If the user is deleted, their posts are deleted too (CASCADE)
    FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- ================================================
-- TABLE 3: COMMENTS
-- A user can comment on any post
-- ================================================
CREATE TABLE comments (
    comment_id INT       NOT NULL AUTO_INCREMENT,
    post_id    INT       NOT NULL,  -- which post this comment is on
    user_id    INT       NOT NULL,  -- who wrote this comment
    content    TEXT      NOT NULL,  -- the actual comment text
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (comment_id),
    FOREIGN KEY (post_id) REFERENCES posts(post_id)  ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)  ON DELETE CASCADE
);

-- ================================================
-- TABLE 4: LIKES
-- Tracks which user liked which post
-- A user can only like the same post once (UNIQUE)
-- ================================================
CREATE TABLE likes (
    like_id    INT       NOT NULL AUTO_INCREMENT,
    user_id    INT       NOT NULL,
    post_id    INT       NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (like_id),

    -- This prevents a user from liking the same post twice
    UNIQUE KEY one_like_per_post (user_id, post_id),

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE
);


-- ================================================
-- TABLE 5: FOLLOWS
-- Tracks who follows whom
-- follower_id  = the person doing the following
-- following_id = the person being followed
-- ================================================
CREATE TABLE follows (
    follow_id    INT       NOT NULL AUTO_INCREMENT,
    follower_id  INT       NOT NULL,
    following_id INT       NOT NULL,
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (follow_id),

    -- A user can only follow someone once
    UNIQUE KEY one_follow (follower_id, following_id),

    -- A user cannot follow themselves
    CHECK (follower_id <> following_id),

    FOREIGN KEY (follower_id)  REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (following_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- ================================================
-- SAMPLE DATA  (for testing)
-- ================================================

-- Add 3 users
INSERT INTO users (username, email, password_hash, bio) VALUES
    ('alice',   'alice@example.com', SHA2('alice123', 256), 'Photographer'),
    ('bob',     'bob@example.com',   SHA2('bob123',   256), 'Travel lover'),
    ('charlie', 'charlie@gmail.com', SHA2('charlie1', 256), 'Food blogger');

-- Add 3 posts  (alice posts 2, bob posts 1)
INSERT INTO posts (user_id, image_url, caption) VALUES
    (1, 'https://cdn.example.com/img/sunset.jpg',  'Beautiful sunset!'),
    (1, 'https://cdn.example.com/img/coffee.jpg',  'Morning coffee'),
    (2, 'https://cdn.example.com/img/tokyo.jpg',   'Tokyo streets');

-- Add comments
INSERT INTO comments (post_id, user_id, content) VALUES
    (1, 2, 'Stunning photo!'),
    (1, 3, 'Where was this taken?'),
    (3, 1, 'I want to visit Tokyo!');

-- Add likes
INSERT INTO likes (user_id, post_id) VALUES
    (2, 1),   -- bob liked alice's sunset
    (3, 1),   -- charlie liked alice's sunset
    (1, 3);   -- alice liked bob's tokyo post

-- Add follows
INSERT INTO follows (follower_id, following_id) VALUES
    (2, 1),   -- bob follows alice
    (3, 1),   -- charlie follows alice
    (1, 2);   -- alice follows bob

-- ================================================
-- USEFUL QUERIES  (run these to test your data)
-- ================================================

-- See all posts with the author's username
SELECT
    posts.post_id,
    users.username   AS author,
    posts.caption,
    posts.created_at
FROM posts
JOIN users ON posts.user_id = users.user_id
ORDER BY posts.created_at DESC;


-- Count likes per post
SELECT
    posts.post_id,
    posts.caption,
    COUNT(likes.like_id) AS total_likes
FROM posts
LEFT JOIN likes ON posts.post_id = likes.post_id
GROUP BY posts.post_id, posts.caption;


-- See all followers of alice (user_id = 1)
SELECT
    users.username AS follower
FROM follows
JOIN users ON follows.follower_id = users.user_id
WHERE follows.following_id = 1;


-- Show comments on a specific post (post_id = 1)
SELECT
    users.username,
    comments.content,
    comments.created_at
FROM comments
JOIN users ON comments.user_id = users.user_id
WHERE comments.post_id = 1;
-- ============================================================
--  END
-- ============================================================