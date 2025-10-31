-- Добавляем колонку для хранения ID сессии, связанной с заказом
ALTER TABLE orders ADD COLUMN session_id UUID;

-- Добавляем индекс для быстрого поиска по ID сессии
CREATE INDEX IF NOT EXISTS idx_orders_session_id ON orders(session_id);
