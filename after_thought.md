#  Afterthoughts & Engineering Reflections

This document outlines technical considerations and potential improvements identified during and after the implementation of the Monthly Utilization Rate dbt project.

---

##  Optimization Opportunities

### 1. Staging Layer Efficiency
- Currently, staging models are materialized as **tables**, which increases storage usage unnecessarily.
- These models could be safely materialized as **views**, especially since they are lightweight transformations and used only as intermediate layers.

### 2. Fact & Dimension Rebuild Strategy
- The current pipeline **rebuilds fact and dimension tables in full** during each run.
- As data volume grows, this approach will become inefficient and costly.
- Implementing **incremental models** using dbt’s `is_incremental()` logic would allow us to process only new or changed records, improving performance.

### 3. Curated View Scope
- The curated views currently read the **entire `episode_fact` table**, calculating utilization rates across all historical months.
- For production use, we should consider **parameterizing the time window** (e.g., the year 2024) to reduce compute load and align with business reporting needs.