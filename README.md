# VVV Slim REST site template
Slim REST tempate to be used with VVV.

## Overview
This template will allow you to create a Slim REST environment using only `vvv-custom.yml`.

The template installs a new REST API using the skeleton provided by [awurth](https://github.com/awurth/SlimREST).

The skeleton features:
- Slim Framework v3
- Eloquent ORM
- Sentinel + OAuth 2
- Respect Validation and Slim Validation
- Monolog

## Installation
To use the template, add the following code to vv-custom.yml
```
sites:
  project-name:
    description: "Project description"
    repo: https://github.com/Crozzroads/vvv-site-template-slim-rest.git
    hosts:
      - project-name.test
```
