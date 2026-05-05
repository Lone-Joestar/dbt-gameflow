WITH 
session_metrics AS

(SELECT * FROM {{ref('stg_sessions')}}),

players as
(   SELECT 
    player_id,
    region,
    subscription_tier
    FROM {{ref('stg_players')}}

),
games as
(
    SELECT app_id,
    game_name,
    genres
    FROM {{ref('stg_steam_games')}}
)

,

final AS

(SELECT 
s.*,

   
    p.region,
    p.subscription_tier,
    g.app_id,
    g.game_name,
    g.genres

FROM session_metrics s 
 left join players p on s.player_id= p.player_id
 left join games g on s.app_id=g.app_id
)
SELECT * from final 