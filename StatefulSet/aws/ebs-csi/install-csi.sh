#!/bin/sh
set -E
source <(curl -s https://raw.githubusercontent.com/rangapv/bash-source/main/s1.sh) > /dev/null 2>&1
source <(curl -s https://raw.githubusercontent.com/rangapv/kubestatus/main/ks.sh) > /dev/null 2>&1
source <(curl -s https://raw.githubusercontent.com/rangapv/metascript/main/AWS/metadata-aws.sh) > /dev/null 2>&1

chkinststat() {

if [[ (( $master -eq 0 )) && (( $node -eq 0 )) ]]
then
        echo ""
else
	echo "This instance(node) is neither a k8s Master nor k8s Node ..Aborting install of Statefullset"
	echo "Re-run this script after installing the k8s components"
	exit
fi

awsid1=`echo $AWS_ACCESS_KEY_ID`
awsid2=`echo $AWS_SECRET_ACCESS_KEY`

if [[ (( -z $awsid1 )) || (( -z $awsid2 )) ]]
then
	echo "AWS_ACCESS and SECRET KEYS are not set or misssing pls set them in environment variables"
	exit
fi

}


chkpre() {

allc1=`sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep "\-\-allow\-priviliged\=true"`
allc1s="$?"
if [[ (( $allc1s -eq 0 )) ]]
then
        echo ""
else
	echo "Pre-requisite of kube-apiserver (allow-priviliged FLAG) is not set"
	exit
fi
awsc1=`which aws`
awsc1s="$?"
if [[ (( $awsc1s -eq 0 )) ]]
then
	echo ""
else
	insaws=`sudo $cm1 awscli`
	insawd="$?"
	if [[ (( $insawss -eq 0 )) ]]
	then
		echo "Successfully installed aws cli "
		getinstdet
	else
		echo "Unable to install aws-cli"
	fi
fi
}

getinstdet() {

		mastc1=`aws ec2 associate-iam-instance-profile --instance-id ${str232} --iam-instance-profile Name="k8srole" --region=${str231}`
   
   mastc1s="$?"
   if [[ (( $masc1s -eq 0 )) ]]
   then
	   echo ""
   else
	   echo "Unable to set profile for this instance ${str232}"
	   exit
   fi
}


cresec () {

sce1=`kubectl create secret generic aws-secret --namespace kube-system --from-literal "key_id=${AWS_ACCESS_KEY_ID}" --from-literal "access_key=${AWS_SECRET_ACCESS_KEY}"`
sce1s=`kubectl get secret aws-secret -n kube-system`
sces1="$?"

if [[ (( ! -z $sces1 )) ]]
then
	echo ""
else
	echo "Secret creation of aws-secret failed "
	exit
fi

}

csidep() {
finale1=`kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.12"`
finale1s="$?"
if [[ (( $finale1s -eq 0 )) ]]
then
	echo "CSI driver created chk pod status(kubectl get pods -all-namespaces) to make sure"
else
	echo "CSI install failed pls debug"
fi
}


#Main Begins

chkinststat
chkpre

cresec
csidep

