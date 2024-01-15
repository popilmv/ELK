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
resource "helm_release" "elasticsearch" {
  name       = "elasticsearch"
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  version    = "8.5.1"

  set {
    name  = "clusterName"
    value = "my-cluster"
  }
}
  set {
  name  = "volumeClaimTemplate.resources.requests.storage"
  value = "5Gi"
}

resource "kubernetes_storage_class" "elasticsearch_ssd" {
  metadata {
    name = "elasticsearch-ssd"
  }
  storage_provisioner = "kubernetes.io/gce-pd"
  reclaim_policy      = "Retain"
  parameters = {
    type = "pd-ssd"
  }
  allow_volume_expansion = true
}

resource "helm_release" "kibana" {
  name       = "kibana"
  repository = "https://helm.elastic.co"
  chart      = "kibana"
  version    = "8.5.1"

  set {
    name  = "elasticsearch.hosts"
    value = "http://exampledomain27.pp.ua:9200"  
  }
}

