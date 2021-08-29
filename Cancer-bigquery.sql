# CBD Assignment-01
# Cancer-bigquery
SQL queries from cancer dataset using google BigQuery 

### Q1. How many mutations have been observed in KRAS?
```sql
SELECT
  COUNT(DISTINCT(sample_barcode_tumor)) AS numSamples
FROM
  `isb-cgc-bq.TCGA_versioned.somatic_mutation_hg38_gdc_r10`
WHERE
  Hugo_Symbol="KRAS"
```
![image](https://user-images.githubusercontent.com/89738639/131255648-d1298614-1f27-4b70-a8d0-c84ff4c7934e.png)

### Q2. What are the most frequently observed mutations and how often do they occur?
```sql
WITH
  temp1 AS (
  SELECT
    sample_barcode_tumor,
    Hugo_Symbol,
    Variant_Classification,
    Variant_Type,
    SIFT,
    PolyPhen
  FROM
    `isb-cgc-bq.TCGA_versioned.somatic_mutation_hg38_gdc_r10`
  GROUP BY
    sample_barcode_tumor,
    Hugo_Symbol,
    Variant_Classification,
    Variant_Type,
    SIFT,
    PolyPhen)
SELECT
  COUNT(*) AS num,
  Hugo_Symbol,
  Variant_Classification,
  Variant_Type,
  SIFT,
  PolyPhen
FROM
  temp1
GROUP BY
  Hugo_Symbol,
  Variant_Classification,
  Variant_Type,
  SIFT,
  PolyPhen
ORDER BY
  num DESC
  ```
  ![image](https://user-images.githubusercontent.com/89738639/131255666-53aba176-f6cd-4d2f-aa0a-64ba0275db10.png)

  ### Q3. Which are the different patients with bladder cancer who have mutations in the CDKN2A gene?
  ```sql
  SELECT
  mutation.case_barcode,
  mutation.Variant_Type
FROM
  `isb-cgc-bq.TCGA_versioned.somatic_mutation_hg19_DCC_2017_02` AS mutation
WHERE
  mutation.Hugo_Symbol = 'CDKN2A'
  AND project_short_name = 'TCGA-LUSC'
GROUP BY
  mutation.case_barcode,
  mutation.Variant_Type
ORDER BY
  mutation.case_barcode
  ```
  ![image](https://user-images.githubusercontent.com/89738639/131255682-c5e1128d-6cfe-4d95-8073-27ca5de05454.png)

  ### Q4. Find the patient data for mutation as 'CDKN2A' and project name as 'TCGA-LUSC'.
  ```sql
  SELECT
  case_list.case_barcode AS case_barcode,
  case_list.Variant_Type AS Variant_Type,
  clinical.demo__gender,
  clinical.demo__vital_status,
  clinical.demo__days_to_death
FROM
  /* this will get the unique list of cases having the TP53 gene mutation in BRCA cases*/
  ( SELECT
    mutation.case_barcode,
    mutation.Variant_Type
  FROM
    isb-cgc-bq.TCGA_versioned.somatic_mutation_hg19_DCC_2017_02 AS mutation
  WHERE
    mutation.Hugo_Symbol = 'CDKN2A'
    AND project_short_name = 'TCGA-LUSC'
  GROUP BY
    mutation.case_barcode,
    mutation.Variant_Type
  ORDER BY
    mutation.case_barcode
    ) AS case_list /* end case_list */
JOIN
  isb-cgc-bq.TCGA.clinical_gdc_current AS clinical
ON
  case_list.case_barcode = clinical.submitter_id
  ```
  ![image](https://user-images.githubusercontent.com/89738639/131255697-c6290991-fcd6-49ce-bc71-235bd1e99ade.png)

  ### Q5. What are the gene expression levels for 'MDM2', 'TP53', 'CDKN1A','CCNE1'?
  ```sql
  SELECT
  genex.case_barcode AS case_barcode,
  genex.sample_barcode AS sample_barcode,
  genex.aliquot_barcode AS aliquot_barcode,
  genex.HGNC_gene_symbol AS HGNC_gene_symbol,
  clinical_info.Variant_Type AS Variant_Type,
  genex.gene_id AS gene_id,
  genex.normalized_count AS normalized_count,
  genex.project_short_name AS project_short_name,
  clinical_info.demo__gender AS gender,
  clinical_info.demo__vital_status AS vital_status,
  clinical_info.demo__days_to_death AS days_to_death
FROM ( /* This will get the clinical information for the cases*/
  SELECT
    case_list.Variant_Type AS Variant_Type,
    case_list.case_barcode AS case_barcode,
    clinical.demo__gender,
    clinical.demo__vital_status,
    clinical.demo__days_to_death
  FROM
    /* this will get the unique list of cases having the CDKN2A gene mutation in bladder cancer BLCA cases*/
    (SELECT
      mutation.case_barcode,
      mutation.Variant_Type
    FROM
      isb-cgc-bq.TCGA_versioned.somatic_mutation_hg19_DCC_2017_02 AS mutation
    WHERE
      mutation.Hugo_Symbol = 'CDKN2A'
      AND project_short_name = 'TCGA-LUSC'
    GROUP BY
      mutation.case_barcode,
      mutation.Variant_Type
    ORDER BY
      mutation.case_barcode
      ) AS case_list /* end case_list */
  INNER JOIN
    isb-cgc-bq.TCGA.clinical_gdc_current AS clinical
  ON
    case_list.case_barcode = clinical.submitter_id /* end clinical annotation */ ) AS clinical_info
INNER JOIN
  isb-cgc-bq.TCGA_versioned.RNAseq_hg19_gdc_2017_02 AS genex
ON
  genex.case_barcode = clinical_info.case_barcode
WHERE
  genex.HGNC_gene_symbol IN ('MDM2', 'TP53', 'CDKN1A','CCNE1')
ORDER BY
  case_barcode,
  HGNC_gene_symbol
  ```
  ![image](https://user-images.githubusercontent.com/89738639/131255717-9a8ba84a-702f-460e-a53f-37bd2016bf1e.png)
