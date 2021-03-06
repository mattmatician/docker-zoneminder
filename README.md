# Zoneminder

## Usage

Here are some example snippets to help you get started creating a container.

### docker-compose ([recommended](https://docs.linuxserver.io/general/docker-compose))

Compatible with docker-compose v2 schemas.

```yaml
---
services:
  db:
    environment:
      MYSQL_DATABASE: zm
      MYSQL_PASSWORD: zmpass
      MYSQL_ROOT_PASSWORD: somezoneminder
      MYSQL_USER: zmuser
      TZ: Europe/London
    image: mysql:5.7.34
    restart: unless-stopped
    volumes:
    - mysql_data:/var/lib/mysql:rw
  zoneminder:
    depends_on:
    - db
    environment:
      ZM_DB_HOST: db
      ZM_DB_NAME: zm
      ZM_DB_PASSWORD: zmpass
      ZM_DB_USER: zmuser
      TZ: Europe/London
    image: mattmatician/zoneminder:latest
    ports:
    - 8080:80/tcp
    restart: unless-stopped
    shm_size: 4g
    volumes:
    - zm_config:/config:rw
    - zm_content:/app:rw
version: '2.1'
volumes:
  mysql_data: {}
  zm_config: {}
  zm_content: {}

```