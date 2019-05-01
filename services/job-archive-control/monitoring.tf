# --------------------------------------------------------------------------------
# SNS TOPIC FOR ALERTS
# --------------------------------------------------------------------------------
module "sns_alerts" {
  source = "git::git@github.com:gruntwork-io/package-messaging.git//modules/sns?ref=v0.1.3"

  name                      = "${local.component_name}-${var.service_environment}-alerts-topic"
  display_name              = "ja-${var.service_environment == "${var.service_environment}" ? "prd" : "stg"}-alr"
  allow_publish_accounts    = []
  allow_subscribe_accounts  = []
  allow_subscribe_protocols = ["https", "email"]
}

resource "aws_ssm_parameter" "ssm_sns_alerts_name" {
  name   = "/${local.component_name}/${var.service_environment}/sns/alerts/name"
  type   = "SecureString"
  value  = "${module.sns_alerts.topic_name}"
  key_id = "${module.kms_master_key.key_id}"
}

resource "aws_ssm_parameter" "ssm_sns_alerts_display_name" {
  name   = "/${local.component_name}/${var.service_environment}/sns/alerts/display-name"
  type   = "SecureString"
  value  = "${module.sns_alerts.topic_display_name}"
  key_id = "${module.kms_master_key.key_id}"
}

resource "aws_ssm_parameter" "ssm_sns_alerts_arn" {
  name   = "/${local.component_name}/${var.service_environment}/sns/alerts/arn"
  type   = "SecureString"
  value  = "${module.sns_alerts.topic_arn}"
  key_id = "${module.kms_master_key.key_id}"
}

# --------------------------------------------------------------------------------
# CloudWatch Dashboard
# --------------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "cloudwatch_dashboard_job_archive" {
  dashboard_name = "${var.service_name}-${var.service_environment}"

  dashboard_body = <<EOF
 {
    "widgets": [
        {
            "type": "metric",
            "x": 12,
            "y": 3,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "buildarchive-${local.legacy_environment}-sqs", { "yAxis": "left", "stat": "Sum", "period": 900 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "legend": {
                    "position": "hidden"
                },
                "title": "Control Q: Visible Messages",
                "period": 300,
                "yAxis": {
                    "left": {
                        "showUnits": false,
                        "label": "Message count"
                    }
                }
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 6,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/SQS", "ApproximateAgeOfOldestMessage", "QueueName", "buildarchive-${local.legacy_environment}-sqs", { "stat": "Maximum", "period": 900 } ]
                ],
                "view": "singleValue",
                "region": "us-east-1",
                "period": 300,
                "title": "Control Q: Max. Age of Messages (15 min.)",
                "stacked": false,
                "setPeriodToTimeRange": false
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 3,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "buildarchive-${local.legacy_environment}-sqs", { "stat": "Sum", "color": "#ff7f0e", "period": 300 } ]
                ],
                "view": "singleValue",
                "region": "us-east-1",
                "period": 300,
                "title": "Control Q: Message Count (5min.)"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 9,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "buildarchive-${local.legacy_environment}-ingest-lambda", "Resource", "buildarchive-${local.legacy_environment}-ingest-lambda", { "id": "errors", "stat": "Sum", "color": "#d62728", "period": 900 } ],
                    [ ".", "Invocations", ".", ".", ".", ".", { "id": "invocations", "stat": "Sum", "visible": false, "period": 900 } ],
                    [ { "expression": "100 - 100 * errors / invocations", "label": "Success rate (%)", "id": "availability", "yAxis": "right", "period": 900 } ]
                ],
                "region": "us-east-1",
                "title": "Control λ: Error count and success rate (%)",
                "yAxis": {
                    "right": {
                        "max": 100
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 9,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "buildarchive-${local.legacy_environment}-ingest-lambda", "Resource", "buildarchive-${local.legacy_environment}-ingest-lambda", { "stat": "Sum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Control λ: Invocations",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 9,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "buildarchive-${local.legacy_environment}-ingest-lambda", "Resource", "buildarchive-${local.legacy_environment}-ingest-lambda", { "stat": "Minimum", "period": 900 } ],
                    [ "...", { "stat": "Average", "period": 900 } ],
                    [ "...", { "stat": "Maximum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Control λ: Duration",
                "period": 300,
                "annotations": {
                    "horizontal": [
                        {
                            "label": "60s timeout, watch for sustained max durations",
                            "value": 60000
                        }
                    ]
                }
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 9,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Events", "TriggeredRules", "RuleName", "buildarchive-${local.legacy_environment}-ingest-event-rule", { "period": 900, "stat": "Sum", "yAxis": "left" } ],
                    [ ".", "Invocations", ".", ".", { "period": 900, "stat": "Sum", "yAxis": "right" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "period": 300,
                "title": "Control λ: Cron triggers vs. invocations",
                "yAxis": {
                    "left": {
                        "label": "Trigger count",
                        "showUnits": false
                    },
                    "right": {
                        "showUnits": false,
                        "label": "Invocation count"
                    }
                },
                "annotations": {
                    "horizontal": [
                        {
                            "color": "#d62728",
                            "label": "Gaps may indicate the event rule has been disabled",
                            "value": 2
                        }
                    ]
                }
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 0,
            "width": 24,
            "height": 3,
            "properties": {
                "markdown": "\n# Job Archive Operational Dashboard\n\nIf you wish to receive Job Archive alerts via email you may subscribe to the Alerts SNS topic via the CLI:\n\n> `aws sns subscribe --topic-arn arn:aws:sns:us-east-1:981263594894:job-archive-control-${var.service_environment}-alerts-topic --protocol email --notification-endpoint {insert-email-alias}@adobe.com`\n\nYou will receive a confirmation email which needs to be acknowledged before any alerts are dispatched.\n"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 3,
            "width": 12,
            "height": 6,
            "properties": {
                "markdown": "\n## Control Component\n\nThis is Job Archive's entry point.\n\nMessages come in directly from Jenkins or the Job Archive API component into the [`buildarchive-${local.legacy_environment}-sqs`](https://console.aws.amazon.com/sqs/home?region=us-east-1#queue-browser:selected=https://sqs.us-east-1.amazonaws.com/981263594894/buildarchive-${local.legacy_environment}-sqs;prefix=) queue. Messages are processed by the [`buildarchive-${local.legacy_environment}-ingest`](https://console.aws.amazon.com/lambda/home?region=us-east-1#/functions/buildarchive-${local.legacy_environment}-ingest-lambda) lambda function which is triggered `every minute` by the CloudWatch Event Rule [`buildarchive-${local.legacy_environment}-ingest-event-rule`](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#rules:name=buildarchive-${local.legacy_environment}-ingest-event-rule).\n\nA message consists of a request to register or set the metadata for a new or existing Task within Job Archive.\n\nThe `buildarchive-${local.legacy_environment}-ingest` lambda function is responsible for 3 key things:\n\n- Process queued messages and save task events to the Job Archive database.\n- Broadcast via SNS all completed tasks based on a task's status. Any task with a status different from 'running' is considered to have completed.\n- Delete successfully processed messages from the queue. If the function executes with errors, messages are left in the queue.\n\n#### Troubleshooting\n- An elevated number of visible messages in the queue and the average age of messages greater than 5 min. would indicate a possible issue. Search [`buildarchive-${local.legacy_environment}-ingest`'s CloudWatch logs](https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#logStream:group=/aws/lambda/buildarchive-${local.legacy_environment}-ingest-lambda;streamFilter=typeLogStreamPrefix) for errors.\n\n#### Resources\n- https://github.com/magento-cicd/jenkins-pipeline-global-library\n- https://github.com/magento-cicd/build-archive-ingest\n- https://build.devops.magento.com/job/build-archive-ingest\n- https://github.com/magento-cicd/terraform-inventories/tree/master/digital-pipeline/buildarchive-sqs\n"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 15,
            "width": 24,
            "height": 2,
            "properties": {
                "markdown": "\n## Data Component\n"
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 23,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "WriteLatency", "DBInstanceIdentifier", "job-archive-data-${var.service_environment}-aurora-cluster-0", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-1", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-2", { "period": 900 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "title": "Cluster Write Latency",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 17,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "FreeLocalStorage", "DBInstanceIdentifier", "job-archive-data-${var.service_environment}-aurora-cluster-0", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-1", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-2", { "period": 900 } ]
                ],
                "view": "timeSeries",
                "region": "us-east-1",
                "title": "Cluster Free Storage Capacity",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 17,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", "job-archive-data-${var.service_environment}-aurora-cluster-0", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-1", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-2", { "period": 900 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "title": "Cluster CPU Utilization",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 23,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "job-archive-data-${var.service_environment}-aurora-cluster-0", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-1", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-2", { "period": 900 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "title": "Cluster Database Connections",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 17,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "ReadLatency", "DBInstanceIdentifier", "job-archive-data-${var.service_environment}-aurora-cluster-2", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-1", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-0", { "period": 900 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "title": "Cluster Read Latency",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 23,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "AuroraReplicaLag", "DBClusterIdentifier", "job-archive-data-${var.service_environment}-aurora-cluster", { "period": 900 } ],
                    [ ".", "AuroraReplicaLagMaximum", ".", ".", { "period": 900 } ],
                    [ ".", "AuroraReplicaLagMinimum", ".", ".", { "period": 900 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "title": "Cluster Replica Lag",
                "period": 300
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 17,
            "width": 6,
            "height": 9,
            "properties": {
                "markdown": "\nThe Job Archive Data component consists of an Aurora PostgreSQL database cluster and an S3 bucket for storing Task artifacts. The cluster is comprised of 3 nodes (as of writing), one read/write Master RDS instance and two read-only replicas.\n\n#### Cluster Endpoints\n- **Read/Write**: \tjob-archive-data-${var.service_environment}-aurora-cluster.cluster-cpzexe7sdc2r.us-east-1.rds.amazonaws.com\n- **Read-only**: job-archive-data-${var.service_environment}-aurora-cluster.cluster-ro-cpzexe7sdc2r.us-east-1.rds.amazonaws.com\n\nWhen accessing the `read-only` endpoint, a cluster node is selected via round-robin, distributing the load across the cluster instances.\n\n#### S3 Bucket\nThe `buildarchive-${local.legacy_environment}-artifacts` bucket stores all artifacts related to a Task using the task's `taskID` as a prefix. This way it is easy to locate all the artifacts for a given task by simply looking up it's `taskID`.\n\n**Note**: To view the bucket's size and number of objects the time window needs to be set to, at least, 3 days.\n"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 29,
            "width": 24,
            "height": 3,
            "properties": {
                "markdown": "\n## Funnel Component\n\nThe Job Archive Funnel component is responsible for collecting Allure Report test data, validating, processing and storing it in the Job Archive database.\n\n- When the Control component determines a task has finished, it broadcasts a message that is picked up by Funnel and placed in the `job-archive-funnel-${var.service_environment}-sqs-completed-tasks` queue. \n- Funnel then looks up the `taskID` and reaches out to the `buildarchive-${local.legacy_environment}-artifacts` bucket and determines if the Task artifacts location contains an Allure Report zip file. \n- If it does, it collects it, stores it in a new S3 location and queues the artifacts for processing into the `job-archive-funnel-${var.service_environment}-sqs-unproccessed-tests` queue.\n- Once tests are analyzed for validity, they are inserted into the database.\n\nIn the event that any of the messages present in the queues above are not able to be processed, after 5 retries, messages are moved into the corresponding dead-letter queue for inspection and root cause analysis.\n"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 38,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "job-archive-funnel-${var.service_environment}-process", "Resource", "job-archive-funnel-${var.service_environment}-process", { "stat": "Sum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Process: Invocations",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 38,
            "width": 9,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "job-archive-funnel-${var.service_environment}-process", "Resource", "job-archive-funnel-${var.service_environment}-process", { "stat": "Minimum", "period": 900 } ],
                    [ "...", { "stat": "Average", "period": 900 } ],
                    [ "...", { "stat": "Maximum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Process: Duration",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 15,
            "y": 38,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "job-archive-funnel-${var.service_environment}-process", "Resource", "job-archive-funnel-${var.service_environment}-process", { "id": "errors", "stat": "Sum", "color": "#d62728", "period": 900 } ],
                    [ ".", "Invocations", ".", ".", ".", ".", { "id": "invocations", "stat": "Sum", "visible": false, "period": 900 } ],
                    [ { "expression": "100 - 100 * errors / invocations", "label": "Success rate (%)", "id": "availability", "yAxis": "right", "period": 900 } ]
                ],
                "region": "us-east-1",
                "title": "Process: Error count and success rate (%)",
                "yAxis": {
                    "right": {
                        "max": 100,
                        "showUnits": false,
                        "label": "Rate %"
                    },
                    "left": {
                        "showUnits": false,
                        "label": "Invocation count"
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 32,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "job-archive-funnel-${var.service_environment}-validate", "Resource", "job-archive-funnel-${var.service_environment}-validate", { "stat": "Sum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Validate: Invocations",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 32,
            "width": 9,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "job-archive-funnel-${var.service_environment}-validate", "Resource", "job-archive-funnel-${var.service_environment}-validate", { "stat": "Minimum", "period": 900 } ],
                    [ "...", { "stat": "Average", "period": 900 } ],
                    [ "...", { "stat": "Maximum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Validate: Duration",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 15,
            "y": 32,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "job-archive-funnel-${var.service_environment}-validate", "Resource", "job-archive-funnel-${var.service_environment}-validate", { "id": "errors", "stat": "Sum", "color": "#d62728", "period": 900 } ],
                    [ ".", "Invocations", ".", ".", ".", ".", { "id": "invocations", "stat": "Sum", "visible": false, "period": 900 } ],
                    [ { "expression": "100 - 100 * errors / invocations", "label": "Success rate (%)", "id": "availability", "yAxis": "right", "period": 900 } ]
                ],
                "region": "us-east-1",
                "title": "Validate: Error count and success rate (%)",
                "yAxis": {
                    "right": {
                        "max": 100,
                        "showUnits": false,
                        "label": "Rate %"
                    },
                    "left": {
                        "showUnits": false,
                        "label": "Invocation Count"
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 21,
            "y": 32,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "job-archive-funnel-${var.service_environment}-sqs-completed-tasks-dead-letter", { "color": "#d62728", "stat": "Sum" } ],
                    [ ".", "ApproximateAgeOfOldestMessage", ".", "job-archive-funnel-${var.service_environment}-sqs-unprocessed-tests-dead-letter", { "stat": "Sum" } ]
                ],
                "view": "singleValue",
                "region": "us-east-1",
                "title": "Validate Errors (DLQ)",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 21,
            "y": 38,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "job-archive-funnel-${var.service_environment}-sqs-unprocessed-tests-dead-letter", { "color": "#d62728", "stat": "Sum" } ],
                    [ ".", "ApproximateAgeOfOldestMessage", ".", ".", { "stat": "Sum" } ]
                ],
                "view": "singleValue",
                "region": "us-east-1",
                "title": "Processed Errors (DLQ)",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 20,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "job-archive-data-${var.service_environment}-aurora-cluster-0", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-1", { "period": 900 } ],
                    [ "...", "job-archive-data-${var.service_environment}-aurora-cluster-2", { "period": 900 } ]
                ],
                "view": "timeSeries",
                "region": "us-east-1",
                "title": "Cluster Free RAM",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 26,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "MaximumUsedTransactionIDs", "DBClusterIdentifier", "job-archive-data-${var.service_environment}-aurora-cluster", { "period": 900 } ]
                ],
                "view": "singleValue",
                "stacked": true,
                "region": "us-east-1",
                "title": "Cluster Transaction ID Count",
                "setPeriodToTimeRange": false,
                "period": 300
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 53,
            "width": 24,
            "height": 2,
            "properties": {
                "markdown": "\n## API Component\n\nThe Job Archive API Component is the future main entry point for Job Archive while direct access is Job Archive Control is phased out.\n\nAPI requests are routed through an AWS API Gateway to matching Lambda functions for each of the API paths.\n"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 44,
            "width": 24,
            "height": 3,
            "properties": {
                "markdown": "\n## Webhooks Component\n\nThe Job Archive Webhooks component is currently in charge of notifying the Converter Service of completed \"Public-Pull-Request\" and \"Existing-PR-Test\" jobs.\n\n- It receives a broadcast request from the Job Archive Control component and queues in in the `job-archive-webhooks-${var.service_environment}-queue`. \n- If a completed task matches the Converter Service criteria above, it dispatches messages to the `conv-svc-${var.service_environment}-sqs` queue.\n- If an error occurs, messages are moved to the corresponding dead-leter queue after 3 retries.\n"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 47,
            "width": 9,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "job-archive-webhooks-${var.service_environment}-notify", "Resource", "job-archive-webhooks-${var.service_environment}-notify", { "stat": "Minimum", "period": 900 } ],
                    [ "...", { "stat": "Average", "period": 900 } ],
                    [ "...", { "stat": "Maximum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Notify λ: Duration",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 47,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "job-archive-webhooks-${var.service_environment}-notify", "Resource", "job-archive-webhooks-${var.service_environment}-notify", { "stat": "Sum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": " Notify λ: Invocations",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 15,
            "y": 47,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "job-archive-webhooks-${var.service_environment}-notify", "Resource", "job-archive-webhooks-${var.service_environment}-notify", { "id": "errors", "stat": "Sum", "period": 900, "color": "#d62728" } ],
                    [ ".", "Invocations", ".", ".", ".", ".", { "id": "invocations", "stat": "Sum", "visible": false, "period": 900 } ],
                    [ { "expression": "100 - 100 * errors / invocations", "label": "Success rate (%)", "id": "availability", "yAxis": "right", "period": 900 } ]
                ],
                "region": "us-east-1",
                "title": "Notify λ: Error count and success rate (%)",
                "yAxis": {
                    "right": {
                        "max": 100,
                        "showUnits": false,
                        "label": "Rate %"
                    },
                    "left": {
                        "showUnits": false,
                        "label": "Invocation count"
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 21,
            "y": 47,
            "width": 3,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "job-archive-webhooks-${var.service_environment}-queue-dead-letter", { "color": "#d62728" } ],
                    [ ".", "ApproximateAgeOfOldestMessage", ".", "." ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "us-east-1",
                "title": "Notify Errors (DLQ)",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 80,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "job-archive-api-${var.service_environment}-warmup", "Resource", "job-archive-api-${var.service_environment}-warmup", { "stat": "Sum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Warmup Invocations",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 80,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "job-archive-api-${var.service_environment}-warmup", "Resource", "job-archive-api-${var.service_environment}-warmup", { "stat": "Minimum", "period": 900 } ],
                    [ "...", { "stat": "Average", "period": 900 } ],
                    [ "...", { "stat": "Maximum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Warmup Duration",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 80,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "job-archive-api-${var.service_environment}-warmup", "Resource", "job-archive-api-${var.service_environment}-warmup", { "id": "errors", "stat": "Sum", "color": "#d62728" } ],
                    [ ".", "Invocations", ".", ".", ".", ".", { "id": "invocations", "stat": "Sum", "visible": false } ],
                    [ { "expression": "100 - 100 * errors / invocations", "label": "Success rate (%)", "id": "availability", "yAxis": "right" } ]
                ],
                "region": "us-east-1",
                "title": "Warmup Error count and success rate (%)",
                "yAxis": {
                    "right": {
                        "max": 100,
                        "showUnits": false,
                        "label": "Rate %"
                    },
                    "left": {
                        "showUnits": false,
                        "label": "Error Count"
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 62,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "job-archive-api-${var.service_environment}-task", "Resource", "job-archive-api-${var.service_environment}-task", { "stat": "Sum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Task Invocations",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 62,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "job-archive-api-${var.service_environment}-task", "Resource", "job-archive-api-${var.service_environment}-task", { "stat": "Minimum", "period": 900 } ],
                    [ "...", { "stat": "Average", "period": 900 } ],
                    [ "...", { "stat": "Maximum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Task Duration",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 62,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "job-archive-api-${var.service_environment}-task", "Resource", "job-archive-api-${var.service_environment}-task", { "id": "errors", "stat": "Sum", "color": "#d62728", "period": 900 } ],
                    [ ".", "Invocations", ".", ".", ".", ".", { "id": "invocations", "stat": "Sum", "visible": false, "period": 900 } ],
                    [ { "expression": "100 - 100 * errors / invocations", "label": "Success rate (%)", "id": "availability", "yAxis": "right", "period": 900 } ]
                ],
                "region": "us-east-1",
                "title": "Task Error count and success rate (%)",
                "yAxis": {
                    "right": {
                        "max": 100,
                        "showUnits": false,
                        "label": "Rate %"
                    },
                    "left": {
                        "label": "Error Count",
                        "showUnits": false
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 68,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "job-archive-api-${var.service_environment}-metadata", "Resource", "job-archive-api-${var.service_environment}-metadata", { "stat": "Sum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Metadata Invocations",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 68,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "job-archive-api-${var.service_environment}-metadata", "Resource", "job-archive-api-${var.service_environment}-metadata", { "stat": "Minimum", "period": 900 } ],
                    [ "...", { "stat": "Average", "period": 900 } ],
                    [ "...", { "stat": "Maximum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Metadata Duration",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 68,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "job-archive-api-${var.service_environment}-metadata", "Resource", "job-archive-api-${var.service_environment}-metadata", { "id": "errors", "stat": "Sum", "color": "#d62728" } ],
                    [ ".", "Invocations", ".", ".", ".", ".", { "id": "invocations", "stat": "Sum", "visible": false } ],
                    [ { "expression": "100 - 100 * errors / invocations", "label": "Success rate (%)", "id": "availability", "yAxis": "right" } ]
                ],
                "region": "us-east-1",
                "title": "Metadata Error count and success rate (%)",
                "yAxis": {
                    "right": {
                        "max": 100,
                        "showUnits": false,
                        "label": "Rate %"
                    },
                    "left": {
                        "showUnits": false,
                        "label": "Error Count"
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 74,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "job-archive-api-${var.service_environment}-artifacts", "Resource", "job-archive-api-${var.service_environment}-artifacts", { "stat": "Sum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Artifacts Invocations",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 74,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Duration", "FunctionName", "job-archive-api-${var.service_environment}-artifacts", "Resource", "job-archive-api-${var.service_environment}-artifacts", { "stat": "Minimum", "period": 900 } ],
                    [ "...", { "stat": "Average", "period": 900 } ],
                    [ "...", { "stat": "Maximum", "period": 900 } ]
                ],
                "region": "us-east-1",
                "view": "timeSeries",
                "stacked": false,
                "title": "Artifacts Duration",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 74,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Errors", "FunctionName", "job-archive-api-${var.service_environment}-artifacts", "Resource", "job-archive-api-${var.service_environment}-artifacts", { "id": "errors", "stat": "Sum", "period": 900, "color": "#d62728" } ],
                    [ ".", "Invocations", ".", ".", ".", ".", { "id": "invocations", "stat": "Sum", "visible": false, "period": 900 } ],
                    [ { "expression": "100 - 100 * errors / invocations", "label": "Success rate (%)", "id": "availability", "yAxis": "right", "period": 900 } ]
                ],
                "region": "us-east-1",
                "title": "Artifacts Error count and success rate (%)",
                "yAxis": {
                    "right": {
                        "max": 100,
                        "label": "Rate %",
                        "showUnits": false
                    },
                    "left": {
                        "showUnits": false,
                        "label": "Error Count"
                    }
                },
                "view": "timeSeries",
                "stacked": false,
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 12,
            "y": 55,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "4XXError", "ApiName", "${var.service_environment}-job-archive-api", { "period": 900, "stat": "Sum", "id": "m1", "color": "#d62728" } ],
                    [ ".", "Count", ".", ".", { "period": 900, "stat": "Sum", "id": "m2", "color": "#ff7f0e", "visible": false } ],
                    [ { "expression": "100 - 100 * m1 / m2", "label": "Success Rate", "id": "e1", "yAxis": "right", "color": "#2ca02c", "period": 900, "stat": "Sum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "period": 300,
                "yAxis": {
                    "left": {
                        "showUnits": false,
                        "label": "Error Count"
                    },
                    "right": {
                        "showUnits": false,
                        "label": "Rate %"
                    }
                },
                "title": "API Gateway 4XX Error Rate"
            }
        },
        {
            "type": "metric",
            "x": 18,
            "y": 55,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "5XXError", "ApiName", "${var.service_environment}-job-archive-api", { "period": 900, "stat": "Sum", "id": "m2", "color": "#d62728" } ],
                    [ ".", "Count", ".", ".", { "period": 900, "stat": "Sum", "id": "m1", "color": "#ff7f0e", "visible": false } ],
                    [ { "expression": "100 - 100 * m2 / m1", "label": "Success Rate", "id": "e1", "yAxis": "right", "color": "#2ca02c", "period": 900, "stat": "Sum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "period": 300,
                "yAxis": {
                    "left": {
                        "showUnits": false,
                        "label": "Error Count"
                    },
                    "right": {
                        "showUnits": false,
                        "label": "Rate %"
                    }
                },
                "title": "API Gateway 5XX Error Rate"
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 55,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "Latency", "ApiName", "${var.service_environment}-job-archive-api", { "period": 900, "stat": "Average" } ],
                    [ ".", "IntegrationLatency", ".", ".", { "period": 900, "stat": "Average" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "title": "API Gateway Latency (avg)",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 55,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/ApiGateway", "Count", "ApiName", "${var.service_environment}-job-archive-api", { "stat": "Sum", "period": 900 } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "us-east-1",
                "title": "API Gateway Requests Count"
            }
        },
        {
            "type": "text",
            "x": 0,
            "y": 61,
            "width": 24,
            "height": 1,
            "properties": {
                "markdown": "\n### API Lambdas\n"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 26,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/S3", "BucketSizeBytes", "StorageType", "StandardStorage", "BucketName", "buildarchive-${local.legacy_environment}-artifacts", { "period": 604800, "stat": "Maximum" } ],
                    [ ".", "NumberOfObjects", ".", "AllStorageTypes", ".", ".", { "period": 604800, "stat": "Maximum" } ]
                ],
                "view": "singleValue",
                "stacked": false,
                "region": "us-east-1",
                "title": "Artifacts Storage: buildarchive-${local.legacy_environment}-artifacts",
                "period": 300
            }
        }
    ]
}
 EOF
}
