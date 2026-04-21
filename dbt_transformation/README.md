## dbt transformations (BigQuery)

This folder contains the dbt project that transforms the raw GDELT events (external table in BigQuery) into staging + marts models used for reporting (risk score, sentiment trend, emerging hotspots).

### Prerequisites

- **BigQuery dataset + tables** are provisioned by Terraform in [`terraform/`](../terraform/).
- **Python/dbt** installed locally (or run via any dbt-friendly environment).

### 1) Create a dbt profile (`profiles.yml`)

This repo does not commit credentials. Create a dbt profile on your machine:

- **Windows**: `%USERPROFILE%\\.dbt\\profiles.yml`
- **Linux/macOS**: `~/.dbt/profiles.yml`

Example for BigQuery (service account JSON key file):

```yaml
dbt_transformation:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: "<YOUR_GCP_PROJECT_ID>"
      dataset: "<YOUR_BQ_DATASET_NAME>"
      threads: 4
      keyfile: "C:/path/to/your/gcp.json"
      job_execution_timeout_seconds: 300
      job_retries: 1
      location: "EU"
```

Notes:
- `project` must match your GCP project.
- `dataset` must match the dataset created by Terraform (see [`/terraform/variables.tf`](../terraform/variables.tf)).
- Models reference the source table `external_gdelt_events_csv` in that dataset.

### 2) Run dbt

From /dbt_transformation directory:

```bash
dbt debug
dbt build
```

### How sources are configured

The source config uses dbt target values (no hardcoded project/dataset):

- `database: {{ target.project }}`
- `schema: {{ target.dataset }}`

The source table name must match the partitioned table created during the ingestion step.

Make sure that:
- the ingestion step has been completed
- the table exists in BigQuery
- the dataset name matches the one defined in your `profiles.yml`

Otherwise, dbt models will fail due to missing sources.

See [`models/staging/sources.yml`](models/staging/sources.yml).
