# 📋 Clone — ManageIQ Automate Domain

The **Clone** repository contains a ManageIQ **Automate domain** for cloning services. The content is maintained as code and can be synchronized with a ManageIQ environment using `rake` tasks.

---

## 🚀 Overview

### 📦 What's included
- 🧩 **Automate code** — `Clone/`
- 🗂️ **Service dialogs** — `service_dialogs/`

---

## ✅ Requirements

- A running **ManageIQ** environment.
- Access to the ManageIQ Rails app directory (typically `vmdb`) with `rake` available.
- Repository content present on the target system (copied or mounted).
- The filesystem paths in commands below are **examples** and may differ in your environment.

---

## ⚙️ Import to environment

Import the **Automate domain** from this repository into ManageIQ:

```bash
cd /var/www/miq/vmdb
rake evm:automate:import DOMAIN=Clone IMPORT_DIR=/opt/manageiq/automation/clone OVERWRITE=true ENABLED=true
```

> This command imports only the Automate domain (`Clone/`). Import service dialogs as needed:

### 🗂️ Service dialogs

```bash
cd /var/www/miq/vmdb
rake evm:import:service_dialogs -- --source=/opt/manageiq/automation/clone/service_dialogs
```

---

## 📤 Export from environment back to repository

Export the **Automate domain** from ManageIQ back into this repository:

```bash
# Export may leave old files for renamed instances/methods — clean the domain folder first.
cd /opt/manageiq/automation/clone
rm -rf Clone

cd /var/www/miq/vmdb
rake evm:automate:export DOMAIN=Clone EXPORT_DIR=/opt/manageiq/automation/clone
```

> The section below shows how to export service dialogs. Review and commit changes carefully.

### 🗂️ Service dialogs

```bash
rake evm:export:service_dialogs -- --directory=/opt/manageiq/automation/clone/service_dialogs
```

> Note: this task may export dialogs not related to this domain. Review changes and commit only what is intended.

---

## 📄 License

This project is licensed under the MIT License. See [`LICENSE`](./LICENSE).
