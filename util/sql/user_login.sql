DROP TABLE IF EXISTS users;
CREATE TABLE users (
            id            INTEGER AUTO_INCREMENT PRIMARY KEY, 
            username      char(25),
            password      char(25),
            email_address char(35),
            first_name    char(35),
            last_name     char(35) 
);

DROP TABLE IF EXISTS roles;
CREATE TABLE roles (
            id   INTEGER PRIMARY KEY,
            role TEXT
);

DROP TABLE IF EXISTS users_to_roles;
CREATE TABLE users_to_roles (
            user_id INTEGER,
            role_id INTEGER,
            PRIMARY KEY (user_id, role_id)
);

DROP TABLE IF EXISTS openid;
CREATE TABLE openid (
            openid_url char(100) PRIMARY KEY,
            user_id_id INTEGER
            
);

