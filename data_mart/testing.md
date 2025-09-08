# Testing 

We can add quality controls, and run them in our dag as a process. This would help us do simple data checks to make sure the data is accurate and not very weird. Also
very helpful in Root Cause Analysis as they becoming a starting point, rather than us having to track the entire lineage. 

In production, these tests would run after the staging models are run (this can be added as a task in our Airflow dag). But since we dont have incoming data, I have created a small example for testing processed_members (used to build hist_members)

