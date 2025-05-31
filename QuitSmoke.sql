CREATE DATABASE QuitSmokingPlatform;
GO

USE QuitSmokingPlatform;
GO

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_membership_plans_price ON membership_plans(price);
CREATE INDEX idx_user_memberships_user ON user_memberships(user_id);
CREATE INDEX idx_user_memberships_status ON user_memberships(status);
CREATE INDEX idx_payment_user ON payment_transactions(user_id);
CREATE INDEX idx_payment_status ON payment_transactions(transaction_status);
CREATE INDEX idx_smoking_user ON smoking_records(user_id);
CREATE INDEX idx_smoking_record_date ON smoking_records(record_date);
CREATE INDEX idx_quit_plans_user ON quit_plans(user_id);
CREATE INDEX idx_quit_plans_target_date ON quit_plans(target_quit_date);
CREATE INDEX idx_progress_user ON progress_records(user_id);
CREATE INDEX idx_progress_record_date ON progress_records(record_date);
CREATE INDEX idx_notifications_type ON notifications(notification_type);
CREATE INDEX idx_notifications_frequency ON notifications(frequency);
CREATE INDEX idx_badges_name ON achievement_badges(name);
CREATE INDEX idx_chat_sessions_user ON chat_sessions(user_id);
CREATE INDEX idx_chat_sessions_coach ON chat_sessions(coach_id);
CREATE INDEX idx_chat_messages_session ON chat_messages(session_id);
CREATE INDEX idx_feedback_user ON feedback(user_id);
CREATE INDEX idx_feedback_rating ON feedback(rating);

CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) UNIQUE NOT NULL,
    password NVARCHAR(255) NOT NULL, -- Mã hóa bằng SHA2_256
    full_name NVARCHAR(255) NOT NULL,
    phone NVARCHAR(20) NULL,
    role NVARCHAR(20) DEFAULT 'user' CHECK (role IN ('user', 'coach', 'admin')),
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE membership_plans (
    plan_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    price DECIMAL(10,2),
    duration_in_days INT,
    features NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE user_memberships (
    membership_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    plan_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    status NVARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'expired', 'cancelled')),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_user_membership FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_plan_membership FOREIGN KEY (plan_id) REFERENCES membership_plans(plan_id)
);

CREATE TABLE payment_transactions (
    transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    membership_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATETIME DEFAULT GETDATE(),
    payment_gateway NVARCHAR(100),
    transaction_status NVARCHAR(50) CHECK (transaction_status IN ('pending', 'completed', 'failed')),
    CONSTRAINT fk_payment_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_payment_membership FOREIGN KEY (membership_id) REFERENCES user_memberships(membership_id)
);

CREATE TABLE smoking_records (
    record_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    record_date DATE NOT NULL,
    cigarettes_count INT,
    frequency NVARCHAR(50),
    cost_per_cigarette DECIMAL(10,2),
    total_cost DECIMAL(10,2),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_smoking_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE quit_plans (
    quit_plan_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    reason NVARCHAR(MAX),
    start_date DATE,
    target_quit_date DATE,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_quit_plan_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE progress_records (
    progress_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    record_date DATE NOT NULL,
    no_smoking_days INT,
    money_saved DECIMAL(10,2),
    health_improvement NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_progress_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255),
    message NVARCHAR(MAX),
    notification_type NVARCHAR(20) CHECK (notification_type IN ('motivation', 'achievement', 'reminder')),
    frequency NVARCHAR(20) DEFAULT 'daily' CHECK (frequency IN ('daily', 'weekly', 'monthly')),
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE achievement_badges (
    badge_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    icon_url NVARCHAR(255),
    criteria NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE()
);

CREATE TABLE user_badges (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    badge_id INT NOT NULL,
    awarded_date DATE,
    comment NVARCHAR(MAX),
    CONSTRAINT fk_user_badge FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_badge FOREIGN KEY (badge_id) REFERENCES achievement_badges(badge_id)
);

CREATE TABLE chat_sessions (
    session_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    coach_id INT NOT NULL,
    start_time DATETIME DEFAULT GETDATE(),
    end_time DATETIME,
    status NVARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'closed')),
    CONSTRAINT fk_chat_session_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_chat_session_coach FOREIGN KEY (coach_id) REFERENCES users(user_id)
);

CREATE TABLE chat_messages (
    message_id INT IDENTITY(1,1) PRIMARY KEY,
    session_id INT NOT NULL,
    sender_id INT NOT NULL,
    message NVARCHAR(MAX) NOT NULL,
    sent_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_chat_message FOREIGN KEY (session_id) REFERENCES chat_sessions(session_id),
    CONSTRAINT fk_chat_sender FOREIGN KEY (sender_id) REFERENCES users(user_id)
);

CREATE TABLE feedback (
    feedback_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment NVARCHAR(MAX),
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT fk_feedback_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

