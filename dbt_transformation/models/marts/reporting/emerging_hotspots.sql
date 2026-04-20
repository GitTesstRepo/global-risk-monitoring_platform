WITH daily_counts AS (
SELECT
    t1.event_date,
    t1.action_geo_country_code AS country_code,
    t1.short_form_name AS country_name,
    COUNT(*) AS event_count

FROM {{ ref('fct_events') }} AS t1
GROUP BY 
    t1.action_geo_country_code,
    t1.short_form_name,
    t1.event_date
),

rolling_metrics AS (
SELECT
    event_date,
    country_code,
    country_name,
    event_count,
    SUM(event_count) OVER (PARTITION BY country_code ORDER BY UNIX_DATE(event_date) RANGE BETWEEN 6 PRECEDING AND CURRENT ROW) AS curr7,
    SUM(event_count) OVER (PARTITION BY country_code ORDER BY UNIX_DATE(event_date) RANGE BETWEEN 13 PRECEDING AND 7 PRECEDING) AS prev7
FROM daily_counts
)

SELECT
    event_date,
    country_code,
    country_name,
    COALESCE(curr7, 0) - COALESCE(prev7, 0) AS hotspot_criteria
FROM rolling_metrics
WHERE country_code IS NOT NULL
    AND country_name IS NOT NULL
QUALIFY RANK() OVER (PARTITION BY event_date ORDER BY hotspot_criteria DESC) <= 10
