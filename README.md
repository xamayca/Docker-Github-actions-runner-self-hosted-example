![Code-quality-workflow](https://github.com/xamayca/Docker-Github-actions-runner-self-hosted-example/actions/workflows/code-quality.yml/badge.svg)


# Docker & Github actions runner self hosted example

---

Ce projet montre comment configurer un runner GitHub Actions auto-hébergé à l'aide de Docker, pour exécuter vos workflows CI/CD localement ou sur un serveur privé.

---

## Prérequis

- Docker Desktop doit être installé sur votre machine.

---

## Installation du GitHub Actions Runner dans Docker

#### 1 - Clonage du dépot
```bash
git clone https://github.com/xamayca/Docker-Github-actions-runner-self-hosted-example.git
```

#### 2 - Accéder au répertoire du projet
```bash
cd Docker-Github-actions-runner-self-hosted-example
```

#### 3 - Construction de l'image docker Github Actions runner
```bash
docker-compose up --build
```

test workflow