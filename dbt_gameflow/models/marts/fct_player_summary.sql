WITH 

base as (SELECT * FROM {{ref('int_player_activity')}} ),
final AS
(
    SELECT 
    *,
    {{safe_divide('total_playtime','num_sessions')}} as playtime_per_session,
    case 
        when num_sessions = 0 then 'inactive'
        when num_sessions <5 then 'casual'
        when num_sessions <20 then 'regular'
        else 'power user'
    end as player_segment,
    datediff('day',last_seen_date,current_date) as days_since_last_session,

    case 
        when is_churned then 'churned'
        when datediff('day',last_seen_date,current_date)>30 then 'high risk'
        when datediff('day',last_seen_date,current_date)>14 then 'medium risk'
        else 'healthy'
    end as churn_risk

FROM base

)

SELECT * from final 