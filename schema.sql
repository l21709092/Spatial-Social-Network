-- schema.sql
-- 1. Users table (authentication)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Profiles table (puublic info)
CREATE TABLE profiles (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    display_name VARCHAR(100),
    bio TEXT,
    avatar_url VARCHAR(500),
    cover_url VARCHAR(500),
    location VARCHAR(100)
);

--3. Rooms Table (3d spaces)
CREATE TABLE rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT NOW()
);

--4. POSTS TABLE (SOCIAL FEED)
CREATE TABLE posts (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references users(id) on delete cascade,
    content text not null,
    image_url varchar(500),
    created_at timestamp default NOW(),
    updated_at timestamp default now()
);

--5. follows table (social graph)
CREATE TABLE follows (
    follower_id uuid references users(id) on delete cascade,
    following_id uuid references users(id) on delete cascade,
    created_at timestamp default now(),
    primary key (follower_id, following_id)
);

--6. messages table (persistent dms)
CREATE TABLE messages (
    id uuid primary key default gen_random_uuid(),
    sender_id uuid references users(id) on delete cascade,
    receiver_id uuid references users(id) on delete cascade,
    content text not null,
    created_at timestamp default now(),
    read_at timestamp
);

--7. comments table (comments on posts)
create table comments(
    id uuid primary key default gen_random_uuid(),
    post_id uuid references posts(id) on delete cascade,
    user_id uuid references users(id) on delete cascade,
    content text not null,
    created_at timestamp default now()
);

--8. likes table (likes on posts)
create table likes(
    user_id uuid references users(id) on delete cascade,
    post_id uuid references posts(id) on delete cascade,
    created_at timestamp default now(),
    primary key (user_id, post_id)
);

--9. room members table (users in rooms)
create table room_members(
    room_id uuid references rooms(id) on delete cascade,
    user_id uuid references users(id) on delete cascade,
    joined_at timestamp default now(),
    primary key (room_id, user_id)
);

-- 10. notifications table (user notifications)
create table notifications(
    id uuid primary key default gen-random_uuid(),
    user_id uuid references users(id) on delete cascade,
    type varchar(50) not null,
    actor_id uuid references users(id) on delete cascade,
    reference_id uuid,
    is_read BOOLEAN default false,
    created_at timestamp default now()
);

--11. verification records table (for verification stuff)
create table verification_records(
    id uuid primary key default gen-random_uuid(),
    user_id uuid references users(id) on delete cascade,
    verification_type varchar(50) not null,
    status varchar(20) not null default 'pending',
    verified_at timestamp,
    proof_metadata jsonb
);
--indexes for performance
create index idx_posts_user_id on posts(user_id);
create index idx_posts_created_at on posts(created_at desc);
create index idx_follows_follower on follows(follower_id);
create index idx_follows_following on follows(following_id);
create index idx_messages_sender on messages(sender_id);
create index idx_messages_receiver on messages (receiver_id);
create index idx_comments_post_id on comments(post_id);
create index idx_comments_user_id on comments(user_id);
create index idx_likes_post_id on likes(post_id);
create index idx_room_members_user_id on room_members(user_id);
create index idx_notifications_user_id on notifications(user_id);
create index idx_notifications_is_read on notifications(is-read);
create index idx_notifications_created_at on notifications(created_at desc);
create index idx_verification_user_id on verification_records(user_id);
create index idx_verification_type on verification_records(verification_type);