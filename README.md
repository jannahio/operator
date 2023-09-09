- Speaker: Osman Jalloh
- Role: Software Architect at Jannah.io.
- Jannah.io: A lab (laboratory) for developing cloud native software solutions.

Introducing the Jannah Software Accelerator project.
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

Speaker: Osman Jalloh
Role: Software Architect at Jannah.io.
Jannah.io: A lab (laboratory) for developing cloud native software solutions.
Where are we in this marvelous journey?
- Moving on from Juju, towards Django as the engine for our Kubernetes operator.

Recap:
- At the time of our introductory video, we used Canonical Juju (https://juju.is) as the engine to our operator.
- At the beginning our journey, Juju was useful to proof the concept of a Python based Kubernetes operator.
- At the current point in our journey, we have switched the operator engine to use Python's Django Framework.
- Thus, Jannah Operator is being implemented as a Django Application.
- We are modeling the entire software stack by sub-classing Django's Model.
   - https://docs.djangoproject.com/en/4.2/ref/models/instances/#django.db.models.Model.
- The Django application will have a web based frontend, as well as native Android, and iOS mobile applications.

Demo:
- This Demo is to showcase the developer environment.
- I will perform the following steps:
   1) Clone the operator code base.
   2) Copy the environment variable shell script into the cloned operator directory.
   3) Run a 'make jannah-config' command to generate Molecule configuration files (as well as environment files).
   4) Run a 'make molecule-destroy' command to destroy existing Jannah deployment on the Kubernetes cluster.
   5) Run a 'make molecule-reset' command to reset the molecule environment.
   6) Run a 'make molecule-converge' command'.
      - Clones Jannah frontend application code bases (web, iOS, Android).
      - Deploys Jannah dependencies (Kubeflow) on the local kubernetes cluster.
      - Deploys Jannah Django application as container on the demo machine (laptop).
      - Deploys Jannah Frontend web application as a container on the demo machine (laptop).
   7) Open the DJango Middleware in an IntelliJ IDE for local development.
      - Show the Django models implementation in Python
         - Emphasize that these models are simplistic for now, but will be evolving as the project moves forward
   8) Open the Django Web Frontend application in VS Code IDE for local development.
   9) Open the iOS mobile application in a Xcode IDE for local development.
   10) Open the Android mobile application in an Android Studio IDE for local development.

====Next Video Style======
----Zoom in on specific Jannah Components
1) Start with Django app
- Models
- Python implementation
- Web Adimin Implementation
- Graphql API
- Query implementation
- Web dev/debug tool to test queries
        