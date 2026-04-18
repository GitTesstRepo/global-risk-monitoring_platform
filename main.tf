terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.28.0"
    }
  }
}

provider "google" {
  credentials = "./gcs.json"
  project     = "terra-77564"
  region      = "us-central1"
}

resource "google_storage_bucket" "data-lake" {
  name          = "terra-77564-data-lake"
  location      = "US"
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
