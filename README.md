```
cp .env.example .env
```
Change password

Run 
```
docker-compose up -d
```

To restore backup, insert .pkb file into backup directory and run
```
make restore FILE=filename.pkb
```

To generate backup run 
```
make backup
```


Directory rclone_backup made in order to send backups to cloud
