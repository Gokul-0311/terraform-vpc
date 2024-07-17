resource "google_compute_network" "vpc" {
    name = "myvpc"
    routing_mode = "REGIONAL"
    auto_create_subnetworks = "false"

    depends_on = [
        google_project_service.compute_api
    ]
}

resource "google_compute_subnetwork" "public_subnet" {
    name = "public subnet"
    region = "var.region"
    network = "google_compute_network.vpc.id"
    ip_cidr_range ="10.0.1.0/24"
    depends_on = [google_compute_network.vpc.id]
}
resource "google_compute_subnetwork" "private_subnet" {
    name = "private subnet"
    region = "var.region"
    network = "google_compute_network.vpc.id"
    ip_cidr_range ="10.0.2.0/24"
    private_ip_google_access = "true"
    depends_on = [google_compute_network.vpc.id]
}

resource "google_compute_router" "router" {
    name = "router"
    region = "var.region"
    network = "google_compute_network.vpc.id"
}

resource "google_compute_router_nat" "nat" {
    name = "nat"
    region = "var.region"
    router = "google_compute_router.router.name"
    nat_ip_allocate_option = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetwork {
        name = "google_compute_subnetwork.private_subnet.name"
        source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
}

resource "google_compute_firewall" "my_firewall" {
    name = "my_firewall"
    project = "var.project"
    network = "google_compute_network.vpc.id"

    allow {
        protocol = "tcp"
        ports = ["22", "80", "443"]
    }

    source_ranges = ["0.0.0.0/0"]
}