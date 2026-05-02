import duckdb

con=duckdb.connect('data/gameflow.duckdb')

print("Loading steam games...")
con.execute("""

    CREATE OR REPLACE TABLE raw.steam_games as 
    SELECT * from read_csv_auto('data/raw/games.csv',
                                ignore_errors=true,
                                sample_size=1000
)
""")


count= con.execute("SELECT COUNT(*) FROM raw.steam_games").fetchone()[0]
print(f"raw.steam_games: {count:,} rows")


#Preview columns 
cols=con.execute("DESCRIBE raw.steam_games").fetchdf()
print("\nColumns:")
print(cols[['column_name','column_type']].to_string())

con.close()

print("\nDone.")