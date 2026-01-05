# Stop Manually Dropping BigQuery Tables: Automate It!

A safe and flexible BigQuery stored procedure for automating table cleanup operations - perfect for Data Engineers who need to clean unnecessary tables from data warehouses.

## 📌 Overview

This stored procedure simplifies table management in BigQuery datasets by providing a reusable, safe, and flexible solution for cleaning up multiple tables at once. Whether you're clearing test data, removing deprecated tables, or performing routine maintenance, this tool eliminates the need for manual, time-consuming, and error-prone operations.

### Why BigQuery Instead of Python?

While Python is often the go-to solution, this BigQuery-based approach is designed for:
- **Non-technical users** who need to perform cleanup operations
- **Users without Python access** or programming experience
- **Quick operations** directly in the BigQuery console
- **Scenarios where** keeping everything in BigQuery is preferred

## ✨ Features

- ✅ **Selective or bulk operations** - Target specific tables or clean up an entire dataset
- ✅ **Multiple operation modes** - Choose between `TRUNCATE`, `DROP`, or `TRUNCATE_AND_DROP`
- ✅ **Built-in safety with dry-run mode** - Preview operations before execution
- ✅ **Clear feedback** - See exactly what operations were performed
- ✅ **Input validation** - Helpful error messages when something goes wrong

## 🚀 Quick Start

### Step 1: Create the Stored Procedure

Run the SQL script to create the procedure in your BigQuery project:

```bash
# Using the provided SQL file
bq query --use_legacy_sql=false < create_procedure_cleanup_tables.sql
```

Or copy the procedure code from `create_procedure_cleanup_tables.sql` and execute it in the BigQuery console, updating the path:

```sql
CREATE OR REPLACE PROCEDURE `your-project-id.your_dataset.cleanup_tables`(...)
```

### Step 2: Call the Procedure

Use the example call script provided:

```bash
# Using the provided SQL file
bq query --use_legacy_sql=false < call_procedure_cleanup_tables.sql
```

Or customize your own call as shown in the examples below.

## 📖 Parameters

The stored procedure accepts six parameters:

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `project_id` | STRING | Yes | Your GCP project ID (e.g., "your-project-id") |
| `dataset_id` | STRING | Yes | The BigQuery dataset name (e.g., "your_dataset") |
| `filter_specific_tables` | BOOL | Yes | `TRUE` to target specific tables, `FALSE` for all tables |
| `table_names` | ARRAY<STRING> | Yes | Array of table names (only used when `filter_specific_tables` is `TRUE`) |
| `operation` | STRING | Yes | Operation type: `TRUNCATE`, `DROP`, or `TRUNCATE_AND_DROP` |
| `dry_run` | BOOL | Yes | `TRUE` to preview, `FALSE` to execute |

## 🎯 Operation Modes

### TRUNCATE
**What it does:** Removes all rows while preserving table structure and schema.

**When to use:** Perfect for clearing test data or resetting tables while keeping the table definition intact.

### DROP
**What it does:** Completely removes the table including data and schema.

**When to use:** Permanently remove deprecated or temporary tables that are no longer needed.

### TRUNCATE_AND_DROP
**What it does:** First truncates, then drops the table.

**When to use:** More efficient for very large tables - truncating first can help with performance.

## 💡 Usage Examples

### Example 1: Dry Run - Preview Operations (Safe)

Always start with a dry run to see what would happen:

```sql
DECLARE project_id STRING DEFAULT "your-project-id";
DECLARE dataset_id STRING DEFAULT "your_dataset";
DECLARE filter_specific_tables BOOL DEFAULT TRUE;
DECLARE table_names ARRAY<STRING> DEFAULT ["temp_table1", "temp_table2"];
DECLARE operation STRING DEFAULT "TRUNCATE_AND_DROP";
DECLARE dry_run BOOL DEFAULT TRUE;  -- Preview mode

CALL `your-project-id.your_dataset.cleanup_tables`(
  project_id,
  dataset_id,
  filter_specific_tables,
  table_names,
  operation,
  dry_run
);
```

**Output:**
```
[DRY RUN] Would execute: TRUNCATE TABLE `your-project-id.your_dataset.temp_table1`
[DRY RUN] Would execute: DROP TABLE IF EXISTS `your-project-id.your_dataset.temp_table1`
[DRY RUN] Would execute: TRUNCATE TABLE `your-project-id.your_dataset.temp_table2`
[DRY RUN] Would execute: DROP TABLE IF EXISTS `your-project-id.your_dataset.temp_table2`
```

### Example 2: Truncate Specific Tables

```sql
DECLARE project_id STRING DEFAULT "your-project-id";
DECLARE dataset_id STRING DEFAULT "your_dataset";
DECLARE filter_specific_tables BOOL DEFAULT TRUE;
DECLARE table_names ARRAY<STRING> DEFAULT ["temp_table1", "temp_table2"];
DECLARE operation STRING DEFAULT "TRUNCATE";
DECLARE dry_run BOOL DEFAULT FALSE;  -- Execute mode

CALL `your-project-id.your_dataset.cleanup_tables`(
  project_id,
  dataset_id,
  filter_specific_tables,
  table_names,
  operation,
  dry_run
);
```

**Output:**
```
✓ Executed: TRUNCATE TABLE `your-project-id.your_dataset.temp_table1`
✓ Executed: TRUNCATE TABLE `your-project-id.your_dataset.temp_table2`
```

### Example 3: Drop All Tables in a Dataset

```sql
DECLARE project_id STRING DEFAULT "your-project-id";
DECLARE dataset_id STRING DEFAULT "test_dataset";
DECLARE filter_specific_tables BOOL DEFAULT FALSE;  -- Target ALL tables
DECLARE table_names ARRAY<STRING> DEFAULT [];  -- Empty array
DECLARE operation STRING DEFAULT "DROP";
DECLARE dry_run BOOL DEFAULT TRUE;  -- ALWAYS preview first!

CALL `your-project-id.your_dataset.cleanup_tables`(
  project_id,
  dataset_id,
  filter_specific_tables,
  table_names,
  operation,
  dry_run
);
```

### Example 4: Drop Only Specific Tables

```sql
DECLARE project_id STRING DEFAULT "your-project-id";
DECLARE dataset_id STRING DEFAULT "production_backup";
DECLARE filter_specific_tables BOOL DEFAULT TRUE;
DECLARE table_names ARRAY<STRING> DEFAULT ["temp_table1", "temp_table2"];
DECLARE operation STRING DEFAULT "DROP";
DECLARE dry_run BOOL DEFAULT FALSE;

CALL `your-project-id.your_dataset.cleanup_tables`(
  project_id,
  dataset_id,
  filter_specific_tables,
  table_names,
  operation,
  dry_run
);
```

**Output:**
```
✓ Executed: DROP TABLE `your-project-id.your_dataset.temp_table1`
✓ Executed: DROP TABLE `your-project-id.your_dataset.temp_table2`
```

## 🛡️ Best Practices

### Always Start with Dry Run

```sql
-- Step 1: Preview operations
DECLARE dry_run BOOL DEFAULT TRUE;
CALL `...cleanup_tables`(...);

-- Step 2: Review the output carefully

-- Step 3: Execute if everything looks correct
DECLARE dry_run BOOL DEFAULT FALSE;
CALL `...cleanup_tables`(...);
```

### Be Careful with filter_specific_tables = FALSE

When set to `FALSE`, the procedure targets ALL tables in the dataset. Always use dry run first:

```sql
-- DANGER: This will drop ALL tables in the dataset!
DECLARE filter_specific_tables BOOL DEFAULT FALSE;
DECLARE dry_run BOOL DEFAULT TRUE;  -- PREVIEW FIRST!
```

### Verify Table Names

Ensure table names in the array match exactly (case-sensitive):

```sql
-- Correct
DECLARE table_names ARRAY<STRING> DEFAULT ["MyTable", "my_other_table"];

-- Incorrect - will not match if case is wrong
DECLARE table_names ARRAY<STRING> DEFAULT ["mytable", "My_Other_Table"];
```

## ⚠️ Safety Warnings

**IMPORTANT:**
- `TRUNCATE` and `DROP` operations are **irreversible**
- Always use `dry_run = TRUE` first
- Consider backing up important data before running
- Be extra cautious with `filter_specific_tables = FALSE` (affects all tables)
- Test on non-production datasets first

## ❌ Error Handling

### No Tables Found

If no tables match your criteria:

```
No tables found matching the criteria. Check that:
- Tables exist in dataset: your_dataset
- filter_specific_tables = true
- table_names = bookmarks, watchlist
```

**Common causes:**
- Table names spelled incorrectly
- Tables don't exist in the specified dataset
- Case sensitivity mismatch

### Invalid Operation

```sql
DECLARE operation STRING DEFAULT "DELETE";  -- Invalid!
```

**Error:**
```
Invalid operation: DELETE. Valid options are: TRUNCATE, DROP, TRUNCATE_AND_DROP
```

## 🔐 Required Permissions

To use this procedure, you need:
- **BigQuery Data Editor** role (or higher) on the dataset
- `bigquery.tables.delete` permission for DROP operations
- `bigquery.tables.update` permission for TRUNCATE operations

## 📚 Resources

- [BigQuery Stored Procedures Documentation](https://cloud.google.com/bigquery/docs/procedures)
- [BigQuery DDL Statements](https://cloud.google.com/bigquery/docs/reference/standard-sql/data-definition-language)

## 👤 Author

**Serhii Hinkul**

- [LinkedIn](https://www.linkedin.com/in/ginkulsergei/)
- [GitHub](https://github.com/ginkulsergei)

## 💬 Feedback

Feel free to share any remarks or suggestions. I'd love to hear your feedback!

## 📄 Files in This Repository

- `create_procedure_cleanup_tables.sql` - SQL script to create the stored procedure
- `call_procedure_cleanup_tables.sql` - Example script to call the procedure
- `README.md` - This documentation

## 📝 License

This project is open source and available for use by anyone with BigQuery access.

---

**Made with ❤️ for Data Engineers who value automation and safety**
