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
