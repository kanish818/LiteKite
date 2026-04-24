
# ─── Groq AI Routes ────────────────────────────────────────────────────────────

@app.route('/api/portfolio-analyze', methods=['POST'])
def portfolio_analyze():
    """Analyze portfolio using Groq AI"""
    try:
        data = request.json
        total = data.get('total', 0)
        stocks = data.get('stocks', [])
        cash = data.get('cash', 0)

        prompt = f"""You are an expert financial advisor. Analyze this stock portfolio and provide a JSON response only — no markdown, no explanations, just raw JSON.

Portfolio:
- Total value: ${total:.2f}
- Cash available: ${cash:.2f}
- Holdings: {json.dumps(stocks)}

Return ONLY this exact JSON structure:
{{
  "portfolio_health": {{
    "diversification_score": "score and brief note",
    "risk_assessment": "Low/Medium/High with brief explanation",
    "sector_balance": "brief note on sector distribution"
  }},
  "stock_analysis": {{
    "TICKER1": {{"outlook": "Bullish/Bearish/Neutral", "suggestion": "hold/buy more/reduce"}},
    "TICKER2": {{"outlook": "Bullish/Bearish/Neutral", "suggestion": "hold/buy more/reduce"}}
  }},
  "recommendations": {{
    "immediate_actions": ["action1", "action2"],
    "rebalancing": "rebalancing advice",
    "cash_strategy": "how to deploy the cash"
  }},
  "market_context": {{
    "current_environment": "brief market overview",
    "opportunities": ["opportunity1", "opportunity2"],
    "risks": ["risk1", "risk2"]
  }}
}}"""

        completion = groq_client.chat.completions.create(
            model="llama3-8b-8192",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=1500,
        )
        analysis_text = completion.choices[0].message.content.strip()
        if analysis_text.startswith("```"):
            analysis_text = analysis_text.split("```")[1]
            if analysis_text.startswith("json"):
                analysis_text = analysis_text[4:]
        return jsonify({"analysis": analysis_text})
    except Exception as e:
        print(f"Error in portfolio_analyze: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route('/api/analyze', methods=['POST'])
def analyze_stock():
    """Analyze a single stock using Groq AI"""
    try:
        data = request.json
        symbol = data.get('symbol', '')
        avg_price = data.get('avg_price', 0)
        shares = data.get('shares', 0)
        ltp = data.get('ltp', 0)

        pnl = (ltp - avg_price) * shares
        pnl_pct = ((ltp - avg_price) / avg_price * 100) if avg_price > 0 else 0

        prompt = f"""You are an expert stock analyst. Analyze this stock position and return ONLY raw JSON — no markdown, no explanation.

Stock: {symbol}
Average purchase price: ${avg_price}
Current price (LTP): ${ltp}
Shares held: {shares}
Unrealized P&L: ${pnl:.2f} ({pnl_pct:.2f}%)

Return ONLY this exact JSON:
{{
  "pros": {{
    "pro1": "advantage of holding this stock",
    "pro2": "another positive factor"
  }},
  "cons": {{
    "con1": "risk or concern",
    "con2": "another negative factor"
  }},
  "suggestion": "A clear 2-3 sentence recommendation on whether to hold, buy more, or sell."
}}"""

        completion = groq_client.chat.completions.create(
            model="llama3-8b-8192",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=800,
        )
        analysis_text = completion.choices[0].message.content.strip()
        if analysis_text.startswith("```"):
            analysis_text = analysis_text.split("```")[1]
            if analysis_text.startswith("json"):
                analysis_text = analysis_text[4:]
        return jsonify({"analysis": analysis_text})
    except Exception as e:
        print(f"Error in analyze_stock: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route('/api/suggest-stocks', methods=['POST'])
def suggest_stocks():
    """Suggest stocks using Groq AI"""
    try:
        data = request.json
        total = data.get('total', 0)
        stocks = data.get('stocks', [])
        cash = data.get('cash', 0)

        prompt = f"""You are an expert financial advisor. Suggest stocks based on this portfolio. Return ONLY raw JSON — no markdown, no explanation.

Portfolio:
- Total value: ${total:.2f}
- Cash to deploy: ${cash:.2f}
- Current holdings: {json.dumps(stocks)}

Return ONLY this exact JSON:
{{
  "portfolio_analysis": {{
    "risk_profile": "Conservative/Moderate/Aggressive",
    "investment_style": "Growth/Value/Blend",
    "sector_exposure": "brief note on current sector exposure"
  }},
  "recommendations": {{
    "stock1": {{
      "ticker": "AAPL",
      "name": "Apple Inc",
      "sector": "Technology",
      "investment_duration": "Long-term",
      "reason": "why this stock fits the portfolio",
      "suggested_allocation": "$X or X% of available cash"
    }},
    "stock2": {{
      "ticker": "MSFT",
      "name": "Microsoft Corp",
      "sector": "Technology",
      "investment_duration": "Long-term",
      "reason": "why this stock fits the portfolio",
      "suggested_allocation": "$X or X% of available cash"
    }}
  }},
  "existing_holdings": {{
    "advice": "Brief advice on the existing holdings."
  }}
}}"""

        completion = groq_client.chat.completions.create(
            model="llama3-8b-8192",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=1500,
        )
        analysis_text = completion.choices[0].message.content.strip()
        if analysis_text.startswith("```"):
            analysis_text = analysis_text.split("```")[1]
            if analysis_text.startswith("json"):
                analysis_text = analysis_text[4:]
        return jsonify({"analysis:": analysis_text})
    except Exception as e:
        print(f"Error in suggest_stocks: {str(e)}")
        return jsonify({"error": str(e)}), 500


@app.route('/api/stock-prediction', methods=['POST'])
def stock_prediction():
    """Predict stock trend using Groq AI"""
    try:
        data = request.json
        symbol = data.get('symbol', '')
        stock_data = data.get('data', [])

        prompt = f"""You are an expert technical analyst. Predict the short-term trend for {symbol}. Return ONLY raw JSON — no markdown, no explanation.

Recent data points: {json.dumps(stock_data[-10:]) if stock_data else "Not provided"}

Return ONLY this JSON:
{{
  "prediction": "Bullish/Bearish/Neutral",
  "confidence": "High/Medium/Low",
  "target_price": "estimated price target",
  "analysis": "2-3 sentence technical analysis",
  "key_levels": {{
    "support": "support level",
    "resistance": "resistance level"
  }}
}}"""

        completion = groq_client.chat.completions.create(
            model="llama3-8b-8192",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=600,
        )
        analysis_text = completion.choices[0].message.content.strip()
        if analysis_text.startswith("```"):
            analysis_text = analysis_text.split("```")[1]
            if analysis_text.startswith("json"):
                analysis_text = analysis_text[4:]
        return jsonify({"prediction": analysis_text})
    except Exception as e:
        print(f"Error in stock_prediction: {str(e)}")
        return jsonify({"error": str(e)}), 500
