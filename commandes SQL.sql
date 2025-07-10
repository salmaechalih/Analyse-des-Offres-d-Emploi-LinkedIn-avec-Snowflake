----creation de la base de donnée Likedein-----------------
CREATE OR REPLACE DATABASE linkedin;
USE DATABASE linkedin;
CREATE OR REPLACE SCHEMA linkedin_schema;
USE SCHEMA linkedin_schema;

USE DATABASE linkedin;
USE SCHEMA linkedin_schema;

CREATE or replace FILE FORMAT csv_format
TYPE = 'CSV'
FIELD_DELIMITER = ','
RECORD_DELIMITER = '\n'
SKIP_HEADER = 1
field_optionally_enclosed_by = '\042'
null_if = ('');



-------------creation de stage --------------------
CREATE OR REPLACE STAGE linkedin_stage
URL = 's3://snowflake-lab-bucket/';

LIST @linkedin_stage;

SHOW STAGES;

--********************** creation des tables ***************************--



---------------------for Table jobstings-------------------------------

--***creation de  table job_stings***---
CREATE OR REPLACE TABLE job_postings (
job_id number,
company_id number,
title VARCHAR,
description VARCHAR,
max_salary number,
med_salary number,
min_salary number,
pay_period VARCHAR,
formatted_work_type VARCHAR,
location_ VARCHAR,
applies number,
original_listed_time number,
remote_allowed number,
views_ number,
job_posting_url VARCHAR,
application_url VARCHAR,
application_type VARCHAR,
expiry number,
closed_time number,
formatted_experience_level varchar,
skills_desc varchar,
listed_time number,
posting_domain varchar,
sponsored number,
work_type varchar,
currency VARCHAR,
compensation_type VARCHAR
);
select title from job_postings;
--***verification des données***--
select * from job_postings ;
--***Importaion des données depuis le stage ***--
COPY INTO job_postings
FROM @linkedin_stage/job_postings.csv
FILE_FORMAT = (
  TYPE = 'CSV',
  SKIP_HEADER = 1,
  FIELD_OPTIONALLY_ENCLOSED_BY = '"',
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

------------------------for table Benifits------------------

--***creation de table BENEFITS***---
CREATE OR REPLACE TABLE BENEFITS (
    job_id number,
    inferred number,
    type varchar
);
--***Importaion des données depuis le stage ***--
COPY INTO BENEFITS
FROM @linkedin_stage/benefits.csv
FILE_FORMAT = (
  TYPE = 'CSV',
  SKIP_HEADER = 1,
  FIELD_OPTIONALLY_ENCLOSED_BY = '"',
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';
select * from  BENEFITS;

----------------------for table companies--------------------------------

--***creation de table Bcompanies***---
CREATE OR REPLACE TABLE companie (
  data VARIANT
);

--***Importaion des données depuis le stage ***--
COPY INTO companie
FROM @linkedin_stage/companies.json
FILE_FORMAT = (
  TYPE = 'JSON',
  STRIP_OUTER_ARRAY = TRUE,
  TRIM_SPACE = TRUE,
  NULL_IF = ('', 'null')
);
---***transformations requises pour assurer la cohérence des données (from json to csv)***---
CREATE OR REPLACE VIEW companies_csv AS
SELECT
  data:"company_id"::STRING AS company_id,
  data:"name"::STRING AS name,
  data:"description"::STRING AS description,
  data:"company_size"::NUMBER AS company_size,
  data:"state"::STRING AS state,
  data:"country"::STRING AS country,
  data:"city"::STRING AS city,
  data:"zip_code"::STRING AS zip_code,
  data:"address"::STRING AS address,
  data:"url"::STRING AS url
FROM companie;

select * from companies_csv;
--------------for employes count--------------------

--***creation de table employes count***---
CREATE OR REPLACE TABLE employes_count (
  company_id STRING,
  employee_count NUMBER,
  follower_count NUMBER,
  time_recorded NUMBER
);
--***Importaion des données depuis le stage ***--
COPY INTO employes_count
FROM @linkedin_stage/employee_counts.csv
FILE_FORMAT = (
  TYPE = 'CSV',
  SKIP_HEADER = 1,
  FIELD_OPTIONALLY_ENCLOSED_BY = '"',
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';

select * from employes_count;

------------for table job_skilles---------------

--***creation de table job_skilles***---
CREATE OR REPLACE TABLE job_skills (
  job_id number PRIMARY KEY,       
  skill_abr varchar     
);

--***Importaion des données depuis le stage ***--
COPY INTO job_skills 
FROM @linkedin_stage/job_skills.csv
FILE_FORMAT = (
  TYPE = 'CSV',
  SKIP_HEADER = 1,
  FIELD_OPTIONALLY_ENCLOSED_BY = '"',
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE';
------for table job_industries----------

--***creation de table job_industries***---
CREATE OR REPLACE TABLE job_industries_json (
  data VARIANT
);
--***Importaion des données depuis le stage ***--
COPY INTO job_industries_json
FROM @linkedin_stage/job_industries.json
FILE_FORMAT = (
  TYPE = 'JSON',
  STRIP_OUTER_ARRAY = TRUE,
  TRIM_SPACE = TRUE,
  NULL_IF = ('', 'null')
);
select * from job_industries_json;
---***transformations requises pour assurer la cohérence des données (from json to csv -->create a view )***---
CREATE OR REPLACE VIEW job_industries_csv AS
SELECT
  data:"industry_id"::string AS industry_id,
  data:"job_id"::string  AS job_id
FROM job_industries_json;

select * from job_industries_csv;

--------------------for table company sepcialities----------------------

--***creation de table company sepcialities***---
CREATE OR REPLACE TABLE Company_specialities (
  data VARIANT
);
--***Importaion des données depuis le stage ***--
COPY INTO Company_specialities
FROM @linkedin_stage/company_specialities.json
FILE_FORMAT = (
  TYPE = 'JSON',
  STRIP_OUTER_ARRAY = TRUE,
  TRIM_SPACE = TRUE,
  NULL_IF = ('', 'null')
);

---***transformations requises pour assurer la cohérence des données (from json to csv -->create a view )***---
CREATE OR REPLACE VIEW job_specialities_csv AS
SELECT
  data:"company_id"::string AS company_id,
  data:"speciality"::string  AS speciality
FROM Company_specialities;

select * from job_specialities_csv;

------------------company industries-------------------------

--***creation de table company industrie***---
CREATE OR REPLACE TABLE Company_industries (
  data VARIANT
);
--***Importaion des données depuis le stage ***--
COPY INTO Company_industries
FROM @linkedin_stage/company_industries.json
FILE_FORMAT = (
  TYPE = 'JSON',
  STRIP_OUTER_ARRAY = TRUE,
  TRIM_SPACE = TRUE,
  NULL_IF = ('', 'null')
);
---***transformations requises pour assurer la cohérence des données (from json to csv -->create a view )***---

CREATE OR REPLACE VIEW company_industries_csv AS
SELECT
  data:"company_id"::string AS company_id,
  data:"industry"::string  AS industry
FROM Company_industries;

select * from company_industries_csv;

--************************** Partie analyse *********************************---

---Top 10 des titres de postes les plus publiés par industrie.
SELECT 
  ji.industry_id, 
  jp.title, 
  COUNT(*) AS nb_postings
FROM job_industries_csv ji
JOIN job_postings jp ON ji.job_id = jp.job_id
GROUP BY ji.industry_id, jp.title
ORDER BY nb_postings DESC
LIMIT 10;
---Top 10 des postes les mieux rémunérés par industrie.






SELECT 
  ji.industry_id, 
  jp.title, 
  MAX(jp.max_salary) AS salaire_max
FROM job_industries_csv ji
JOIN job_postings jp ON ji.job_id = jp.job_id
WHERE jp.max_salary IS NOT NULL
GROUP BY ji.industry_id, jp.title
ORDER BY salaire_max DESC
LIMIT 10;
select * from job_postings

---Répartition des offres d’emploi par taille d’entreprise.

SELECT 
  c.company_size, 
  COUNT(*) AS nb_jobs
FROM job_postings jp
JOIN companies_csv c ON jp.company_id = c.company_id
GROUP BY c.company_size
ORDER BY nb_jobs DESC;


----Répartition des offres d’emploi par secteur d’activité.


SELECT 
  ci.industry, 
  COUNT(*) AS nb_jobs
FROM job_postings jp
JOIN company_industries_csv ci ON jp.company_id = ci.company_id
GROUP BY ci.industry
ORDER BY nb_jobs DESC;

------Répartition des offres d’emploi par type d’emploi (temps plein, stage, temps partiel).

SELECT 
  formatted_work_type, 
  COUNT(*) AS nb_jobs
FROM job_postings
WHERE formatted_work_type = 'Full-time' 
   or  formatted_work_type = 'Internship' 
   or  formatted_work_type = 'Part-time'
GROUP BY formatted_work_type
ORDER BY nb_jobs DESC;














