import requests
import json

print("Testing /api/analyze...")
r = requests.post("http://127.0.0.1:5000/api/analyze", json={
    "symbol": "AMZN",
    "avg_price": 263.53,
    "shares": 15,
    "ltp": 263.98
})
print(f"Status: {r.status_code}")
if r.status_code == 200:
    data = r.json()
    print("SUCCESS! Response keys:", list(data.keys()))
    print("Analysis snippet:", data.get("analysis","")[:200])
else:
    print("ERROR:", r.text[:500])

print("\nTesting /api/portfolio-analyze...")
r2 = requests.post("http://127.0.0.1:5000/api/portfolio-analyze", json={
    "total": 4087.60,
    "cash": 5919.45,
    "stocks": [{"ticker": "AMZN", "totalShares": 15, "avg_purchase_price": 263.53, "current_price": 263.98}]
})
print(f"Status: {r2.status_code}")
if r2.status_code == 200:
    data2 = r2.json()
    print("SUCCESS! Response keys:", list(data2.keys()))
else:
    print("ERROR:", r2.text[:500])
