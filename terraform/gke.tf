resource "google_container_cluster" "autopilot" {
  name     = "genai-autopilot-cluster"
  location = "us-central1"
  network  = google_compute_network.gke_vpc.id
  subnetwork = google_compute_subnetwork.gke_subnet.id

  enable_autopilot = true
  private_cluster_config {
    enable_private_nodes = true
    enable_private_endpoint = false
    master_ipv4_cidr_block = "172.19.0.0/28"  # Changed to avoid conflict
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges"
    services_secondary_range_name = "services-range"
  }

  release_channel {
    channel = "REGULAR"
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block = "0.0.0.0/0"
      display_name = "All networks"
    }
  }

  datapath_provider = "ADVANCED_DATAPATH"
}
