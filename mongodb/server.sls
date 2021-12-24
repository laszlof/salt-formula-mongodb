{%- from "mongodb/map.jinja" import server with context %}

{%- if server.get('enabled', False) %}

mongodb_repo:
  pkgrepo.managed:
    - humanname: MongoDB Repository
    - baseurl: 'https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/{{ server.version }}/x86_64/'
    - gpgcheck: 1
    - enabled: True
    - gpgkey: 'https://www.mongodb.org/static/pgp/server-{{ server.version }}.asc'

mongodb_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

/etc/mongod.conf:
  file.managed:
  - source: salt://mongodb/files/mongod.conf
  - template: jinja
  - require:
    - pkg: mongodb_packages

{%- if server.shared_key is defined %}
/etc/mongodb.key:
  file.managed:
  - contents_pillar: mongodb:server:shared_key
  - mode: 600
  - user: mongodb
  - require:
    - pkg: mongodb_packages
  - watch_in:
    - service: mongodb_service
{%- endif %}

{{ server.lock_dir }}:
  file.directory:
    - makedirs: true

mongodb_service:
  service.running:
  - name: {{ server.service }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - file: {{ server.lock_dir }}
    - pkg: mongodb_packages
  - watch:
    - file: /etc/mongodb.conf

{%- endif %}
