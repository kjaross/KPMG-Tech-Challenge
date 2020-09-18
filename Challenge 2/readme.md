
cat ~/.aws/credentials
[test]
aws_access_key_id = xxxxxx
aws_secret_access_key = xxxxxx

cat ~/.aws/config 
[profile test]
region = us-east-1
output = json

------------------------
cd packer
packer validate ami.json
packer build ami.json

------------------------
cd terraform
terraform init      #initialize a working directory with modules

terraform plan -refresh=true -out=plan    #Write a plan file to the given path. This can be used as input to the "apply" 
command.  
refresh - Update state prior to checking for differences (used to detect any drift from the last-known state)

terraform apply plan

------------------------

test the output on command-line:
watch -n 5 curl -s http://web-alb-498725002.us-east-1.elb.amazonaws.com

To Test the scaliong policy:-
seq 1 300000 | xargs -n1 -P3 bash -c 'i=$0; url="http://web-alb-498725002.us-east-1.elb.amazonaws.com"; curl -s $url'

xargs - it can take output of a command and passes it as argument of another command

-P - parallel mode
-n - maximum number of arguments taken from standard input