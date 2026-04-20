WITH fips AS (
    SELECT * FROM {{ ref ('fips') }}
),

renamed AS (
    SELECT
        Code AS code,
        Short_form_name AS short_form_name
    FROM fips
)

SELECT * FROM renamed