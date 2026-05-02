{% macro cents_to_usd(column_name) %}

round({{column_name}}/100,2)

{% endmacro %}