#!yamlex

rsnapshot_options: !aggregate
  exclude_file: /etc/rsync.exclude
  sync_first: true

rsnapshot_backups: !aggregate
  home_localhost:
    destination: /opt/backup
    dirs_to_backup:
      /home:  localhost/
      /etc:  localhost/
      /opt/backup/pg/dumps:  localhost/
      /opt/backup/mysql/dumps:  localhost/
    parameters:
      logfile: /var/log/rsnapshot.log
    retain:
      - hourly: 6
      - daily: 7
      - weekly: 4
      - monthly: 12
      - quarterly: 4
      - yearly: 12
    crontab:
      sync:
        minute: 10
        hour: 2
      hourly:
        minute: 9
        hour: '0,4,8,12,16,20'
      daily:
        minute: 9
        hour: 2
      weekly:
        minute: 8
        hour: 2
        dayweek: 0
      monthly:
        minute: 7
        hour: 2
        daymonth: 1
      quarterly:
        minute: 7
        hour: 2
        month: '1,4,7,10'
        daymonth: 1
      yearly:
        minute: 6
        hour: 2
        month: 1
        daymonth: 1
