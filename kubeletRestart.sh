#!/bin/bash
OUTPUT=`ps -ef |grep kubelet|grep -v grep`
cmd1="nohup sudo kubelet --kubeconfig $HOME/.kube/config --cluster-dns 10.96.0.10 & 2>&1 &"
if [ -z "$OUTPUT" ]
then
  echo $(eval "$cmd1")
else
  echo "the process is running"
fi
