# ☁️ Projet : Architecture API-Driven sur AWS simulé (LocalStack)

## 📖 Présentation du projet
L'objectif de ce TP est de mettre en place une architecture Cloud "Serverless" permettant de piloter des ressources d'infrastructure (EC2) via des requêtes HTTP. 

Toute l'infrastructure est simulée localement grâce à **LocalStack**, permettant de reproduire un environnement AWS complet (API Gateway, Lambda, EC2) au sein de GitHub Codespaces sans frais.

---

## 🏗️ Architecture Cible
Le flux de données suit ce parcours :
1. **Utilisateur** : Envoie une requête HTTP `GET` avec des paramètres (ex: `action=stop`).
2. **API Gateway** : Reçoit la requête et la transmet à la fonction Lambda.
3. **AWS Lambda** : Exécute un code Python (`boto3`) pour interagir avec le service EC2.
4. **Instance EC2** : Change d'état (Démarrage ou Arrêt) selon l'ordre reçu.



---

## 🛠️ Stack Technique
* **Émulateur Cloud** : LocalStack
* **Outils CLI** : AWS CLI & `awslocal` (wrapper pour LocalStack)
* **Langage** : Python 3.9 (Boto3)
* **Automatisation** : Bash Scripting

---

## 🚀 Installation et Déploiement

### 1. Préparation de l'environnement
Dans votre terminal Codespace, installez les dépendances nécessaires :
```bash
# Installation de l'AWS CLI (v2) et de awslocal
curl "[https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip](https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip)" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install
pip install awscli-local
```
Lancement de LocalStack
```
localstack start -d
# Attendre que les services soient "ready"
localstack status services
```
J'ai conçu un script deploy_aws.sh qui automatise l'intégralité du provisionnement :

Bash
```

chmod +x deploy_aws.sh
./deploy_aws.sh
```

---

## 🔍 Test et Vérification

Une fois le script terminé, vous pouvez piloter l'instance avec une commande `curl` :

### Arrêter l'instance :
```bash
curl "http://localhost:4566/restapis/<ID_API>/prod/_user_request_/control?action=stop&instance_id=<ID_INSTANCE>"
```
Vérification du statut (CLI) :
```
awslocal ec2 describe-instances --query 'Reservations[0].Instances[0].State.Name'
