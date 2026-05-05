WITH games AS
(SELECT app_id,game_name
FROM {{ref('stg_steam_games')}}),

players as
(SELECT 
player_id,
region,
platform,
subscription_tier,
created_at,
currency
FROM {{ref('stg_players')}})

,
purchase as
(SELECT * FROM {{ref('stg_purchases')}})
,


final as
(
    SELECT pu.*,
g.game_name,
p.region,
p.platform,
p.subscription_tier,
p.currency,
RANK() OVER (PARTITION BY p.player_id ORDER BY pu.purchased_at) as purchase_sequence,
SUM(pu.amount_usd) OVER (PARTITION by p.player_id ORDER BY pu.purchased_at) as cumulative_spending,
LAG(pu.purchased_at) OVER (PARTITION BY pu.player_id ORDER BY pu.purchased_at) as previous_purchase_date,
COUNT(purchase_id) OVER (PARTITION BY pu.player_id) as total_purchases_by_player,

datediff('day',
    LAG(pu.purchased_at) OVER (PARTITION BY pu.player_id ORDER BY pu.purchased_at),
    pu.purchased_at
) as days_between_purchases,



datediff('day',p.created_at,pu.purchased_at) as days_to_purchase

FROM purchase pu
left join players p on pu.player_id=p.player_id
left join games g on pu.app_id=g.app_id
)


SELECT * FROM final