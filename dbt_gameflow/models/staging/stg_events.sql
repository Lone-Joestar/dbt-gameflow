-- one row per event _id

WITH 
source as
(SELECT * FROM raw.events)

,
final AS
(SELECT event_id,
player_id,
app_id,
event_type,
occurred_at,
hour(occurred_at) as event_hour,
dayofweek(occurred_at) as event_day_of_week,
session_id,
metadata

FROM source
)
SELECT * FROM final