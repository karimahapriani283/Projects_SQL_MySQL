SELECT * FROM ds_salaries;

-- Apakah ada data yang NULL?
SELECT *
FROM ds_salaries
WHERE
	work_year IS NULL
	OR experience_level IS NULL
	OR employment_type IS NULL
	OR job_title IS NULL
	OR salary IS NULL
	OR salary_currency IS NULL
	OR salary_in_usd IS NULL
	OR employee_residence IS NULL
	OR remote_ratio IS NULL
	OR company_location IS NULL
	OR company_size IS NULL;

-- 1. Melihat ada job title apa saja
SELECT DISTINCT job_title
FROM ds_salaries
ORDER BY job_title;

SELECT DISTINCT job_title 
FROM ds_salaries
ORDER BY job_title ASC;

-- 2. Job title apa saja yang berkaitan dengan data analyst
SELECT DISTINCT job_title
FROM ds_salaries
WHERE job_title LIKE '%data analyst%'
ORDER BY job_title;
--
SELECT DISTINCT job_title 
FROM ds_salaries 
WHERE job_title LIKE '%Data Analyst%'
ORDER BY job_title ASC;

-- 3.0 Berapa rata-rata gaji data analyst?
SELECT AVG(salary_in_usd) AS avg_salary_in_usd
FROM ds_salaries;
-- Revisi jawaban no. 3.0
SELECT AVG(salary_in_usd) AS avg_salary_in_usd
FROM ds_salaries
WHERE job_title LIKE '%data analyst%';

-- 3.a rata-rata gaji tiap jabatan
SELECT job_title,
ROUND(AVG(salary_in_usd), 0) AS avg_salary_in_usd
FROM ds_salaries
GROUP BY job_title;
-- 3. b. rata-rata gaji khusus posisi "Data Analyst"
SELECT ROUND(AVG(salary_in_usd)) AS avg_salary_in_usd
FROM ds_salaries
WHERE job_title = 'Data Analyst';
-- 3.c rata-rata gaji semua variasi jabatan yang mengandung "Data Analyst"
SELECT ROUND(AVG(salary_in_usd)) AS avg_salary_in_usd
FROM ds_salaries
WHERE job_title LIKE '%Data Analyst%';

-- 4.0 Berapa rata-rata gaji data analyst berdasarkan experience levelnya?
SELECT experience_level,
	(AVG(salary_in_usd) * 15000) / 12 AS avg_sal_rp_monthly
FROM ds_salaries
GROUP BY experience_level;

-- 4.a. rata-rata gaji bulanan (Rp)
SELECT experience_level,
	ROUND((AVG(salary_in_usd) * 15000) / 12) AS avg_sal_rp_monthly,
	COUNT(*) AS total_employee
FROM ds_salaries
WHERE job_title LIKE '%data analyst%'
GROUP BY experience_level
ORDER BY
	CASE experience_level
		WHEN 'EN' THEN 1
		WHEN 'MI' THEN 2
		WHEN 'SE' THEN 3
		WHEN 'EX' THEN 4
END;
-- 4.b. rata-rata gaji tahunan (dalam USD) untuk seorang Data Analyst berdasarkan tingkat pengalamannya?
-- rata-rata gaji tahunan
SELECT 
    experience_level, 
    ROUND(AVG(salary_in_usd), 0) AS avg_salary_usd,
    COUNT(*) AS total_employee
FROM ds_salaries
WHERE job_title LIKE '%Data Analyst%'
GROUP BY experience_level
ORDER BY avg_salary_usd DESC;
-- 4.c. Pengaruh Pengalaman terhadap Gaji pada semua posisi pekerjaan
SELECT experience_level, 
    ROUND(AVG(salary_in_usd), 0) AS avg_salary_in_usd
FROM ds_salaries
GROUP BY experience_level
ORDER BY avg_salary_in_usd DESC;

-- 5.1. Berapa rata-rata gaji data analyst berdasarkan experience level dan jenis employment?
SELECT
	experience_level,
	employment_type,
	(AVG(salary_in_usd) * 15000) / 12 AS avg_sal_rp_monthly
FROM ds_salaries
GROUP BY
	experience_level,
	employment_type
ORDER BY
	experience_level,
	employment_type;

-- 5.a. rata-rata gaji (Rp) data analyst berdasarkan experience level dan jenis employment?
SELECT
	experience_level,
	employment_type,
	ROUND(AVG(salary_in_usd) * 15000 / 12) AS avg_sal_rp_monthly
FROM ds_salaries
WHERE job_title LIKE '%data analyst%'
GROUP BY
	experience_level,
	employment_type
ORDER BY
	CASE experience_level
		WHEN 'EN' THEN 1
        WHEN 'MI' THEN 2
        WHEN 'SE' THEN 3
        WHEN 'EX' THEN 4
    END,
	employment_type;
-- 5.b. rata-rata gaji (USD) data analyst berdasarkan experience level dan jenis employment?
SELECT
	experience_level,
	employment_type,
	ROUND(AVG(salary_in_usd) / 12) AS avg_sal_usd_monthly
FROM ds_salaries
WHERE job_title LIKE '%data analyst%'
GROUP BY
	experience_level,
	employment_type
ORDER BY
	CASE experience_level
		WHEN 'EN' THEN 1
        WHEN 'MI' THEN 2
        WHEN 'SE' THEN 3
        WHEN 'EX' THEN 4
    END,
	employment_type;
-- 5.c. Negara dengan gaji yang menarik untuk posisi data analyst, full time, exp kerjanya entry level dan menengah / MI?
SELECT company_location,
	ROUND(AVG(salary_in_usd)) AS avg_sal_in_usd
FROM ds_salaries
WHERE job_title LIKE '%data analyst%'
	AND employment_type = 'FT'
	AND experience_level IN ('MI', 'EN')
GROUP BY company_location
HAVING avg_sal_in_usd >= 20000;

-- 6.a. Jumlah total employee pada semua posisi yang bekerja 100% secara remote penuh
SELECT COUNT(*) AS total_employee_remote
FROM ds_salaries
WHERE remote_ratio = 100;
-- 6.b. Jumlah total employee dengan posisi Data Analyst yang bekerja 100% secara remote penuh
SELECT remote_ratio, COUNT(*) AS total_employee_remote
FROM ds_salaries
WHERE job_title LIKE '%data analyst%'
	  AND remote_ratio = 100;
-- 6.c. Tren Gaji Tahunan
SELECT work_year, 
    ROUND(AVG(salary_in_usd), 0) AS avg_salary_in_usd,
    COUNT(*) AS total_employee
FROM ds_salaries
GROUP BY work_year
ORDER BY work_year ASC;
-- 7. Top 5 Pekerjaan Paling Populer
SELECT job_title, 
    COUNT(*) AS total_employee
FROM ds_salaries
GROUP BY job_title
ORDER BY total_employee DESC
LIMIT 5;
-- 8. Analisis Kesenjangan Gaji Kerja Lokal (Domestic Employment)  vs Remote Luar Negeri (Cross-Border Employment)
SELECT 
    CASE 
        WHEN employee_residence = company_location THEN 'Domestic Employment'
        ELSE 'Cross-Border Employment'
    END AS status_job,
    ROUND(AVG(salary_in_usd), 0) AS avg_salary_in_usd,
    COUNT(*) AS total_employee
FROM ds_salaries
GROUP BY status_job;
-- 9. Ukuran Perusahaan vs Gaji
SELECT company_size, 
    ROUND(AVG(salary_in_usd), 0) AS avg_salary_in_usd
FROM ds_salaries
GROUP BY company_size
ORDER BY 
    CASE company_size
        WHEN 'S' THEN 1
        WHEN 'M' THEN 2
        WHEN 'L' THEN 3
    END;
-- 10.a. Di tahun berapa, kenaikan gaji dari MI ke SE itu memiliki kenaikan yang tertinggi? 
-- untuk pekerjaan yang berkaitan dengan data analyst yang penuh waktu
WITH ds_1 AS (
	SELECT work_year,
		ROUND(AVG(salary_in_usd)) AS sal_in_usd_se
	FROM ds_salaries
	WHERE
		employment_type = 'FT'
		AND experience_level = 'SE'
		AND job_title LIKE '%data analyst%'
	GROUP BY work_year
),
ds_2 AS (
	SELECT work_year,
		ROUND(AVG(salary_in_usd)) AS sal_in_usd_mi
	FROM ds_salaries
	WHERE
		employment_type = 'FT'
		AND experience_level = 'MI'
		AND job_title LIKE '%data analyst%'
	GROUP BY work_year
),
t_year AS (
	SELECT DISTINCT work_year
	FROM ds_salaries
)
SELECT
	t_year.work_year,
	ds_1.sal_in_usd_se,
	ds_2.sal_in_usd_mi,
	ds_1.sal_in_usd_se - ds_2.sal_in_usd_mi differences
FROM t_year
	LEFT JOIN ds_1 ON ds_1.work_year = t_year.work_year
	LEFT JOIN ds_2 ON ds_2.work_year = t_year.work_year;
-- 10.b. Di tahun berapa, kenaikan gaji dari MI ke EX itu memiliki kenaikan yang tertinggi? 
-- untuk pekerjaan yang berkaitan dengan data analyst yang penuh waktu
WITH ds_1 AS (
	SELECT work_year,
		ROUND(AVG(salary_in_usd)) AS sal_in_usd_ex
	FROM ds_salaries
	WHERE
		employment_type = 'FT'
		AND experience_level = 'EX'
		AND job_title LIKE '%data analyst%'
	GROUP BY work_year
),
ds_2 AS (
	SELECT work_year,
		ROUND(AVG(salary_in_usd)) AS sal_in_usd_mi
	FROM ds_salaries
	WHERE
		employment_type = 'FT'
		AND experience_level = 'MI'
		AND job_title LIKE '%data analyst%'
	GROUP BY work_year
),
t_year AS (
	SELECT DISTINCT work_year
	FROM ds_salaries
)
SELECT
	t_year.work_year,
	ds_1.sal_in_usd_ex,
	ds_2.sal_in_usd_mi,
	ds_1.sal_in_usd_ex - ds_2.sal_in_usd_mi differences
FROM t_year
	LEFT JOIN ds_1 ON ds_1.work_year = t_year.work_year
	LEFT JOIN ds_2 ON ds_2.work_year = t_year.work_year;
-- 10.c. Perbadingan Rata-rata Gaji per Pekerjaan antara Tahun 2020 dan  2022
WITH salary_2020 AS (
    SELECT job_title, AVG(salary_in_usd) AS avg_salary_2020
    FROM ds_salaries
    WHERE work_year = 2020
    GROUP BY job_title
),
salary_2022 AS (
    SELECT job_title, AVG(salary_in_usd) AS avg_salary_2022
    FROM ds_salaries
    WHERE work_year = 2022
    GROUP BY job_title
)
SELECT 
    s22.job_title,
    ROUND(s20.avg_salary_2020, 0) AS avg_salary_2020,
    ROUND(s22.avg_salary_2022, 0) AS avg_salary_2022,
    ROUND(s22.avg_salary_2022 - s20.avg_salary_2020, 2) AS nominal_increase,
    ROUND(((s22.avg_salary_2022 - s20.avg_salary_2020) / s20.avg_salary_2020) * 100, 2) AS percentage_increase
FROM salary_2022 AS s22
JOIN salary_2020 AS s20 ON s22.job_title = s20.job_title
ORDER BY percentage_increase DESC;










-- Data employee Full-Time (FT) dengan pengalaman Senior (SE) pada semua posisi
SELECT * 
FROM ds_salaries
WHERE employment_type = 'FT' 
  AND experience_level = 'SE';
-- Data employee Full-Time (FT) dengan pengalaman SE pada posisi Data Analyst
SELECT *
FROM ds_salaries
WHERE employment_type = 'FT'
	AND experience_level = 'SE'
    AND job_title LIKE '%data analyst%';











-- Peringkat Gaji Tertinggi untuk Setiap Jenis Pekerjaan
SELECT job_title,
    salary_in_usd,
    DENSE_RANK() OVER (PARTITION BY job_title ORDER BY salary_in_usd DESC) AS rank_salary
FROM ds_salaries;



