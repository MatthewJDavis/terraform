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

or use environment variable:

```bash
export ARM_SUBSCRIPTION_ID=your_subscription_id
export ARM_TENANT_ID=your_tenant_id
export ARM_CLIENT_ID=your_appId
export ARM_CLIENT_SECRET=your_password
```