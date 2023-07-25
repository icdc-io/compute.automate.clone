# Clone automation package

Automation package for Cloning of services.

## Import code from repository to DEV environment

```bash
cd /var/www/miq/vmdb
rake evm:automate:import DOMAIN=Clone IMPORT_DIR=/opt/manageiq/automation/clone OVERWRITE=true ENABLED=true
```

After import fresh automation code you must import service dialogs and customization buttons.


## Export code from DEV environment info repository

```bash
# Remove old template provisioning, as export leaves old files for renamed instances and methods in repository.
cd /opt/manageiq/automation/clone
rm -rf Clone
# Import new
cd /var/www/miq/vmdb
rake evm:automate:export DOMAIN=Clone EXPORT_DIR=/opt/manageiq/automation/clone
```

Export service dialogs:
 - as it exports all dialogs then remove not related dialogs and commit carefully only those which ready for production

```bash
rake evm:export:service_dialogs -- --directory=/opt/manageiq/automation/clone/service_dialogs
```

