SELECT
    t.name AS Table_Name,
    c.column_id,
    c.name AS Column_Name,
    ty.name AS Data_Type,
    c.max_length,
    c.is_nullable
FROM sys.tables t
JOIN sys.columns c
    ON t.object_id = c.object_id
JOIN sys.types ty
    ON c.user_type_id = ty.user_type_id
WHERE t.name LIKE 'Dim_%'
ORDER BY
    t.name,
    c.column_id;