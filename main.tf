terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.43.1"
    }
  }
}

provider "google" {
  credentials = file("sa.key")
  project     = "tform-test-367510"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  name         = "devbox"
  machine_type = "e2-standard-8"
  tags         = ["ssh-access"]

  advanced_machine_features {
    enable_nested_virtualization = true

  }

  scheduling {
    preemptible                 = true
    automatic_restart           = false
    provisioning_model          = "SPOT"
    instance_termination_action = "STOP"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}


resource "google_compute_firewall" "rules" {
  name        = "allowssh"
  network     = google_compute_network.vpc_network.name
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh-access"]
  source_ranges = ["0.0.0.0/0"]
}



