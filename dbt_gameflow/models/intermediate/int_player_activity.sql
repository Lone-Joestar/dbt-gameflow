-- one row per player

WITH
players as
(SELECT * FROM {{ref('stg_players')}}),

session_metrics as
(SELECT 
        player_id,
        COUNT(session_id) AS num_sessions,
        SUM(duration_minutes) as total_playtime,
        AVG(duration_minutes) as avg_session_length,
        SUM(CASE WHEN was_crash THEN 1 ELSE 0 END) as total_crashes,
        MAX(session_start) as last_seen_date

FROM {{ref('stg_sessions')}}
GROUP BY player_id
),
purchase_metrics as
(SELECT 
        player_id,
        COUNT(purchase_id) AS total_purchases,
        SUM(amount_usd) AS gross_revenue,
        SUM(CASE WHEN NOT is_refunded then amount_usd ELSE 0 END ) as net_revenue,
        COUNT(DISTINCT app_id) AS unique_games_played
FROM {{ref('stg_purchases')}}
GROUP BY player_id
),
event_metrics as
(SELECT
        player_id,
        COUNT(event_id) AS total_events,
        COUNT(CASE WHEN event_type='login' THEN 1 END) as total_logins,
        COUNT(CASE WHEN event_type='level_complete' THEN 1 END ) as total_levels,
        COUNT(CASE WHEN event_type='achievement_unlocked' THEN 1 END) as achievements_unlocked
FROM {{ref('stg_events')}}
GROUP BY player_id )
,
final as 
(
    SELECT p.*,
    s.num_sessions,
    s.total_playtime,
    s.avg_session_length,
    s.total_crashes,
    pu.total_purchases,
    pu.gross_revenue,
    pu.net_revenue,
    pu.unique_games_played,
    e.total_events,
    e.total_logins,
    e.total_levels,
    e.achievements_unlocked






    from players p
    left join session_metrics s on p.player_id=s.player_id
    left join purchase_metrics pu on p.player_id= pu.player_id
    left join event_metrics e on p.player_id=e.player_id
)

SELECT * from final
