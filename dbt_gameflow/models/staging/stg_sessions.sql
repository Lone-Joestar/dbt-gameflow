--one row per gaming session 
WITH source AS
(SELECT * FROM raw.sessions)
,
final AS
(SELECT 
            session_id,
            player_id,
            app_id,
            duration_minutes,

            case    
                when duration_minutes <15 then 'casual'
                when duration_minutes <60 then 'normal'
                when duration_minutes <180 then 'extended'
                else 'marathon'
            end as session_type,

            session_start,
            hour(session_start) as hour_session_start,
            dayofweek(session_start) as day_session_start,
            session_end,
            platform,
            region,
            was_crash
            from source)
SELECT * from final 