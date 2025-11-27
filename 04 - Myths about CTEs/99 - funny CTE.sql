WITH hat
AS (
   SELECT
     CAST(REPLICATE(' ', 11) || '/V\' AS VARCHAR(100))
       AS hat_pattern,
     1 AS level
   
   UNION ALL
      
   SELECT
     CAST(
       REPLICATE(' ', 10-level) || '/'
         || REPLICATE('V', 2 * level + 1) || 'V\'
         AS VARCHAR(100))
       AS REPLICATEed_pattern,
     hat.level + 1
  FROM hat
  WHERE level < 6
)
SELECT hat_pattern
FROM hat
  
UNION ALL
  
SELECT
  CAST(
    REPLICATE(' ', 5) || '|' || '             ' || '|'
    AS VARCHAR(100))
  AS forehead
  
UNION ALL
  
SELECT
  CAST(
    REPLICATE(' ', 5) || '|' || '  O   /   O  ' || '|'
    AS VARCHAR(100))
  AS eyes
  
UNION ALL
  
SELECT
  CAST(
    REPLICATE(' ', 5) || '|' || '     /_      ' || '|'
    AS VARCHAR(100))
  AS nose
  
UNION ALL
SELECT
  CAST(
    REPLICATE(' ', 5) || '|' || '     ~~~~~   ' || '|'
    AS VARCHAR(100))
  AS mouth
  
UNION ALL
SELECT
  CAST(
    REPLICATE(' ', 5) || '|' || '   {  |  }   ' || '|'
    AS VARCHAR(100))
  AS chin;