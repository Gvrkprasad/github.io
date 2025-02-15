cidr_block      = { "dev" = "10.0.0.0/16", "prod" = "11.0.0.0/16" }
web_ami_id      = "ami-00bb6a80f01f03502"
app_ami_id      = "ami-00bb6a80f01f03502"
key_name        = "glpsk370-ubuntu"
environment     = { "dev" = "dev", "prod" = "prod" }
instance_type   = { "dev" = "t2.micro", "prod" = "t3.micro" }
iam_user1       = { "dev" = "babusai", "prod" = "gvrkprasad" }
bucket_name     = { "dev" = "glps-tf-bkt", "prod" = "dorababu-terraform-bucket" }
env_bucket_name = { "dev" = "dora-tf-dev", "prod" = "gvrkprasad-tf-prod" }
db_username     = { "dev" = "dorababu", "prod" = "gvrkprasad" }
db_password     = { "dev" = "SivakalaDorababu", "prod" = "Gvrkprasad" }
#elastic_compute_could (ec2) variable_data
ec2_ami           = { "dev" = "ami-0b7207e48d1b6c06f", "prod" = "ami-02ddb77f8f93ca4ca" }
ec2_instance_type = { "dev" = "t2.micro", "prod" = "t3.micro" }
ec2_keypair       = { "dev" = "glpsk370-linux", "prod" = "glpsk370-redhat" }
file_path        = "C:/glps/cache.jpg"
sns_topic_name = "s3_sns_lamda_topic"