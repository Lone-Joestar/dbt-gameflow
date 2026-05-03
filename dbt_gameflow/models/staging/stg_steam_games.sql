-- one row per game
-- source: raw.steam_games (Kaggle Steam dataset, loaded via pandas)

with source as (

    select * from raw.steam_games

),

final as (

    select
        app_id,
        game_name,
        release_date,
        price_usd,
        peak_ccu                                            as peak_concurrent_users,
        required_age,
        genres,
        categories,
        positive_reviews,
        negative_reviews,
        coalesce(review_ratio, 0)                           as review_ratio,
        achievements                                        as achievement_count,
        avg_playtime_minutes,
        recommendations

    from source

)

select * from final