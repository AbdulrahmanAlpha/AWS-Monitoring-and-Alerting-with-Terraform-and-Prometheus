## Introduction
In this project, we will be setting up a monitoring and alerting system on AWS using Terraform and Prometheus. We will create an EC2 instance to host Prometheus, install Prometheus on the instance, and configure Prometheus to collect metrics from our AWS infrastructure. We will also set up alerts in Prometheus to notify us when certain conditions are met, such as high CPU usage.

## Prerequisites

Before we get started, you will need to have the following:

- An AWS account
- An AWS access key and secret key with appropriate permissions to create resources
- Terraform installed on your local machine
- An SSH key pair for accessing the EC2 instance

## Step 1: Create an EC2 instance

The first step is to create an EC2 instance to host Prometheus. We will use Terraform to create the instance. 

1. Create a new directory for the project.

```
mkdir prometheus-aws
cd prometheus-aws
```

2. Create a new file named `main.tf` in the directory and add the following code:

```terraform
provider "aws" {
  region = "us-west-2"
}

resource "aws_security_group" "prometheus" {
  name_prefix = "prometheus-"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ssh_access" {
  name_prefix = "prometheus-ssh-"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "prometheus" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  key_name      = "my-keypair"
  security_groups = [
    aws_security_group.prometheus.name,
    aws_security_group.ssh_access.name,
  ]

  tags = {
    Name = "prometheus-instance"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/my-keypair.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "wget https://github.com/prometheus/prometheus/releases/download/v2.33.1/prometheus-2.33.1.linux-amd64.tar.gz",
      "tar xfz prometheus-2.33.1.linux-amd64.tar.gz",
      "cd prometheus-2.33.1.linux-amd64/",
      "./prometheus --config.file=prometheus.yml &",
    ]
  }
}
```

3. Replace the `region`, `ami`, `key_name`, and `private_key` values with your own values.

4. Run `terraform init` to initialize the project.

5. Run `terraform apply` to create the EC2 instance. This will take a few minutes.

## Step 2: Install Prometheus

Now that we have an EC2 instance, we can install Prometheus on it. We will use SSH to connect to the instance and run the installation commands.

1. Connect to the EC2 instance using SSH.

```
ssh -i ~/.ssh/my-keypair.pem ubuntu@<instance-public-ip>
```

2. Once you're connected, run the following commands to install Prometheus:

```
wget https://github.com/prometheus/prometheus/releases/download/v2.33.1/prometheus-2.33.1.linux-amd64.tar.gz
tar xfz prometheus-2.33.1.linux-amd64.tar.gz
cd prometheus-2.33.1.linux-amd64/
./prometheus --config.file=prometheus.yml &
```

This will download and extract the Prometheus binaries, and start Prometheus using the default configuration file.

## Step 3: Configure Prometheus to collect metrics

Now that Prometheus is installed, we need to configure it tocollect metrics from our AWS infrastructure. We will use AWS CloudWatch as a data source for metrics.

1. In the AWS Management Console, navigate to CloudWatch and select "Metrics" from the left-hand menu.

2. Select the metrics you want to collect, such as CPU usage and network traffic, and choose "Create Alarm".

3. Configure the alarm to trigger when the metric exceeds a certain threshold, such as when CPU usage is above 80%.

4. In the "Actions" section, choose "Send notification to" and select an SNS topic to receive the alert.

5. Save the alarm and repeat for any additional metrics you want to monitor.

6. In the Prometheus configuration file (`prometheus.yml`), add the CloudWatch endpoint as a target for metrics scraping:

```yaml
scrape_configs:
  - job_name: 'cloudwatch'
    scrape_interval: 15s
    metrics_path: '/cloudwatch'
    static_configs:
      - targets: ['<cloudwatch-endpoint>']
```

Replace `<cloudwatch-endpoint>` with the endpoint URL for your CloudWatch instance.

7. Restart Prometheus for the new configuration to take effect.

## Step 4: Set up alerts in Prometheus

Now that we have metrics being collected in Prometheus, we can set up alerts to notify us when certain conditions are met. We will use the Prometheus alerting rules to define the conditions for triggering an alert.

1. In the Prometheus configuration file, add the alerting rules:

```yaml
rule_files:
  - /etc/prometheus/alert.rules

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - localhost:9093
```

2. Create a new file named `alert.rules` in the `/etc/prometheus` directory and add the following rule:

```yaml
groups:
- name: example
  rules:
  - alert: HighCPUUsage
    expr: node_cpu_seconds_total{mode="idle"} < 100
    for: 1m
    labels:
      severity: critical
    annotations:
      summary: "High CPU usage detected"
      description: "CPU usage is above 80% for 1 minute"
```

This rule will trigger an alert when the CPU usage is above 80% for 1 minute.

3. Restart Prometheus for the new rules to take effect.

4. Set up an alert manager to receive and handle alerts. You can use a tool like Alertmanager or PagerDuty for this.

## Conclusion

Congratulations! You have now set up a monitoring and alerting system on AWS using Terraform and Prometheus. You can now monitor your AWS infrastructure and receive alerts when problems arise. This system can be extended by adding more metrics, rules, and integrations to fit your use case.