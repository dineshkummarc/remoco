-- SQL schema converted from ER_Diagram_2026-11-26T13_45_15.638Z.md
-- Target: MySQL / MariaDB (InnoDB, utf8mb4)
-- Notes:
--   * Integer primary keys use AUTO_INCREMENT.
--   * company_id is VARCHAR(36); other unspecified VARCHAR columns use VARCHAR(255).
--   * CHATS.task_id is UNIQUE to enforce at most one chat room per task.
--   * VIDEO_CALLS.initiator_id is not constrained because the Mermaid diagram does not mark it as an FK.

CREATE TABLE companies (
    company_id VARCHAR(36) NOT NULL,
    company_name VARCHAR(255),
    is_registered BOOLEAN,
    company_ntn VARCHAR(255),
    company_sector VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255),
    PRIMARY KEY (company_id),
    UNIQUE KEY uq_companies_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE employees (
    employee_id INT NOT NULL AUTO_INCREMENT,
    employee_name VARCHAR(255),
    cnic VARCHAR(255),
    email VARCHAR(255),
    password VARCHAR(255),
    company_id VARCHAR(36),
    designation VARCHAR(255),
    PRIMARY KEY (employee_id),
    UNIQUE KEY uq_employees_cnic (cnic),
    UNIQUE KEY uq_employees_email (email),
    CONSTRAINT fk_employees_company
        FOREIGN KEY (company_id) REFERENCES companies(company_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE tasks (
    task_id INT NOT NULL AUTO_INCREMENT,
    title VARCHAR(255),
    task_description TEXT,
    due_date DATE,
    task_priority ENUM('High', 'Medium', 'Low'),
    task_status ENUM('Not Started', 'In Progress', 'Completed'),
    team_lead_id INT,
    assigned_by INT,
    tm1 INT,
    tm2 INT,
    tm3 INT,
    completion_date DATE,
    PRIMARY KEY (task_id),
    KEY idx_tasks_team_lead (team_lead_id),
    KEY idx_tasks_assigned_by (assigned_by),
    KEY idx_tasks_tm1 (tm1),
    KEY idx_tasks_tm2 (tm2),
    KEY idx_tasks_tm3 (tm3),
    CONSTRAINT fk_tasks_team_lead
        FOREIGN KEY (team_lead_id) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_tasks_assigned_by
        FOREIGN KEY (assigned_by) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_tasks_tm1
        FOREIGN KEY (tm1) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_tasks_tm2
        FOREIGN KEY (tm2) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_tasks_tm3
        FOREIGN KEY (tm3) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE checkpoints (
    checkpoint_id INT NOT NULL AUTO_INCREMENT,
    task_id INT NOT NULL,
    checkpoint VARCHAR(255),
    status VARCHAR(255),
    PRIMARY KEY (checkpoint_id),
    KEY idx_checkpoints_task (task_id),
    CONSTRAINT fk_checkpoints_task
        FOREIGN KEY (task_id) REFERENCES tasks(task_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE chats (
    chat_id INT NOT NULL AUTO_INCREMENT,
    chat_title VARCHAR(255),
    task_id INT NOT NULL,
    pm_id INT,
    tl_id INT,
    tm1_id INT,
    tm2_id INT,
    tm3_id INT,
    firebase_room_id VARCHAR(255),
    PRIMARY KEY (chat_id),
    UNIQUE KEY uq_chats_task (task_id),
    KEY idx_chats_pm (pm_id),
    KEY idx_chats_tl (tl_id),
    KEY idx_chats_tm1 (tm1_id),
    KEY idx_chats_tm2 (tm2_id),
    KEY idx_chats_tm3 (tm3_id),
    CONSTRAINT fk_chats_task
        FOREIGN KEY (task_id) REFERENCES tasks(task_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_chats_pm
        FOREIGN KEY (pm_id) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_chats_tl
        FOREIGN KEY (tl_id) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_chats_tm1
        FOREIGN KEY (tm1_id) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_chats_tm2
        FOREIGN KEY (tm2_id) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    CONSTRAINT fk_chats_tm3
        FOREIGN KEY (tm3_id) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE shared_files (
    file_id INT NOT NULL AUTO_INCREMENT,
    chat_id INT NOT NULL,
    uploaded_by INT NOT NULL,
    file_name VARCHAR(255),
    file_path VARCHAR(255),
    upload_time DATETIME,
    PRIMARY KEY (file_id),
    KEY idx_shared_files_chat (chat_id),
    KEY idx_shared_files_uploaded_by (uploaded_by),
    CONSTRAINT fk_shared_files_chat
        FOREIGN KEY (chat_id) REFERENCES chats(chat_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_shared_files_employee
        FOREIGN KEY (uploaded_by) REFERENCES employees(employee_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE video_calls (
    call_id INT NOT NULL AUTO_INCREMENT,
    chat_id INT NOT NULL,
    call_start DATETIME,
    call_end DATETIME,
    call_status ENUM('requested', 'active', 'completed'),
    initiator_id INT,
    agora_channel VARCHAR(255),
    PRIMARY KEY (call_id),
    KEY idx_video_calls_chat (chat_id),
    CONSTRAINT fk_video_calls_chat
        FOREIGN KEY (chat_id) REFERENCES chats(chat_id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
