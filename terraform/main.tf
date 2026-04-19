terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.28.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}

resource "google_storage_bucket" "default" {
  name          = var.gcs_bucket_name
  location      = var.location
  storage_class = var.gcs_storage_class
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "default" {
  dataset_id = var.bq_dataset_name
  location   = var.location
}

resource "google_bigquery_table" "default" {
  dataset_id          = google_bigquery_dataset.default.dataset_id
  table_id            = var.bq_external_table_name
  deletion_protection = false

  # Define the schema as a JSON string
  schema = <<EOF
[
  {
    "name": "GLOBALEVENTID",
    "type": "INTEGER"
  },
  {
    "name": "SQLDATE",
    "type": "INTEGER"
  },
  {
    "name": "MonthYear",
    "type": "INTEGER"
  },
  {
    "name": "Year",
    "type": "INTEGER"
  },
  {
    "name": "FractionDate",
    "type": "FLOAT"
  },
  {
    "name": "Actor1Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Name",
    "type": "STRING"
  },
  {
    "name": "Actor1CountryCode",
    "type": "STRING"
  },
  {
    "name": "Actor1KnownGroupCode",
    "type": "STRING"
  },
  {
    "name": "Actor1EthnicCode",
    "type": "STRING"
  },
  {
    "name": "Actor1Religion1Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Religion2Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Type1Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Type2Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Type3Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Name",
    "type": "STRING"
  },
  {
    "name": "Actor2CountryCode",
    "type": "STRING"
  },
  {
    "name": "Actor2KnownGroupCode",
    "type": "STRING"
  },
  {
    "name": "Actor2EthnicCode",
    "type": "STRING"
  },
  {
    "name": "Actor2Religion1Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Religion2Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Type1Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Type2Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Type3Code",
    "type": "STRING"
  },
  {
    "name": "IsRootEvent",
    "type": "INTEGER"
  },
  {
    "name": "EventCode",
    "type": "STRING"
  },
  {
    "name": "EventBaseCode",
    "type": "STRING"
  },
  {
    "name": "EventRootCode",
    "type": "STRING"
  },
  {
    "name": "QuadClass",
    "type": "INTEGER"
  },
  {
    "name": "GoldsteinScale",
    "type": "FLOAT"
  },
  {
    "name": "NumMentions",
    "type": "INTEGER"
  },
  {
    "name": "NumSources",
    "type": "INTEGER"
  },
  {
    "name": "NumArticles",
    "type": "INTEGER"
  },
  {
    "name": "AvgTone",
    "type": "FLOAT"
  },
  {
    "name": "Actor1Geo_Type",
    "type": "INTEGER"
  },
  {
    "name": "Actor1Geo_FullName",
    "type": "STRING"
  },
  {
    "name": "Actor1Geo_CountryCode",
    "type": "STRING"
  },
  {
    "name": "Actor1Geo_ADM1Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Geo_ADM2Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Geo_Lat",
    "type": "FLOAT"
  },
  {
    "name": "Actor1Geo_Long",
    "type": "FLOAT"
  },
  {
    "name": "Actor1Geo_FeatureID",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_Type",
    "type": "INTEGER"
  },
  {
    "name": "Actor2Geo_FullName",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_CountryCode",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_ADM1Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_ADM2Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_Lat",
    "type": "FLOAT"
  },
  {
    "name": "Actor2Geo_Long",
    "type": "FLOAT"
  },
  {
    "name": "Actor2Geo_FeatureID",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_Type",
    "type": "INTEGER"
  },
  {
    "name": "ActionGeo_FullName",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_CountryCode",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_ADM1Code",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_ADM2Code",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_Lat",
    "type": "FLOAT"
  },
  {
    "name": "ActionGeo_Long",
    "type": "FLOAT"
  },
  {
    "name": "ActionGeo_FeatureID",
    "type": "STRING"
  },
  {
    "name": "DATEADDED",
    "type": "INTEGER"
  },
  {
    "name": "SOURCEURL",
    "type": "STRING"
  }
]
EOF

  external_data_configuration {
    autodetect    = true
    source_format = "CSV"

    source_uris = [
      "gs://${var.gcs_bucket_name}/2026*.export.CSV"
    ]

    csv_options {
      quote           = ""
      field_delimiter = "\t"
    }
  }
}

resource "google_bigquery_table" "raw" {
  dataset_id          = google_bigquery_dataset.default.dataset_id
  table_id            = var.bq_raw_table_name
  deletion_protection = false

  time_partitioning {
    type  = "DAY"
    field = "SQLDATE"
  }

  clustering = ["ActionGeo_CountryCode"]

  # Define the schema as a JSON string
  schema = <<EOF
[
  {
    "name": "GLOBALEVENTID",
    "type": "INTEGER"
  },
  {
    "name": "SQLDATE",
    "type": "DATE"
  },
  {
    "name": "MonthYear",
    "type": "INTEGER"
  },
  {
    "name": "Year",
    "type": "INTEGER"
  },
  {
    "name": "FractionDate",
    "type": "FLOAT"
  },
  {
    "name": "Actor1Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Name",
    "type": "STRING"
  },
  {
    "name": "Actor1CountryCode",
    "type": "STRING"
  },
  {
    "name": "Actor1KnownGroupCode",
    "type": "STRING"
  },
  {
    "name": "Actor1EthnicCode",
    "type": "STRING"
  },
  {
    "name": "Actor1Religion1Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Religion2Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Type1Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Type2Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Type3Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Name",
    "type": "STRING"
  },
  {
    "name": "Actor2CountryCode",
    "type": "STRING"
  },
  {
    "name": "Actor2KnownGroupCode",
    "type": "STRING"
  },
  {
    "name": "Actor2EthnicCode",
    "type": "STRING"
  },
  {
    "name": "Actor2Religion1Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Religion2Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Type1Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Type2Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Type3Code",
    "type": "STRING"
  },
  {
    "name": "IsRootEvent",
    "type": "INTEGER"
  },
  {
    "name": "EventCode",
    "type": "STRING"
  },
  {
    "name": "EventBaseCode",
    "type": "STRING"
  },
  {
    "name": "EventRootCode",
    "type": "STRING"
  },
  {
    "name": "QuadClass",
    "type": "INTEGER"
  },
  {
    "name": "GoldsteinScale",
    "type": "FLOAT"
  },
  {
    "name": "NumMentions",
    "type": "INTEGER"
  },
  {
    "name": "NumSources",
    "type": "INTEGER"
  },
  {
    "name": "NumArticles",
    "type": "INTEGER"
  },
  {
    "name": "AvgTone",
    "type": "FLOAT"
  },
  {
    "name": "Actor1Geo_Type",
    "type": "INTEGER"
  },
  {
    "name": "Actor1Geo_FullName",
    "type": "STRING"
  },
  {
    "name": "Actor1Geo_CountryCode",
    "type": "STRING"
  },
  {
    "name": "Actor1Geo_ADM1Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Geo_ADM2Code",
    "type": "STRING"
  },
  {
    "name": "Actor1Geo_Lat",
    "type": "FLOAT"
  },
  {
    "name": "Actor1Geo_Long",
    "type": "FLOAT"
  },
  {
    "name": "Actor1Geo_FeatureID",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_Type",
    "type": "INTEGER"
  },
  {
    "name": "Actor2Geo_FullName",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_CountryCode",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_ADM1Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_ADM2Code",
    "type": "STRING"
  },
  {
    "name": "Actor2Geo_Lat",
    "type": "FLOAT"
  },
  {
    "name": "Actor2Geo_Long",
    "type": "FLOAT"
  },
  {
    "name": "Actor2Geo_FeatureID",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_Type",
    "type": "INTEGER"
  },
  {
    "name": "ActionGeo_FullName",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_CountryCode",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_ADM1Code",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_ADM2Code",
    "type": "STRING"
  },
  {
    "name": "ActionGeo_Lat",
    "type": "FLOAT"
  },
  {
    "name": "ActionGeo_Long",
    "type": "FLOAT"
  },
  {
    "name": "ActionGeo_FeatureID",
    "type": "STRING"
  },
  {
    "name": "DATEADDED",
    "type": "INTEGER"
  },
  {
    "name": "SOURCEURL",
    "type": "STRING"
  }
]
EOF
}
