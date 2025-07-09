include .env

# Konfiguracja
CONTAINER := mssql_tools
SQL_USER := SA
SQL_PASS := $(SA_PASSWORD)
BACKUP_DIR := /var/opt/mssql/Backup
DATA_DIR := /var/opt/mssql/data
DB_NAME := bdFaktury

# Format daty do nazwy pliku backupu: YYYYMMDDHHMMSS
TIMESTAMP := $(shell date +%Y%m%d%H%M%S)

.PHONY: backup restore upload

backup:
	docker exec -i $(CONTAINER) /opt/mssql-tools/bin/sqlcmd -S mssql -U $(SQL_USER) -P $(SQL_PASS) -Q "BACKUP DATABASE [$(DB_NAME)] TO DISK = N'$(BACKUP_DIR)/Kopia_$(DB_NAME)_$(TIMESTAMP).pkb' WITH INIT;"
	docker cp $(CONTAINER):$(BACKUP_DIR)/Kopia_$(DB_NAME)_$(TIMESTAMP).pkb ./rclone_backup/Kopia_$(DB_NAME)_$(TIMESTAMP).pkb
	chown meh:meh rclone_backup/Kopia_$(DB_NAME)_$(TIMESTAMP).pkb
	chmod 644 rclone_backup/Kopia_$(DB_NAME)_$(TIMESTAMP).pkb

restore:
ifndef FILE
	$(error Musisz podać nazwę pliku backupu jako FILE=...)
endif
	docker exec -i $(CONTAINER) /opt/mssql-tools/bin/sqlcmd -S mssql -U $(SQL_USER) -P $(SQL_PASS) -Q "RESTORE DATABASE [$(DB_NAME)] FROM DISK = N'$(BACKUP_DIR)/$(FILE)' WITH MOVE 'bdFaktury' TO '$(DATA_DIR)/bdFaktury.mdf', MOVE 'bdFaktury_log' TO '$(DATA_DIR)/bdFaktury_log.ldf', REPLACE, RECOVERY;"

upload:
	rclone copy /home/meh/elisoft-db/rclone_backup gdrive:elisoft_terminal_bak
