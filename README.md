# sftp-to-s3-container
A container that takes sftp uploads and deposits them in an s3 bucket.

docker build --rm -t equalexpertsmicrodc/sftp-to-s3-container:latest .

docker run -it --name sftp -p 9999:22 --privileged equalexpertsmicrodc/sftp-to-s3-container:latest --s3bucketname=my_bucket_name --sshpubkey="$(cat /Users/alanplatt/.ssh/id_rsa.pub)" --awsaccesskeyid=$KEY --awssecretaccesskey=$SECRET_KEY

sftp -P 9999 -i ~/.ssh/id_rsa my_bucket_name@localhost


# Kubernetes deployment
$ export NAME=sftp-to-s3
$ kubectl apply -f <(cat k8s.yaml.template | envsubst)
