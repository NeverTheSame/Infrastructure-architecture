 **Table of content:**
 - [Task statement](#item-two)
 - [Requirements](#item-three)
 - [Project Overview](#item-five)
 - [Architectural Design](#item-six)
 - [Microservices architecture](#item-seven)
 - [Choice of EKS](#item-ten)
 - [CI/CD for microservices architecture](#item-eight)
 - [Developer's journey](#item-nine)

# Infrastructure architecture assessment
<a id="item-two"></a>
## Task statement
The application is a complex system developed and maintained as a cloud-native application and offered as a service (imagine building AWS's RDS service).
Provide an infrastructure architecture that would be the most suitable for running a development and production environment to fulfill the following requirements.
- The application is multitenant and multiple customers access the same application instance
- There are thousands of customers
- The code needs to be versioned
- Developers need many dependencies and configure complex tool changes to build and develop
- Dependencies are constantly updated due to the need to tackle security vulnerabilities
- The most common development language for the backend is C/C++
- The most common development languages for the front end are JavaScript/React
- ~50 developers commit a change to production once every week, but at least one commit per developer is expected every day
- The frontend and backend solutions have a test bed that runs with each build
- Longevity and stress tests are run once every week
- Software developers run on different Windows and MacOSX operating systems
- The team needs to deploy their frontend and backend solutions at different cycles
- The team only keeps their software solution's current and previous versions (for reverts)
- The team needs to produce software updates without disrupting the service
- The team needs to maintain a 99.99% uptime SLA

<a id="item-three"></a>
## Requirements
Design an infrastructure architecture that meets the requirements for cloud-native application.

1. **Multi-Tenancy**:
    - Implement a multi-tenant architecture where multiple customers share the same application instance.
    - Each tenant's data and activities must be isolated to ensure privacy and security.
    - Consider different levels of isolation based on the sensitivity of the data and the type of market (e.g., business-to-consumer vs. business-to-business).
    - Use separate databases for each tenant to maintain data separation.

2. **Scalability for Thousands of Customers**:
    - Use cloud services that can scale horizontally ("scale out") to accommodate thousands of customers.
    - Use microservices architecture to handle varying workloads.
    - Distribute tenants across multiple availability zones for high availability.

3. **Version Control and Dependencies**:
    - Use a Git version control system for managing code versions.
    - Set up a CI/CD pipeline to automate builds, tests, and deployments.
    - Containerize dependencies (e.g., Docker) to ensure consistent development environments.
    - Use package managers (e.g., npm, pip) for managing language-specific dependencies.

4. **Backend and Frontend Development**:
    - For both frontend (JavaScript/React) and backend (C/C++), consider containerized microservices orchestrated by Kubernetes.
    </BR> Reason for **choosing over serverless functions**: 
       - Resource Management: Kubernetes can scale in three dimensions — increasing the number of pods, pod size, and nodes in the cluster. Serverless functions can only have memory defined. 
       - Predictable Workloads: Containers are great for predictable workloads, heavy traffic, high compute-intensive, and long batch running applications.

5. **Developer Workflow**:
    - Provide development environments that match production as closely as possible.
    - Use Terraform to define and manage resources.
    </BR> To run a development and production environment, use separate `.tfvars` files: [**TF/dev.tfvars**](/TF/dev.tfvars) and [**TF/prod.tfvars**](TF/prod.tfvars)
    - Support both Windows and MacOSX development environments.

6. **Deployment Strategies**:
    - Implement blue-green deployments or canary releases to minimize service disruption.
    </BR> To implement blue-green deployment `.tfvars` files for environment-specific variables: [**TF/blue.tfvars**](TF/blue.tfvars) / [**TF/green.tfvars**](TF/green.tfvars). Source: [Use Application Load Balancers for blue-green and canary deployments](https://developer.hashicorp.com/terraform/tutorials/aws/blue-green-canary-tests-deployments)
    - Separate frontend and backend deployments to allow independent scaling and updates.

7. **Version Management**:
    - Keep track of current and previous software versions.
    </BR> Can be achieved by using Terraform module versioning: specify which version of a module to use in configuration. For example, specify a particular version of a module in Terraform configuration:
        ```
        module "ecs-service" {
            source = "github.com/dev-app/eks?ref=v1"
        }
        ```
    - Use version tags in Git for easy rollback.
    - Automate version management in CI/CD pipeline.
    - Keep Terraform's state in S3 to maintain a history of changes: [**TF/backend.tf**](TF/backend.tf)

8. **High Availability and Uptime**:
    - Deploy across multiple availability zones or regions.
    - Use load balancers and failover mechanisms.
    - Monitor and alert on SLA violations.

9. **Security and Compliance**:
    - Encrypt data at rest and in transit.
    - Implement access controls and authentication.
    - Adhere to industry-specific compliance requirements (e.g., HIPAA, GDPR).

10. **Testing and Monitoring**:
    - Integrate automated testing into the CI/CD pipeline.
    - Run longevity and stress tests regularly.
    - Monitor application performance, logs, and metrics.

## Design document 
<a id="item-five"></a>
### Project Overview
1. **Project Overview**:
   - The project aims to develop and maintain a cloud-native application offered as a service.
   - It involves both frontend (JavaScript/React) and backend (C/C++) components.
   - The application serves multiple tenants (customers) who share the same instance.
   - The infrastructure must meet high availability and uptime requirements.

2. **Project Scope**:
   - The scope includes designing, implementing, and managing the entire cloud-native ecosystem.
   - It covers development, testing, deployment, monitoring, and maintenance.
   - The project focuses on scalability, security, and efficient resource utilization.

3. **Objectives**:
   - Develop a robust, scalable, and secure cloud-native application.
   - Enable efficient version control and dependency management.
   - Implement CI/CD pipelines for automated builds and deployments.
   - Ensure compatibility with both Windows and MacOSX development environments.
   - Achieve a 99.99% uptime SLA.
   - Support continuous updates without service disruption.

4. **Stakeholders**:
   - **Development Team**: Includes backend and frontend developers, DevOps engineers, and testers.
   - **Customers (Tenants)**: Users of the application who belong to different organizations.
   - **Operations Team**: Responsible for maintaining the production environment.
   - **Management and Business Owners**: Interested in meeting SLAs and business goals.

<a id="item-six"></a>
### Architectural Design
**1. Infrastructure Overview**:
- **Cloud Provider**: Use **Amazon Web Services (AWS)** as the cloud provider.
- **Terraform**: Leverage Terraform for infrastructure provisioning and management.
- **Kubernetes**: Container orchestration / dependency management.
- **Components**:
    - **Database**: RDS for PostgreSQL: [**TF/db.tf**](TF/db.tf)
    - **Storage**: S3 for object storage [**TF/s3.tf**](TF/s3.tf)
    - **Networking**: VPC, subnets, security groups, and route tables.
    - **Monitoring and Logging**: CloudWatch for metrics and logs.
    - **Deployment**: GitHub actions for CI/CD pipelines.

**2. Workload Classification**:
- **Frontend**:
    - Host the frontend (JavaScript/React) on S3 or use CloudFront for content delivery.
    - Use Lambda@Edge for serverless processing at the edge.
- **Backend**:
    - Containerize backend services (C/C++) using Docker.
    - Deploy containers on ECS for orchestration.
    - Implement autoscaling based on workload. 
    </BR> Use Horizontal Pod Autoscaler (HPA) to manage workload. The HPA controller monitors the workload’s pods to determine if it needs to change the number of pod replicas: [**K8S/horizontal-pod-autoscaler.yaml**](K8S/horizontal-pod-autoscaler.yaml)

**3. Network Design**:
- **Virtual Private Cloud (VPC)**:
    - Create a VPC with public and private subnets: [**TF/networking.tf**](TF/networking.tf)
    - Place frontend resources in public subnets. 
       - When creating frontend resources, specify the newly created public subnet as their subnet. This ensures that frontend resources are accessible from the internet.
    - Backend services and databases in private subnets.
- **Security Groups and Network ACLs**:
    - Define security groups to control inbound/outbound traffic:[**TF/security.tf**](TF/security.tf)
    - Alternatively, use network ACLs for subnet-level access control.
       - It will add some complexity to the design because network ACLs (NACLs) are used on the subnet-level access control level instead of security groups.
- **Route Tables**:
    - Route traffic between subnets and to the internet: [**TF/route_tables.tf**](TF/route_tables.tf)
    - Use NAT gateways for private subnet internet access.
- **Load Balancers**:
    - Set up Application Load Balancers (ALB) for frontend: [**TF/load_balancers.tf**](TF/load_balancers.tf)
    - Network Load Balancers (NLB) for backend services.

### **4. Security Considerations**:
- **Identity and Access Management (IAM)**:
    - Use IAM roles and policies for fine-grained access control: [**security.md**](security.md)
    - Least privilege principle for permissions.
- **Encryption**:
    - Enable encryption at rest (S3, RDS) using KMS: [**TF/s3.tf**](TF/s3.tf), *storage_encrypted* in [**TF/db.tf**](TF/db.tf)
    - Use SSL/TLS for data in transit.
       - In TF, often defined by a parameter such as `require_secure_transport`
       - Alternatively, can be achieved with a different TF provider: [tls](https://registry.terraform.io/providers/hashicorp/tls/latest/docs): [**TF/tls.tf**](TF/tls.tf)
- **Secrets Management**:
    - Store sensitive information (database credentials, API keys) in AWS Secrets Manager: [**TF/secrets.tf**](TF/secrets.tf)
- **Monitoring and Auditing**:
    - Set up CloudTrail for auditing API calls: [**TF/monitoring.tf**](TF/monitoring.tf)
    - Monitor security groups, VPC flow logs, and CloudWatch alarms.
- **DDoS Protection**:
    - Use AWS Shield for DDoS protection
       - Implemented in CloudFront distributions and Route53 health checks: [**TF/ddos.tf**](TF/ddos.tf)
    - Configure WAF (Web Application Firewall) for frontend protection: *aws_wafv2_web_acl* in [**TF/security.tf**](TF/security.tf)
- **Backup and Disaster Recovery**:
    - Regularly back up RDS database: *aws_db_instance/backup_retention_period* in [**TF/db.tf**](TF/db.tf)
       - To avoid destroying the database after each apply, use the lifecycle argument with ignore_changes to ignore changes to the snapshot_identifier.
    - Implement automated snapshots and cross-region replication: [**TF/backup.tf**](TF/backup.tf)
    - Test disaster recovery procedures.
      -  **Test Many Scenarios**: It's important to test a variety of disaster scenarios, including equipment failures, user errors, and natural disasters.
      -  **Regular Testing**: Regular testing helps identify any flaws or changes that might affect the disaster recovery plan.
      -  **Document Everything**: Keep detailed records of all tests, including what was tested, how it was tested, and the results.
      -  **Keep Everyone Updated**: Make sure all relevant stakeholders are aware of the testing process and results.
      -  **Define Metrics**: Establish clear metrics for evaluating the success of the disaster recovery plan.

### **5. Managing dependencies**:
1. **Version Control System (VCS)**: Use `Git` for managing codebase. This allows developers to work on different features simultaneously without interfering with each other's work. It also provides a history of changes, making it easier to track and revert changes if necessary.
2. **Package Managers**: Allows to specify the versions of the libraries project depends on, and they can automatically install and update these libraries.
   - Use `npm` for JavaScript/React and a suitable package manager. Reason: high adoptability, ease of use, large support.
   - Use `Conan` for C/C++ to manage dependencies. Reason: open-source, good documentation.
3. **Automated Dependency Updates**: Use `Dependabot` to automatically create pull requests to update dependencies. Reasons:
    - Dependency Alerts: alert developers when a repository is using a software dependency with a known vulnerability.
    - Security Updates: Automatically raise pull requests to update the dependencies you use that have known security vulnerabilities.
    - Version Updates: automatically raise pull requests to keep your dependencies up-to-date.
4. **Continuous Integration/Continuous Deployment (CI/CD)**: Use `GitHub Actions` to automate the process of building, testing, and deploying application. [**.github/workflows/node-tests.yaml**](.github/workflows/node-tests.yaml) checks out the code, sets up Node.js, installs the dependencies, and runs the tests.
5. **Automated Testing**: Include unit tests, integration tests, and end-to-end tests. Tools like Jest for JavaScript or Google Test for C++ can be used for unit testing. Selenium or Puppeteer can be used for end-to-end testing.

<a id="item-seven"></a>
### **6. Microservices architecture**:
Decision is to not use a monolithic architecture and instead use a **microservices** architecture. 

#### Pros
- **Scalability**: Microservices can be scaled independently (satisfying the "There are thousands of customers" requirement).
  - It also satisfies the requirement of "~50 developers commit a change to production once every week, but at least one commit per developer is expected every day" because it allows the development process to look as described below. See [Developer's journey](#item-nine).
- **Technology Diversity**: Microservices can be written in different languages and use different technologies. This satisfies the requirement of the different language used for the backend (C/C++) and languages for the front (JavaScript/React).
- **Possibility of rolling update in Kubernetes** to achieve a 99.99% uptime SLA
  - K8S deployment strategy that allows to update application gradually, with zero downtime. Rather than deploying the new version all at once, a rolling update replaces the old version with the new version incrementally. This approach minimizes downtime and ensures that application is always available during the update process.
  - Consists of the following phases: 
    - Update Initiation - when a new version of application is deployed Kubernetes starts creating new pods with the updated configuration.
    - Incremental Replacement - gradually replace old pods with these new ones
    - Health Checks - monitor the health of the new pods.
    - Rollback - can roll back to return to the previous version of application.
- **Loose coupling** / **Isolation**: Microservices can be developed, deployed, and scaled independently. This satisfies the requirement of the team needs to deploy their frontend and backend solutions at different cycles. E.g. if a frontend container needs to be scaled (unexpected users' visits spike), it can be done without affecting the backend containers.
- **Shorted release cycle**: for effective continuous delivery and deployment.

#### Cons
1. Added complexity - microservices application is a distributed system.
2. More difficult to monitor with multiple instances of each service distributed across servers.
3. More difficult to test.

<a id="item-ten"></a>
#### Choice of EKS
To achieve true cloud-native application architecture, decision is to use EKS (Elastic Kubernetes Service) as a container orchestration tool. Reasons:
- **EKS is a managed service** - AWS manages the Kubernetes control plane, which makes it easier to set up and maintain Kubernetes clusters.
- **EKS is highly available** - EKS runs across multiple availability zones, which ensures high availability.

</BR>**To provision EKS** cluster, decision is to use Terraform. Reason:
- Hashicorp maintains an [official documentation about deploying EKS with Terraform](https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks).
- See [**TF/eks.tf**](TF/eks.tf)


<a id="item-eight"></a>
### CI/CD for microservices architecture
Decision is to use **polyrepo** (separate Git projects) opposed to monorepo. 
#### Polyrepo pros
- **Easier to manage** - each microservice has its own repository, which makes it easier to manage and update.
- **Less source code to download** - developers only need to download the code for the microservice they are working on.
- **One pipeline for one project** - each microservice has its own pipeline, which makes it easier to manage and update.
- **Less chance for a downtime** - if a developer makes a mistake and breaks the build, it will only affect the microservice they are working on. The rest of the application will continue to work.

#### Cons
1. Switching between projects is tedious
2. Searching, testing and debugging is more difficult
3. Sharing resources more difficult

<a id="item-nine"></a>
## Developer's journey
1. **Local Development**: Developer:
   - works on their code locally: [**Code/dev-app.py**](Code/dev-app.py)
   - makes changes to their respective microservices. 
   - tests their changes locally using Docker (to replicate the production environment on local machine): [**Code/Dockerfile**](Code/Dockerfile)
   - **Outcome:** Docker image of their service that can be run locally to see if it works as expected: [**Code/test-docker-app.sh**](Code/test-docker-app.sh)
2. **Code Commit**: Once the developer is satisfied with changes, they:
   - commit the code to Git (`git add .` and `git commit -m "message"`)
   - (automatically) trigger the CI/CD pipeline whenever file is commited to `main` branch 
   </BR>**Note:** In real-world scenario, developers team can use different git approaches, such as `feature branch workflow` (separate branch for feature) or `gitflow workflow` (main, development, feature, release, etc.)
   - have pipeline configured to automatically build Docker images for each service whenever code is pushed to the repository: [**.github/workflows/docker-build.yaml**](.github/workflows/docker-build.yaml)
3. **Continuous Integration**: The CI/CD pipeline pulls the latest code from the Git after all the tests pass. The image then is pushed to a Docker registry: `docker push dev-image:latest`
4. **Continuous Deployment**: Once the Docker images are in the registry, deploy to a Kubernetes cluster. Kubernetes pulls the images from the registry and runs them as containers. Use Kubernetes deployment to manage services and ensure that there are 3 replicas are always running.
    - Create a Kubernetes deployment: [**K8S/deployment.yaml**](K8S/deployment.yaml)
    - Create a Kubernetes service for each deployment: [**K8S/service.yaml**](K8S/service.yaml)
    - Make sure kubectl is configured to connect to EKS cluster: `aws eks update-kubeconfig --region us-west-2 --name dev-cluster`
    - Apply the deployment and service to the Kubernetes cluster. For example, `kubectl apply -f deployment.yaml` and `kubectl apply -f service.yaml`
    - Kubernetes pulls the Docker image from the registry and starts the specified number of replicas.
5. **Rolling Updates & Rollbacks**: To deploy a new version of a service without downtime and easily rollback to a previous version in case of an error, update the Docker image in the Kubernetes deployment and apply it to the cluster. Kubernetes will gradually replace the old replicas with new ones.
6. **Monitoring & Logging**: 
   1. Once service is running use Terraform [eks-monitoring-logging module](https://registry.terraform.io/modules/shamimice03/eks-monitoring-logging/aws/latest) to send EKS logs to CloudWatch: [**TF/monitoring.tf**](TF/monitoring.tf)
   2. Once logs are in Cloudwatch, create alarms to monitor the application's performance and to catch any issues. If a problem is detected, it can be quickly addressed and a new version of the application can be deployed: [**TF/monitoring.tf**](TF/monitoring.tf) → aws_cloudwatch_metric_alarm.eks-alarm**
   3. In addition to that, to achieve 99.99% uptime SLA, implement readiness probe in Kubernetes to determine when a container is ready to start accepting traffic. A Pod is considered ready when all of its containers are ready: [**K8S/readiness-pod.yaml**](K8S/readiness-pod.yaml)

## Helpful links
- [Approaches to implementing multi-tenancy in SaaS applications](https://developers.redhat.com/articles/2022/05/09/approaches-implementing-multi-tenancy-saas-applications)
- [5 principles for cloud-native architecture—what it is Google Cloud](https://cloud.google.com/blog/products/application-development/5-principles-for-cloud-native-architecture-what-it-is-and-how-to-master-it)
- [Cloud-Native Architecture](https://www.geeksforgeeks.org/cloud-native-architecture/)
- [What is multitenancy? | Multitenant architecture | Cloudflare](https://www.cloudflare.com/learning/cloud/what-is-multitenancy/)