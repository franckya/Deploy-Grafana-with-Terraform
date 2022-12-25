# Configure the Azure Provider
provider "azurerm" {
  version = "=2.40.0"
  subscription_id = "your_subscription_id"
  tenant_id = "your_tenant_id"
  client_id = "your_client_id"
  client_secret = "your_client_secret"
}

# Create a resource group
resource "azurerm_resource_group" "grafana_prometheus" {
  name     = "grafana-prometheus-rg"
  location = "westus2"
}

# Create a virtual network
resource "azurerm_virtual_network" "grafana_prometheus" {
  name                = "grafana-prometheus-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.grafana_prometheus.location
  resource_group_name = azurerm_resource_group.grafana_prometheus.name
}

# Create a subnet
resource "azurerm_subnet" "grafana_prometheus" {
  name                 = "grafana-prometheus-subnet"
  resource_group_name  = azurerm_resource_group.grafana_prometheus.name
  virtual_network_name = azurerm_virtual_network.grafana_prometheus.name
  address_prefix       = "10.0.1.0/24"
}

# Create a public IP address
resource "azurerm_public_ip" "grafana" {
  name                = "grafana-public-ip"
  location            = azurerm_resource_group.grafana_prometheus.location
  resource_group_name = azurerm_resource_group.grafana_prometheus.name
  allocation_method   = "Dynamic"
}

# Create a network security group
resource "azurerm_network_security_group" "grafana" {
  name                = "grafana-nsg"
  location            = azurerm_resource_group.grafana_prometheus.location
  resource_group_name = azurerm_resource_group.grafana_prometheus.name

  security_rule {
    name                       = "allow_http"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a virtual machine for Grafana
resource "azurerm_virtual_machine" "grafana" {
  name                  = "grafana-vm"
  location              = azurerm_resource_group.grafana_prometheus.location
  resource_group_name   = azurerm_resource_group.grafana_prometheus.name
  network_interface_ids = [azurerm_network_interface
