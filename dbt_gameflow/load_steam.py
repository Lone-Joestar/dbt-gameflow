import duckdb
import pandas as pd

con = duckdb.connect('data/gameflow.duckdb')

print("Loading Steam games...")
df = pd.read_csv(
    'data/raw/games.csv',
    on_bad_lines='skip',
    encoding='utf-8',
    engine='python',
    index_col=False
)

# Select only the columns we need by exact name
keep = ['AppID', 'Name', 'Release date', 'Price', 'Peak CCU',
        'Required age', 'Genres', 'Categories', 'Positive',
        'Negative', 'Achievements', 'Average playtime forever',
        'Recommendations']

df = df[keep].copy()
df.columns = ['app_id', 'game_name', 'release_date', 'price_usd',
              'peak_ccu', 'required_age', 'genres', 'categories',
              'positive_reviews', 'negative_reviews', 'achievements',
              'avg_playtime_minutes', 'recommendations']

df['review_ratio'] = (
    df['positive_reviews'] /
    (df['positive_reviews'] + df['negative_reviews'])
).round(2)

print(f"Loaded {len(df):,} rows")
print(df[['app_id','game_name','price_usd','genres']].head(3).to_string())

con.execute("CREATE OR REPLACE TABLE raw.steam_games AS SELECT * FROM df")
count = con.execute("SELECT COUNT(*) FROM raw.steam_games").fetchone()[0]
print(f"✓ raw.steam_games: {count:,} rows")
con.close()