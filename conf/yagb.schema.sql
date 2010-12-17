-- Database : yagb
-- try SQL2003 (work for MySQL > 4.1.x, PostgreSQL > 8.x, SQLite > 3.x)
-- vim: set ft=sql :

-- CREATE DATABASE IF NOT EXISTS yagb;

CREATE TABLE yagb_messages (
    id INTEGER NOT NULL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    email VARCHAR(255) NOT NULL,
    homepage VARCHAR(255),
    message TEXT,
    post_time BIGINT NOT NULL,
    ip BIGINT NOT NULL,
    useragent VARCHAR(255) NOT NULL
);
