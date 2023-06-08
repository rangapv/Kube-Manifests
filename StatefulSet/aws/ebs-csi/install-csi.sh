#!/bin/bash
set -E
source <(curl -s https://raw.githubusercontent.com/rangapv/bash-source/main/s1.sh) >>/dev/null 2>&1
source <(curl -s https://raw.githubusercontent.com/rangapv/kubestatus/main/ks.sh) >>/dev/null 2>&1
source <(curl -s https://raw.githubusercontent.com/rangapv/metascript/main/AWS/chkmetadata.sh) >>/dev/null 2>&1

chkinststat() {
#echo "master is $master, node is $node"
if [[ (( $master -eq 0 )) && (( $node -eq 0 )) ]]
then
	echo "This instance(node) is neither a k8s Master nor k8s Node ..Aborting install of Statefullset"
	echo "Re-run this script after installing the k8s components"
	exit
else
	echo ""
fi


if [ ! -z  "$1" ]
then

AWS_ACCESS_KEY_ID="$1"

fi


if [ ! -z  "$2" ]
then

AWS_SECRET_ACCESS_KEY="$2"

fi

awsid1=`echo $AWS_ACCESS_KEY_ID`
awsid2=`echo $AWS_SECRET_ACCESS_KEY`

if [[ (( -z $awsid1 )) || (( -z $awsid2 )) ]]
then
	echo "AWS_ACCESS and SECRET KEYS are not set or misssing pls set them in environment variables"
	exit
else
	echo ""
fi

}


chkpre() {

allc1=`sudo cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep "\-\-allow\-privileged\=true"`
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
if [[ (( "$awsc1s" -eq "0" )) ]]
then
	echo ""
else
	insaws=`sudo $cm1 awscli`
	insawd="$?"
	if [[ (( $insawd -eq 0 )) ]]
	then
		echo "Successfully installed aws cli "
#		getinstdet
	else
		echo "Unable to install aws-cli"
	fi
fi
}

getinstdet() {

	mastc1=`aws ec2 associate-iam-instance-profile --instance-id ${str232} --iam-instance-profile Name="k8srole" --region=${str231}`
   
   mastc1s="$?"
   if [[ (( $mastc1s -eq 0 )) ]]
   then
	   echo ""
   else
	   echo "Unable to set profile for this instance ${str232}"
	   exit
   fi
}


cresec () {

sce1s=`kubectl get secret aws-secret -n kube-system`
sces1="$?"

if [[ (( ! -z $sce1s )) && (( $sces1 -eq 0 )) ]]
then
	echo ""
	echo "aws-secret already exists"
else
sce1=`kubectl create secret generic aws-secret --namespace kube-system --from-literal "key_id=${AWS_ACCESS_KEY_ID}" --from-literal "access_key=${AWS_SECRET_ACCESS_KEY}"`
	echo "Successfully created Secret aws-secret "
fi

}

helmins() {


hlm1=`which helm`
hlm1s="$?"

if [[ (( $hlm1s -ne 0 )) ]]
then
	inshlm=`mkdir helm;cd ./helm;git init;git pull https://github.com/rangapv/CloudNative.git;./helm.sh`
else
	echo "Current installation of helm is $hlm1"
fi

}

csidep() {
ecsic=`kubectl get po --all-namespaces | grep "ebs-csi-" | grep "unning" |wc -l`

if [[ (( $ecsic -lt 1 )) ]]
then
  #finale1=`kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.12"`
  #finale1=`kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.19"`
  helmins  
  finale1s="$?"

  if [[ (( $finale1s -eq 0 )) ]]
  then
	echo "CSI driver created chk pod status(kubectl get pods --all-namespaces) to make sure"
  else
	echo "CSI install failed pls debug"
  fi

else
	echo "ebscsi install requirement already satisified, check pod status"
	echo "Total ebs-csi pods running are $ecsic"
fi

}


#Main Begins
chkinststat "$1" "$2"
chkpre

cresec
csidep
