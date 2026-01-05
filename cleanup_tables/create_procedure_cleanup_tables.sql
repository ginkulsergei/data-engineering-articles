CREATE OR REPLACE PROCEDURE `your-project-id.your_dataset.cleanup_tables`(
  IN project_id STRING,
  IN dataset_id STRING,
  IN filter_specific_tables BOOL,
  IN table_names ARRAY<STRING>,
  IN operation STRING,  -- Options: 'TRUNCATE', 'DROP', 'TRUNCATE_AND_DROP'
  IN dry_run BOOL  -- TRUE: only print queries, FALSE: execute queries
)
BEGIN
  DECLARE full_dataset STRING;
  DECLARE filter_clause STRING;
  DECLARE queries ARRAY<STRUCT<truncate_query STRING, drop_query STRING>>;
  DECLARE executed_messages ARRAY<STRING> DEFAULT [];

  -- Validate operation parameter
  IF operation NOT IN ('TRUNCATE', 'DROP', 'TRUNCATE_AND_DROP') THEN
    SELECT ERROR(CONCAT('Invalid operation: ', operation, '. Valid options are: TRUNCATE, DROP, TRUNCATE_AND_DROP'));
  END IF;

  -- Build the full path to the __TABLES__ metadata view
  SET full_dataset = CONCAT("`", project_id, ".", dataset_id, ".__TABLES__`");

  -- Build the filter clause based on the boolean flag
  SET filter_clause = CASE 
    WHEN filter_specific_tables THEN 
      CONCAT(" AND table_id IN ('", ARRAY_TO_STRING(table_names, "', '"), "')")
    ELSE ""
  END;

  -- Get all queries into an array
  EXECUTE IMMEDIATE
    CONCAT(
      "WITH tables AS (SELECT * FROM ", 
      full_dataset, 
      ") SELECT ARRAY_AGG(STRUCT(",
      "  CONCAT('TRUNCATE TABLE `", project_id, ".", dataset_id, ".', table_id, '`') AS truncate_query, ",
      "  CONCAT('DROP TABLE IF EXISTS `", project_id, ".", dataset_id, ".', table_id, '`') AS drop_query",
      ")) FROM tables ",
      "WHERE dataset_id = '", dataset_id, "'",
      filter_clause
    ) INTO queries;

  -- Check if queries array is NULL or empty
  IF queries IS NULL OR ARRAY_LENGTH(queries) = 0 THEN
    SELECT 'No tables found matching the criteria. Check that:' AS warning,
           CONCAT('- Tables exist in dataset: ', dataset_id) AS check_1,
           CONCAT('- filter_specific_tables = ', CAST(filter_specific_tables AS STRING)) AS check_2,
           CONCAT('- table_names = ', ARRAY_TO_STRING(table_names, ', ')) AS check_3;
    RETURN;
  END IF;

  -- Execute or print queries based on dry_run flag
  IF dry_run THEN
    -- DRY RUN: Collect all messages and display in one result
    FOR record IN (SELECT * FROM UNNEST(queries))
    DO
      IF operation IN ('TRUNCATE', 'TRUNCATE_AND_DROP') THEN
        SET executed_messages = ARRAY_CONCAT(executed_messages, [CONCAT('[DRY RUN] Would execute: ', record.truncate_query)]);
      END IF;
      
      IF operation IN ('DROP', 'TRUNCATE_AND_DROP') THEN
        SET executed_messages = ARRAY_CONCAT(executed_messages, [CONCAT('[DRY RUN] Would execute: ', record.drop_query)]);
      END IF;
    END FOR;
    
    -- Display all queries
    SELECT 
      operation AS operation
    FROM UNNEST(executed_messages) AS operation;
  ELSE
    -- ACTUAL EXECUTION: Execute the queries and log what was done
    FOR record IN (SELECT * FROM UNNEST(queries))
    DO
      IF operation IN ('TRUNCATE', 'TRUNCATE_AND_DROP') THEN
        EXECUTE IMMEDIATE record.truncate_query;
        SET executed_messages = ARRAY_CONCAT(executed_messages, [CONCAT('✓ Executed: ', record.truncate_query)]);
      END IF;
      
      IF operation IN ('DROP', 'TRUNCATE_AND_DROP') THEN
        EXECUTE IMMEDIATE record.drop_query;
        SET executed_messages = ARRAY_CONCAT(executed_messages, [CONCAT('✓ Executed: ', record.drop_query)]);
      END IF;
    END FOR;
    
    -- Display what was executed
    SELECT 
      operation AS completed_operation
    FROM UNNEST(executed_messages) AS operation;
  END IF;
END;


