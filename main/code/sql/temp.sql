CREATE TABLE dbo.stg_users (
    user_id INT,
    name    VARCHAR(100),
    email   VARCHAR(255)
);

CREATE TABLE dbo.users (
    user_id     INT PRIMARY KEY,
    name        VARCHAR(100),
    email       VARCHAR(255),
    created_at  DATETIME DEFAULT GETDATE()
);

