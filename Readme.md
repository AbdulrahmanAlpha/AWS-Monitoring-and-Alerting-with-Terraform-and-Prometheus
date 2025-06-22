# ⚙️ AWS Monitoring and Alerting with Terraform & Prometheus

This project provisions a Prometheus-based monitoring setup on AWS using **Terraform**. It deploys an EC2 instance, installs Prometheus, and sets up basic alerting rules, enabling you to monitor infrastructure metrics, such as CPU usage, in real-time.

---

## 📌 Features

✅ Provision EC2 instance with Prometheus installed  
✅ Open security group access to Prometheus UI (port 9090) and SSH (port 22)  
✅ Install Prometheus via `remote-exec` and custom shell script  
✅ Prometheus auto-discovers EC2 instances using `ec2_sd_configs`  
✅ Custom alert rules (e.g., high CPU usage)  
✅ Infrastructure as Code with **Terraform**

---

## 🧱 Architecture Overview

```

+------------------------------+
\|      AWS EC2 Instance       |
\|    Ubuntu + Prometheus      |
\|  ────────────────           |
\|  🔸 Prometheus UI (9090)     |
\|  🔸 Prometheus.yml config    |
\|  🔸 Alerts.rules             |
+------------------------------+


    ↓ Terraform


+------------------------------+
\|   AWS Infrastructure Setup   |
\|  - EC2 + Security Groups     |
\|  - Key Pair for SSH          |
\|  - User Data Provisioning    |
+------------------------------+

````

---

## 🧾 Files Overview

| File                          | Description                                   |
|-------------------------------|-----------------------------------------------|
| `main.tf`                    | Terraform config for EC2 + Security Groups     |
| `prometheus-installation.sh` | Bash script to download & run Prometheus       |
| `prometheus.yml`             | Prometheus config: scrape targets, alerts      |
| `alerts.rules`               | Prometheus alert rules (e.g., High CPU usage)   |

---

## 🧰 Prerequisites

- AWS account with Access Key / Secret Key
- Terraform ≥ 1.0.0
- SSH Key pair created in AWS (`my-keypair.pem`)
- Security group rules allow ports `22` and `9090`
- Replace access credentials in `prometheus.yml` (or use IAM roles in production)

---

## 🚀 How to Deploy

### 1. Update Configuration

Make sure to update:
- `access_key` and `secret_key` in `prometheus.yml`  
- Key pair name in `main.tf`  
- Path to your `.pem` file in `main.tf`

---

### 2. Initialize Terraform

```bash
terraform init
````

---

### 3. Plan and Apply

```bash
terraform plan
terraform apply
```

---

### 4. Access Prometheus UI

Once the EC2 instance is deployed, visit:

```
http://<EC2-PUBLIC-IP>:9090
```

You can find the EC2 IP in the Terraform output or AWS Console.

---

## 🔔 Example Alert Rule (CPU Usage)

```yaml
groups:
  - name: cpu_alerts
    rules:
      - alert: HighCpuUsage
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"
          description: "{{ $labels.instance }} has high CPU usage ({{ $value }}%)"
```

---

## 🧪 How to Test

* Use `stress` command (install manually) to simulate high CPU:

```bash
sudo apt install stress
stress --cpu 2 --timeout 300
```

* Check the Prometheus Alerts tab to verify the `HighCpuUsage` alert triggers.

---

## 📦 Cleaning Up

```bash
terraform destroy
```

---

## 🙋‍♂️ Author

Made with ❤️ by **Abdulrahman A. Muhamad**
🔗 GitHub: [@AbdulrahmanAlpha](https://github.com/AbdulrahmanAlpha)
🔗 LinkedIn: [/in/abdulrahmanalpha](https://linkedin.com/in/abdulrahmanalpha)

---

## 📚 Resources

* [Prometheus Docs](https://prometheus.io/docs/introduction/overview/)
* [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
* [EC2 SD Config in Prometheus](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#ec2_sd_config)
