WITH base as
(SELECT * FROM {{ref('int_game_metrics')}}),

final AS
(
SELECT  *,
RANK() OVER (ORDER BY gross_revenue DESC) as revenue_rank,
RANK() OVER (ORDER BY total_sessions DESC) as popularity_rank,
RANK() OVER (PARTITION BY genres ORDER BY gross_revenue DESC) AS genre_revenue_rank
FROM base
)

SELECT * FROM final