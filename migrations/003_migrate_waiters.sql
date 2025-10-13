-- Этап 2: Скрипт для миграции (переноса) данных из старой таблицы waiters в новую таблицу users.
-- Версия 2: Имена колонок исправлены в соответствии с реальной схемой таблицы waiters.

-- Этот скрипт следует запускать ПОСЛЕ того, как были выполнены миграции 001 и 002.
-- Он предполагает, что в таблице 'restaurants' уже существует колонка 'account_id'.

INSERT INTO users (name, login, password_hash, role, restaurant_id, account_id, gender, created_at)
SELECT
    w.username, -- Используем username в качестве имени
    w.username, -- и в качестве логина
    w.password_hash, -- Используем корректное имя поля
    'WAITER', -- Устанавливаем роль жестко
    w.restaurant_id,
    r.account_id, -- Получаем account_id через связь с рестораном
    'other', -- Устанавливаем пол по умолчанию
    w.created_at -- Сохраняем оригинальную дату создания
FROM
    waiters w
JOIN
    restaurants r ON w.restaurant_id = r.id
ON CONFLICT (login) DO NOTHING; -- Защита от дубликатов: если пользователь с таким логином уже существует, ничего не делать.