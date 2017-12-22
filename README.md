# sftp-to-s3-container
A container that takes sftp uploads and deposits them in a mounted s3 bucket via fuse s3fs.

Available on [Docker hub](https://hub.docker.com/r/equalexpertsmicrodc/sftp-to-s3-container/)

### Build
```
docker build --rm -t equalexpertsmicrodc/sftp-to-s3-container:latest .
```

### Run example
```
docker run -it --name sftp -p 9999:22 --privileged equalexpertsmicrodc/sftp-to-s3-container:latest --s3bucketname=my_bucket_name --sshpubkey="$(cat /Users/alanplatt/.ssh/id_rsa.pub)" --awsaccesskeyid=$KEY --awssecretaccesskey=$SECRET_KEY
```

### Use with sftp command line tool
```
sftp -P 9999 -i ~/.ssh/id_rsa my_bucket_name@localhost
```

## Kubernetes deployment
```
export APPNAME=sftp-to-s3
export ENVIRONMENT=dev
export S3BUCKETNAME=test-bucket
export SSHPUBKEY="$(cat /Users/alanplatt/.ssh/id_rsa.pub)"
kubectl apply -f <(cat k8s.yaml.template | envsubst)
```
