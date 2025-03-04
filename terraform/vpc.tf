resource "google_compute_network" "gke_vpc" {
  name                    = "gke-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "172.16.0.0/20"
  network       = google_compute_network.gke_vpc.id
  region        = "us-central1"

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "172.17.0.0/20"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "172.18.0.0/16"
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling       = 0.1
    metadata           = "EXCLUDE_ALL_METADATA"
  }
}

# Cloud Router for NAT gateway
resource "google_compute_router" "router" {
  name    = "gke-router"
  network = google_compute_network.gke_vpc.id
  region  = "us-central1"
}

# NAT gateway
resource "google_compute_router_nat" "nat" {
  name                               = "gke-nat"
  router                            = google_compute_router.router.name
  region                            = google_compute_router.router.region
  nat_ip_allocate_option            = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
