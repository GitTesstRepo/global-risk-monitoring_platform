SELECT
    t1.event_date AS date,
    t1.short_form_name AS country_name,
    t1.action_geo_country_code AS country_code,
    COUNT(*) AS event_count,
    ROUND(COUNT(*) * AVG(ABS(LEAST(t1.goldstein_scale, 0))), 2) AS risk_score,
    ROUND(COUNT(*) * AVG(ABS(LEAST(t1.avg_tone, 0))), 2) AS risk_score2

FROM {{ ref('fct_events') }} AS t1
WHERE t1.action_geo_country_code IS NOT NULL
GROUP BY t1.event_date, t1.short_form_name, t1.action_geo_country_code
QUALIFY RANK() OVER (PARTITION BY t1.event_date ORDER BY risk_score DESC) <= 10
