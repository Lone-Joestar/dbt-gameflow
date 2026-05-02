{% macro safe_divide(numerator,denominator) %}
    round({{numerator}}/nullif({{denominator}},0),2)
{% endmacro %}