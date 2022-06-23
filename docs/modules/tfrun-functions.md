# Terraform Run Sentinel Module

# limit_cost_and_percentage_increase
This function validates that the proposed monthly cost from the [cost estimates](https://www.terraform.io/docs/cloud/cost-estimation/index.html) of a plan done against a workspace is less than a given limit which is given in US dollars and that the percentage increase of the monthly cost is less than a given maximum percentage.

## Declaration
`limit_cost_and_percentage_increase = func(limit, max_percent)`

## Arguments
* **limit**: the upper limit on the allowed estimated monthly costs (in US dollars) for the resources provisioned in the workspace, given as a [decimal](https://docs.hashicorp.com/sentinel/imports/decimal/).
* **max_percent**: the upper limit on the percentage increase of the estimated monthly costs compared to the current monthly cost (if available), also given as a decimal.

## Common Functions Used
None

## What It Returns
This function returns `true` if the estimated monthly costs of the workspace are under `limit` and the percentage increase of those costs is less than `max_percent` or if no cost estimates were available. Otherwise, it returns `false`.

## What It Prints
This function prints messages indicating whether or not the estimated monthly costs are allowed or not. Additionally, if no cost estimates are available, it prints a message to indicate that.

## Examples
Here is an example of calling this function, assuming that the tfrun-functions.sentinel file that contains it has been imported with the alias `run`:
```
limit = decimal.new(1000)
max_percent = decimal.new(10.0)
cost_validated = run.limit_cost_and_percentage_increase(limit, max_percent)
```
Note that any policy calling this function must also import the standard decimal import with `import "decimal"`.

This function is used by the cloud agnostic policy [limit-cost-and-percentage-increase.sentinel](../../../cloud-agnostic/limit-cost-and-percentage-increase.sentinel).

# limit_cost_by_workspace_name
This function validates that the proposed monthly cost from the [cost estimates](https://www.terraform.io/docs/cloud/cost-estimation/index.html) of a plan done against a workspace is less than a given limit (given in US dollars). The limit is determined from a map that associates workspace names with different limits using regex matching.

The idea is that you might set different limits for Dev, QA, and Production workspaces.

## Declaration
`limit_cost_by_workspace_name = func(limits)`

## Arguments
* **limits**: a map associating strings (the keys of the map) with different upper limits (the values of the map) for the allowed estimated monthly costs (in US dollars) for the resources provisioned in the workspace. The strings are treated as workspace name prefixes and suffixes. In other words, the limit associated with the string "dev" will be applied to workspaces whose names start with "dev-" or end with "-dev". The limits assigned to each string in the map must be given as [decimals](https://docs.hashicorp.com/sentinel/imports/decimal/). Of course, you must coordinate the naming of your workspaces with the keys of the `limits` map.

## Common Functions Used
None

## What It Returns
This function returns `true` if the estimated monthly cost of the workspace is under the limit in the `limits` map that corresponds to the workspace name or if no cost estimates were available. Otherwise, it returns `false`. Note that if a workspace name does not match any of the keys in the `limits` map, the function will return `false` and probably cause the policy that called it to fail.

## What It Prints
This function prints messages indicating whether or not the estimated monthly costs are under the limit in the `limits` map that corresponds to the workspace name. Additionally, if no cost estimates are available or if the `limits` map does not contain a key that matches the workspace name, it prints a message to indicate that.

## Examples
Here is an example of calling this function, assuming that the tfrun-functions.sentinel file that contains it has been imported with the alias `run`:
```
limits = {
  "dev": decimal.new(200),
  "qa": decimal.new(500),
  "prod": decimal.new(1000),
}
cost_validated = run.limit_cost_by_workspace_name(limits)
```
Note that any policy calling this function must also import the standard decimal import with `import "decimal"`.

This function is used by the cloud agnostic policy [limit-cost-by-workspace-name.sentinel](../../../cloud-agnostic/limit-cost-by-workspace-name.sentinel).

# limit_proposed_monthly_cost
This function validates that the proposed monthly cost from the [cost estimates](https://www.terraform.io/docs/cloud/cost-estimation/index.html) of a plan done against a workspace is less than a given limit which is given in US dollars.

## Declaration
`limit_proposed_monthly_cost = func(limit)`

## Arguments
* **limit**: the upper limit on the allowed estimated monthly cost (in US dollars) for the resources provisioned in the workspace, given as a [decimal](https://docs.hashicorp.com/sentinel/imports/decimal/).

## Common Functions Used
None

## What It Returns
This function returns `true` if the estimated monthly cost of the workspace is less than or equal to `limit` or if no cost estimates were available. Otherwise, it returns `false`.

## What It Prints
This function prints messages indicating whether or not the estimated monthly cost is less than or equal to the limit. Additionally, if no cost estimates are available, it prints a message to indicate that.

## Examples
Here is an example of calling this function, assuming that the tfrun-functions.sentinel file that contains it has been imported with the alias `run`:
```
limit = decimal.new(1000)
cost_validated = run.limit_proposed_monthly_cost(limit)
```
Note that any policy calling this function must also import the standard decimal import with `import "decimal"`.

This function is used by the cloud agnostic policy [limit-proposed-monthly-cost.sentinel](../../../cloud-agnostic/limit-proposed-monthly-cost.sentinel).
