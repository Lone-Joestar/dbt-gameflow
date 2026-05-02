{% macro is_valid_email(column_name) %}

{{column_name}} LIKE '%@%.%'

{% endmacro %}