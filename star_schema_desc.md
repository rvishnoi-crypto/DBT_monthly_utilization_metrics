#  Star Schema Description

This document outlines the star schema implemented to support the Monthly Utilization Rate metric and broader analytical use cases. 

---

##  Schema Overview

### 1. `member_dim`

Tracks member-level attributes with historical changes using SCD Type 2 logic.

| Column Name         | Data Type   | Description                                                                 |
|---------------------|-------------|-----------------------------------------------------------------------------|
| member_id           | INTEGER     | Primary key                                                                 |
| name                | VARCHAR     | Member's full name                                                          |
| email               | VARCHAR     | Member's email address                                                      |
| date_of_birth       | DATE        | Member's date of birth                                                      |
| province            | VARCHAR     | Province of residence                                                       |
| organization_id     | INTEGER     | org id                                                                      |
| eligible_programs   | VARCHAR[]   | List of programs the member is eligible for                                 |
| dbt_valid_from      | TIMESTAMP   | Start timestamp for SCD2 record (first appearance in raw data)              |
| dbt_valid_to        | TIMESTAMP   | End timestamp for SCD2 record (e.g., province change or subscription end)   |
| dbt_is_current      | BOOLEAN     | Indicates whether the record is the current version                         |
| created_at          | DATE        | Date the member was originally created                                      |

---

### 2. `organization_dim`

Captures organization-level attributes and tracks program changes over time.

| Column Name         | Data Type   | Description                                                                 |
|---------------------|-------------|-----------------------------------------------------------------------------|
| organization_id     | INTEGER     | Primary key                                                                 |
| organization_name   | VARCHAR     | Name of the organization                                                    |
| programs            | VARCHAR[]   | List of programs offered by the organization                                |
| dbt_valid_from      | TIMESTAMP   | Start timestamp for SCD2 record (first appearance in raw data)              |
| dbt_valid_to        | TIMESTAMP   | End timestamp for SCD2 record (e.g., program change or organization exit)   |
| dbt_is_current      | BOOLEAN     | Indicates whether the record is the current version                         |
| created_at          | DATE        | Date the organization was originally created in the eligibility system      |

---

### 3. `episode_fact`

Stores episode-level interactions between members and clinicians. Includes metadata for tracking episode lifecycle changes.

| Column Name             | Data Type   | Description                                                                 |
|-------------------------|-------------|-----------------------------------------------------------------------------|
| event_id                | VARCHAR     | Primary key                                                                 |
| episode_id              | INTEGER     | Unique identifier for the episode                                           |
| member_id               | INTEGER     | Foreign key referencing `member_dim`                                        |
| episode_created_at      | TIMESTAMP   | Timestamp when the episode was initiated                                    |
| issue_type              | VARCHAR     | Type of health issue addressed                                              |
| triage_recommendation   | VARCHAR     | Recommended care path or clinician                                          |
| status                  | VARCHAR     | Episode status (`pending`, `resolved`, etc.)                                |
| organization_id         | INTEGER     | Foreign key referencing `organization_dim`                                  |
| dbt_valid_from          | TIMESTAMP   | Start timestamp for episode status                                          |
| dbt_valid_to            | TIMESTAMP   | End timestamp for episode status (if applicable, or NULL if unresolved)     |
| dbt_is_current          | BOOLEAN     | Indicates whether the episode status is current                             |

### 4. `provincial_util_rate`

Delivers the Monthly Utilization Rate aggregated by province. 

| Column Name               | Data Type   | Description                                                                 |
|---------------------------|-------------|-----------------------------------------------------------------------------|
| calendar_month            | STRING      | Calendar month in `YYYY-MM` format                                          |
| province                  | VARCHAR     | Province of residence at time of episode                                   |
| count_of_eligible_members | INTEGER     | Number of members enrolled on the last day of the month                    |
| count_of_episodes_created | INTEGER     | Number of episodes created during the month                                |
| utilization_rate          | FLOAT       | Monthly utilization rate (episodes ÷ eligible members)                     |

### 5. `org_util_rate`

Delivers the Monthly Utilization Rate aggregated by organization.

| Column Name               | Data Type   | Description                                                                 |
|---------------------------|-------------|-----------------------------------------------------------------------------|
| calendar_month            | DATE        | Calendar month of episode creation (truncated to month)                    |
| organization_id           | INTEGER     | Unique identifier for the organization                                     |
| organization_name         | VARCHAR     | Name of the organization                                                   |
| count_of_eligible_members | INTEGER     | Number of members enrolled on the last day of the month                    |
| count_of_episodes_created | INTEGER     | Number of episodes created during the month                                |
| utilization_rate          | FLOAT       | Monthly utilization rate (episodes ÷ eligible members)                     |


Note: `dbt_valid_to` can be NULL 

Here are some cases to pay attention to : 

- For members, if member changes province, his record for previous province will have an `dbt_valid_to` = When he is new province and the record for the new province will have `dbt_valid_to` = NULL
- For members, if member is not in the latest batch, meaning he/she has unsubscribed, then the previous record will have a valid `dbt_valid_to` date. 
- For organizations, if org changes programs, their record for previous program will have an `dbt_valid_to` = When they have new program and the record for the new programs will have `dbt_valid_to` = NULL
- For organizations, if they are not in the latest batch, meaning they has unsubscribed or ineligble, then the previous record will have a valid `dbt_valid_to` date. 
- For events, if for an episode_id and member_id, the status has changed the record with the pending status will be closed and have a valid `dbt_valid_to` date. 
---

## SCD Type 2 Tracking

All dimension tables are implemented with SCD Type 2 logic to preserve historical changes. This enables:

- Accurate point-in-time joins between facts and dimensions
- Tracking member province changes over time
- Monitoring organization program evolution
- Analyzing episode lifecycle durations

---

##  Analytical Use Cases

This schema supports a wide range of business questions beyond the Monthly Utilization Rate:

###  Historical Attribution
- How did member province distributions shift over time?
- What was the organization-program mapping at the time of each episode?

###  Episode Lifecycle Analysis
- What is the average time an episode remains in `pending` status?
- How does resolution time vary by `issue_type` or `triage_recommendation`?

###  Member Behavior Insights
- How frequently do members change provinces during an episode?
- Is there a correlation between province changes and episode outcomes?

###  Operational & Strategic Impact
- Could province-level member movement impact healthcare costs or billing?
- Are certain programs more effective in resolving specific issue types?

---

