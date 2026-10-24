# DW2026 - Year-long Data Warehouse Project

## My role

**Thapelo Fortuin - Individual project author.**

I completed this entire year-long data warehousing project individually, covering
database design, SQL scripts, SSIS pipelines, the SSAS cube, Excel reports, and
documentation. The source data and academic materials are part of the supplied
coursework; their inclusion does not imply that I authored the source datasets
or the provided templates.

## Architecture

Source CSV files -> Stage 1 -> Stage 2 -> AtomicDW -> SSAS cube -> Excel reports

- **SQL Server:** staging and atomic warehouse schemas, import-batch metadata,
  dimensions, and an invoice fact table.
- **SSIS:** initial and incremental loading packages, transformations, error
  handling, and connection managers.
- **SSAS:** an Atomic DW cube with Customer, Date, Employee, Package Type, and
  Stock Item dimensions.
- **Excel:** prepared reports and the project design workbook.

## Repository layout

| Folder | Contents |
| --- | --- |
| `SQLScripts/` | Stage 1, Stage 2, and AtomicDW object creation and metadata queries |
| `SSISSolution/` | SSIS integration project, packages, parameters, and connections |
| `SSASSolution/` | SSAS project, cube, data source view, and dimensions |
| `SourceFiles/` | Supplied source datasets organised by import period |
| `ErrorFiles/` | Captured and corrected import records from the project |
| `Documentation/` | Design workbook, datatype mapping, and expression notes |
| `PreparedReports/` | Excel reporting workbook |

## Run in your own environment

1. Install compatible SQL Server, SSIS/SSAS, Visual Studio data tools, and Excel.
2. Review the SQL scripts before executing them: creation scripts drop and
   recreate project objects. Use dedicated development databases.
3. Update connection managers and data sources for your SQL Server instance.
4. Review `Project.params` and replace the original `C:\DW2026\` paths with your
   local project directories. Create local backup and output directories as needed.
5. Create the staging/warehouse objects, run the required SSIS loading packages,
   then deploy/process the cube and reconnect the Excel reports.

The original local instance references and Windows-integrated connections are
retained as project configuration; they must be changed on another machine.
Generated builds, IDE state, deployment outputs, and backups are excluded.

## Verification

Repository packaging and source structure were checked during publication.
SQL/SSIS/SSAS execution has not been rerun as part of this import. No benchmark
results or test-pass claims are inferred from the presence of packages or reports.
