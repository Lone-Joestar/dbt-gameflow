WITH 
game as 
(SELECT
app_id,
game_name,
genres,
price_usd,
review_ratio,
achievement_count,
peak_concurrent_users 
FROM {{ref('stg_steam_games')}}
),

session_metrics AS
(SELECT 
app_id,
COUNT(session_id) as total_sessions,
SUM(duration_minutes) as total_playtime_minutes,
AVG(duration_minutes) as avg_session_duration,
SUM(CASE WHEN was_crash THEN 1 ELSE 0 END) as total_crashes,
{{safe_divide('SUM(CASE WHEN was_crash THEN 1 ELSE 0 END)','COUNT(session_id)')}} as crash_rate

FROM {{ref('stg_sessions')}}
GROUP BY app_id),

purchase_metrics AS
(
SELECT 
    app_id,
    COUNT(purchase_id) as total_purchases,
    SUM(amount_usd) as gross_revenue,
    SUM(CASE WHEN NOT is_refunded THEN amount_usd ELSE 0 END ) as net_revenue,
    COUNT(DISTINCT player_id) as unique_buyers

FROM {{ref('stg_purchases')}}
GROUP BY app_id
),

final AS
(
    SELECT 
    g.app_id,
    g.game_name,
g.genres,
g.price_usd,
g.review_ratio,
g.achievement_count,
g.peak_concurrent_users ,
s.total_sessions,
s.total_playtime_minutes,
s.avg_session_duration,
s.total_crashes,
s.crash_rate,
p.total_purchases,
p.gross_revenue,
p.net_revenue,
p.unique_buyers

FROM game g
left join session_metrics s on g.app_id=s.app_id
left join purchase_metrics p on g.app_id=p.app_id
)

SELECT * FROM final