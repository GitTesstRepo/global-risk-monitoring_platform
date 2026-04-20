WITH cte AS (
SELECT
    t1.action_geo_country_code,
    t1.short_form_name,
    SUM
    (
        CASE
            WHEN t1.event_date > CURRENT_DATE() - INTERVAL 3 DAY THEN 1
            ELSE 0
        END
    ) AS curr_3,
    SUM
    (
        CASE
        WHEN t1.event_date BETWEEN CURRENT_DATE() - INTERVAL 2 * 3 DAY AND CURRENT_DATE() - INTERVAL 3 DAY THEN 1
        ELSE 0
        END
    ) AS prev_3

FROM {{ ref('fct_events') }} AS t1
GROUP BY t1.action_geo_country_code, t1.short_form_name
)

SELECT
  action_geo_country_code AS country_code,
  short_form_name AS country_name,
  curr_3 - prev_3 AS criteria
FROM cte
WHERE action_geo_country_code IS NOT NULL
