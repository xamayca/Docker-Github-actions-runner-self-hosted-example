#!/bin/bash

# Définit les labels du runner GitHub Actions auto-hébergé
export GITHUB_RUNNER_LABELS="x64,linux"

# Définit le répertoire de travail du runner GitHub Actions auto-hébergé
export GITHUB_RUNNER_WORKDIR="workdir-runner"

# Vérifie que les variables d'environnement requises sont définies et les exporte
for variable in GITHUB_REPOSITORY_OWNER GITHUB_REPOSITORY_NAME GITHUB_PERSONAL_TOKEN; do
  if [ -z "${!variable}" ]; then
    echo "⚠️ $variable est manquante ou vide ! Veuillez la définir dans .env à la racine de votre projet."
    exit 1
  fi
  export "${variable}"="${!variable}"
done

echo "🚀 Demande d’un jeton pour le runner auto-hébergé GitHub Actions sur https://github.com/${GITHUB_REPOSITORY_OWNER}/${GITHUB_REPOSITORY_NAME}..."

# Requête l'API GitHub pour obtenir le jeton d'enregistrement du runner auto-hébergé GitHub Actions
# https://docs.github.com/fr/rest/actions/self-hosted-runners?apiVersion=2022-11-28#create-a-registration-token-for-a-repository
REQUEST=$(curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_PERSONAL_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/"${GITHUB_REPOSITORY_OWNER}"/"${GITHUB_REPOSITORY_NAME}"/actions/runners/registration-token)

echo "🔑 Extraction du jeton d'enregistrement avec JQ depuis la réponse de l'API GitHub..."

# Extrait le jeton d'enregistrement depuis la réponse de l'API avec jq et l'exporte comme variable d'environnement
GITHUB_RUNNER_TOKEN=$(echo "${REQUEST}" | jq --raw-output .token)

echo "📁 Création du répertoire de travail pour le runner auto-hébergé GitHub Actions..."
# Crée le répertoire de travail du runner auto-hébergé GitHub Actions dans le répertoire personnel de l'utilisateur
mkdir -p "${HOME}/${GITHUB_RUNNER_WORKDIR}"

echo "🔐 Attribution des permissions sur le répertoire de travail..."
# Applique les permissions en lecture, écriture et exécution pour le propriétaire, et lecture/exécution pour les autres
chmod 755 "${HOME}/${GITHUB_RUNNER_WORKDIR}"

echo "⚙️ Configuration du runner auto-hébergé GitHub Actions avec des paramètres personnalisés..."

# Exécution du script 'config.sh' de GitHub Actions pour configurer et installer le runner
# Pour voir les options disponibles, exécutez : ./config.sh --help
./config.sh \
  --unattended \
  --url https://github.com/"${GITHUB_REPOSITORY_OWNER}"/"${GITHUB_REPOSITORY_NAME}" \
  --token "${GITHUB_RUNNER_TOKEN}" \
  --name "${GITHUB_REPOSITORY_NAME}-actions-runner" \
  --labels "${GITHUB_RUNNER_LABELS}" \
  --work "${HOME}/${GITHUB_RUNNER_WORKDIR}" \
  --replace

echo "▶️  Démarrage du runner auto-hébergé GitHub Actions avec les paramètres spécifiés..."

# Fonction de nettoyage pour désenregistrer le runner GitHub Actions
cleanup() {
  echo "🧹 Fonction de nettoyage appelée, désenregistrement du runner auto-hébergé GitHub Actions..."
  ./config.sh remove --token "${GITHUB_RUNNER_TOKEN}"
}

# Appelle la fonction de nettoyage en cas d'interruption (Ctrl+C), de signal de terminaison ou à la sortie du script
trap cleanup INT TERM

# Exécute le script 'run.sh' de GitHub Actions en arrière-plan en passant tous les arguments reçus
./run.sh &
RUNNER_PID=$!

# Attend la fin du processus en arrière-plan (run.sh) avant de continuer
wait "$RUNNER_PID"