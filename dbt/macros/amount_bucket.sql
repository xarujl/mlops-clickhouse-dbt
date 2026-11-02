{% macro amount_bucket(amount_expression) %}
    multiIf(
        {{ amount_expression }} < 25, 'small',
        {{ amount_expression }} < 100, 'medium',
        {{ amount_expression }} < 500, 'large',
        'very_large'
    )
{% endmacro %}
