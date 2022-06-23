# Terraform Plan Sentinel Module

# evaluate_attribute
This function evaluates the value of an attribute within a resource, data source, or block. The attribute can be deeply nested.

## Declaration
`evaluate_attribute = func(r, attribute)`

## Arguments
* **r**: a single resource or block containing an attribute whose value you want to determine. The function converts a plain resource reference like `rc` tp `rc.change.after`; if you want to evaluate the previous state, pass `rc.change.before`.
* **attribute**: a string giving the attribute. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`. If `r` represents a block, then `attribute` should be specified relative to that block.

In practice, this function is only called by the filter functions, so the specification of the `attribute` parameter will be done when calling them.

## Common Functions Used
This function calls itself recursively to support nested attributes of resources and blocks.

## What It Returns
This function returns the value of the attribute of the resource or block. The type will vary depending on what kind of attribute is evaluated.

## What It Prints
This function does not print anything.

## Examples
This function is called by all of the filter functions in the tfplan-functions.sentinel module. Here is a typical example:
```
v = evaluate_attribute(rc, attr) else null
```

# filter_attribute_contains_items_from_list
This function filters a collection of resources, data sources, or blocks to those with an attribute that contains any members of a given list. A policy would call it when it does not want the attribute to contain any members of the list.

## Declaration
`filter_attribute_contains_items_from_list = func(resources, attr, forbidden, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should not contain any items in a given list. The attribute should be a list or a map. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params` rather than `boot_disk[0].initialize_params`.
* **forbidden**: a list of values the attribute should not contain. If you want to disallow null, include "null" in the list.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) contains any items of the list (`forbidden`) while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingSGRules = plan.filter_attribute_contains_items_from_list(SGIngressRules,
                  "cidr_blocks",forbidden_cidrs, true)
```

This function is used by the [restrict-ingress-sg-rule-cidr-blocks.sentinel (AWS)](../../../aws/restrict-ingress-sg-rule-cidr-blocks.sentinel) policy.

# filter_attribute_contains_items_not_in_list
This function filters a collection of resources, data sources, or blocks to those with an attribute that contains any items that are not in a given list. A policy would call it when it wants the attribute to only contain members of the list (but not necessarily all of them).

## Declaration
`filter_attribute_contains_items_not_in_list = func(resources, attr, allowed, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should should only contain items from a given list. The attribute should be a list or a map. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params` rather than `boot_disk[0].initialize_params`.
* **allowed**: a list of values the attribute is allowed to contain. If you want to allow null, include "null" in the list.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) contains any items that are not in the list (`allowed`) while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingIRs = plan.filter_attribute_contains_items_not_in_list(ingressRules,
               "cidr_blocks", allowed_cidrs, false)
```

# filter_attribute_does_not_have_prefix
This function filters a collection of resources, data sources, or blocks to those with an attribute that does have a specified prefix. A policy would call it when it wants the attribute to start with that prefix.

It uses Sentinel's standard [strings](https://docs.hashicorp.com/sentinel/imports/strings/) import.

## Declaration
`filter_attribute_does_not_have_prefix = func(resources, attr, prefix, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should start with the given prefix. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **prefix**: the prefix that the attribute should start with.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) does not start with `prefix`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingAccessKeys = plan.filter_attribute_does_not_have_prefix(allAccessKeys,
                      "pgp_key", "keybase:", true)

violatingEC2Instances = plan.filter_attribute_does_not_have_prefix(
                        allEC2Instances, "instance_type", "m5.", true)
```

# filter_attribute_does_not_have_suffix
This function filters a collection of resources, data sources, or blocks to those with an attribute that does have a specified suffix. A policy would call it when it wants the attribute to end with that suffix.

It uses Sentinel's standard [strings](https://docs.hashicorp.com/sentinel/imports/strings/) import.

## Declaration
`filter_attribute_does_not_have_suffix = func(resources, attr, suffix, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should end with the given suffix. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **suffix**: the suffix that the attribute should end with.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) does not end with `suffix`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingS3Buckets = plan.filter_attribute_does_not_have_suffix(allS3Buckets,
                      "acl", "-full-control", true)

violatingGCESubnets = plan.filter_attribute_does_not_have_suffix(
                        allGCESubnets, "ip_cidr_range", "/24", true)
```

# filter_attribute_does_not_match_regex
This function filters a collection of resources, data sources, or blocks to those with an attribute that does not match a given regular expression (regex). A policy would call it when it wants the attribute to match that regex.

It uses the Sentinel [matches](https://docs.hashicorp.com/sentinel/language/spec/#matches-operator) operator which uses [RE2](https://github.com/google/re2/wiki/Syntax) regex.

## Declaration
`filter_attribute_does_not_match_regex = func(resources, attr, expr, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should match the given regex. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **expr**: the regex expression that should be matched. Note that any occurrences of `\` need to be escaped with `\` itself since Sentinel allows certain special characters to be escaped with `\`. For example, if you wanted to match sub-domains of ".acme.com", you would set `expr` to `(.+)\\.acme\\.com$` instead of the more usual `(.+)\.acme\.com$`. If you want to allow `null`, set `expr` to `(<regex>|null)`.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) does not match the given regex, `expr`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingACMCerts = plan.filter_attribute_does_not_match_regex(allACMCerts,
                    "domain_name", "(.+)\\.hashidemos\\.io$", true)

violatingAccessKeys = plan.filter_attribute_does_not_match_regex(allAccessKeys,
                      "pgp_key", "^keybase:(.+)", true)
```

# filter_attribute_greater_than_equal_to_value
This function filters a collection of resources, data sources, or blocks to those with an attribute that is greater than or equal to a given numeric value. A policy would call it when it wants the attribute to be less than the given value.

## Declaration
`filter_attribute_greater_than_equal_to_value = func(resources, attr, value, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should be less than or equal to a given value. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **value**: the value of the attribute should be less than the given value. This should be an integer or a float.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is greater than or equal to the given value, `value`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingToPortGreater = plan.filter_attribute_greater_than_equal_to_value(ingressRules,
								"to_port", forbidden_to_port, false)
```

This function is used by the policies [restrict-ingress-sg-rule-ssh.sentinel (AWS)](../../../aws/restrict-ingress-sg-rule-ssh.sentinel), [restrict-ingress-sg-rule-rdp.sentinel (AWS)](../../../aws/restrict-ingress-sg-rule-rdp.sentinel)# filter_attribute_greater_than_value
This function filters a collection of resources, data sources, or blocks to those with an attribute that is greater than a given numeric value. A policy would call it when it wants the attribute to be less than or equal to the given value.

## Declaration
`filter_attribute_greater_than_value = func(resources, attr, value, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should be less than or equal to a given value. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **value**: the value the attribute should be less than or equal to. This should be an integer or a float.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is greater than the given value, `value`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
highCPUVMs = plan.filter_attribute_greater_than_value(allVMs,
             "num_cpus", maxCPUs, true)


highMemoryVMs = plan.filter_attribute_greater_than_value(allVMs,
                "memory", maxMemory, true)

violatingDisks = plan.filter_attribute_greater_than_value(disks,
                 "size", maxDiskSize, false)
```

This function is used by the policies [restrict-vm-cpu-and-memory.sentinel (VMware)](../../../vmware/restrict-vm-cpu-and-memory.sentinel), [restrict-vm-disk-size.sentinel (VMware)](../../../vmware/restrict-vm-disk-size.sentinel)

# filter_attribute_has_prefix
This function filters a collection of resources, data sources, or blocks to those with an attribute that has a specified prefix. A policy would call it when it wants the attribute to not start with that prefix.

It uses Sentinel's standard [strings](https://docs.hashicorp.com/sentinel/imports/strings/) import.

## Declaration
`filter_attribute_has_prefix = func(resources, attr, prefix, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should not start with the given prefix. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **prefix**: the prefix that the attribute should not start with.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) starts with `prefix`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingAccessKeys = plan.filter_attribute_has_prefix(allAccessKeys,
                      "pgp_key", "keybase:", true)

violatingAzureVMs = plan.filter_attribute_has_prefix(
                        allAzureVMs, "vm_size", "Standard_", true)
```

# filter_attribute_has_suffix
This function filters a collection of resources, data sources, or blocks to those with an attribute that has a specified suffix. A policy would call it when it wants the attribute to not end with that suffix.

It uses Sentinel's standard [strings](https://docs.hashicorp.com/sentinel/imports/strings/) import.

## Declaration
`filter_attribute_has_suffix = func(resources, attr, suffix, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should not end with the given suffix. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **suffix**: the suffix that the attribute should not end with.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) ends with `suffix`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingS3Buckets = plan.filter_attribute_has_suffix(allS3Buckets,
                      "acl", "-full-control", true)

violatingGCESubnets = plan.filter_attribute_has_suffix(
                        allGCESubnets, "ip_cidr_range", "/8", true)
```

# filter_attribute_in_list
This function filters a collection of resources, data sources, or blocks to those with an attribute contained in a provided list. A policy would call it when it does not want the attribute set to any member of the list.

## Declaration
`filter_attribute_in_list = func(resources, attr, forbidden, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that must not be in a given list. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **forbidden**: a list of values the attribute is forbidden to have. If you want to disallow null, include "null" in the list.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is in in the list (`forbidden`) while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingEC2Instances = plan.filter_attribute_in_list(allEC2Instances,
                        "instance_type", forbidden_types, true)

violatingAzureVMs = plan.filter_attribute_in_list(allAzureVMs,
                    "vm_size", forbidden_sizes, true)

violatingGCEInstances = plan.filter_attribute_in_list(allGCEInstances,
                        "machine_type", forbidden_types, true)
```

# filter_attribute_is_not_value
This function filters a collection of resources, data sources, or blocks to those with an attribute that is not equal to a given value. A policy would call it when it wants the attribute to equal the given value.

## Declaration
`filter_attribute_is_not_value = func(resources, attr, value, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should equal a given value. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **value**: the value the attribute should have. This can be any primitive data type.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is not equal to the given value, `value`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
nonPrivateS3Buckets = plan.filter_attribute_is_not_value(allS3Buckets,
                      "acl", "private", true)

nonEncryptedS3Buckets = plan.filter_attribute_is_not_value(allS3Buckets,
  "server_side_encryption_configuration.0.rule.0.apply_server_side_encryption_by_default.0.sse_algorithm",
  "aws:kms", true)

violatingAzureAppServices = plan.filter_attribute_is_not_value(allAzureAppServices,
                            "https_only", true, true)
```

This function is used by the [require-private-acl-and-kms-for-s3-buckets.sentinel (AWS)](../../../aws/require-private-acl-and-kms-for-s3-buckets.sentinel) and [restrict-app-service-to-https.sentinel (Azure)](../../../azure/restrict-app-service-to-https.sentinel) policies.

# filter_attribute_is_value
This function filters a collection of resources, data sources, or blocks to those with an attribute that is equal to a given value. A policy would call it when it wants the attribute to not equal the given value.

## Declaration
`filter_attribute_is_value = func(resources, attr, value, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should not equal a given value. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **value**: the value the attribute should not have. This can be any primitive data type. If you want to match null, set value to "null".
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is equal to the given value, `value`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
nonPrivateS3Buckets = plan.filter_attribute_is_value(allS3Buckets,
                      "acl", "public_read", true)


violatingAzureAppServices = plan.filter_attribute_is_value(allAzureAppServices,
                            "https_only", false, true)
```

# filter_attribute_less_than_equal_to_value
This function filters a collection of resources, data sources, or blocks to those with an attribute that is less than or equal to a given numeric value. A policy would call it when it wants the attribute to be greater than the given value.

## Declaration
`filter_attribute_less_than_equal_to_value = func(resources, attr, value, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should be greater than or equal to a given value. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **value**: the value or the attribute should be greater than the given value. This should be an integer or a float.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is less than or equal to the given value, `value`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingFromPortLess = plan.filter_attribute_less_than_equal_to_value(ingressRules,
							"from_port", forbidden_from_port, false)
```
This function is used by the policies [restrict-ingress-sg-rule-ssh.sentinel (AWS)](../../../aws/restrict-ingress-sg-rule-ssh.sentinel), [restrict-ingress-sg-rule-rdp.sentinel (AWS)](../../../aws/restrict-ingress-sg-rule-rdp.sentinel)# filter_attribute_less_than_value
This function filters a collection of resources, data sources, or blocks to those with an attribute that is less than a given numeric value. A policy would call it when it wants the attribute to be greater than or equal to the given value.

## Declaration
`filter_attribute_less_than_value = func(resources, attr, value, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should be greater than or equal to a given value. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **value**: the value the attribute should be greater than or equal to. This should be an integer or a float.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is less than the given value, `value`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
lowCPUVMs = plan.filter_attribute_less_than_value(allVMs,
             "num_cpus", minCPUs, true)


lowMemoryVMs = plan.filter_attribute_less_than_value(allVMs,
                "memory", minMemory, true)
```

# filter_attribute_matches_regex
This function filters a collection of resources, data sources, or blocks to those with an attribute that matches a given regular expression (regex). A policy would call it when it wants the attribute to not match that regex.

It uses the Sentinel [matches](https://docs.hashicorp.com/sentinel/language/spec/#matches-operator) operator which uses [RE2](https://github.com/google/re2/wiki/Syntax) regex.

## Declaration
`filter_attribute_matches_regex = func(resources, attr, expr, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should match the given regex. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **expr**: the regex expression that should be matched. Note that any occurrences of `\` need to be escaped with `\` itself since Sentinel allows certain special characters to be escaped with `\`. For example, if you did not want to match sub-domains of ".acme.com", you would set `expr` to `(.+)\\.acme\\.com$` instead of the more usual `(.+)\.acme\.com$`. If you want to match null, set expr to "null".
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) matches the given regex, `expr`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingACMCerts = plan.filter_attribute_matches_regex(allACMCerts,
                    "domain_name", "(.+)\\.hashidemos\\.io$", true)

violatingAccessKeys = plan.filter_attribute_matches_regex(allAccessKeys,
                      "pgp_key", "^keybase:(.+)", true)
```

# filter_attribute_not_contains_list
This function filters a collection of resources, data sources, or blocks to those with an attribute that does not contain all members of a given list. A policy would call it when it wants the attribute to contain all members of the list.

## Declaration
`filter_attribute_not_contains_list = func(resources, attr, required, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that must contain all items from a given list. The attribute should be a list or map. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params` rather than `boot_disk[0].initialize_params`.
* **required**: a list of values all of which the attribute should contain.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) does not contain all items of the list (`required`) while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingEC2Instances = plan.filter_attribute_not_contains_list(allEC2Instances,
                        "tags", mandatory_tags, true)

violatingAzureVMs = plan.filter_attribute_not_contains_list(allAzureVMs,
                    "tags", mandatory_tags, true)

violatingGCEInstances = plan.filter_attribute_not_contains_list(allGCEInstances,
                        "labels", mandatory_labels, true)
```

This function is used by several policies including [enforce-mandatory-tags.sentinel (AWS)](../../../aws/enforce-mandatory-tags.sentinel), [enforce-mandatory-tags.sentinel (Azure)](../../../azure/enforce-mandatory-tags.sentinel), and [enforce-mandatory-labels.sentinel (GCP)](../../../gcp/enforce-mandatory-labels.sentinel).

# filter_attribute_not_in_list
This function filters a collection of resources, data sources, or blocks to those with an attribute that is not contained in a provided list. A policy would call it when it wants the attribute to have a value from the list.

## Declaration
`filter_attribute_not_in_list = func(resources, attr, allowed, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that must be in a given list. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **allowed**: a list of values the attribute is allowed to have. If you want to allow null, include "null" in the list.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is not in the list (`allowed`) while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingEC2Instances = plan.filter_attribute_not_in_list(allEC2Instances,
                        "instance_type", allowed_types, true)

violatingAzureVMs = plan.filter_attribute_not_in_list(allAzureVMs,
                    "vm_size", allowed_sizes, true)

violatingGCEInstances = plan.filter_attribute_not_in_list(allGCEInstances,
                        "machine_type", allowed_types, true)
```

This function is used by many policies including [restrict-ec2-instance-type.sentinel (AWS)](../../../aws/restrict-ec2-instance-type.sentinel), [restrict-vm-size.sentinel (Azure)](../../../azure/restrict-vm-size.sentinel), and [restrict-gce-machine-type.sentinel (GCP)](../../../gcp/restrict-gce-machine-type.sentinel).

# filter_attribute_was_not_value
This function filters a collection of resources, data sources, or blocks to those with an attribute that was not equal to a given value. A policy would call it when it wants the attribute to equal the given value, especially when trying to delete a resource. Note that this function passes `rc.change.before` instead of `rc` to the `evaluate_attribute()` function which converts `rc` to `rc.change.after`.

## Declaration
`filter_attribute_was_not_value = func(resources, attr, value, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should have previously equaled a given value. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **value**: the value the attribute should have been equal to. This can be any primitive data type.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is not equal to the given value, `value`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
nonPrivateS3Buckets = plan.filter_attribute_was_not_value(allS3Buckets,
                      "acl", "private", true)

violatingAzureAppServices = plan.filter_attribute_is_not_value(allAzureAppServices,
                            "https_only", true, true)
```

# filter_attribute_was_value
This function filters a collection of resources, data sources, or blocks to those with an attribute that was equal to a given value. A policy would call it when it wants the attribute to not equal the given value, especially when trying to delete a resource. Note that this function passes `rc.change.before` instead of `rc` to the `evaluate_attribute()` function which converts `rc` to `rc.change.after`.

## Declaration
`filter_attribute_was_value = func(resources, attr, value, prtmsg)`

## Arguments
* **resources**: a map of resources derived from [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) or a list of blocks returned by the `find_blocks` function.
* **attr**: the name of a resource attribute given as a string that should not have previously equaled a given value. If the attribute is nested, the various blocks containing it should be delimited with periods (`.`). Indices of lists should not include brackets and should start with 0. So, you would use `boot_disk.0.initialize_params.0.image` rather than `boot_disk[0].initialize_params[0].image`.
* **value**: the value the attribute should not have been equal to. This can be any primitive data type. If you want to match null, set value to "null".
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `resources` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources, data sources, or blocks that meet the condition of the filter function. The `resources` map contains the actual resource instances for which the attribute (`attr`) is equal to the given value, `value`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
violatingRDSInstances = plan.filter_attribute_was_value(RDSInstancesBeingDeleted,
                        "deletion_protection", true, false)

violatingAzureAppServices = plan.filter_attribute_was_value(allAzureAppServices,
                            "https_only", true, true)
```

This function is used by the [protect-against-rds-instance-deletion.sentinel (AWS)](../../../aws/protect-against-rds-instance-deletion.sentinel) policy.

# find_blocks
This function finds all blocks of a specific type under a single resource or block in the current plan using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

## Declaration
`find_blocks = func(parent, child)`

## Arguments
* **parent**: a single resource or block of a resource
* **child**: a string representing the child blocks to be found in the parent.

## Common Functions Used
None

## What It Returns
This function returns a single list of child blocks found in the parent resource or block. Each child block is represented by a map.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
ingressRules = plan.find_blocks(sg, "ingress")

disks = plan.find_blocks(vm, "disk")
```

This function is used by the [restrict-ingress-sg-rule-cidr-blocks.sentinel (AWSc)](../../../aws/restrict-ingress-sg-rule-cidr-blocks.sentinel) and [restrict-vm-disk-size.sentinel (VMware)](../../../vmware/restrict-vm-disk-size.sentinel) policies.

# find_datasources
This function finds all data source instances of a specific type that are being created, modified, or read in the current plan using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import. Data sources with the "no-op" action are also included, but only if their `change.after` attribute is not null.

When evaluating data sources that do not reference any computed values (those known after doing an apply), it is usually better to use the [tfstate/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html) import and the corresponding [find_datasources](../tfstate-functions/find_datasources.md) function that uses that import.

## Sentinel Module
This function is contained in the [tfplan-functions.sentinel](../tfplan-functions.sentinel) Sentinel module.

## Declaration
`find_datasources = func(type)`

## Arguments
* **type**: the type of datasource to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data source instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
allAMIs = plan.find_datasources("aws_ami")

allImages = plan.find_datasources("azurerm_image")

allImages = plan.find_datasources("google_compute_image")

allDatastores = plan.find_datasources("vsphere_datastore")
```

# find_datasources_being_destroyed
This function finds all data source instances being destroyed but not re-created in the current plan using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

## Declaration
`find_datasources_being_destroyed = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data source instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/data source-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.data source_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-data source_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
datasourcesBeingDestroyed = plan.find_data sources_being_destroyed()
```

# find_datasources_by_provider
This function finds all data source instances for a specific provider that are being created, modified, or read in the current plan using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import. Data sources with the "no-op" action are also included, but only if their `change.after` attribute is not null.

When evaluating data sources that do not reference any computed values (those known after doing an apply), it is usually better to use the [tfstate/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfstate-v2.html) import and the corresponding [find_datasources](../tfstate-functions/find_datasources.md) function that uses that import.

If you are using Terraform 0.12, use the short form of the provider name such as "null". If you are using Terraform 0.13, you can use the short form or the fully-qualified provider source such as "registry.terraform.io/hashicorp/null", but only use the latter if you are only want to find resources from a specific registry. If you use the short form, the function will reduce `rc.provider_name` for each resource to the short form, but if you use the long form, it will not.

## Sentinel Module
This function is contained in the [tfplan-functions.sentinel](../tfplan-functions.sentinel) Sentinel module.

## Declaration
`find_datasources_by_provider = func(provider)`

## Arguments
* **provider**: the provider, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data source instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
allAWSDataSources = plan.find_datasources_by_provider("aws")

allAWSDataSources = plan.find_datasources_by_provider("registry.terraform.io/hashicorp/aws")

allAzureDataSources = plan.find_datasources_by_provider("azurerm")

allGCPDataSources = plan.find_datasources_by_provider("google")

allVMwareDataSources = plan.find_datasources("vsphere")
```

# find_resources
This function finds all resource instances of a specific type in the current plan that are being created, modified or read using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import. Resources with the "no-op" action are also included, but only if their `change.after` attribute is not null.

## Declaration
`find_resources = func(type)`

## Arguments
* **type**: the type of resource to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
allEC2Instances = plan.find_resources("aws_instance")

allAzureVMs = plan.find_resources("azurerm_virtual_machine")

allGCEInstances = plan.find_resources("google_compute_instance")

allVMs = plan.find_resources("vsphere_virtual_machine")
```

This function is used by many policies including [restrict-ec2-instance-type.sentinel (AWS)](../../../aws/restrict-ec2-instance-type.sentinel), [restrict-vm-size..sentinel (Azure)](../../../azure/restrict-vm-size..sentinel), [restrict-gce-machine-type.sentinel (GCP)](../../../gcp/restrict-gce-machine-type.sentinel), and [restrict-vm-cpu-and-memory.sentinel (VMware)](../../../vmware/restrict-vm-cpu-and-memory.sentinel).

# find_resources_being_destroyed
This function finds all resource instances being destroyed but not re-created in the current plan using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import.

## Declaration
`find_resources_being_destroyed = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
resourcesBeingDestroyed = plan.find_resources_being_destroyed()
```

This function is used by the [prevent-destruction-of-prohibited-resources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prevent-destruction-of-prohibited-resources.sentinel) policy.

# find_resources_by_provider
This function finds all resource instances for a specific provider in the current plan that are being created, modified, or read using the [tfplan/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html) import. Resources with the "no-op" action are also included, but only if their `change.after` attribute is not null.

If you are using Terraform 0.12, use the short form of the provider name such as "null". If you are using Terraform 0.13, you can use the short form or the fully-qualified provider source such as "registry.terraform.io/hashicorp/null", but only use the latter if you are only want to find resources from a specific registry. If you use the short form, the function will reduce `rc.provider_name` for each resource to the short form, but if you use the long form, it will not.

## Declaration
`find_resources_by_provider = func(provider)`

## Arguments
* **provider**: the provider, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resource instances indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the instances. The map is actually a filtered sub-collection of the [`tfplan.resource_changes`](https://www.terraform.io/docs/cloud/sentinel/import/tfplan-v2.html#the-resource_changes-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
allAWSResources = plan.find_resources_by_provider("aws")

allAWSResources = plan.find_resources_by_provider("registry.terraform.io/hashicorp/aws")

allAzureResources = plan.find_resources_by_provider("azurerm")

allGCPResources = plan.find_resources_by_provider("google")

allVMwareResources = plan.find_resources_by_provider("vsphere")
```

# print_violations
This function prints the violation messages that were previously returned by one of the filter functions of the tfplan-functions.sentinel module. While those filter functions can print the violations messages themselves (if their `prtmsg` parameter is set to `true`), it is sometimes preferable to delay printing of the messages until later in the policy, typically after printing one or more messages giving the address of the resource that violated it.

## Declaration
`print_violations = func(messages, prefix)`

## Arguments
* **messages**: a map of messages returned by one of the filter functions.
* **prefix**: a string that should be printed before each message.

## Common Functions Used
None

## What It Returns
This function always returns `true`.

## What It Prints
This function prints the messages in the `messages` map prefixed with the `prefix` string.

## Examples
Here are some examples of calling this function, assuming that the tfplan-functions.sentinel file that contains it has been imported with the alias `plan`:
```
if length(violatingIRs["messages"]) > 0 {
  violatingSGsCount += 1
  print("SG Ingress Violation:", address, "has at least one ingress rule",
        "with forbidden cidr blocks")
  plan.print_violations(violatingIRs["messages"], "Ingress Rule")
}

if length(violatingDisks["messages"]) > 0 {
  disksValidated = false
  print(address, "has at least one disk with size greater than", maxDiskSize)
  plan.print_violations(violatingDisks["messages"], "Disk")
}
```

This function is used by the [restrict-ingress-sg-rule-cidr-blocks.sentinel (AWS)](../../../aws/restrict-ingress-sg-rule-cidr-blocks.sentinel) and [restrict-vm-disk-size.sentinel (VMware)](../../../vmware/restrict-vm-disk-size.sentinel).

# to_string
This function converts any Sentinel object including complex compositions of primitive types (string, int, float, and bool), null, undefined, lists, and maps to a string.

## Declaration
`to_string = func(obj)`

## Arguments
* **obj**: a Sentinel object of any type

## Common Functions Used
This function calls itself recursively to support composite objects.

## What It Returns
This function returns a single string.

## What It Prints
This function does not print anything.

## Examples
This function is called by all of the filter functions in the tfplan-functions.sentinel module. Here is a typical example:
```
message = to_string(address) + " has " + to_string(attr) + " with value " +
          to_string(v) + " that is not in the allowed list: " +
          to_string(allowed)
```
