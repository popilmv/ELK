provider "google" {
  credentials = file("key.json")
  project     = "high-territory-403908"
  region      = "us-central1"
}

resource "google_container_cluster" "my_cluster" {
  name     = "my-cluster"
  location = "us-central1-a"
  deletion_protection=false

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 100  
    image_type   = "COS_CONTAINERD"
    spot         = true
  }

  initial_node_count = 1
}

resource "google_container_node_pool" "infra_pool" {
  name       = "infra-pool"
  cluster    = google_container_cluster.my_cluster.name
  location   = google_container_cluster.my_cluster.location

  node_config {
    machine_type = "e2-small"
    disk_size_gb = 40
    image_type   = "COS_CONTAINERD"
  }

  initial_node_count = 1
}

resource "google_container_node_pool" "app_pool" {
  name       = "app-pool"
  cluster    = google_container_cluster.my_cluster.name
  location   = google_container_cluster.my_cluster.location

  node_config {
    machine_type = "e2-small"
    disk_size_gb = 40
    image_type   = "COS_CONTAINERD"
  }

  initial_node_count = 1
}
