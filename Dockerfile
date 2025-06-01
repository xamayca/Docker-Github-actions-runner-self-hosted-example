# Utilise une image Debian "bookworm" allégée comme base pour le conteneur
# https://hub.docker.com/_/debian
FROM debian:bookworm-slim

# Évite les invites interactives lors de l'installation des paquets
# https://www.debian.org/releases/bookworm/s390x/ch05s02.fr.html
ENV DEBIAN_FRONTEND=noninteractive

# Version du GitHub Actions runner utilisée lors du build
# https://github.com/actions/runner/releases/
ARG RUNNER_VERSION="2.324.0"

# SHA-256 checksum de l'archive GitHub Actions runner utilisée pour vérifier son intégrité lors du build
ARG RUNNER_SHA256="e8e24a3477da17040b4d6fa6d34c6ecb9a2879e800aa532518ec21e49e21d7b4"

# Mise à jour de la liste des paquets et nettoyage du cache apt
RUN apt-get update && apt-get clean

# Installation des paquets nécessaires uniquement, sans dépendances recommandées & suppression de la liste des paquets
# - ca-certificates: https://packages.debian.org/fr/sid/ca-certificates
# - curl: https://packages.debian.org/fr/sid/curl
# - sudo: https://packages.debian.org/fr/sid/sudo
# - jq: https://packages.debian.org/fr/sid/jq
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    sudo \
    jq \
    && rm -rf /var/lib/apt/lists/*

# Création d’un utilisateur 'github' avec répertoire personnel pour exécuter le GitHub Actions runner
# https://manpages.debian.org/bookworm/passwd/useradd.8.fr.html
RUN useradd --create-home github

# Ajoute l'utilisateur 'github' au groupe sudo
# https://manpages.debian.org/bookworm/passwd/usermod.8.fr.html
RUN usermod --append --groups sudo github

# Ajoute une règle qui autorise le groupe sudoers d'exécuter des commandes sans mot de passe
RUN echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Passer sur le compte de l'utilisateur 'github'
USER github

# Définit le répertoire de travail pour le runner GitHub Actions (le créer s'il n'existe pas)
WORKDIR /actions-runner

# Téléchargement de l'archive GitHub Actions runner avec curl
RUN curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Vérifie l'intégrité de l'archive à l'aide du checksum SHA-256 attendu
RUN echo "${RUNNER_SHA256} actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | sha256sum --check

# Extrait l'archive du GitHub Actions runner, puis la supprime après extraction
RUN tar xzf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    rm -rf ./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Lance le script 'installdependencies.sh' du GitHub Actions runner pour installer les dépendances manquantes
# https://github.com/actions/runner/blob/main/docs/start/envlinux.md
RUN sudo ./bin/installdependencies.sh

# Copie le script d'entrée dans le répertoire actions-runner et attribue la propriété à l'utilisateur et au groupe 'github'
COPY --chown=github:github entrypoint.sh /actions-runner/entrypoint.sh

# Rend le script d'entrée exécutable
RUN chmod u+x /actions-runner/entrypoint.sh

# Définit l'exécutable par défaut du conteneur, ici le script 'entrypoint.sh'
ENTRYPOINT ["/actions-runner/entrypoint.sh"]