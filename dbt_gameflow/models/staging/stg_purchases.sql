--one row per purchase transaction
-- source: raw.purchases
with source as
(SELECT purchase_id,
        player_id,
        app_id,
        purchased_at,
        month(purchased_at) as purchase_month,
        hour(purchased_at) as purchase_hour,
        amount_usd,
        payment_type,
        item_type,
        is_refunded
        FROM raw.purchases)
,
final AS    
    (SELECT * FROM source)

SELECT * from final