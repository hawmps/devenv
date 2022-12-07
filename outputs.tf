output "devenvip" {
  description = "IP address of created instance"
  value       = resource.google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}
