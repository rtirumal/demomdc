{
  "Id": "redshift-logs",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": [
            "public-read",
            "public-read-write"
          ]
        }
      },
      "Effect": "Deny",
      "Principal": "*",
      "Resource": "arn:aws:s3:::${bucket}/*",
      "Sid": "ensure-private-read-write"
    },
    {
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${redshift_log_account_id}:user/logs"
      },
      "Resource": "arn:aws:s3:::${bucket}/${redshift_logs_prefix}*",
      "Sid": "redshift-logs-put-object"
    },
    {
      "Action": "s3:GetBucketAcl",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${redshift_log_account_id}:user/logs"
      },
      "Resource": "arn:aws:s3:::${bucket}",
      "Sid": "redshift-logs-get-bucket-acl"
    }
  ],
  "Version": "2012-10-17"
}
