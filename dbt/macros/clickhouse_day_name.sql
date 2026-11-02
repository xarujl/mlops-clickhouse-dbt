{# dbt_date does not ship a ClickHouse day_name implementation in this release. #}
{% macro clickhouse__day_name(date, short=True) %}
    {% set long_name %}
        multiIf(
            toDayOfWeek({{ date }}) = 1, 'Monday',
            toDayOfWeek({{ date }}) = 2, 'Tuesday',
            toDayOfWeek({{ date }}) = 3, 'Wednesday',
            toDayOfWeek({{ date }}) = 4, 'Thursday',
            toDayOfWeek({{ date }}) = 5, 'Friday',
            toDayOfWeek({{ date }}) = 6, 'Saturday',
            'Sunday'
        )
    {% endset %}
    {% if short %}
        substring({{ long_name }}, 1, 3)
    {% else %}
        {{ long_name }}
    {% endif %}
{% endmacro %}
