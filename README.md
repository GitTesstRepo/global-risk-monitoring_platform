# Global Geopolitical Risk Monitor (GDELT-based)

## Problem Statement

This project builds an end-to-end batch data engineering pipeline that transforms raw global news event data from the GDELT dataset into a structured analytical system.

The goal is to enable monitoring and analysis of global geopolitical dynamics by providing insights into:

- geopolitical risk levels by country
- global sentiment trends over time
- emerging hotspots based on recent activity changes

Raw event data is highly noisy, unstructured, and too large for direct analysis. This pipeline solves this by ingesting, transforming, and modeling the data into an optimized analytical format suitable for dashboards and decision-making.

---

## Cloud Infrastructure

The project is built on Google Cloud Platform (GCP) with Infrastructure as Code (IaC) using Terraform.

All core data infrastructure is deployed in the cloud:

- Google Cloud Storage (data lake for raw data)
- BigQuery (data warehouse with partitioned and clustered tables)

Terraform is used to provision and manage all cloud resources in a reproducible way.

### Local vs Cloud Execution

While all data storage and processing layers are implemented in the cloud, the orchestration and transformation layers are executed locally for development convenience:

- Kestra is run locally via Docker Compose
- dbt is executed locally and connects directly to BigQuery

This setup ensures a cost-efficient development workflow while maintaining a fully cloud-based data architecture.

### Provisioned resources:

- Google Cloud Storage (data lake for raw GDELT files)
- BigQuery dataset (data warehouse)
- External and partitioned BigQuery tables

Terraform is used to ensure that all infrastructure can be fully recreated in a reproducible way.

---

## Data Ingestion (Batch Pipeline + Orchestration)

The pipeline is implemented as a batch workflow orchestrated using Kestra and runs on an hourly schedule.

### Pipeline flow:

1. Python script retrieves GDELT master file based on execution date
2. Relevant compressed event files are downloaded and extracted
3. Raw files are stored in Google Cloud Storage (data lake), partitioned by date (YYYYMMDD)
4. BigQuery external table reads data directly from GCS (external table provisioned by Terraform)
5. Data is loaded into partitioned and clustered BigQuery tables for downstream processing

This setup ensures a fully automated and reproducible end-to-end batch ingestion pipeline.

---

## Data Warehouse Design

The data warehouse is implemented in BigQuery and optimized for analytical workloads.

### Key design choices:

- Partitioning by event date to reduce query scan cost
- Clustering by country for faster filtering
- Separation into staging and mart layers

This structure is optimized for the primary query patterns used in the dashboard, such as time-series analysis and country-level aggregation.

---

## Data Transformations (dbt)

All transformations are implemented using dbt to ensure modularity and reproducibility.

### Data model structure:

- staging layer:
  - data cleaning
  - type casting
  - normalization of raw GDELT fields

- mart layer:
  - aggregated metrics for dashboard
  - sentiment calculations
  - risk scoring per country
  - growth rate computation for emerging hotspots

dbt ensures versioned, testable, and maintainable transformations across the pipeline.

---

## Dashboard (Looker Studio)

The final analytical layer of the project is implemented in Looker Studio and is publicly accessible:

- Dashboard: `https://datastudio.google.com/reporting/05eb33e6-53bd-4c5e-b039-9c73c2012026`

The dashboard provides an interactive interface for exploring geopolitical risk patterns derived from the GDELT dataset and consists of three analytical views:

### 1. Global Risk Index by Country
A categorical view of geopolitical risk distribution across countries based on aggregated event activity and sentiment.

### 2. Global Sentiment Trend (7d Rolling Avg)
A time-series visualization showing the evolution of global sentiment over time with smoothing applied to reduce noise.

### 3. Emerging Geopolitical Hotspots (7d Growth vs Previous 7d)
A comparative metric identifying countries with the highest increase in event activity relative to the previous time window.

The dashboard enables exploratory analysis of global geopolitical patterns through risk, trend, and change detection perspectives.

---

## Reproducibility

The entire project is fully reproducible and can be run from scratch.

## Environment Setup

The project is developed and tested using Python 3.13.
Python 3.14 was intentionally not used due to compatibility issues with dbt and related dependencies (dbt-bigquery, dbt-core adapters).  This issue is documented in the official dbt repository discussion:
`https://github.com/dbt-labs/dbt-core/issues/12098`
Using Python 3.13 ensures stable dependency resolution and reproducible environment setup across all pipeline components.

## Repository layout

- `dbt_transformation/`: dbt project (BigQuery staging + marts).
- `kestra_flows/`: Kestra flows. The GDELT ingestion flow is `gdelt_ingestion.yaml`.
- `terraform/`: GCP resources (GCS + BigQuery).
- `docker-compose.yaml`: operates Kestra locally.
- `load_data.py`: ingestion script (GDELT masterfile → download exports → upload to GCS).
- `requirements.txt`: A file that lists the Python dependencies required to run the ingestion and transformation scripts.

## Quickstart (Windows / PowerShell)

### 1) Clone the repository

   ```bash
   git clone https://github.com/GitTesstRepo/global-risk-monitoring_platform
   cd global-risk-monitoring_platform
   ```

### 2) Create GCP service JSON key

1. Create a service account in Google Cloud Console.
   - You can assign it the **Owner** role, but if you prefer to be more specific, the service account will need permissions for **Google Cloud Storage** and **BigQuery**.

2. Download the service account's **JSON key**.

3. Rename the JSON file to `gcp.json` and move it to the root directory of the project.

This key will be used for authentication when interacting with Google Cloud resources in your pipeline.

### 3) Provision cloud resources (Terraform)

Run Terraform from `terraform/` directory:

1. **Configure Terraform variables**:
   - Open the file `terraform/variables.tf`.
   - Fill in the necessary values for the variables (e.g., GCP project ID, bucket name, etc.).

2. **Run Terraform**:

   From the `terraform/` directory, run the following commands to provision the resources:

   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

terraform init: Initializes the Terraform working directory and downloads required provider plugins.
terraform plan: Generates an execution plan, showing which resources will be created or modified.
terraform apply: Applies the execution plan and provisions the resources on Google Cloud.

This will create the necessary infrastructure, including Google Cloud Storage (data lake) and BigQuery (data warehouse) resources.

### 3) Start Kestra locally

From repo root:

```bash
docker compose up -d
```

1. Open Kestra UI at: `http://localhost:8080`
2. Import all flows:
- Navigate to Flows section in the Kestra UI.
- Click Import and select all the YAML files from the kestra_flows directory to import them into Kestra.
3. Run flows:
- After importing, select the flows from the list and trigger them manually or let them run as per their scheduled configurations.

This will ensure that all ingestion and orchestration tasks are ready for execution in Kestra.

### 4) Run dbt transformations

Follow [`dbt_transformation/README.md`](dbt_transformation/README.md) to create your `profiles.yml`, then run:

```bash
cd dbt_transformation
dbt run
dbt test
```

## Running ingestion locally (without Kestra)

1. Create a virtual environment (recommended for dependency isolation):

```bash
python -m venv .venv
```

2. Activate the virtual environment:

3. Install dependencies:

```bash
python -m pip install -r requirements.txt
```

4. Run the ingestion process:

```bash
python load_data.py --date 20260401
```

This ensures that the environment is isolated, preventing conflicts with other Python packages and ensuring consistent dependency management across different setups.

## End-to-end Steps (high level)

1. Clone repository
2. Configure GCP credentials (service account JSON)
3. Deploy infrastructure using Terraform
4. Start orchestration layer (Kestra via Docker Compose)
5. Run batch ingestion pipeline
6. Execute dbt transformations
7. Launch Looker Studio dashboard

All components are containerized or script-based, ensuring consistent execution across environments.

---

## Technologies Used

- Google Cloud Platform (GCS, BigQuery)
- Terraform (Infrastructure as Code)
- Kestra (Workflow orchestration)
- Docker / Docker Compose
- dbt (Data transformations)
- Python (data ingestion)
- SQL (data modeling)
- Looker Studio (dashboarding)

---

## Architecture Overview

The project implements a modular batch data platform on Google Cloud:

            ┌──────────────────────┐
            │        GDELT         │
            │ (Global Event Feed)  │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │        Kestra        │
            │(Batch Orchestration) │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Google Cloud Storage │
            │ (Data Lake - Raw)    │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ BigQuery Warehouse   │
            │ - External Tables    │
            │ - Partitioned Tables │
            │ - Clustered Tables   │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ dbt Transformations  │
            │ staging → marts      │
            │ metrics layer        │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │ Looker Studio        │
            │ Analytical Dashboard │
            └──────────────────────┘

This modular architecture ensures that the pipeline is flexible, scalable, and can handle the large volume of global news events efficiently, providing actionable insights into global geopolitical risk.
