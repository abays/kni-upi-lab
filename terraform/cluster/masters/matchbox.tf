resource "matchbox_profile" "master" {
  count = var.master_count
  name   = var.master_nodes[count.index]["name"]
  kernel = "${var.pxe_kernel}"

  initrd = [
    "${var.pxe_initrd}",
  ]

  args = flatten([
    "${var.pxe_kernel_args}",
    "coreos.inst.install_dev=${var.master_nodes[count.index]["install_dev"]}",
    "coreos.inst.ignition_url=${var.matchbox_http_endpoint}/ignition?mac=${var.master_nodes[count.index]["mac_address"]}",
    (lookup(var.master_nodes[count.index], "baremetal_interface", "") != "" || lookup(var.master_nodes[count.index], "provisioning_interface", "") != "" ? "ip=dhcp coreos.no_persist_ip=1" : " "),
  ])
  raw_ignition = "${var.ignition_config_content}"
}

resource "matchbox_group" "master" {
  count   = var.master_count
  name    = var.master_nodes[count.index]["name"]
  profile = "${matchbox_profile.master[count.index]["name"]}"

  selector = {
    mac = "${var.master_nodes[count.index]["mac_address"]}"
  }
}
