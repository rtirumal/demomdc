# Simple Queuing Service (SQS) Queue

This Terraform Module creates Amazon's [Simple Queuing Service (SQS) Queue)](https://aws.amazon.com/sqs/). The
resources managed by these templates are:

* An SQS Queue, which can be used for managing messages/notifications between different software components.
  
## About SQS Queues

#### How do SQS Queues work?

Amazon Simple Queue Service (SQS) is a fully managed message queuing service that enables you to decouple and scale microservices, distributed systems, and serverless applications. SQS eliminates the complexity and overhead associated with managing and operating message oriented middleware, and empowers developers to focus on differentiating work. Using SQS, you can send, store, and receive messages between software components at any volume, without losing messages or requiring other services to be available. Get started with SQS in minutes using the AWS console, Command Line Interface or SDK of your choice, and three simple commands.

SQS offers two types of message queues. Standard queues offer maximum throughput, best-effort ordering, and at-least-once delivery. SQS FIFO queues are designed to guarantee that messages are processed exactly once, in the exact order that they are sent.

#### How can I manage Messages from the SQS Queue I created?

Please refer to the [SQS
Console](https://console.aws.amazon.com/sqs/home?region=us-east-1) for more details on how the Queue was created and what options are available. You can send, poll and delete messages from the Queue, or subscribe to an Amazon SNS Topic. Available options are under **Queue Actions** menu.
You can also review the [API Reference for Amazon SQS](https://docs.aws.amazon.com/AWSSimpleQueueService/latest/APIReference/Welcome.html) for development purposes. AWS SDK exposes several API endpoints for managing Messages in SQS.

## Variables


| Variable Name | Variable Type | Supported Values | Default Value | Purpose |
| --- | ---| --- | --- | --- |
| `aws_region` | String | Alphanumeric | N/A | The AWS region in which all resources will be created |
| `aws_account_id` | String | Alphanumeric | N/A | The ID of the AWS Account in which to create resources. |
| `name` | String | Alphanumeric | N/A | The friendly name of the SQS Queue |
|`visibility_timeout_seconds` | Numeric | 0 - 43200 | 30 | The visibility timeout for the queue, in seconds |
| `message_retention_seconds` | Numeric | 60 - 1209600 | 345600 | The number of seconds Amazon SQS retains a message |
| `max_message_size` | Numeric | 1024 - 262144 |  262144| limit of how many bytes a message can contain before Amazon SQS rejects it |
| `delay_seconds` | Numeric | 0 - 900 | 0 | The time in seconds that the delivery of all messages in the queue will be delayed |
| `receive_wait_time_seconds` | Numeric |  0 - 20 | 0 | The time in seconds for which a ReceiveMessage call will wait for a message to arrive (long polling) before returning |
| `fifo_queue` | Boolean |  true, false |  false | Boolean designating a FIFO queue |
| `dead_letter_queue` | Boolean | true, false | false | Set to true to enable a dead letter queue. Messages that cannot be processed/consumed successfully will be sent to a second queue so you can set aside these messages and analyze what went wrong.|
| `custom_tags` | Map | Alphanumeric | N/A | Optional mapping of tags to assign to the SQS Queue |
