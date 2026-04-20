WITH events AS (
    SELECT * FROM {{ ref('stg_external_gdelt_events_csv') }}
),

geo_types AS (
    SELECT 
        DISTINCT action_geo_type AS geo_type_id,
        {{ get_geo_type_names('action_geo_type') }} AS geo_type_name
    FROM events
)

SELECT * FROM geo_types