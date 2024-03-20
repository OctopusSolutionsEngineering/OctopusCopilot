resource "octopusdeploy_static_worker_pool" "workerpool_docker" {
  name        = "Docker"
  description = "Workers running Docker containers"
  is_default  = false
  sort_order  = 3
}
