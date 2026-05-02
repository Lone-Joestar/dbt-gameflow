WITH source AS
(SELECT * FROM  raw.players ),

final AS (

    SELECT player_id,
    username,
    region,
    platform,
    subscription_tier,
    created_at,
    year(created_at) as signup_year,
    month(created_at) as signup_month,
    dayofweek(created_at) as signup_day_of_week,
    churned_at,
    is_churned,
    datediff('day',created_at,churned_at) as days_to_churn ,
    age_bucket,
    currency
    from source
        )


SELECT * FROM final 
