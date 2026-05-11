# Erik Emmerfors

**SysOps | DevOps | AI Automation Engineer**  
📍 Malmö, Sweden | ✉️ [psiloc@gmail.com](mailto:psiloc@gmail.com) | 🌐 [github.com/psilore](https://github.com/psilore)

---

## 🚀 Professional Profile

A versatile, hands-on Senior DevOps & AI Automation Consultant at Extrapreneur, specializing in the design, security, and scaling of hybrid environments. Erik bridges the gap between infrastructure stability and developer velocity through robust IaC automation, secure secrets management, and self-hosted AI integrations. He excels at navigating complex enterprise ecosystems (IKEA, Modelon) while maintaining an agile, consultant-driven approach to solving infrastructure bottlenecks.

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
* **OS & Hardware:** Advanced Debian/Ubuntu administration; hardware optimization for ThinkPad P15s (hybrid graphics/power management).
* **Virtualization:** Bare-metal cluster management via **Proxmox VE**, KVM, and LXC.
* **Networking:** High-performance **Nginx** reverse proxies, SSL/TLS termination, and zero-trust VPNs (**Tailscale**).
* **Security:** Hardened SSH configurations (ControlMaster) and strict network boundary enforcement.

### ⚙️ Platform Engineering & DevOps
* **Infrastructure as Code:** Enterprise-scale **Ansible** (FQCN standards, modular collections, and `ansible-lint` governance).
* **Secrets Management:** Zero-plaintext workflows using **Ansible Vault**.
* **Containerization:** Full lifecycle management via **Docker & Docker Compose**; volume isolation and health monitoring.
* **CI/CD:** Automated backup pipelines for GitHub/GitLab and custom Python/Bash automation flows.

### 🧠 AI Engineering & Automation
* **Local LLM Infrastructure:** Scaling open-source models using **Ollama** with hardware/GPU acceleration.
* **Workflow Orchestration:** Designing autonomous agents in **n8n** to bridge APIs, databases, and LLMs.
* **Hybrid AI:** Architecting pipelines combining local execution (**Ollama**) with cloud power (**Google Gemini**) for log analysis and interactive system diagnostics.

## 💼 Highlighted Professional Experience

### **Senior DevOps & Systems Consultant | Extrapreneur**

> [!IMPORTANT]  
> I am not allowed to give to much appraisal, I am going to that anyway!
> Thank you @peter, @cecilia, @rickard and @agnes, I would not have found you, thank you for finding me

_2022 – Present_

> Lead Consultant architecting unified infrastructure suites and driving automation strategies for major Swedish industrial and retail clients.

#### **Current Assignment: Modelon** *Lund, Sweden (Remote / Hybrid) | 2026 – Present*

* **Ansible Modernization:** Led the refactoring of a major on-premise Ansible repository to modern FQCN standards.
* **Secure Architecture:** Enforced `ansible-lint` in CI/CD and migrated all credentials to a template-based **Ansible Vault** strategy.
* **Resiliency:** Implemented rolling server updates across hybrid systems, minimizing manual patching and downtime.

#### **Internal Project: Extrapreneur Core Infrastructure**

_2022 – 2026_

* **Unified IaC:** Developed the `eo-infrastructure` suite using **Azure ARM** and Ansible for hybrid cloud/self-hosted provisioning.
* **Orchestration Engine:** Created a **Makefile-driven** deployment engine for developer services (n8n, Qdrant, Ollama, Grafana).
* **Auto-Documentation:** Built Python workflows to dynamically sync Markdown docs from GitHub to **Confluence**.

#### **Assignment: Ingka Group (IKEA)**

_2023 – 2025_

* **Scalable Repo Management:** Governed CI/CD and DevOps structures for **50+ repositories** across cross-functional teams.
* **Cloud Infrastructure:** Designed and scaled cloud-native environments within **Google Cloud Platform (GCP)**.

#### **Assignment: Inter IKEA Group**

_2022 – 2023_

* **Cloud & Linux Engineering:** Engineered scalable AWS components and maintained hardened Linux environments.
* **Frontend Development:** Developed high-performance web interfaces utilizing **TypeScript**.

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

> _References, education and full project breakdown available upon request by either buy me coffee or pay $50 an undisclosed bank account._
