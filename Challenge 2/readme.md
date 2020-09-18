Challenge #2
"We need to write code that will query the meta data of an instance within aws and provide a json formatted output. The choice of language and implementation is up to you.
 
Bonus Points:
The code allows for a particular data key to be retrieved individually"



Steps:
#1 Copy the script to the EC2 instance
scp -i "test.pem" query-metadata.sh ec2-user@ec2-35-171-87-60.compute-1.amazonaws.com

#2 SSH into a EC2 instance, in my case I SSH into the instance I've deployed in Challenge 1:
ssh -i "test.pem" ec2-user@ec2-35-171-87-60.compute-1.amazonaws.com

#3 Run the script
./query-metadata.sh

Note: individual data keys can be retreaved by setting up a required metadata key in the DATA_KEY variable.



