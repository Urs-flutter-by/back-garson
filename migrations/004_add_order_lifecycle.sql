-- Этап 3: Расширение логики заказов для аналитики

-- 1. Добавление колонок в существующую таблицу orders
DO $$
BEGIN
    -- Добавляем колонку статуса заказа
    IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='status') THEN
        ALTER TABLE orders ADD COLUMN status TEXT NOT NULL DEFAULT 'pending_confirmation';
    END IF;

    -- Добавляем колонку для ответственного официанта
    IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='waiter_id') THEN
        ALTER TABLE orders ADD COLUMN waiter_id UUID REFERENCES users(id) ON DELETE SET NULL;
    END IF;

    -- Добавляем колонку для ответственного повара
    IF NOT EXISTS(SELECT 1 FROM information_schema.columns WHERE table_name='orders' AND column_name='chef_id') THEN
        ALTER TABLE orders ADD COLUMN chef_id UUID REFERENCES users(id) ON DELETE SET NULL;
    END IF;
END $$;

-- 2. Создание таблицы для истории статусов заказа
CREATE TABLE IF NOT EXISTS order_status_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    -- ID пользователя, сменившего статус. Может быть NULL, если, например, статус меняет система
    changed_by_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Добавление индексов для ускорения выборок
CREATE INDEX IF NOT EXISTS idx_orders_waiter_id ON orders(waiter_id);
CREATE INDEX IF NOT EXISTS idx_orders_chef_id ON orders(chef_id);
CREATE INDEX IF NOT EXISTS idx_order_status_history_order_id ON order_status_history(order_id);
