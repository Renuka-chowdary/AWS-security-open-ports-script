#!/bin/sh

#Finding the security group ID which is attached to the instances
sgroup=$(aws ec2 describe-instances | grep "SECURITYGROUPS" | awk {'print $2'}) 

#Removing all the contents on the file for store updated info about security groups
echo "AWS alert! You have universal ports open on some security groups">/tmp/sg_data

#Reading the security group ID one by one

for sname in $sgroup
do
            #Finding the Instance name with instance-group-ID
    	iname=$(aws ec2 describe-instances --filters "Name=instance.group-id,Values=$sname" | grep "Name" | awk {'print $3'})

   	#Fetching the security group configuration data with SG-ID and filtering it
    	ports=$(aws ec2 describe-security-groups --group-id $sname | grep -e "tcp" -e "0.0.0.0/0" | awk {'print $2'} | tr '\n' ' ' | xargs -n2 | awk {'print $1'} | grep -v "0.0.0.0/0" | sed 's/\<80\>//g')
    	if [ "$ports" != "" ]; then
            	a="\n"
            	b="\nInstance name =>[$iname] Attached security group ID =>[$sname]"
            	c="\nUniversal open ports :\n$ports"
            	#Storing all the data in file   	 
           	echo "$a $b $c">>/tmp/sg_data
    	else
            	echo ""
    	fi
done
#Reading file and send mail with file data
a=$(cat /tmp/sg_data)
echo "$a" | mail -s "AWS security alert!"  renuka.c@hashedin.com

