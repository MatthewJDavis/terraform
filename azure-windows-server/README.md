# Code to run the example below.

```code
terraform plan -var-file='azureProviderCreds.tfsecvars'
```

.tfsecvars file not saved to source control, layout like:

```code
subscription_id = "
tenant_id = ""
client_id = ""
client_secret = ""
```