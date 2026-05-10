# Erik Emmerfors

**SysOps | DevOps | AI Automation Engineer**  
📍 Malmö, Sweden | ✉️ [psiloc@gmail.com](mailto:psiloc@gmail.com) | 🌐 [github.com/psilore](https://github.com/psilore)

---

## 🚀 Professional Profile

A versatile, hands-on Systems Operations (SysOps), Platform Engineering (DevOps), and AI Automation Engineer with extensive experience designing, securing, and scaling hybrid environments. Specializes in bridge-building between infrastructure stability and developer velocity through robust Infrastructure-as-Code (IaC) automation, secure secrets management, containerization, and self-hosted local Artificial Intelligence integrations. Passionate about automating repetitive tasks, building interactive CLI tools, and creating smart orchestration workflows.

---

## 🛠️ Core Expertise & Technical Stack

<p align="center">
  <img src="https://img.shields.io/badge/Ansible-E00A1A?style=flat-square&logo=ansible&logoColor=white" alt="Ansible" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=flat-square&logo=docker&logoColor=white" alt="Docker" />
  <img src="https://img.shields.io/badge/Go-00ADD8?style=flat-square&logo=go&logoColor=white" alt="Go" />
  <img src="https://img.shields.io/badge/Proxmox-E74C3C?style=flat-square&logo=proxmox&logoColor=white" alt="Proxmox" />
  <img src="https://img.shields.io/badge/Debian-A81D33?style=flat-square&logo=debian&logoColor=white" alt="Debian" />
  <img src="https://img.shields.io/badge/Nginx-009639?style=flat-square&logo=nginx&logoColor=white" alt="Nginx" />
  <img src="https://img.shields.io/badge/n8n-FF6C37?style=flat-square&logo=n8n&logoColor=white" alt="n8n" />
  <img src="https://img.shields.io/badge/Python-3776AB?style=flat-square&logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/Ollama-000000?style=flat-square&logo=ollama&logoColor=white" alt="Ollama" />
  <img src="https://img.shields.io/badge/Google_Gemini-8E75C2?style=flat-square&logo=googlegemini&logoColor=white" alt="Gemini" />
  <img src="https://img.shields.io/badge/Bash-4EAA25?style=flat-square&logo=gnu-bash&logoColor=white" alt="Bash" />
</p>

### 💻 System Operations (SysOps)

- **OS & Hardware Optimization**: In-depth administration of Debian/Ubuntu Linux platforms; experience optimizing hardware-specific features (e.g., hybrid graphics/Optimus, power management, and hardware acceleration on ThinkPad P15s Gen 1 architectures).
- **Virtualization & Hypervisors**: Bare-metal cluster management and deployment using **Proxmox VE**, virtual machines (KVM), and lightweight Linux Containers (LXC).
- **High-Availability Networking**: Implementing and configuring high-performance **Nginx** reverse proxies, secure SSL/TLS termination, HTTP method handling (e.g., POST/308 redirects), and secure VPN networking (Tailscale).
- **Infrastructure Security**: Securing remote SSH connections utilizing **ControlMaster**, customized agent-forwarding configurations, and strict network boundary restrictions.

### ⚙️ Platform Engineering & DevOps

- **Infrastructure as Code (IaC)**: Architecting enterprise Ansible architectures. Expert in transitioning flat architectures to official modular collections, developing reusable Ansible roles, managing complex dynamic inventories, and enforcing formatting guidelines via `ansible-lint`.
- **Secrets Management**: Securing production inventories and deployments via **Ansible Vault** to guarantee zero plain-text passwords or credentials in repositories.
- **Containerization**: Designing and hosting containerized applications utilizing **Docker** and **Docker Compose**, managing container lifecycles, local volumes, network isolation, and health monitoring (e.g., Patchmon, PostgreSQL setups).
- **CI/CD & Repository Automation**: Implementing secure backups for GitHub/GitLab repositories onto off-site servers, cron automation pipelines, shell scripting (Bash, Python), and error notification flows.

### 🧠 AI Engineering & Automation Orchestration

- **Local LLM Infrastructure**: Deploying, optimizing, and scaling open-source large language models using **Ollama** in Docker/LXC, integrating hardware/GPU acceleration for local execution.
- **Orchestration & Workflow Automation**: Designing autonomous agent workflows using **n8n**, connecting third-party APIs, triggers, databases, and local LLMs to automate business logic and system monitoring.
- **Hybrid AI Models & Agents**: Developing pipelines that combine local execution via **Ollama** and cloud capabilities via **Google Gemini** to digest system logs, parse complex alerts, and interactively guide setup routines.

---

## 💼 Highlighted Professional Experience

### **Senior DevOps & Systems Engineer** | Modelon _(Inferred/Representative)_

_Lund, Sweden (Remote / Hybrid) | 2026 - Present_

- **Ansible Modernization**: Led the refactoring of a major on-premise Ansible repository, migrating legacy roles to modern FQCN standards and utilizing official community collections.
- **Secure Architecture**: Established strict `ansible-lint` compliance in CI/CD pipelines. Transitioned all environment variables and credentials to a secure, template-based Ansible Vault strategy.
- **Rolling Updates & Resiliency**: Implemented rolling server updates across hybrid systems, improving service availability and minimizing manual patching effort.

### **DevOps & Platform Engineer** | [Extrapreneur](https://github.com/extrapreneur/)

_2022 - 2026_

- **Hybrid Infrastructure & IaC**: Architected the unified IaC suite (`eo-infrastructure`), employing **Azure ARM templates** for secure cloud deployments (App Services, Static Web Apps with Azure AD SSO integration) alongside **Ansible** playbooks for self-hosted service provisioning on Debian-based hosts.
- **Infrastructure Orchestration**: Created a comprehensive **Makefile orchestration engine** (`make deploy-start`, `make update`, `make dry-run`) simplifying complex Docker Compose deployment and administration procedures for developer services (such as **n8n** connected to Qdrant/Ollama, and **Grafana** observability stacks with Loki/Prometheus/Promtail).
- **Application & Container Lifecycle**: Maintained and optimized multi-stage **Docker builds** and composed application platforms for **`eo-alltid`** (Node.js/Express API integrated with MS Graph and ResRobot transit data) and **`eo-idag`** (React/Vite frontend hosted via Nginx).
- **CI/CD & Documentation Pipelines**: Developed python automated workflows (`publish_docs_to_confluence.py`) integrated with GitHub Actions to publish Markdown-based documentation dynamically to Atlassian Confluence.

### **DevOps & SysOps Engineer** | Ingka Group (IKEA)

_2023 - 2025_

- **Scalable Repository Management**: Managed and maintained the CI/CD and DevOps structures for over **50 code repositories** distributed across several cross-functional teams.
- **Cloud Infrastructure (GCP)**: Designed, monitored, and scaled cloud-native infrastructure utilizing **Google Cloud Platform (GCP)**.
- **Application Logic**: Maintained and enhanced internal tooling using **TypeScript** to optimize continuous deployment and infrastructure monitoring.

### **Linux & Frontend Developer** | Inter IKEA Group

_2022 - 2023_

- **Frontend Development**: Designed and developed modern, high-performance web interfaces utilizing **TypeScript**.
- **Cloud Hosting (AWS)**: Engineered and deployed scalable, secure application components in **Amazon Web Services (AWS)**.
- **Linux Engineering**: Configured and maintained reliable underlying Linux environments to support application execution and dev pipelines.

---

## 🛠️ Selected Open Source & Personal Projects

### **`night-tower` — Autonomous Homelab & Infrastructure Suite**

_Infrastructure Architect | Ansible, Docker, Tailscale, Ollama, n8n_

- Built and open-sourced a complete, GitOps-driven homelab infrastructure engine managing a private multi-host virtualization environment.
- **Automated Provisioning (Ansible)**: Designed a modular Ansible architecture with specialized playbooks for rolling OS maintenance, Tailscale node upgrades, single-service maintenance, and container lifecycle tasks, utilizing **Ansible Vault** for zero-plaintext secrets storage.
- **Zero-Trust Sidecar Networking**: Implemented containerized **Tailscale sidecar proxy networks** for isolated services (pattern: `<service-name>.<funny-name>.ts.net`) ensuring secure local and remote access without open public ports.
- **Self-Hosted AI & Orchestration**: Deployed **Ollama** (local, hardware-accelerated LLM engine) alongside **n8n** for autonomous alert routing, system log diagnostic processing, and automated workflow state backups.
- **Monitoring & Observability**: Integrated centralized performance monitoring (Telegraf agents, Grafana, Uptime Kuma) and system patch orchestration (Patchmon).
- Available on GitHub: [github.com/psilore/night-tower](https://github.com/psilore/night-tower)

### **`setup-client` — Interactive Environment Configurator**

_Creator / Lead Developer | Go (Golang)_

- Built a Go-based interactive CLI setup utility to simplify system initialization on fresh Linux installs.
- Refactored a complex, flat options tree into a clean, categorized submenu structure (e.g., _Development_, _Security_, _Terminal_, _System_) to significantly improve UX and reduce setup errors.
- Available on GitHub: [github.com/psiloc/setup-client](https://github.com/psiloc/setup-client) _(placeholder)_

### **Self-Hosted AI & Orchestration Engine**

_Platform Architect | Ollama, n8n, Docker_

- Designed a unified local AI hub running n8n alongside Ollama in a secure containerized network.
- Built automated pipelines that capture system event logs, route them through local LLMs for analysis, and notify administrative channels when anomalies occur.
- Optimized model response times by integrating Debian-level hardware acceleration and tuning system resources.

### **Automated Off-site GitHub Backup System**

_Developer | Bash, Cron, Git_

- Developed an encrypted, robust backup suite that clones, compresses, and sends repository mirrors to external secure vaults.
- Built self-monitoring capabilities, outputting runtime diagnostics and shipping error reports over email upon failure.

---

## 📜 Licenses & Certifications

- **[GitHub Actions (Intermediate)](https://learn.microsoft.com/en-us/users/erikemmerfors-4264/credentials/299daad0768be516)** — _Microsoft_  
  Issued Nov 2025 · Expires Nov 2027 | **ID**: `299DAAD0768BE516`  
  _Skills: GitHub, DevOps_
- **[GitHub Administration (Intermediate)](https://learn.microsoft.com/en-us/users/erikemmerfors-4264/credentials/35208bf3ad623cbe)** — _Microsoft_  
  Issued Nov 2025 · Expires Nov 2027 | **ID**: `35208BF3AD623CBE`  
  _Skills: GitHub_
- **[Deeper Technical Understanding of n8n (Level II)](https://community.n8n.io/badges/105/completed-n8n-course-level-2?username=psiloc)** — _n8n_  
  Issued May 2022 | **ID**: `105`  
  _Skills: n8n, JavaScript, Automation Orchestration_
- **[GitHub Foundations (Elementary)](https://learn.microsoft.com/en-us/users/erikemmerfors-4264/credentials/d21c0ac63c6986d3)** — _Microsoft_  
  Issued Nov 2025 · Expires Nov 2027 | **ID**: `D21C0AC63C6986D3`  
  _Skills: GitHub, Git_
- **[n8n Beginners' Course (Level I)](https://community.n8n.io/badges/104/completed-n8n-course-level-1?username=psiloc)** — _n8n_  
  Issued Oct 2021 | **ID**: `104`  
  _Skills: Bash, Linux, API Integration_
- **[Responsive Web Design](https://www.freecodecamp.org/certification/fcc0a24dcf6-05a5-4784-ba6b-2ccdb96b208c/responsive-web-design)** — _freeCodeCamp_  
  Issued Jul 2020  
  _Skills: Figma, Responsive HTML/CSS, JavaScript_

---

> _References, education and full project breakdown available upon request._
