import duckdb
import random
import pandas as pd
import uuid
from datetime import datetime, timedelta

random.seed(42)

# ── CONFIG ────────────────────────────────────────────────
N_PLAYERS     = 10_000
N_SESSIONS    = 200_000
N_PURCHASES   = 30_000
N_EVENTS      = 500_000

START_DATE    = datetime(2023, 1, 1)
END_DATE      = datetime(2024, 12, 31)

REGIONS       = ['NA', 'EU', 'APAC', 'LATAM', 'MEA']
PLATFORMS     = ['PC', 'PS5', 'Xbox', 'Mobile', 'Switch']
CURRENCIES    = ['USD', 'EUR', 'GBP', 'BRL', 'JPY']
SUB_TIERS     = ['free', 'basic', 'premium', 'ultimate']
EVENT_TYPES   = ['level_complete', 'achievement_unlocked', 'match_start',
                 'match_end', 'item_purchased', 'friend_added', 'login', 'logout']
PAYMENT_TYPES = ['credit_card', 'paypal', 'gift_card', 'crypto']

def rand_date(start=START_DATE, end=END_DATE):
    delta = end - start
    return start + timedelta(seconds=random.randint(0, int(delta.total_seconds())))

def rand_id():
    return str(uuid.uuid4())

# ── LOAD REAL STEAM APP IDS FIRST ─────────────────────────
print("Loading real Steam AppIDs...")
con = duckdb.connect('data/gameflow.duckdb')
steam_ids = con.execute("""
    SELECT AppID 
    FROM raw.steam_games 
    WHERE Price > 0 
    AND Name IS NOT NULL
    LIMIT 500
""").fetchdf()['AppID'].tolist()
print(f"  ✓ Loaded {len(steam_ids)} real Steam game IDs")

# ── GENERATE ──────────────────────────────────────────────
print("Generating players...")
players = []
for _ in range(N_PLAYERS):
    created = rand_date()
    churned = random.random() < 0.3
    churn_date = rand_date(created, END_DATE) if churned else None
    players.append({
        'player_id': rand_id(),
        'username': f"player_{random.randint(10000,99999)}",
        'email': f"user_{random.randint(10000,99999)}@email.com",
        'region': random.choice(REGIONS),
        'platform': random.choice(PLATFORMS),
        'subscription_tier': random.choice(SUB_TIERS),
        'created_at': created,
        'churned_at': churn_date,
        'is_churned': churned,
        'age_bucket': random.choice(['13-17','18-24','25-34','35-44','45+']),
        'currency': random.choice(CURRENCIES),
    })

player_ids = [p['player_id'] for p in players]

print("Generating sessions...")
sessions = []
for _ in range(N_SESSIONS):
    start = rand_date()
    duration = random.randint(5, 360)
    sessions.append({
        'session_id': rand_id(),
        'player_id': random.choice(player_ids),
        'app_id': random.choice(steam_ids),
        'session_start': start,
        'session_end': start + timedelta(minutes=duration),
        'duration_minutes': duration,
        'platform': random.choice(PLATFORMS),
        'region': random.choice(REGIONS),
        'was_crash': random.random() < 0.02,
    })

print("Generating purchases...")
purchases = []
for _ in range(N_PURCHASES):
    purchases.append({
        'purchase_id': rand_id(),
        'player_id': random.choice(player_ids),
        'app_id': random.choice(steam_ids),
        'purchased_at': rand_date(),
        'amount_usd': round(random.uniform(0.99, 99.99), 2),
        'payment_type': random.choice(PAYMENT_TYPES),
        'item_type': random.choice(['skin', 'weapon', 'pass', 'currency', 'game']),
        'is_refunded': random.random() < 0.03,
    })

print("Generating events...")
session_ids = [s['session_id'] for s in sessions]
events = []
for _ in range(N_EVENTS):
    events.append({
        'event_id': rand_id(),
        'player_id': random.choice(player_ids),
        'app_id': random.choice(steam_ids),
        'event_type': random.choice(EVENT_TYPES),
        'occurred_at': rand_date(),
        'session_id': random.choice(session_ids),
        'metadata': f'{{"level": {random.randint(1,100)}, "score": {random.randint(0,10000)}}}',
    })

# ── LOAD INTO DUCKDB ──────────────────────────────────────
print("Loading into DuckDB...")

datasets = {
    'raw.players': players,
    'raw.sessions': sessions,
    'raw.purchases': purchases,
    'raw.events': events,
}

for table, rows in datasets.items():
    df = pd.DataFrame(rows)
    con.execute(f"DROP TABLE IF EXISTS {table}")
    con.execute(f"CREATE TABLE {table} AS SELECT * FROM df")
    count = con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    print(f"  ✓ {table}: {count:,} rows")

con.close()
print("\nDone. gameflow.duckdb ready with real Steam game IDs.")