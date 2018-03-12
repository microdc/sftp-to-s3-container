# sftp-to-s3-container
A container that takes sftp uploads and deposits them in a mounted s3 bucket via fuse s3fs.

Available on [Docker hub](https://hub.docker.com/r/microdc/sftp-to-s3-container/)

### Build
```
docker build --rm -t microdc/sftp-to-s3-container:latest .
```

### Run example
```
docker run -it --name sftp -p 9999:22 --privileged microdc/sftp-to-s3-container:latest --s3bucketname=my_bucket_name --sshpubkey="$(cat /Users/alanplatt/.ssh/id_rsa.pub)" --awsaccesskeyid=$KEY --awssecretaccesskey=$SECRET_KEY
```

### Use with sftp command line tool
```
sftp -P 9999 -i ~/.ssh/id_rsa my_bucket_name@localhost
```

## Kubernetes deployment (KOPS on AWS)
```
export APPNAME=sftp-to-s3
export ENVIRONMENT=dev
export S3BUCKETNAME=test-bucket
export SSHPUBKEY="$(cat /Users/alanplatt/.ssh/id_rsa.pub)"
kubectl apply -f <(cat k8s.yaml.template | envsubst)
```

# TODO
* When the container dies the host key changes.  This may get annoying.
* Not run with privileged mode - sffs currently requires this
