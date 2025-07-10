import streamlit as st
import pandas as pd
import altair as alt

from snowflake.snowpark.context import get_active_session

#  Titre & sous-titre de l'app
st.title(" Analyse des offres LinkedIn")
st.subheader(" 📊 1.Top 10 des titres de postes les plus publiés par secteur d'activité")

#  Récupérer la session Snowflake active
session = get_active_session()
#Analyse 1

#  Exécuter la requête SQL
query = """
SELECT 
  ji.industry_id, 
  jp.title, 
  COUNT(*) AS nb_postings
FROM linkedin.linkedin_schema.job_industries_csv ji
JOIN linkedin.linkedin_schema.job_postings jp ON ji.job_id = jp.job_id
GROUP BY ji.industry_id, jp.title
ORDER BY nb_postings DESC
LIMIT 10;
"""
df = session.sql(query).to_pandas()




#  Afficher le graphique en barres

df.columns = [col.lower() for col in df.columns]
st.bar_chart(df.set_index("title")["nb_postings"])








#Analyse 2
st.subheader("💰 2. Top 10 des postes les mieux rémunérés par industrie")

query = """
SELECT 
  ji.industry_id, 
  jp.title, 
  MAX(jp.max_salary) AS salaire_max
FROM linkedin.linkedin_schema.job_industries_csv ji
JOIN linkedin.linkedin_schema.job_postings jp ON ji.job_id = jp.job_id
WHERE jp.max_salary IS NOT NULL
GROUP BY ji.industry_id, jp.title
ORDER BY salaire_max DESC
LIMIT 10;
"""

#  Exécuter la requête d'abord
df = session.sql(query).to_pandas()

#  Nettoyage des colonnes et des types
df.columns = [col.lower() for col in df.columns]
df["salaire_max"] = pd.to_numeric(df["salaire_max"], errors="coerce")

#  Visualisation avec Altair
import altair as alt
chart = alt.Chart(df).mark_circle(size=100).encode(
    x='salaire_max:Q',
    y='title:N',
    color='industry_id:N',
    tooltip=['title', 'salaire_max', 'industry_id']
)
st.altair_chart(chart, use_container_width=True)







#analyse 3

st.subheader("🏢 3. Répartition des offres par taille d’entreprise")

query = """
SELECT 
  c.company_size, 
  COUNT(*) AS nb_jobs
FROM linkedin.linkedin_schema.job_postings jp
JOIN linkedin.linkedin_schema.companies_csv c ON jp.company_id = c.company_id
GROUP BY c.company_size
ORDER BY nb_jobs DESC;
"""
df = session.sql(query).to_pandas()
df.columns = [col.lower() for col in df.columns]




chart = alt.Chart(df).mark_bar().encode(
    x="nb_jobs:Q",
    y=alt.Y("company_size:N", sort='-x'),
    tooltip=["company_size", "nb_jobs"]
)

st.altair_chart(chart, use_container_width=True)



# Analyse 4


st.subheader("🏭 4.Répartition des offres par secteur d’activité")

query = """
SELECT 
  ci.industry, 
  COUNT(*) AS nb_jobs
FROM linkedin.linkedin_schema.job_postings jp
JOIN linkedin.linkedin_schema.company_industries_csv ci ON jp.company_id = ci.company_id
GROUP BY ci.industry
ORDER BY nb_jobs DESC;
"""
df = session.sql(query).to_pandas()
df.columns = [col.lower() for col in df.columns]
df.columns = [col.lower() for col in df.columns]
df.rename(columns={"secteur": "industry", "nb_jobs": "offres"}, inplace=True)


chart = alt.Chart(df).mark_arc(innerRadius=30, outerRadius=100).encode(
    theta="offres:Q",
    color="industry:N",
    tooltip=["industry", "offres"]
)
st.altair_chart(chart, use_container_width=True)


# analyse 5
st.subheader("⏱️ 5. Répartition par type d’emploi")

query = """
SELECT 
  formatted_work_type, 
  COUNT(*) AS nb_jobs
FROM linkedin.linkedin_schema.job_postings
WHERE formatted_work_type = 'Full-time' 
   or  formatted_work_type = 'Internship' 
   or  formatted_work_type = 'Part-time'
GROUP BY formatted_work_type
ORDER BY nb_jobs DESC;
"""
df = session.sql(query).to_pandas()
df.columns = [col.lower() for col in df.columns]
df.columns = [col.lower() for col in df.columns]



st.bar_chart(df.set_index("formatted_work_type")["nb_jobs"])



