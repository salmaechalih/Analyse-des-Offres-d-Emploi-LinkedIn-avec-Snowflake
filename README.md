# Analyse-des-Offres-d-Emploi-LinkedIn-avec-Snowflake
# 📊 Analyse des Offres d'Emploi LinkedIn avec Snowflake

1.  Objectif du Projet :

Ce projet consiste à analyser des offres d’emploi publiées sur LinkedIn à l’aide de **Snowflake** et **Streamlit**. L’objectif est d’explorer le marché de l’emploi, identifier les tendances par secteur, entreprise ou type d’emploi, et visualiser ces insights à travers des tableaux interactifs.

---

2. Source des Données :

Les fichiers sont hébergés sur un bucket S3 public :  
`s3://snowflake-lab-bucket/`


3. Fichiers utilisés :
- `benefits.csv`
- `companies.json`
- `company_industries.json`
- `company_specialities.json`
- `employee_counts.csv`
- `job_industries.json`
- `job_postings.csv`
- `job_skills.csv`



4. Processus Réalisé : 

### 1️⃣ Création de la base de données
### 2️⃣ Définition des formats de fichier
### 3️⃣ Création du stage externe
### 4️⃣ Création des tables
### 5️⃣ Chargement des données

5. Analyses Réalisées
  ### ✅ Top 10 des titres de postes les plus publiés par industrie
  ![Texte alternatif](résultats%20obtenus/visualisation1.png)


