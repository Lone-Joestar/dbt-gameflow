WITH base as
(SELECT * FROM {{ref('int_session_enriched')}})
,
final AS

(
SELECT *,
RANk() OVER(PARTITION BY player_id ORDER BY duration_minutes DESC) as session_rank_by_duration,
LAG(session_start) OVER (PARTITION BY player_id ORDER BY session_start) as previous_session_date,
datediff('day',LAG(session_start) OVER (PARTITION BY player_id ORDER BY session_start) ,session_start) as days_since_last_session,
AVG(duration_minutes) OVER (PARTITION BY player_id ORDER BY session_start ROWS BETWEEN 6 PRECEDING AND CURRENT ROW ) as rolling_7sessions_avg_duration,
ROW_NUMBER() OVER (PARTITION BY player_id ORDER BY session_start) AS session_number,
SUm(duration_minutes) OVER (PARTITION BY player_id ORDER BY session_start) as cumulative_playtime ,
MAX(duration_minutes) OVER (PARTITION BY player_id) AS player_max_session,

duration_minutes - AVG(duration_minutes) OVER (PARTITION BY player_id) as duration_vs_avg_minutes
FROM base )

SELECT * from final 