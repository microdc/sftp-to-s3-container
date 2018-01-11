#!/bin/bash

set -e

err() {
  echo -e "[ERR] ${1}"
  exit 1
}

log() {
  echo -e "[LOG] ${1}"
}

usage() {
  err """
  This container allows sftp access to an s3 bucket.
  Please provide the required options.

  REQUIRED
  --s3bucketname           The Name of the s3 bucket only (no s3://)
  --sshpubkey              The public key of the ssh user


  OPTIONAL
  --awsaccesskeyid         AWS Access Key (defaults to container profile)
  --awssecretaccesskey     AWS Secret Access Key (as above)
  --s3bucketpath           The path within the s3 bucket (defaults to /)
  --sshuser                The user used for sftp (defaults to s3bucketname)
  """
}

main() {

  while [ "$1" != "" ]; do
    PARAM=$(echo "$1" | awk -F= '{print $1}')
    VALUE=$(echo "$1" | awk -F= '{print $2}')
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        --awsaccesskeyid)
            OPTION_AWSACCESSKEYID="${VALUE}"
            ;;
        --awssecretaccesskey)
            OPTION_AWSSECRETACCESSKEY="${VALUE}"
            ;;
        --iamrole)
            OPTION_IAMROLE="${VALUE}"
            ;;
        --s3bucketname)
            OPTION_S3BUCKETNAME="${VALUE}"
            ;;
        --s3bucketpath)
            OPTION_S3BUCKETPATH="${VALUE}"
            ;;
        --sshuser)
            OPTION_SSHUSER="${VALUE}"
            ;;
        --sshpubkey)
            OPTION_SSHPUBKEY="${VALUE}"
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            ;;
    esac
    shift
  done

  export AWSACCESSKEYID="${OPTION_AWSACCESSKEYID:-unset}"
  export AWSSECRETACCESSKEY="${OPTION_AWSSECRETACCESSKEY:-unset}"
  export S3BUCKETNAME="${OPTION_S3BUCKETNAME:-unset}"
  export S3BUCKETPATH="${OPTION_S3BUCKETPATH:-/}"
  export SSHUSER="${OPTION_SSHUSER:-$S3BUCKETNAME}"
  export SSHPUBKEY="${OPTION_SSHPUBKEY:-unset}"
  export IAMROLE="${OPTION_IAMROLE:-unset}"

  if [ "$S3BUCKETNAME" = "unset" ]; then
    echo "--s3bucketname unset"
    usage
  fi

  if [ "$SSHPUBKEY" = "unset" ]; then
    echo "--sshpubkey unset"
    usage
  fi

  if [ "$IAMROLE" = "unset" ]; then
    S3FSOPTIONS="allow_other"
  else
    S3FSOPTIONS="allow_other,iam_role=${IAMROLE}"
  fi

  log "Generate host keys"
  /usr/bin/ssh-keygen -A || err "Cant generate host keys"

  log "Create user ${SSHUSER}"
  useradd -m -s /bin/false "${SSHUSER}" || err "Fail to create ${SSHUSER}"

  log "Create ssh directory in user home"
  mkdir -vp "/home/${SSHUSER}/.ssh/" || err "Failed to create dir"

  log "Create ssh pub key file"
  echo "${SSHPUBKEY}" > "/home/${SSHUSER}/.ssh/authorized_keys" || err "Failed to create ssh pub key file"

  log "Set home directory ownership and perms"
  chmod 700 "/home/${SSHUSER}/.ssh"
  chmod 600 "/home/${SSHUSER}/.ssh/authorized_keys"
  chown -R "${SSHUSER}:${SSHUSER}" "/home/${SSHUSER}"

  log "Mount s3 bucket"
  echo s3fs "${S3BUCKETNAME}:${S3BUCKETPATH}" "/mnt/${S3BUCKETNAME}" -f -o "${S3FSOPTIONS}"
  mkdir -p "/mnt/${S3BUCKETNAME}"
  s3fs "${S3BUCKETNAME}:${S3BUCKETPATH}" "/mnt/${S3BUCKETNAME}" -f -o "${S3FSOPTIONS}" &
  S3FS_PID=$!

  log "Start sshd daemon"
  exec /usr/sbin/sshd -D -e &
  SSHD_PID=$!

  while kill -0 "${S3FS_PID}" && kill -0 "${SSHD_PID}"; do sleep 5; done

}

main "$@"

