SELECT *
FROM patient_visits;

-- STEP 1
-- Tugas 1 hitung umur pasien dari date_of_birth (dob)
SELECT 
    patient_id,
    date_of_birth,
    TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age
FROM patient_visits;
-- TIMESTAMPDIFF(YEAR, dob, CURDATE()) → hitung umur dari tanggal lahir sampai hari ini
-- Syntax benar, tapi querry tidak muncul, hal ini karena date_of_birth masih dalam bentuk format Text BUKAN Date, harus diganti
-- FIX Querry
SELECT 
    patient_id,
    date_of_birth,
    TIMESTAMPDIFF(
        YEAR, 
        STR_TO_DATE(date_of_birth, '%m/%d/%Y'),
        CURDATE()
    ) AS age
FROM patient_visits;
-- STR_TO_DATE(date_of_birth, '%m/%d/%Y') ubah text jadi DATE

-- Tugas 2 kelompok umur (Age Group)
-- Querry pada date_of_birth masih dalam format text jika menggunakan syntax dibawah ini
SELECT 
    patient_id,
    date_of_birth,
    TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age,    
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 0 AND 17 THEN '0-17'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 18 AND 39 THEN '18-39'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 40 AND 64 THEN '40-64'
        ELSE '65+'
    END AS age_group
FROM patient_visits;
-- Note: CASE = seperti IF di Excel
-- FIX QUERRY
SELECT 
    patient_id,
    date_of_birth,
    TIMESTAMPDIFF(
        YEAR, 
        STR_TO_DATE(date_of_birth, '%m/%d/%Y'),
        CURDATE()
    ) AS age,
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%m/%d/%Y'), CURDATE()) BETWEEN 0 AND 17 THEN '0-17'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%m/%d/%Y'), CURDATE()) BETWEEN 18 AND 39 THEN '18-39'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%m/%d/%Y'), CURDATE()) BETWEEN 40 AND 64 THEN '40-64'
        ELSE '65+'
    END AS age_group
FROM patient_visits;

-- Tugas 3 hitung jumlah pasien per kelompok
-- QUERRY SALAH
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 0 AND 17 THEN '0-17'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 18 AND 39 THEN '18-39'
        WHEN TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) BETWEEN 40 AND 64 THEN '40-64'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS total_patients
FROM patient_visits
GROUP BY age_group
ORDER BY age_group;
-- FIX QUERRY
SELECT 
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%m/%d/%Y'), CURDATE()) BETWEEN 0 AND 17 THEN '0-17'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%m/%d/%Y'), CURDATE()) BETWEEN 18 AND 39 THEN '18-39'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%m/%d/%Y'), CURDATE()) BETWEEN 40 AND 64 THEN '40-64'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS total_patients
FROM patient_visits
GROUP BY age_group
ORDER BY age_group;
-- STEP / TASK 1 DONE

DESCRIBE patient_visits;


-- STEP 2
-- menghitung frekuensi ICD Code
SELECT 
    icd_code,
    COUNT(*) AS total_cases
FROM patient_visits
GROUP BY icd_code
ORDER BY total_cases DESC;

-- top 10 Diagnosis
SELECT 
    icd_code,
    COUNT(*) AS total_cases
FROM patient_visits
GROUP BY icd_code
ORDER BY total_cases DESC
LIMIT 10;

-- breakdown by age_group
SELECT 
    icd_code,
    CASE 
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%m/%d/%Y'), CURDATE()) BETWEEN 0 AND 17 THEN '0-17'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%m/%d/%Y'), CURDATE()) BETWEEN 18 AND 39 THEN '18-39'
        WHEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(date_of_birth, '%m/%d/%Y'), CURDATE()) BETWEEN 40 AND 64 THEN '40-64'
        ELSE '65+'
    END AS age_group,
    COUNT(*) AS total_cases
FROM patient_visits
GROUP BY icd_code, age_group
ORDER BY total_cases DESC;

-- breakdown by gender
SELECT 
    icd_code,
    patient_sex,
    COUNT(*) AS total_cases
FROM patient_visits
GROUP BY icd_code, patient_sex
ORDER BY total_cases DESC;
-- STEP 2 DONE!


-- STEP 3 VISIT UTILIZATION
-- Step 3A Total Visit Per Patient
SELECT 
    patient_id,
    COUNT(*) AS total_visits
FROM patient_visits
GROUP BY patient_id
ORDER BY total_visits DESC;

-- Step 3B Rata-rata Visit
SELECT 
    AVG(total_visits) AS avg_visits
FROM (
    SELECT 
        patient_id,
        COUNT(*) AS total_visits
    FROM patient_visits
    GROUP BY patient_id
) AS visit_counts;

-- Step 3C High Utilizers (>= 4 visit)
SELECT 
    patient_id,
    COUNT(*) AS total_visits
FROM patient_visits
GROUP BY patient_id
HAVING COUNT(*) >= 4
ORDER BY total_visits DESC;

-- Persentase High Utilizers
SELECT 
    COUNT(DISTINCT patient_id) AS high_utilizers,
    (SELECT COUNT(DISTINCT patient_id) FROM patient_visits) AS total_patients,
    COUNT(DISTINCT patient_id) * 100.0 / 
    (SELECT COUNT(DISTINCT patient_id) FROM patient_visits) AS percentage
FROM patient_visits
GROUP BY patient_id
HAVING COUNT(*) >= 4;
-- STEP 3 FIX DONE! [REAL-WORLD HEALTHCARE ANALYSIS]


-- FINAL STEP - STEP 4 (Procedure CPT) (TERAKHIR!)
-- Step 4A Ranking CPT CODE
SELECT 
    cpt_code,
    COUNT(*) AS total_procedures
FROM patient_visits
GROUP BY cpt_code
ORDER BY total_procedures DESC;

-- Step 4B Top Procedures
SELECT 
    cpt_code,
    COUNT(*) AS total_procedures
FROM patient_visits
GROUP BY cpt_code
ORDER BY total_procedures DESC
LIMIT 10;

SELECT * FROM patient_visits;