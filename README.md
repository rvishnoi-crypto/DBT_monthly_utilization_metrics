# Analytics Engineering Code Challenge

Thank you for your interest in Dialogue Engineering! This code challenge is an opportunity for you to show us what you can do, and will be used as a jumping-off point for later interviews.

## Challenge

You are given a few raw datasets in a simulated data warehouse. The data includes information about client organizations, members, and episodes of care.

Your challenge is to model the Monthly Utilization Rate metric--defined below--by extracting, cleaning, and transforming the data in the simulated data mart. Your goal is to demonstrate not only the correct metric, but also a well-structured data model following a dimensional modelling (aka "star schema") structure that is performant, extensible, and documented.

#### About the data

The raw data reflects a simplified version of the data that Dialogue uses to run its business. You will see:

- **Organizations**, which are Dialogue customers. Organizations subscribe to one or more programs that are provided to their members.
- **Members**, which are the people who use Dialogue's services. Members can enrol with an organization and thus access the programs that their organization is subscribed to.
- **Episodes** of care, which are the interactions that members have with Dialogue concerning a specific health issue.

Episodes proceed through a series of stages. The member may abandon the episode at any time.

- **Triage**. The member interacts with a chatbot or a human coordinator to determine which clinician is best suited to help. This stage extends from the moment the episode is first created until the moment a triage recommendation is set.
- **Care**. The member meets with a clinician who addresses their issue. This stage extends from the moment the episode exits triage to the moment the episode resolved.
- **Resolved**. An episode is said to be "resolved" when it's status is changed from `pending` to `resolved` by the clinician.

A field-wise data dictionary for the raw data is available in the `data_mart/models/schema.yml` file with more details.

#### Monthly Utilization Rate definition and requirements

The Monthly Utilization Rate is defined as the number of episodes created in each calendar month divided by the number of members enrolled on the last day of the calendar month.

The metric must be aggregated by the member's province of residence and, separately, by the name of the organization to which the member was enrolled _at the time the episode was created_. This should be stable over time. For example, when a member's province of residence changes, episodes started before the change should be allocated to the original province; those created after the change should be allocated to the new province.

Please use the data model that you've designed to deliver this metric in the form of two aggregate relations:
- **`utilization_rate_by_province`**, with at least the fields `calendar_month`, `province`, `count_of_eligible_members`, `count_of_episodes_created`, `utilization_rate`.
- **`utilization_rate_by_organization`** model, with at least the fields `calendar_month`, `organization_name`, `count_of_eligible_members`, `count_of_episodes_created`, `utilization_rate`.

#### What tools can you use?

You are given a vanilla dbt project as part of the challenge, as this is the tool we use at Dialogue. If you know dbt please use it; otherwise you are welcome to replace the dbt project with whatever tools, languages, libraries, or other resourses you're most comfortable with! The only requirement is that the whole solution can be submitted to the git repository and we can run it ourselves after you submit.

We are more interested in how you apply strong data modelling best-practices in a production data warehouse than what tools you use to implement them.

## What to submit

The submission should include:

- The code implementing the metric and your data transformation & modelling logic, including any code, models, tests, and documentation.
- Instructions on how to run your code, including any dependencies that need to be installed.

Note that it is not necessary to include updated data files -- we will remove the transformed data and re-run your transformation against the original raw data in order to do the evaluation.

## Evaluation

We expect to be able to do the following according to the instructions you provide in your submission README:

1. Run your transformations and modelling code against the original raw data.
2. Inspect the resulting data mart in duckdb.
3. Run any tests that you have implemented.
4. View any documentation you have written.

As long as it's clear in the README how to do these things, you're welcome to make changes to the structure of the project or the tools used.

We're looking for your data modelling to be:
- **correct** in that the metric meets the requirements above;
- **performant-enough** to be run on a regular basis. For the purposes of this challenge, assume that 
    - the transformation will be run once every night, incorporating the previous day's new data, and
    - the data set will be up to 10x larger than you see in the simulated data warehouse;
- **well-documented**, including a data dictionary and any other relevant documentation that would help an analyst understand the data and how to use it;
- **extensible** such that new data sources and attributes can be added to the mart in the future without breaking existing reports;


## Inspecting the raw data

The raw data is stored in a [duckDB](https://duckdb.org/) database which simulates a data warehouse. You can inspect it directly with commands like the following:

```bash
poetry run duckdb data_warehouse.duckdb

v1.1.3 19864453f7
Enter ".help" for usage hints.

D select schema_name, table_name, sql from duckdb_tables;

D select * from raw.members;
```

## Using dbt (optional)

If you choose to use dbt for your solution, we've provided a vanilla project to help get you started quicker.

#### Prerequisites

- A Python 3.10 environment. This challenge should work on higher versions, but hasn't been tested.
- [Poetry](https://python-poetry.org/docs/#installing-with-the-official-installer) for dependency management.

#### Quick start

Install the dependencies and run the empty dbt project:

```bash
poetry install
cd data_mart
poetry run dbt run
poetry run dbt test
```

If you are new to dbt but you still wish to use it for this challenge, start here:

- [What is dbt?](https://docs.getdbt.com/docs/introduction)
- [About dbt Projects](https://docs.getdbt.com/docs/build/projects)

The vanilla project comes with a couple of example models and tests. You can safely remove them and replace them with your solution.

#### Read the raw data documentation

The raw data's dictionary is available in the `data_mart/models/schema.yml` file. You can either read it there, or review it in the form of generated dbt documentation by running both of the following commands:

```bash
poetry run dbt docs generate
poetry run dbt docs serve
```
