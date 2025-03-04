terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = "gen-ai-app-poc-efe5"
  region  = "us-central1"
}
