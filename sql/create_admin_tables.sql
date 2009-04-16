CREATE database wormbase_admin;
USE database wormbase_admin;

CREATE TABLE scripts (
    id INTEGER PRIMARY KEY,
    command TEXT,
    brief_description TEXT,
    notes TEXT,
    intended_machine TEXT,
    authorization_required TEXT,
);
