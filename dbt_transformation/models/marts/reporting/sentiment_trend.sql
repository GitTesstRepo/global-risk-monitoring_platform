WITH cte AS (
SELECT
    t1.event_date,
    ROUND(AVG(t1.goldstein_scale), 2) AS daily_mood

FROM {{ ref('fct_events') }} AS t1
GROUP BY t1.event_date
)

SELECT
    event_date AS date,
    ROUND(AVG(daily_mood) OVER (ORDER BY UNIX_DATE(event_date) RANGE BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS avg_sentiment
FROM cte
