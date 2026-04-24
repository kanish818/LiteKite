import os, sys
sys.path.insert(0, '.')
from dotenv import load_dotenv
load_dotenv()
from groq import Groq

client = Groq(api_key=os.getenv('GROQ_API_KEY'))
print("API Key found:", bool(os.getenv('GROQ_API_KEY')))

try:
    r = client.chat.completions.create(
        model="llama3-8b-8192",
        messages=[{"role": "user", "content": "Return this JSON only: {\"status\": \"ok\"}"}],
        max_tokens=50
    )
    print("SUCCESS:", r.choices[0].message.content)
except Exception as e:
    print("ERROR:", str(e))
