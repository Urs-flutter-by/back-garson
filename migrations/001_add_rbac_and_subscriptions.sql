-- Этап 1: Создание базовой структуры для RBAC и системы подписок.

-- 1. Таблица для управления аккаунтами клиентов (владельцами ресторанов)
CREATE TABLE IF NOT EXISTS accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Таблица для управления подписками и лимитами
CREATE TABLE IF NOT EXISTS subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    plan_name TEXT NOT NULL DEFAULT 'basic',
    status TEXT NOT NULL DEFAULT 'active', -- active, past_due, canceled
    valid_until TIMESTAMPTZ NOT NULL,
    max_waiters INTEGER NOT NULL DEFAULT 1,
    max_tables INTEGER NOT NULL DEFAULT 5,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Справочник ролей
CREATE TABLE IF NOT EXISTS roles (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

-- 4. Справочник всех возможных разрешений в системе
CREATE TABLE IF NOT EXISTS permissions (
    id SERIAL PRIMARY KEY,
    action_key TEXT NOT NULL UNIQUE,
    description TEXT
);

-- 5. Связующая таблица для назначения разрешений ролям (многие-ко-многим)
CREATE TABLE IF NOT EXISTS role_permissions (
    role_id TEXT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id INTEGER NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- Заполнение начальными данными

-- Заполняем таблицу ролей
INSERT INTO roles (id, name, description) VALUES
    ('SUPER_ADMIN', 'Супер Администратор', 'Полный доступ ко всей системе'),
    ('ADMIN_RESTAURANT', 'Администратор Ресторана', 'Управление одним или несколькими ресторанами'),
    ('WAITER', 'Официант', 'Прием и ведение заказов'),
    ('CHEF', 'Повар', 'Приготовление заказов')
ON CONFLICT (id) DO NOTHING;

-- Заполняем таблицу разрешений
INSERT INTO permissions (action_key, description) VALUES
    ('restaurant:create', 'Создание нового ресторана'),
    ('restaurant:edit', 'Редактирование своего ресторана'),
    ('restaurant:delete', 'Удаление ресторана'),
    ('hall:create', 'Создание зала в ресторане'),
    ('hall:edit', 'Редактирование зала'),
    ('hall:delete', 'Удаление зала'),
    ('table:create', 'Создание стола в зале'),
    ('table:edit', 'Редактирование стола'),
    ('table:delete', 'Удаление стола'),
    ('dish:create', 'Создание блюда в меню'),
    ('dish:edit', 'Редактирование блюда'),
    ('dish:delete', 'Удаление блюда'),
    ('user:create', 'Создание нового сотрудника'),
    ('user:edit', 'Редактирование сотрудника'),
    ('user:delete', 'Удаление сотрудника'),
    ('order:read', 'Просмотр заказов'),
    ('order:status:confirm', 'Подтверждение заказа клиента'),
    ('order:status:prepare', 'Взятие заказа в работу'),
    ('order:status:ready_for_pickup', 'Отметка заказа как готового'),
    ('order:status:serve', 'Отметка заказа как поданного')
ON CONFLICT (action_key) DO NOTHING;

-- Назначаем разрешения для роли "Администратор Ресторана"
-- (Предполагаем, что суперадмин имеет все права по умолчанию в коде)
INSERT INTO role_permissions (role_id, permission_id)
SELECT 'ADMIN_RESTAURANT', id FROM permissions WHERE action_key IN (
    'restaurant:edit',
    'hall:create', 'hall:edit', 'hall:delete', 
    'table:create', 'table:edit', 'table:delete',
    'dish:create', 'dish:edit', 'dish:delete',
    'user:create', 'user:edit', 'user:delete',
    'order:read'
) ON CONFLICT DO NOTHING;

-- Назначаем разрешения для роли "Официант"
INSERT INTO role_permissions (role_id, permission_id)
SELECT 'WAITER', id FROM permissions WHERE action_key IN (
    'order:read',
    'order:status:confirm',
    'order:status:serve'
) ON CONFLICT DO NOTHING;

-- Назначаем разрешения для роли "Повар"


