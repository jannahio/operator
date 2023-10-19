Jannah.io September 2023
- Speaker: Osman Jalloh
- Role: Software Architect at Jannah.io
- www.jannah.io: A lab (laboratory) for developing cloud native software solutions.
- Series: Software DevOps with Artificial Intelligence, Automation, and Blockchain
- Episode: The Software Developer Environment
- Github Repository: https://github.com/alchemiccoruja
- Intended Audience:
    - Business Developers
    - Venture Capitalists
    - Upcoming Developers, (Frontend, Backend, devOps, Security, Data Scientists, Blockchain Enthusiasts)
    - Experienced Developers, (Frontend, Backend, devOps, Security, Data Scientists, Blockchain Enthusiasts)


Recap:
In our previous (introductory) video, we invited you to join us on a journey.
- A journey into software development, and the business of data:
    - Software enginneering.
    - Data science.
    - Machine learning.
    - Block chain.
- Find our video series on Youtube at @Jannah_io
    - Playlist at:
        - https://youtube.com/playlist?list=PLalaYX-k2k3Ml625P-XFDcS3dAujrmaq4&si=z2ZKMZk4MaPp6_X5
- Where are we on this marvelous journey?
    - Moving on from Juju, towards Django as the engine for our Kubernetes operator.
- At the time of our introductory video, we used Canonical Juju (https://juju.is) as the engine to our operator.
- Juju was useful in the proof of concept (POC) phase of our Journey.
    - Using a Python based Kubernetes operator.
- At the current point in our journey, we have switched the operator engine to use Python's [Django Framework] (https://www.djangoproject.com/).
- Thus, Jannah Operator is being implemented as a Django Application.
- We are modeling the entire software stack by sub-classing Django's Model implementation.
    - https://docs.djangoproject.com/en/4.2/ref/models/instances/#django.db.models.Model.
- The Django application will have a VueJS web based frontend, as well as native Android (Kotlin), and iOS (SwiftUI) mobile applications.

Demo:
- Purpose is to showcase the developer environment.
    - I will perform the following steps:
        1) Clone the operator code base.
        2) Copy the environment variables shell script into the cloned operator directory.
        3) Run a 'make jannah-config' command to generate Molecule configuration files (as well as environment variable files).
        4) Run a 'make molecule-destroy' command to destroy existing Jannah deployment on the Kubernetes cluster.
        5) Run a 'make molecule-reset' command to reset the molecule state environment.
        6) Run a 'make molecule-converge' command'.
            - Clones Jannah frontend application code bases (web, iOS, Android).
            - Use (https://docs.docker.com/build/buildkit/)[Docker Buildkit]
                - Builds foundation images for Jannah infrastructure:
                    - jallohmediabuild/jannah-ubuntu-frontend-web-arm64
                    - jallohmediabuild/jannah-ubuntu-middleware-arm64
                    - jallohmediabuild/jannah-streamos-frontend-web-arm64
                    - jallohmediabuild/jannah-streamos-middleware-amd64
                - Buildkit will make these images accessible to the local Kubernetes instance on Docker Desktop.
                    - While the images are being built:
                        - Open the VueJS web frontend application in VSCode IDE for local development.
                        - Open the iOS mobile application in a Xcode IDE for local development.
                        - Open the Android mobile application in an Android Studio IDE for local development.
            - Deploys Jannah dependencies (Kubeflow) on the local kubernetes cluster.
            - Deploys Jannah Django application as container on the demo machine (laptop).
            - Deploys Jannah Frontend web application as a container on the demo machine (laptop).
        7) Open the Django Middleware application in an IntelliJ IDE for local development.
            - Show the Django models implementation in Python
                - Emphasize that these models are simplistic for now,
                  but will be evolving as the project moves forward.
            - Show routing to admin and graphql urls
                - /admin
                - /graphql
                    - sample query:
                        - query UserList{
                          users{
                          cursor,
                          hasMore,
                          users{
                          id,
                          username,
                          firstName,
                          lastName,
                          email,
                          isActive,
                          dateJoined,
                          avatar,
                          location,
                          website,
                          }
                          }
                          }
            - Run 'python manage.py runserver' command to start the Django application locally
            - Enter sample data via the Django Web admin.
                1) Sites
                    - Site 1
                    - Site 2
                2) Users
                    - Osman
                    - Babar
                3) Boot Layer Logs
                    - Boot Layer Operator Deployment Logs
                        - All logs leading up to the deployment of the operator Django application.
                4) Network Layer Logs
                    - All logs related to Networking services that support the Jannah infrastructure.
                5) Storage Layer Logs
                    - Log data for all storage components of the Jannah infrastructure.
                6) Compute Layer Logs
                    - All data related to Compute (Applications, Business Logic) components of the Jannah infrastructure.
                7) UX Layer Logs
                    - All data that are related to user interaction on the Jannah infrastructure
                8) Feedback Layer Logs
                    - All data related to user feedback, including error ticket trackers.
                9) Workflow Metadata Layer
                    - Sites Workflows: The workflow representing the available Jannah Django sites.
                    - Users Workflows: The workflows representing user on the Jannah infrastructure.
                    - Boots Workflows: The workflows relating to systems booting on the Jannah infrastructure.
                    - Network Workflows: Workflows related to Networking layer on the Jannah infrastructure.
                    - Storage Workflows: All workflows related to Storage (Data Persistent) within the Jannah infrastructure.
                    - Compute Workflows: All workflows related to compute (application) components within Jannah infrastructure.
                    - UX Workflows: All workflows related to UX within the Jannah infrastructure.
                    - Feedback Workflows: All workflows related to Feedback components within the Jannah infrastructure.
        8) Run 'ionic serve' command to install npm packages and start the web app locally.
        9) Show applications and mobile app emulators for local Jannah development.
        10) Ending with current milestone.
            - Current problems needing solutions
                - Debug Kotlin Apollo Connection between Android app and Django GraphQL API.
                - Now that the iOS application can talk to the Django app, lets display the content/results from the API calls.
                -
            - Challenge/Invitation to join team, and solve problems
                - Audience:
                    - Business Developers
                    - Venture Capitalists
                    - Upcoming Developers, (Frontend, Backend, devOps, Security, Data Scientists, Blockchain Enthusiasts)
                    - Experienced Developers, (Frontend, Backend, devOps, Security, Data Scientists, Blockchain Enthusiasts)

-------------------------------------------------------------------------------------------------------
April 17th, 20203
Introducing the Jannah Software Accelerator project.
- Speaker: Osman Jalloh
- Role: Software Architect at Jannah.io.
- Jannah.io: A lab (laboratory) for developing cloud native software solutions.

1) A journey into the business of:
    - Software enginneering.
    - Data science.
    - Machine learning.
    - Block chain.

   Using the best practices in industry and research.
   The series will include videos, blogs, and other social media postings.

2) We need two main 'vehicles' to facilitate our journey.
    - Jannah Accelerator Platform:
        - A tool to groom software ideas into fully monetized products (apps).
    - Jannah Operator.
        - An end-to-end Operator to deploy Jannah infrastructure on a Kubernetes cluster.

3) In this video I will use the end-2-end operator to deploy Jannah components into a local Kubernetes cluster.
    - Deploy Jannah dependency services.
        - Kubleflow (Machine Learning services)
        - Postgres Database
    - Deploy Jannah
        - Jannah Middleware
        - Jannah UI
    - Make command
        - make jannah-config
        - make charm-converge
---------------------------------------------------------------------------------------------------
====Road Map: Details on Specific Jannah Components======
- Start with the Django app
    - Models
    - Python implementation
    - Web Admin Implementation
    - Graphql API
    - Query implementation
    - Web dev/debug tool to test/verify queries
- Then Kubleflow UI
    - Standalone Deployment
        - https://www.kubeflow.org/docs/components/pipelines/v1/installation/standalone-deployment/
        - deploy to:
            - docker desktop
            - kind
    - Local Deployment
        - https://www.kubeflow.org/docs/components/pipelines/v1/installation/localcluster-deployment/
        - deploy to:
            - docker desktop
            - kind
- Full Kubeflow deployment
    - https://www.kubeflow.org/docs/components/pipelines/v1/installation/overview/#full-kubeflow-deployment
    - deploy to:
        - docker desktop
        - kind
---------------------------------------------------------------------------------------------------------------
Debug Utils
-Ansible
- export ANSIBLE_VAULT_DEFAULT_PASS_FILE=~/jannah-operator/ansible_defaultpass.txt
- source boot.env.sh
- cd ansible
- ansible-playbook -i inventory/ site.yml -vvvv --connection=local --vault-id defaultpass@$ANSIBLE_VAULT_DEFAULT_PASS_FILE --tags debug_task;


PGBOUNCER_URI=$(kubectl get secret cluster1-pgbouncer --namespace postgres-operator -o jsonpath='{.data.pgbouncer-uri}' | base64 --decode)

PGBOUNCER_URI=$(kubectl get secret cluster1-pguser-cluster1 --namespace postgres-operator -o jsonpath='{.data.pgbouncer-uri}' | base64 --decode)

get svc/jannah-registry -n jannah -o jsonpath='{.spec.clusterIP}'

docker login jannah-registry:5000

changed: [localhost] => {
    "changed": true,
    "cmd": "helm install -n jannah --create-namespace  jannah ./jannah-operator;\n",
    "delta": "0:00:02.284968",
    "end": "2023-10-18 23:11:10.688732",
    "invocation": {
        "module_args": {
            "_raw_params": "helm install -n jannah --create-namespace  jannah ./jannah-operator;\n",
            "_uses_shell": true,
            "argv": null,
            "chdir": "/Users/osmanjalloh/IdeaProjects/debug/operator",
            "creates": null,
            "executable": null,
            "removes": null,
            "stdin": null,
            "stdin_add_newline": true,
            "strip_empty_ends": true
        }
    },
    "msg": "",
    "rc": 0,
    "start": "2023-10-18 23:11:08.403764",
    "stderr": "",
    "stderr_lines": [],
    "stdout": "NAME: jannah\nLAST DEPLOYED: Wed Oct 18 23:11:08 2023\nNAMESPACE: jannah\nSTATUS: deployed\nREVISION: 1\nNOTES:\n1. Get the application URL by running these commands:\n  export POD_NAME=$(kubectl get pods --namespace jannah -l \"app.kubernetes.io/name=jannah-helm,app.kubernetes.io/instance=jannah\" -o jsonpath=\"{.items[0].metadata.name}\")\n  export CONTAINER_PORT=$(kubectl get pod --namespace jannah $POD_NAME -o jsonpath=\"{.spec.containers[0].ports[0].containerPort}\")\n  echo \"Visit http://127.0.0.1:8080 to use your application\"\n  kubectl --namespace jannah port-forward $POD_NAME 8080:$CONTAINER_PORT",
    "stdout_lines": [
        "NAME: jannah",
        "LAST DEPLOYED: Wed Oct 18 23:11:08 2023",
        "NAMESPACE: jannah",
        "STATUS: deployed",
        "REVISION: 1",
        "NOTES:",
        "1. Get the application URL by running these commands:",
        "  export POD_NAME=$(kubectl get pods --namespace jannah -l \"app.kubernetes.io/name=jannah-helm,app.kubernetes.io/instance=jannah\" -o jsonpath=\"{.items[0].metadata.name}\")",
        "  export CONTAINER_PORT=$(kubectl get pod --namespace jannah $POD_NAME -o jsonpath=\"{.spec.containers[0].ports[0].containerPort}\")",
        "  echo \"Visit http://127.0.0.1:8080 to use your application\"",
        "  kubectl --namespace jannah port-forward $POD_NAME 8080:$CONTAINER_PORT"
    ]
}