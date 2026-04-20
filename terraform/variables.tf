variable "credentials" {
  description = "My Credentials"
  default     = "./gcp.json"
  #ex: if you have a directory where this file is called keys with your service account json file
  #saved there as my-creds.json you could use default = "./keys/my-creds.json"
}

variable "project" {
  description = "Project"
  default     = "replace-with-your-project-name"
}

variable "region" {
  description = "Project Region"
  #Update the below to your desired region
  default = "europe-central2"
}

variable "location" {
  description = "Project Location"
  #Update the below to your desired location
  default = "EU"
}

variable "bq_dataset_name" {
  description = "My BigQuery Daataset Name"
  #Update the below to what you want your dataset to be called
  default = "replace-with-your-dataset"
}

variable "gcs_bucket_name" {
  description = "My Storage Bucket Name"
  #Update the below to a unique bucket name
  default = "replace-with-your-bucket-name"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default     = "STANDARD"
}

variable "bq_external_table_name" {
  description = "External Table Name"
  default     = "external_gdelt_events_csv"
}

variable "bq_raw_table_name" {
  description = "Raw Table Name"
  default     = "raw_gdelt_events_partitioned"
}
