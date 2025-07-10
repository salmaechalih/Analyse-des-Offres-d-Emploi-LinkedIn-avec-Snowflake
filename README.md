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
  ![Texte alternatif](résultats%20obtenus/analyse1.png)
  
 ### ✅ Top 10 des postes les mieux rémunérés par industrie
  ![Texte alternatif](résultats%20obtenus/Analyse2.png)

  ### ✅ Répartition des offres d’emploi par taille d’entreprise
   ![Texte alternatif](résultats%20obtenus/analyse3.png)
   
 ### ✅ Répartition par secteur d’activité
  ![Texte alternatif](résultats%20obtenus/analyse4.png)

  ### ✅ Répartition par type d’emploi (temps plein, partiel, stage)
  ![Texte alternatif](résultats%20obtenus/analyse5.png)

 6. résultats obtenus (visualisation avec streamlit )

### ✅ Top 10 des titres de postes les plus publiés par industrie
 ![Texte alternatif](résultats%20obtenus/visualisation1.png)
 
### ✅ Top 10 des postes les mieux rémunérés par industrie
![Texte alternatif](résultats%20obtenus/visualisation2.png)

### ✅ Répartition des offres d’emploi par taille d’entreprise
![Texte alternatif](résultats%20obtenus/visualisation3.png)

### ✅ Répartition par secteur d’activité
![Texte alternatif](résultats%20obtenus/visualisation4.png)

### ✅ Répartition par type d’emploi (temps plein, partiel, stage)
![Texte alternatif](résultats%20obtenus/visualisation5.png)

7. Les problèmes rencontrés et les solutions apportées
   
-----------------------------------------------------------------------------------------------------------------------------------------------------------
      Problème	                                                              Solution
 -----------------------------------------------------------------------------------------------------------------------------------------------------------
❌ Difficulté à charger les fichiers JSON via COPY INTO	     Les fichiers JSON avaient des tableaux externes et parfois des valeurs 'null' ou des espaces                                                                parasites. La solution a été de définir un format JSON avancé
------------------------------------------------------------------------------------------------------------------------------------------------------------
❌ Requêtes SQL dans Streamlit ne reconnaissent pas les       Les requêtes dans Streamlit doivent utiliser le nom complet : 
tables	                                                      linkedin.linkedin_schema.nom_table, faute de quoi Snowflake ne trouve pas les tables
------------------------------------------------------------------------------------------------------------------------------------------------------------
❌ Erreur dans le traitement de la colonne salaire_max	      La colonne contenait des valeurs non numériques ou manquantes. La solution :                                                                                df["salaire_max"] = pd.to_numeric(df["salaire_max"], errors="coerce")
------------------------------------------------------------------------------------------------------------------------------------------------------------


  
  

  


