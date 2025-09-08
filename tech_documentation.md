# Technical Documentation – Monthly Utilization Rate

## Overview
This dbt project models the **Monthly Utilization Rate (MUR)** metric using raw data on members, organizations, and events. The metric is defined as:

> **Monthly Utilization Rate** = (Number of episodes created in a calendar month) ÷ (Number of members enrolled on the last day of the month)

The metric is aggregated by:
- **Province** of the member at the time of episode creation  
- **Organization** to which the member was enrolled at the time of episode creation  

The project is structured around a **star schema** model with dimension and fact tables, culminating in curated views to deliver the metric.

---

## Project Workflow

### Project Structure

data_mart/
├── models/
│   ├── initial_run/              # Raw data cleansing
│   ├── dimensions/               # Dimensional models
│   ├── facts/                    # Fact models
│   ├── curated/                  # Final metric views
│   └── staging/                  # Daily ingestion staging models
├── snapshots/                    # SCD Type 2 snapshots
├── star_schema_desc.md           # Star schema documentation
└── after_thought.md              # Engineering improvements & future ideas
└── testing.md

### 1. Initial/Historical Load
The initial load involves cleaning, transforming, and tracking historical data. Look into the folder `initial_run` within data_mart. 

#### a. Raw Data Processing
Raw tables include:
- `members`
- `organizations`
- `events`

Transformations are applied in the models located at `data_mart/models/initial_run`:
- Trim text columns  
- Sort array-like complex types  
- Standardize date columns  
- Parse text-based fields (e.g., province codes)  
- Flatten JSON columns  

Run these models with:
```
poetry run dbt run --select processed_members processed_organizations processed_events
```

#### b. Historical Tracking (SCD Type 2)

To track historical changes (e.g., province changes for members, program changes for organizations, status changes for events), we implemented SCD Type 2 models:

Historical tracking  is useful in the curated view we create in the end for analyis and key metric delivery. It lets the business retain the metrics when there are changes in member or organization such as province or programs.

- hist_members
- hist_organizations
- hist_events

Run these models by : 

```poetry run dbt run --select hist_members hist_organizations hist_events```


#### c. Snapshots

The hist models (with SCD 2 implemented) would form our basis for our empty snapshots - snap_members, snap_events, snap_organizations. Later when running as a daily job, these snapshots would be useful in keeping track of the changes in each of these tables.

Columns such as `dbt_valid_from`, `dbt_valid_to`, `dbt_is_current`, can help be precise when joining tables without losing information about the entities like members and organizations. 

Run the following command: 

```poetry run dbt snapshot --select snap_events snap_members snap_organizations```

#### d. Star Schema Modelling

The star schema consists of:

- Dimensions: member_dim, organization_dim

- Fact: episode_fact

Columns and types are documented in `star_schema_desc.md` (Describes design decisions and use cases).

These fact and dims were built using `snap_members`, `snap_organizations` and `snap_events`, which were the respective snapshots (These snapshots had all the information with SCD 2 tracking and would be used to rebuild the fact and dims)

Run the models with:

```
poetry run dbt run --select member_dim organization_dim episode_fact
```

#### e. Curated Views

Now we were at the stage where we can create our curated views to address the montly utilization rate. We have two views provincial_utili_rate and org_util_rate.
These views answer the business question on MUR. 

Run command:

``` poetry run dbt run --select provincial_util_rate org_util_rate ```

### 2. Daily Run

The second stage was to engineer the daily run, which would process latest data daily and rebuild our final data product (curated view for data analysis). For this we make use of the staging tables.

#### a. Staging Tables

The models include : `stg_events`, `stg_members`, `stg_organizations`
They process latest data. 

Run Command : 

```poetry run dbt run --select stg_events stg_members stg_organizations```

The process from here is the same. We run snapshot models (please change jinja template to use `stg` models instead of `hist` models), build the dims and fact using the snapshots and then finally the curated views using the fact and dims. 

The daily run process can be configured in Airflow and a customer date can be inputed for the final curated view (For instance currently, it gives MUR for all months throughout history, based on the business requirement, we can configure it.)

### Overview

Initial_load : Raw -> hist -> snapshot -> fact/dim -> curated
Daily        : Raw -> stg  -> snapshot -> fact/dim -> curated


After this please look at : 
- star_schema_desc.md (Dimensions and Fact)
- after_thought.md (Few reflections after implementations - iterations)
- testing.md

