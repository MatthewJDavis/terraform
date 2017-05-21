# AWS Server

The aws server project launches a ubuntu instance in either us-east-1 or us-west-2 regions. It creates a micro instance for the free tier, security group to allow web traffic on port 8080 and ssh access on port 22.

The user data creates a static html webpage that is served up by busybox.


Running the example

run `terraform apply -var-file="ami.tfvars" -var 'access_key' = {your_access_key} -var 'secret_key' = {your_secret_key} -var 'key_name={your_key_name}'` 

You could also create a secrets file (Do Not check this into source control) secrets.tfsecvars to store your access key, secret key and key name and run the command like:

run `terraform apply -var-file="ami.tfvars" -var-file="secrets.tfsecvars" 

Let is create for a few minutes then in the terminal enter: curl http://{public_ip}:8080
