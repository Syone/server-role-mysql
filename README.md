# Server Role Web

Submodule for server ansible playbook. Run MySQL containers, create databases and users.


## How to use it in my playbook?

Add submodule into your playbook repo:
```
git submodule add https://github.com/syone/server-role-mysql.git roles/mysql
```

Example:
```
---
  - hosts: all
    become: true
    become_user: root
    become_method: sudo
    vars_files:
      - group_vars/vault.yml

      - role: mysql
        vars:
          mysql_containers:
            - name: foo
              port: 3306
              root_password: "{{ mysql_foo_root_password }}"
              version: 9
            - name: bar
              port: 3307
              root_password: "{{ mysql_bar_root_password }}"
              version: 8
          mysql_databases:
            - database: db-one
              container: mysql-foo
              root_password: "{{ mysql_foo_root_password }}"
            - database: db-two
              container: mysql-bar
              root_password: "{{ mysql_bar_root_password }}"
          mysql_users:
            - database: db-one
              container: mysql-foo
              root_password: "{{ mysql_foo_root_password }}"
              user: alice
              password: "{{ mysql_password_alice }}"
            - database: db-two
              container: mysql-bar
              root_password: "{{ mysql_bar_root_password }}"
              user: bob
              password: "{{ mysql_password_bob }}"
```


## Run MySQL container

There is a helper script located here:
```
sudo /root/mysql/run.sh --name [NAME] --port [PORT] --network [NETWORK] --config [CONFIG_FILE_PATH] --version [MYSQL IMAGE TAG]
```

* Container name will be mysql-[NAME]
* Default port is 3306
* Default network name is network-[NAME]
* Default config file name is /root/mysql/my-[NAME].cnf
* Default mysql image tag is "latest". [See all the mysql image tags](https://hub.docker.com/_/mysql)