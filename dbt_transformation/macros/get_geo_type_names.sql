{% macro get_geo_type_names(geo_type_id) -%}
CASE
    WHEN {{ geo_type_id }} = 0 THEN 'NO INFO'
    WHEN {{ geo_type_id }} = 1 THEN 'COUNTRY'
    WHEN {{ geo_type_id }} = 2 THEN 'USSTATE'
    WHEN {{ geo_type_id }} = 3 THEN 'USCITY'
    WHEN {{ geo_type_id }} = 4 THEN 'WORLDCITY'
    WHEN {{ geo_type_id }} = 5 THEN 'WORLDSTATE'
END
{%- endmacro %}