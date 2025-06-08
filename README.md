

# <p align="center"> GitHub actions runner self-hosted example (Docker) </p>

<p align="center">
  <img src="https://github.com/xamayca/Docker-Github-actions-runner-self-hosted-example/actions/workflows/code-quality.yml/badge.svg" alt="Code Quality Badge">
</p>

---

<p align="center">
    Ce projet met en place un runner <a href="https://github.com/features/actions">GitHub Actions</a> auto-hébergé dans un conteneur Docker, optimisé pour un environnement PHP.
</p>

---

Voici les étapes clés du fonctionnement interne du conteneur :

- Le conteneur est basé sur l’image officielle **[PHP CLI](https://hub.docker.com/_/php)** tournant sur Debian.
- La dernière version de l'image officielle **[Composer (latest-bin)](https://hub.docker.com/r/composer/composer)** est copiée dans le conteneur pour gérer les dépendances PHP.
- Les dépendances nécessaires sont installées automatiquement lors de la construction de l’image.
- Un utilisateur `non-root` avec `privilèges sudo` est créé pour assurer la sécurité et la bonne gestion des permissions.
- Au démarrage du conteneur, un script `entrypoint` :
    - Télécharge la dernière version du [Github Actions runner (Release)](https://github.com/actions/runner/releases) depuis GitHub.
    - Extrait et installe le runner dans le conteneur.
    - Configure et authentifie le runner à l’aide du jeton personnel fourni.
    - Lance le runner, prêt à recevoir et exécuter les jobs GitHub Actions.

De cette façon à chaque `push` ou `pull request`, ce runner auto-hébergé exécute vos workflows CI/CD localement ou sur un serveur privé, offrant un contrôle total et une meilleure confidentialité pour votre code.

Le workflow inclus dans ce projet réalise notamment :
- L’action [GitHub checkout](https://github.com/actions/checkout) pour cloner les fichiers du projet dans l’environnement du runner.
- L'installation des dépendances PHP du projet via [Composer](https://getcomposer.org/doc/).
- Une analyse statique du code avec **[PHPStan](https://phpstan.org/)**.
- L’exécution des tests unitaires avec **[PHPUnit](https://phpunit.de/index.html)**.


---

## 📋 Prérequis

- **[Docker Desktop](https://www.docker.com/products/docker-desktop) installé sur votre machine.**
- **[Jeton d'accès personnel GitHub (PAT)](https://docs.github.com/fr/enterprise-cloud@latest/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) avec les autorisations appropriées (ex. : `repo`, `workflow`) pour permettre au runner de s'enregistrer et exécuter les jobs sur le dépôt.**

---

## ⚙️ Installation du GitHub Actions Runner dans Docker

#### <ins> 1. Clonage du dépot </ins>
```bash
git clone https://github.com/xamayca/Docker-Github-actions-runner-self-hosted-example.git
```

#### <ins> 2. Accéder au répertoire du projet </ins>
```bash
cd Docker-Github-actions-runner-self-hosted-example
```

#### <ins> 3. Ajouter les variables d’environnement </ins>

Crée un fichier `.env` à la racine du projet avec les variables suivantes, en remplaçant les valeurs par celles de votre projet :

```env
GITHUB_PERSONAL_TOKEN=<JETON_PERSONNEL_GITHUB>"
GITHUB_REPOSITORY_OWNER="<NOM_D_UTILISATEUR_GITHUB>"
GITHUB_REPOSITORY_NAME="<NOM_DU_DEPOT_GITHUB>"
```

#### <ins> 4. Construction de l'image Docker du GitHub Actions Runner </ins>

Cette commande télécharge les images nécessaires et construit le conteneur avant de le lancer :

```bash
docker compose up --build
```