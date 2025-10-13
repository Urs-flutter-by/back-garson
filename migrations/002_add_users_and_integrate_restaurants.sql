-- Этап 2: Интеграция пользователей и ресторанов

-- 1. Создание единой таблицы для всех сотрудников
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_id UUID NOT NULL REFERENCES accounts(id) ON DELETE CASCADE,
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    login TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    gender TEXT NOT NULL DEFAULT 'other', -- Возможные значения: 'male', 'female', 'other'
    role TEXT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Добавление колонки account_id в таблицу restaurants для привязки к владельцу
-- Сначала проверяем, существует ли колонка, чтобы избежать ошибок при повторном запуске
DO $$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='restaurants' AND column_name='account_id') THEN
        ALTER TABLE restaurants ADD COLUMN account_id UUID REFERENCES accounts(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Индекс для ускорения выборок ресторанов по аккаунту
CREATE INDEX IF NOT EXISTS idx_restaurants_account_id ON restaurants(account_id);

