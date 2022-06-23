module "tfconfig-functions" {
  source = "./modules/tfconfig-functions/tfconfig-functions.sentinel"
}

module "tfplan-functions" {
  source = "./modules/tfplan-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
  source = "./modules/tfstate-functions/tfstate-functions.sentinel"
}

module "tfrun-functions" {
  source = "./modules/tfrun-functions/tfrun-functions.sentinel"
}

policy "enforce-mandatory-tags" {
  source = "./policies/enforce-mandatory-tags.sentinel"
  enforcement_level = "advisory"
}

policy "protect-against-rds-instance-deletion" {
  source = "./policies/protect-against-rds-instance-deletion.sentinel"
  enforcement_level = "advisory"
}

policy "require-dns-support-for-vpcs" {
  source = "./policies/require-dns-support-for-vpcs.sentinel"
  enforcement_level = "advisory"
}
