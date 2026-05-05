WITH base as
(SELECT * FROM {{ref('fct_player_summary')}})
,
final as

(SELECT * 
from base
WHERE churn_risk='high risk' AND is_churned =False
)

SELECT * FROM final