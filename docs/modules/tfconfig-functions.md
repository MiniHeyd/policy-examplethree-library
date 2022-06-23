# Terraform Config Sentinel Module

# evaluate_attribute
This function evaluates an attribute within an item in the Terraform configuration. The attribute must either be a top-level attribute or an attribute directly under "config".

## Declaration
`evaluate_attribute = func(item, attribute)`

## Arguments
* **item**: a single item containing an attribute whose value you want to determine.
* **attribute**: a string giving the attribute. In general, the attribute should be a top-level attribute of item, but it can also have the form "config.x".

In practice, this function is only called by the filter functions, so the specification of the `attribute` parameter will be done when calling them.

## Common Functions Used
None.

## What It Returns
This function returns the attribute as it occurred within the Terraform configuration. The type will vary depending on what kind of attribute is evaluated. If the attribute had the form "config.x", it will look for "constant_value" or "references" under `item.config.x` and then whichever one it finds. In the latter case, it will return a list with all the references that the attribute referenced. Note that this does not evaluate the values of the references.

## What It Prints
This function does not print anything.

## Examples
This function is called by the `filter_attribute_does_not_match_regex` and `filter_attribute_matches_regex` filter functions in the tfconfig-functions.sentinel module like this:
```
val = evaluate_attribute(item, attr) else null
```

# filter_attribute_does_not_match_regex
This function filters a collection of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls to those with an attribute that does not match a given regular expression (regex). A policy would call it when it wants the attribute to match that regex. The attribute must either be a top-level attribute or an attribute directly under "config".

It uses the Sentinel [matches](https://docs.hashicorp.com/sentinel/language/spec/#matches-operator) operator which uses [RE2](https://github.com/google/re2/wiki/Syntax) regex.

## Declaration
`filter_attribute_does_not_match_regex = func(items, attr, expr, prtmsg)`

## Arguments
* **items**: a map of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls.
* **attr**: the name of a top-level attribute or an attribute directly under "config". In the fist case, give the attribute as a string. In the second case, give it as "config.x" where "x" is the attribute you're trying to restrict.
* **expr**: the regex expression that should not be matched. Note that any occurrences of `\` need to be escaped with `\` itself since Sentinel allows certain special characters to be escaped with `\`. For example, if you did not want to not match sub-domains of ".acme.com", you would set `expr` to `(.+)\\.acme\\.com$` instead of the more usual `(.+)\.acme\.com$`.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `items` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the items that meet the condition of the filter function. The `items` map contains the actual resources for which the attribute (`attr`) does not match the given regex, `expr`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
violatingEC2Instances = config.filter_attribute_does_not_match_regex(allEC2Instances,
                        "config.ami", "^data\\.aws_ami\\.(.*)$", true)
```
This is from the [require-most-recent-AMI-version.sentinel](../../../aws/require-most-recent-AMI-version.sentinel) policy.

# filter_attribute_in_list
This function filters a collection of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls to those with a top-level attribute that is contained in a provided list. A policy would call it when it wants the attribute to not have a value from the list.

This function is intended to examine metadata of various Terraform objects within a Terraform configuration. It cannot be used to examine the values of attributes of resources or data sources. Use the filter functions of the tfplan-functions or tfstate-functions modules for that.

## Declaration
`filter_attribute_in_list = func(items, attr, forbidden, prtmsg)`

## Arguments
* **items**: a map of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls.
* **attr**: the name of a top-level attribute given as a string that must be in a given list. Nested attributes cannot be used by this function.
* **forbidden**: a list of values the attribute is not allowed to have.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [to_string](./to_string.md) function.

## What It Returns
This function returns a map with two maps, `items` and `messages`. The `items` map contains the actual items of the original collection for which the attribute (`attr`) is in the list (`allowed`) while the `messages` map contains the violation messages associated with those items.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
violatingProviders = config.filter_attribute_in_list(allProviders,
                     "name", prohibited_list, false)

violatingResources = config.filter_attribute_in_list(allResources,
                     "type", prohibited_list, false)

violatingProvisioners = config.filter_attribute_in_list(allProvisioners,
                     "type", prohibited_list, false)
```

This function is used by several cloud-agnostic policies that prohibit certain types of items including [prohibited-datasources.sentinel](../../../cloud-agnostic/prohibited-datasources.sentinel), [prohibited-providers.sentinel](../../../cloud-agnostic/prohibited-providers.sentinel), [prohibited-provisioners.sentinel](../../../cloud-agnostic/prohibited-provisioners.sentinel), [require-all-providers-have-version-constrain.sentinel (Cloud Agnostic)](../../../cloud-agnostic/require-all-providers-have-version-constrain.sentinel) and [prohibited-resources.sentinel](../../../cloud-agnostic/prohibited-resources.sentinel).

# filter_attribute_matches_regex
This function filters a collection of items such as resources, data sources, or blocks to those with an attribute that matches a given regular expression (regex). A policy would call it when it wants the attribute to not match that regex. The attribute must either be a top-level attribute or an attribute directly under "config".

It uses the Sentinel [matches](https://docs.hashicorp.com/sentinel/language/spec/#matches-operator) operator which uses [RE2](https://github.com/google/re2/wiki/Syntax) regex.

## Declaration
`filter_attribute_matches_regex = func(items, attr, expr, prtmsg)`

## Arguments
* **items**: a map of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls.
* **attr**: the name of a top-level attribute or an attribute directly under "config". In the fist case, give the attribute as a string. In the second case, give it as "config.x" where "x" is the attribute you're trying to restrict.
* **expr**: the regex expression that should be matched. Note that any occurrences of `\` need to be escaped with `\` itself since Sentinel allows certain special characters to be escaped with `\`. For example, if you did not want to match sub-domains of ".acme.com", you would set `expr` to `(.+)\\.acme\\.com$` instead of the more usual `(.+)\.acme\.com$`. If you want to match null, set expr to "null".
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [evaluate_attribute](./evaluate_attribute.md) and the [to_string](./to_string.md) functions.

## What It Returns
This function returns a map with two maps, `items` and `messages`, both of which are indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the items that meet the condition of the filter function. The `items` map contains the actual resources for which the attribute (`attr`) matches the given regex, `expr`, while the `messages` map contains the violation messages associated with those instances.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
violatingEC2Instances = config.filter_attribute_matches_regex(allEC2Instances,
                        "config.ami", "^data\\.aws_ami\\.(.*)$", true)
```

# filter_attribute_not_in_list
This function filters a collection of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls to those with a top-level attribute that is not contained in a provided list. A policy would call it when it wants the attribute to have a value from the list.

This function is intended to examine metadata of various Terraform objects within a Terraform configuration. It cannot be used to examine the values of attributes of resources or data sources. Use the filter functions of the tfplan-functions or tfstate-functions modules for that.

## Declaration
`filter_attribute_not_in_list = func(items, attr, allowed, prtmsg)`

## Arguments
* **items**: a map of items such as providers, provisioners, resources, data sources, variables, outputs, or module calls.
* **attr**: the name of a top-level attribute given as a string that must be in a given list. Nested attributes cannot be used by this function.
* **allowed**: a list of values the attribute is allowed to have.
* **prtmsg**: a boolean indicating whether violation messages should be printed (if `true`) or not (if `false`).

## Common Functions Used
This function calls the [to_string](./to_string.md) function.

## What It Returns
This function returns a map with two maps, `items` and `messages`. The `items` map contains the actual items of the original collection for which the attribute (`attr`) is not in the list (`allowed`) while the `messages` map contains the violation messages associated with those items.

## What It Prints
This function prints the violation messages if the parameter, `prtmsg`, was set to `true`. Otherwise, it does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
violatingProviders = config.filter_attribute_not_in_list(allProviders,
                     "name", allowed_list, false)

violatingResources = config.filter_attribute_not_in_list(allResources,
                     "type", allowed_list, false)

violatingProvisioners = config.filter_attribute_not_in_list(allProvisioners,
                     "type", allowed_list, false)
```

This function is used by several cloud-agnostic policies that allow certain types of items including [allowed-datasources.sentinel](../../../cloud-agnostic/allowed-datasources.sentinel), [allowed-providers.sentinel](../../../cloud-agnostic/allowed-providers.sentinel), [allowed-provisioners.sentinel](../../../cloud-agnostic/allowed-provisioners.sentinel), and [allowed-resources.sentinel](../../../cloud-agnostic/allowed-resources.sentinel).

# find_all_datasources
This function finds all data sources in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to filtering `tfconfig.resources` to those with `mode` equal to `data`, which indicates that they are data sources rather than managed resources.

## Declaration
`find_all_datasources = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data sources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the data sources (excluding indices representing their counts). The map actually contains all data sources from the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allDatasources = config.find_all_datasources()
```

This function is used by the [prohibited-datasources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prohibited-datasources.sentinel) and [allowed-datasources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/allowed-datasources.sentinel) policies.

# find_all_module_calls
This function finds all module calls in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to referencing `tfconfig.module_calls`. It is included so that policies that use the tfconfig-functions.sentinel module do not need to import both it and the tfconfig/v2 module.

## Declaration
`find_all_module_calls = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of all module_calls indexed by the address of the module_call's module and its name. The map actually is identical to the [`tfconfig.module_calls`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-module_calls-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allModuleCalls = config.find_all_module_calls()
```

# find_all_outputs
This function finds all outputs in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to referencing `tfconfig.outputs`. It is included so that policies that use the tfconfig-functions.sentinel module do not need to import both it and the tfconfig/v2 module.

## Declaration
`find_all_outputs = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of all outputs indexed by the address of the output's module and its name. The map actually is identical to the [`tfconfig.outputs`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-outputs-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allOutputs = config.find_all_outputs()
```

# find_all_providers
This function finds all providers in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to referencing `tfconfig.providers`. It is included so that policies that use the tfconfig-functions.sentinel module do not need to import both it and the tfconfig/v2 module.

## Declaration
`find_all_providers = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of all providers indexed by the address of the provider's module and the provider's name and alias. The map actually is identical to the [`tfconfig.providers`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-providers-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allProviders = config.find_all_providers()
```

This function is used by the [require-all-providers-have-version-constrain.sentinel (Cloud Agnostic)](../../../cloud-agnostic/require-all-providers-have-version-constrain.sentinel), [prohibited-providers.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prohibited-providers.sentinel) and [allowed-providers.sentinel (Cloud Agnostic)](../../../cloud-agnostic/allowed-providers.sentinel) policies.

# find_all_provisioners
This function finds all provisioners in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to referencing `tfconfig.provisioners`. It is included so that policies that use the tfconfig-functions.sentinel module do not need to import both it and the tfconfig/v2 module.

## Declaration
`find_all_provisioners = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of all provisioners indexed by the address of the resource the provisioner is attached to and the provisioner's own index within that resource's provisioners. The map actually is identical to the [`tfconfig.provisioners`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-provisioners-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allProvisioners = config.find_all_provisioners()
```

This function is used by the [prohibited-provisioners.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prohibited-provisioners.sentinel) and [allowed-provisioners.sentinel (Cloud Agnostic)](../../../cloud-agnostic/allowed-provisioners.sentinel) policies.

# find_all_resources
This function finds all managed resources in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to filtering `tfconfig.resources` to those with `mode` equal to `managed`, which indicates that they are managed resources rather than data sources.

## Declaration
`find_all_resources = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of managed resources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources (excluding indices representing their counts). The map actually contains all managed resources from the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allResources = config.find_all_resources()
```

This function is used by the [prohibited-resources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/prohibited-resources.sentinel) and [allowed-resources.sentinel (Cloud Agnostic)](../../../cloud-agnostic/allowed-resources.sentinel) policies.

# find_all_variables
This function finds all variables in all modules in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

Calling it is equivalent to referencing `tfconfig.variables`. It is included so that policies that use the tfconfig-functions.sentinel module do not need to import both it and the tfconfig/v2 module.

## Declaration
`find_all_variables = func()`

## Arguments
None

## Common Functions Used
None

## What It Returns
This function returns a single flat map of all variables indexed by the address of the variable's module and its name. The map actually is identical to the [`tfconfig.variables`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-variables-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allVariables = config.find_all_variables()
```

# find_datasources_by_provider
This function finds all data sources created by a specific provider in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_datasources_by_provider = func(provider)`

## Arguments
* **provider**: the provider of data sources to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data sources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the data sources (excluding indices representing their counts). The map is actually a filtered sub-collection of the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allAWSDatasources = config.find_datasources_by_provider("aws")

allAzureDatasources = config.find_datasources_by_provider("azurerm")

allGoogleDatasources = config.find_datasources_by_provider("google")

allVMwareDatasources = config.find_datasources_by_provider("vsphere")
```

# find_datasources_by_type
This function finds all data sources of a specific type in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_datasources_by_type = func(type)`

## Arguments
* **type**: the type of data source to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data sources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the data sources (excluding indices representing their counts). The map is actually a filtered sub-collection of the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allAMIs = config.find_datasources_by_type("aws_ami")

allImages = config.find_datasources_by_type("azurerm_image")

allImages = config.find_datasources_by_type("google_compute_image")

allDatastores = config.find_datasources_by_type("vsphere_datastore")
```

# find_datasources_in_module
This function finds all data sources in a specific module in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_datasources_in_module = func(module_address)`

## Arguments
* **module_address**: the address of the module containing data sources to find, given as a string. The root module is represented by "". A module named `network` called by the root module is represented by "module.network". if that module contained a module named `subnets`, it would be represented by "module.network.module.subnets".

## Common Functions Used
None

## What It Returns
This function returns a single flat map of data sources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the data sources (excluding indices representing their counts). The map is actually a filtered sub-collection of the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allRootModuleDatasources = config.find_datasources_in_module("")

allNetworkDatasources = config.find_datasources_in_module("module.network")
```

# find_descendant_modules
This function finds the addresses of all modules called directly or indirectly by a module in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

It does this by calling itself recursively.

## Declaration
`find_descendant_modules = func(module_address)`

## Arguments
* **module_address**: the address of the module containing descendant modules to find, given as a string. The root module is represented by "". A module with label `network` called by the root module is represented by "module.network". if that module contained a module with label `subnets`, it would be represented by "module.network.module.subnets".

You can determine all module addresses in your current configuration by calling `find_descendant_modules("")`.

## Common Functions Used
This function calls `find_module_calls_in_module()`.

## What It Returns
This function returns a list of module addresses called directly or indirectly from the specified module.

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allModuleAddresses = config.find_descendant_modules("")
```

This function calls itself recursively with this code:
```
module_addresses += find_descendant_modules(new_module_address)
```
It does not use `config.` before calling itself since that is not necessary when calling a function from inside the module that contains it.

It is used by the [use-latest-module-versions.sentinel](../../../cloud-agnostic/http-examples/use-latest-module-versions.sentinel) policy.

# find_module_calls_in_module
This function finds all direct module calls in a specific module in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_module_calls_in_module = func(module_address)`

## Arguments
* **module_address**: the address of the module containing module_calls to find, given as a string. The root module is represented by "". A module named `network` called by the root module is represented by "module.network". if that module contained a module named `subnets`, it would be represented by "module.network.module.subnets".

You can determine all module addresses in your current configuration by calling `find_descendant_modules("")`.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of module calls indexed by the address of the module call's parent module and the module call's name. The map is actually a filtered sub-collection of the [`tfconfig.module_calls`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-module_calls-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
rootModuleCalls = config.find_module_calls_in_module("")

networkModuleCalls = config.find_module_calls_in_module("module.network")
```

This function is called by the `find_descendant_modules` function of the tfconfig-functions.sentinel module.

It is also called by the [use-lastest-module-versions.sentinel](../../../cloud-agnostic/http-examples/use-lastest-module-versions.sentinel) policy.

# find_outputs_by_sensitivity
This function finds all outputs of a specific sensitivity (`true` or `false`) in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_outputs_by_sensitivity = func(sensitive)`

## Arguments
* **sensitive**: the desired sensitivity of outputs which can be `true` or `false` (without quotes).

## Common Functions Used
None

## What It Returns
This function returns a single flat map of outputs indexed by the address of the module and the name of the output. The map is actually a filtered sub-collection of the [`tfconfig.outputs`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-outputs-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
sensitiveOutputs = config.find_outputs_by_sensitivity(true)

nonSensitiveOutputs = config.find_outputs_by_sensitivity(false)
```

# find_outputs_in_module
This function finds all outputs in a specific module in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_outputs_in_module = func(module_address)`

## Arguments
* **module_address**: the address of the module containing outputs to find, given as a string. The root module is represented by "". A module named `network` called by the root module is represented by "module.network". if that module contained a module named `subnets`, it would be represented by "module.network.module.subnets".

## Common Functions Used
None

## What It Returns
This function returns a single flat map of outputs indexed by the address of the module and the name of the output. The map is actually a filtered sub-collection of the [`tfconfig.outputs`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-outputs-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allRootModuleOutputs = config.find_outputs_in_module("")

allNetworkOutputs = config.find_outputs_in_module("module.network")
```

# find_providers_by_type
This function finds all providers of a specific type in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_providers_by_type = func(type)`

## Arguments
* **type**: the type of provider to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of providers indexed by the address of the provider's module and the provider's name and alias. The map is actually a filtered sub-collection of the [`tfconfig.providers`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-providers-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
awsProviders = config.find_providers_by_type("aws")

azureProviders = config.find_providers_by_type("azurerm")

googleProviders = config.find_providers_by_type("google")

vmwareProviders = config.find_providers_by_type("vsphere")
```

This function is used by the function `get_assumed_roles` in the  [aws-functions](../../../aws/aws-functions/aws-functions.sentinel) module.

# find_providers_in_module
This function finds all providers in a specific module in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_providers_in_module = func(module_address)`

## Arguments
* **module_address**: the address of the module containing providers to find, given as a string. The root module is represented by "". A module named `network` called by the root module is represented by "module.network". if that module contained a module named `subnets`, it would be represented by "module.network.module.subnets".

## Common Functions Used
None

## What It Returns
This function returns a single flat map of providers indexed by the address of the provider's module and the provider's name and alias. The map is actually a filtered sub-collection of the [`tfconfig.providers`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-providers-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allRootModuleProviders = config.find_providers_in_module("")

allNetworkProviders = config.find_providers_in_module("module.network")
```

# find_provisioners_by_type
This function finds all provisioners of a specific type in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_provisioners_by_type = func(type)`

## Arguments
* **type**: the type of provisioner to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of provisioners indexed by the address of the resource the provisioner is attached to and the provisioner's own index within that resource's provisioners. The map is actually a filtered sub-collection of the [`tfconfig.provisioners`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-provisioners-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
remoteExecProvisioners = config.find_provisioners_by_type("remote-exec")

localExecProvisioners = config.find_provisioners_by_type("local-exec")
```

This function is used by the cloud-agnostic [prevent-remote-exec-provisioners-on-null-resources.sentinel](../../../cloud-agnostic/prevent-remote-exec-provisioners-on-null-resources.sentinel) policy.

# find_resources_by_provider
This function finds all managed resources created by a specific provider in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_resources_by_provider = func(provider)`

## Arguments
* **provider**: the provider of resources to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources (excluding indices representing their counts). The map is actually a filtered sub-collection of the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allAWSResources = config.find_resources_by_provider("aws")

allAzureResources = config.find_resources_by_provider("azurerm")

allGoogleResources = config.find_resources_by_provider("google")

allVMwareResources = config.find_resources_by_provider("vsphere")
```

# find_resources_by_type
This function finds all managed resources of a specific type in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_resources_by_type = func(type)`

## Arguments
* **type**: the type of resource to find, given as a string.

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources (excluding indices representing their counts). The map is actually a filtered sub-collection of the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allEC2Instances = config.find_resources_by_type("aws_instance")

allAzureVMs = config.find_resources_by_type("azurerm_virtual_machine")

allGCEInstances = config.find_resources_by_type("google_compute_instance")

allVMs = config.find_resources_by_type("vsphere_virtual_machine")
```

# find_resources_in_module
This function finds all managed resources in a specific module in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_resources_in_module = func(module_address)`

## Arguments
* **module_address**: the address of the module containing resources to find, given as a string. The root module is represented by "". A module named `network` called by the root module is represented by "module.network". if that module contained a module named `subnets`, it would be represented by "module.network.module.subnets".

## Common Functions Used
None

## What It Returns
This function returns a single flat map of resources indexed by the complete [addresses](https://www.terraform.io/docs/internals/resource-addressing.html) of the resources (excluding indices representing their counts). The map is actually a filtered sub-collection of the [`tfconfig.resources`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-resources-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allRootModuleResources = config.find_resources_in_module("")

allNetworkResources = config.find_resources_in_module("module.network")
```

# find_variables_in_module
This function finds all variables in a specific module in the Terraform configuration of the current plan's workspace using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

## Declaration
`find_variables_in_module = func(module_address)`

## Arguments
* **module_address**: the address of the module containing variables to find, given as a string. The root module is represented by "". A module named `network` called by the root module is represented by "module.network". if that module contained a module named `subnets`, it would be represented by "module.network.module.subnets".

## Common Functions Used
None

## What It Returns
This function returns a single flat map of variables indexed by the address of the module and the name of the variable. The map is actually a filtered sub-collection of the [`tfconfig.variables`](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html#the-variables-collection) collection.

## What It Prints
This function does not print anything.

## Examples
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
allRootModuleVariables = config.find_variables_in_module("")

allNetworkVariables = config.find_variables_in_module("module.network")
```

# get_ancestor_module_source
This function finds the source of the first ancestor module that is not a local module of the module containing an item from its `module_address` using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import. (A local module is indicated by use of a source starting with "./" or "../".)

It does this by parsing `module_address` which will look like "module.A.module.B" if the item is not in the root module or "" if it is in the root module. It then finds the `module_call` in the parent module that calls the original module and then gets `source` from that module call.

However, if the `source` starts with "./" or "../", the function then calls itself recursively against the address of the module's parent module. It keeps doing this until it finds a non-local module and then gives that module's source.

## Declaration
`get_ancestor_module_source = func(module_address)`

## Arguments
* **module_address**: the address of the module containing some item, given as a string. The root module is represented by "". A module with label `network` called by the root module is represented by "module.network". if that module contained a module with label `subnets`, it would be represented by "module.network.module.subnets".

## Common Functions Used
None.

## What It Returns
This function returns a string containing the source of the ancestor module represented by the `module_address` parameter. If called against the root module of a Terraform configuration, it returns "root".

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
module_address = r.module_address
module_source = config.get_ancestor_module_source(module_address)
```

It is used by the [restrict-resources-by-module-source.sentinel](../../../cloud-agnostic/restrict-resources-by-module-source.sentinel) policy.

# get_module_source
This function finds the source of the module containing an item from its `module_address` using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

It does this by parsing `module_address` which will look like "module.A.module.B" if the item is not in the root module or "" if it is in the root module. It then finds the `module_call` in the parent module that calls the original module and then gets `source` from that module call.

## Declaration
`get_module_source = func(module_address)`

## Arguments
* **module_address**: the address of the module containing some item, given as a string. The root module is represented by "". A module with label `network` called by the root module is represented by "module.network". if that module contained a module with label `subnets`, it would be represented by "module.network.module.subnets".

## Common Functions Used
None.

## What It Returns
This function returns a string containing the source of the module represented by the `module_address` parameter. If called against the root module of a Terraform configuration, it returns "root".

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
module_address = r.module_address
module_source = config.get_module_source(module_address)
```

# get_parent_module_address
This function finds the address of the parent module of the module containing an item from its `module_address` using the [tfconfig/v2](https://www.terraform.io/docs/cloud/sentinel/import/tfconfig-v2.html) import.

It does this by parsing `module_address` which will look like "module.A.module.B" if the item is not in the root module or "" if it is in the root module.

## Declaration
`get_parent_module_address = func(module_address)`

## Arguments
* **module_address**: the address of the module containing some item, given as a string. The root module is represented by "". A module with label `network` called by the root module is represented by "module.network". if that module contained a module with label `subnets`, it would be represented by "module.network.module.subnets".

## Common Functions Used
None.

## What It Returns
This function returns a string containing the address of the parent module of the module represented by the `module_address` parameter. If called against the root module of a Terraform configuration, it returns "root".

## What It Prints
This function does not print anything.

## Examples
Here is an example of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
module_address = r.module_address
parent_module_address = config.get_parent_module_address(module_address)
```

# print_violations
This function prints the violation messages that were previously returned by one of the filter functions of the tfconfig-functions.sentinel module. While those filter functions can print the violations messages themselves (if their `prtmsg` parameter is set to `true`), it is sometimes preferable to delay printing of the messages until later in the policy, typically after printing one or more messages giving the address of the resource that violated it.

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
Here are some examples of calling this function, assuming that the tfconfig-functions.sentinel file that contains it has been imported with the alias `config`:
```
config.print_violations(violatingDatasources["messages"], "Blacklisted data source:")

config.print_violations(violatingProviders["messages"], "Blacklisted provider:")
```

This function is used by many of the cloud agnostic policies including [prohibited-datasources.sentinel](../../../cloud-agnostic/prohibited-datasources.sentinel) and [prohibited-providers.sentinel](../../../cloud-agnostic/prohibited-providers.sentinel).

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
This function is called by all of the filter functions in the tfconfig-functions.sentinel module. Here is a typical example:
```
message = to_string(index) + " has " + to_string(attr) + " with value " +
          to_string(val) + " that is not in the allowed list: " +
          to_string(allowed)
```
