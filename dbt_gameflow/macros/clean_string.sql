{% macro clean_string(column_name) %}

    lower(trim({{column_name}}))

    {% endmacro %}