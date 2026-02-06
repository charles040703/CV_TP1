📖 Présentation du projet
Ce projet met en œuvre une architecture "Serverless" permettant de contrôler des ressources Amazon EC2 via une interface API REST. L'intégralité de l'infrastructure est simulée localement avec LocalStack, reproduisant un environnement AWS réel au sein de GitHub Codespaces.

🏗️ Architecture Technique
Le flux de contrôle est le suivant :

Requête HTTP : L'utilisateur appelle une URL spécifique (/start, /stop ou /status).

API Gateway : Réceptionne l'appel et le transmet à une fonction Lambda.

AWS Lambda : Exécute le code Python (boto3) pour interagir avec le service EC2.

Service EC2 : L'instance cible change d'état ou retourne son statut.

🛠️ Stack Technique
Simulation Cloud : LocalStack 4.13

Langage : Python 3.9 (SDK Boto3)

Automatisation : Script Bash (AWS CLI / awslocal)

Accès Externe : Port Forwarding GitHub Codespaces

🚀 Installation et Déploiement
1. Préparation de l'environnement
Bash

# Installation de l'AWS CLI v2 et de awslocal
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install
pip install awscli-local
2. Lancement de LocalStack
Bash

localstack start -d
3. Déploiement Automatisé
J'ai conçu un script deploy_aws.sh qui automatise 100% du provisionnement (nettoyage, création EC2, packaging Lambda, routes API Gateway) :

Bash

chmod +x deploy_aws.sh
./deploy_aws.sh
🔍 Tests et Pilotage (URLs de Démonstration)
Grâce au port forwarding de GitHub, l'API est accessible publiquement via les endpoints suivants (remplacer les IDs par ceux générés par le script) :

Statut de l'instance :

https://<CODESPACE_URL>/restapis/<API_ID>/prod/_user_request_/status

Démarrer l'instance :

https://<CODESPACE_URL>/restapis/<API_ID>/prod/_user_request_/start

Arrêter l'instance :

https://<CODESPACE_URL>/restapis/<API_ID>/prod/_user_request_/stop

💡 Choix Techniques & Optimisations
🌐 Résolution DNS Interne
Pour permettre à la Lambda de communiquer avec le service EC2 sans utiliser localhost (qui désignerait le conteneur de la Lambda lui-même), j'ai utilisé l'endpoint interne : http://localhost.localstack.cloud:4566. Cela garantit la stabilité de la communication inter-services.

⏱️ Gestion du Timeout
Le timeout de la Lambda a été porté à 10 secondes pour absorber le "Cold Start" du conteneur lors de la première requête et assurer une réponse fiable à l'API Gateway.

🔄 Idempotence du Script
Le script de déploiement inclut une phase de nettoyage automatique (delete-function, delete-rest-api) permettant de relancer le déploiement à l'infini sans erreur de conflit de ressources.
