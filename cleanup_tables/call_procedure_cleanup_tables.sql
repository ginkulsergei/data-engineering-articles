---------------------------------------------- Example calls to the PROCEDURE ----------------------------------------------

-- DRY RUN: Preview what would be executed (safe to run)
DECLARE project_id STRING DEFAULT "your-project-id";
DECLARE dataset_id STRING DEFAULT "your_dataset";
DECLARE filter_specific_tables BOOL DEFAULT TRUE;
DECLARE table_names ARRAY<STRING> DEFAULT ["temp_table1", "temp_table2"];
DECLARE operation STRING DEFAULT "DROP";
DECLARE dry_run BOOL DEFAULT TRUE;  -- Safe preview mode

CALL `your-project-id.your_dataset.cleanup_tables`(
  project_id,
  dataset_id,
  filter_specific_tables,
  table_names,
  operation,
  dry_run
);

-- ACTUAL EXECUTION: Execute the operations (WARNING: will delete data!)
/*
DECLARE project_id STRING DEFAULT "your-project-id";
DECLARE dataset_id STRING DEFAULT "your_dataset";
DECLARE filter_specific_tables BOOL DEFAULT TRUE;
DECLARE table_names ARRAY<STRING> DEFAULT ["temp_table1", "temp_table2"];
DECLARE operation STRING DEFAULT "DROP";
DECLARE dry_run BOOL DEFAULT FALSE;  -- Set to FALSE to actually execute

CALL `your-project-id.your_dataset.cleanup_tables`(
  project_id,
  dataset_id,
  filter_specific_tables,
  table_names,
  operation,
  dry_run
);
*/