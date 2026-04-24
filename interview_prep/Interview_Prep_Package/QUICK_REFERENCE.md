# LiteKite Interview Prep - Quick Reference Sheet

## 🎯 30-Second Elevator Pitch

**"LiteKite is a full-stack stock trading platform where users can trade US and Indian stocks with real-time prices, track portfolio performance, and get AI-powered investment analysis. I built it with React TypeScript frontend, Flask Python backend, PostgreSQL database, and integrated Google's Gemini AI for portfolio insights."**

---

## 📅 7-Day Prep Schedule

### Day 1: Project Foundation
- [ ] Read through [INTERVIEW_PREP_GUIDE.md](INTERVIEW_PREP_GUIDE.md) - Project Overview section
- [ ] Practice elevator pitch 10 times
- [ ] Draw system architecture diagram from memory
- [ ] Review [README.md](LiteKite-main/README.md) and [Backend README](LiteKite-Backend-master/README.md)

### Day 2: Backend Deep Dive
- [ ] Read [api/index.py](LiteKite-Backend-master/api/index.py) - main endpoints
- [ ] Review [api/models.py](LiteKite-Backend-master/api/models.py) - database schema
- [ ] Understand authentication flow (JWT + OAuth)
- [ ] Practice explaining buy/sell transaction flow
- [ ] Answer Q1-Q5 from PRACTICE_QUESTIONS.md out loud

### Day 3: Frontend Deep Dive
- [ ] Review [src/App.tsx](LiteKite-main/src/App.tsx) - routing structure
- [ ] Read [src/AuthContext.tsx](LiteKite-main/src/AuthContext.tsx) - state management
- [ ] Review [src/components/BuyDialog.tsx](LiteKite-main/src/components/BuyDialog.tsx)
- [ ] Understand how API calls work
- [ ] Answer Q11-Q12 from PRACTICE_QUESTIONS.md

### Day 4: Database & Security
- [ ] Review database schema and relationships
- [ ] Understand migrations (Alembic files in [migrations/versions/](LiteKite-Backend-master/migrations/versions/))
- [ ] Study security measures (CORS, JWT, bcrypt)
- [ ] Answer Q6-Q7 from PRACTICE_QUESTIONS.md
- [ ] Practice explaining portfolio calculation

### Day 5: Advanced Topics
- [ ] How would you scale this app?
- [ ] Caching strategy (Redis)
- [ ] Real-time updates (WebSockets)
- [ ] Answer Q13-Q14 from PRACTICE_QUESTIONS.md
- [ ] Review common system design patterns

### Day 6: Practice & Edge Cases
- [ ] Answer all quick-fire questions (Q1-Q5) in 30 seconds each
- [ ] Practice explaining complex flows (auth, buy/sell, portfolio)
- [ ] Review tricky questions (Q18-Q20)
- [ ] Think about edge cases and error handling
- [ ] Prepare questions to ask interviewer

### Day 7: Mock Interview & Review
- [ ] Full mock interview (record yourself)
- [ ] Review this cheat sheet
- [ ] Test your project locally (make sure it runs!)
- [ ] Review weak areas from mock
- [ ] Relax and get good sleep!

---

## 🔑 Critical Numbers to Remember

| Metric | Value |
|--------|-------|
| Database Tables | 3 (User, Transaction, IndianStockTransactions) |
| Markets Supported | 2 (US & Indian) |
| Starting Cash (each) | $10,000 |
| Auth Methods | 2 (JWT + Google OAuth) |
| Main API Endpoints | ~15 |
| Frontend Pages | 10+ routes |
| React Version | 18 |
| Flask Version | 3.x |
| Database | PostgreSQL |

---

## 💻 Tech Stack Cheat Sheet

### Frontend Stack
```
React 18.3 + TypeScript
├── Vite (build tool)
├── Tailwind CSS (styling)
├── Shadcn UI (components)
├── React Router v6 (routing)
├── Axios (HTTP client)
├── Recharts (data viz)
├── Framer Motion (animations)
└── Context API (state management)
```

### Backend Stack
```
Flask 3.0 + Python 3.8+
├── Flask-SQLAlchemy (ORM)
├── Flask-Migrate + Alembic (migrations)
├── Flask-JWT-Extended (auth)
├── Flask-CORS (cross-origin)
├── Werkzeug (password hashing)
├── PostgreSQL (database)
├── yfinance (stock data)
├── Pandas (data processing)
└── Google Generative AI (Gemini)
```

### External Services
- Google OAuth 2.0 (authentication)
- Google Gemini API (AI analysis)
- Yahoo Finance (via yfinance)
- Polygon API (stock data backup)
- Finnhub API (news & fundamentals)

---

## 🏗️ Architecture Diagram (Memorize This!)

```
┌──────────────────────────────────────────────┐
│              User Browser                     │
│  ┌────────────────────────────────────────┐  │
│  │   React Frontend (Vite)                 │  │
│  │   - Components (BuyDialog, Portfolio)   │  │
│  │   - AuthContext (global state)          │  │
│  │   - React Router (navigation)           │  │
│  └─────────────┬────────────────────────────┘  │
└────────────────┼───────────────────────────────┘
                 │
              HTTPS/REST
            (axios + JWT)
                 │
┌────────────────▼───────────────────────────────┐
│         Flask Backend API                      │
│  ┌──────────────────────────────────────────┐ │
│  │  Routes (@app.route)                     │ │
│  │  /api/login, /api/buy, /api/portfolio... │ │
│  │                                          │ │
│  │  Middleware                               │ │
│  │  @jwt_required(), CORS, error handlers   │ │
│  └─────────────┬────────────────────────────┘ │
└────────────────┼───────────────────────────────┘
                 │
       ┌─────────┼─────────┬─────────────┐
       │         │         │             │
   ┌───▼──┐  ┌───▼───┐ ┌───▼────┐  ┌────▼────┐
   │ Post │  │ Stock │ │ Gemini │  │  Google │
   │ greSQL│  │ APIs  │ │   AI   │  │  OAuth  │
   │  DB  │  │(yf...)│ │  API   │  │         │
   └──────┘  └───────┘ └────────┘  └─────────┘
```

---

## 📋 Database Schema Quick Reference

### User Table
```sql
CREATE TABLE user (
    id INTEGER PRIMARY KEY,
    username VARCHAR(80) UNIQUE,
    email VARCHAR(120) UNIQUE,
    hash VARCHAR(255),              -- bcrypt hashed password
    cash FLOAT DEFAULT 10000.00,    -- US market cash
    indiancash FLOAT DEFAULT 10000.00,  -- Indian market cash
    google_id VARCHAR(255) UNIQUE   -- OAuth identifier
);
```

### Transaction Table
```sql
CREATE TABLE transaction (
    id INTEGER PRIMARY KEY,
    user_id INTEGER REFERENCES user(id),
    ticker VARCHAR(10),
    name VARCHAR(100),
    shares INTEGER,
    price FLOAT,
    type VARCHAR(4),  -- 'buy' or 'sell'
    time TIMESTAMP DEFAULT NOW()
);
```

**Key Relationship:** One User → Many Transactions

---

## 🔐 Authentication Flow (Know This Cold!)

```
1. User enters username + password
   ↓
2. Frontend: POST /api/login {username, password}
   ↓
3. Backend: Query User table
   ↓
4. Backend: check_password_hash(user.hash, password)
   ↓
5. If valid: create_access_token(identity=user.id)
   ↓
6. Return: {access_token: "eyJhbGc..."}
   ↓
7. Frontend: localStorage.setItem('token', token)
   ↓
8. Frontend: Set Authorization header for all requests
   ↓
9. Protected routes: GET /api/portfolio
   Headers: {Authorization: "Bearer eyJhbGc..."}
   ↓
10. Backend: @jwt_required() validates token
    ↓
11. Extract user_id from token: get_jwt_identity()
    ↓
12. Return user-specific data
```

---

## 💰 Buy Stock Flow (Critical!)

```
Frontend:
1. User enters symbol "AAPL" + shares 10
2. GET /api/quote/AAPL → returns price: $175.50
3. Display: "10 shares × $175.50 = $1,755.00"
4. User clicks "Confirm Buy"
5. POST /api/buy {symbol: "AAPL", shares: 10}

Backend:
6. Extract user_id from JWT token
7. Validate: user.cash >= (shares × price)
8. If insufficient: return 400 error
9. Database transaction:
   try:
       user.cash -= total_cost
       transaction = Transaction(...)
       db.session.add(transaction)
       db.session.commit()
   except:
       db.session.rollback()
10. Return: {message: "Success", remaining_cash: 8245.00}

Frontend:
11. Show success toast
12. Update cash display
13. Refresh portfolio
```

---

## 🧮 Portfolio Calculation Algorithm

```python
# Step 1: Get all transactions for user
transactions = Transaction.query.filter_by(user_id=user_id).all()

# Step 2: Aggregate shares by ticker
holdings = {}
for txn in transactions:
    if txn.type == 'buy':
        holdings[txn.ticker] += txn.shares
    else:  # sell
        holdings[txn.ticker] -= txn.shares

# Step 3: Filter stocks with shares > 0
holdings = {k: v for k, v in holdings.items() if v > 0}

# Step 4: Get current prices
for ticker in holdings:
    current_price = yfinance.Ticker(ticker).info['currentPrice']
    current_value = holdings[ticker] * current_price
    
# Step 5: Calculate profit/loss
profit_loss = current_value - invested_amount
```

---

## 🛡️ Security Measures

| Vulnerability | Prevention |
|--------------|-----------|
| SQL Injection | SQLAlchemy ORM (parameterized queries) |
| XSS | React auto-escapes JSX |
| CSRF | JWT (stateless), SameSite cookies |
| Password Attacks | Bcrypt hashing with salt |
| JWT Theft | HTTPS only, short expiration |
| API Abuse | Rate limiting (future) |
| CORS Issues | Flask-CORS with whitelisted origins |

---

## 🔄 API Endpoints Quick List

### Public Routes
```
POST /api/register     - Create account
POST /api/login        - Get JWT token
GET  /api/quote/:sym   - Get stock quote
GET  /api/auth/google  - OAuth flow
```

### Protected Routes (require JWT)
```
GET  /api/portfolio         - User's stock holdings
GET  /api/indianportfolio   - Indian stock holdings
POST /api/buy               - Purchase US stocks
POST /api/sell              - Sell US stocks
POST /api/buyindian         - Purchase Indian stocks
POST /api/sellindian        - Sell Indian stocks
GET  /api/history           - Transaction history
GET  /api/analyze           - AI portfolio analysis
GET  /api/fundamentals/:sym - Stock fundamentals
GET  /api/graph/:sym        - Historical price data
```

---

## ⚡ Must-Know Code Snippets

### JWT Authentication Decorator
```python
from flask_jwt_extended import jwt_required, get_jwt_identity

@app.route('/api/portfolio')
@jwt_required()
def portfolio():
    user_id = get_jwt_identity()
    # ... fetch portfolio for this user
```

### Password Hashing
```python
from werkzeug.security import generate_password_hash, check_password_hash

# Registration
hash = generate_password_hash(password)

# Login
if check_password_hash(user.hash, password):
    # Valid password
```

### React Protected Route
```typescript
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated } = useAuth();
  return isAuthenticated ? children : <Navigate to="/login" />;
};
```

### Fetch with Auth
```typescript
const token = localStorage.getItem('token');
const response = await axios.get(`${url}/portfolio`, {
  headers: { 'Authorization': `Bearer ${token}` }
});
```

---

## 🎤 Top 10 Questions You MUST Answer Well

1. **"Walk me through your project."**
   → Use elevator pitch + architecture diagram

2. **"How does authentication work?"**
   → JWT flow diagram (login → token → protected routes)

3. **"Explain the buy stock flow."**
   → Frontend → API → validation → DB transaction

4. **"How do you calculate portfolio?"**
   → Aggregate transactions, fetch current prices

5. **"Security measures in your app?"**
   → Bcrypt, JWT, CORS, SQLAlchemy, input validation

6. **"Why Flask over Django/FastAPI?"**
   → Lightweight, flexible, good for APIs, familiar

7. **"Database schema and relationships?"**
   → 3 tables, User 1→M Transaction

8. **"How would you scale this?"**
   → Redis cache, load balancing, DB replicas, CDN

9. **"Biggest challenge?"**
   → Race conditions in transactions (use DB locking)

10. **"What would you improve?"**
    → Testing, WebSockets, caching, k8s deployment

---

## 💡 When You Go Blank During Interview

### Stalling Strategies (Use These!)
- "That's a great question, let me think for a moment..."
- "Could you clarify what you mean by [X]?"
- "Let me draw a diagram to explain this better..."
- "In my project, I encountered something similar..."
- *Take a sip of water*

### Redirect to Your Strengths
- "I haven't implemented [X] specifically, but in LiteKite I used [Y] which has similar principles..."
- "I'm not familiar with that exact approach, but here's how I solved it..."
- "That's an interesting problem. Based on my experience with [related topic], I would approach it by..."

### Be Honest
- "I don't have deep experience with [X], but I understand it involves [Y and Z]"
- "That's something I'd need to research more, but I'd start by looking at [documentation/resource]"

---

## 🎯 Final Pre-Interview Checklist

### 1 Hour Before
- [ ] Review this cheat sheet
- [ ] Practice elevator pitch 3 times
- [ ] Draw architecture diagram from memory
- [ ] Test camera, mic, internet connection
- [ ] Have water ready
- [ ] Close distracting apps/tabs

### Mental Preparation
- [ ] "I built this project and understand it deeply"
- [ ] "I can explain my decisions confidently"
- [ ] "It's okay to say 'I don't know' and show how I'd learn"
- [ ] "I'll think out loud and show my problem-solving"
- [ ] "I'll ask clarifying questions when needed"

### During Interview - Remember to:
✅ Make eye contact and smile
✅ Speak clearly and at moderate pace
✅ Use the whiteboard/screen share for diagrams
✅ Ask for clarification when needed
✅ Mention trade-offs in your decisions
✅ Show enthusiasm about your project
✅ Have 2-3 questions ready for them

### Don't:
❌ Memorize answers word-for-word (sounds robotic)
❌ Rush through explanations
❌ Say "it just works" without explaining HOW
❌ Badmouth any technology
❌ Lie about what you know
❌ Go completely silent for long periods

---

## 🚀 Key Talking Points to Weave In

- **"In LiteKite, I implemented..."** (bring it back to YOUR project)
- **"I chose [X] over [Y] because..."** (show decision-making)
- **"The trade-off was..."** (demonstrate understanding of complexity)
- **"If I were to scale this..."** (show forward thinking)
- **"I learned [X] by..."** (demonstrate learning ability)
- **"An interesting challenge was..."** (show problem-solving)

---

## 📊 Mental Model: Full Request Lifecycle

```
User Action (Click "Buy")
    ↓
React Component (BuyDialog.tsx)
    ↓
Event Handler (handleBuy)
    ↓
Axios HTTP Request
    ↓
    ... NETWORK ...
    ↓
Flask Route (@app.route('/api/buy'))
    ↓
Authentication (@jwt_required)
    ↓
Business Logic (validate, calculate)
    ↓
SQLAlchemy ORM
    ↓
PostgreSQL Database
    ↓
    ... DATABASE ...
    ↓
Response back to Flask
    ↓
JSON serialization
    ↓
    ... NETWORK ...
    ↓
Axios Promise Resolution
    ↓
React State Update (setPortfolio)
    ↓
Component Re-render
    ↓
UI Update (user sees success toast)
```

You should be able to explain EACH step of this flow!

---

## 🎓 Advanced Topics (If They Go Deep)

### Database Indexing
```sql
CREATE INDEX idx_user_txn ON transaction(user_id);
CREATE INDEX idx_ticker ON transaction(ticker);
```
**Why:** Speeds up queries filtering by user_id or ticker

### ACID Properties
- **Atomicity:** All or nothing (commit or rollback)
- **Consistency:** Valid state always
- **Isolation:** Concurrent transactions don't interfere
- **Durability:** Committed data persists

### REST Principles
- **GET:** Retrieve data (idempotent)
- **POST:** Create resource
- **PUT:** Update/replace resource (idempotent)
- **DELETE:** Remove resource (idempotent)

### JWT Structure
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9  ← Header
.eyJ1c2VyX2lkIjoxMjN9                ← Payload (user_id: 123)
.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV   ← Signature
```

### React Hooks Used
- `useState` - Component state
- `useEffect` - Side effects (API calls)
- `useContext` - Global state (auth)
- `useNavigate` - Programmatic routing
- Custom: `useToast` - Notifications

---

## 🔥 Common Mistakes to Avoid

1. **Saying "I don't know" and stopping**
   - Instead: "I haven't implemented that, but I would approach it by..."

2. **Overcomplicating simple answers**
   - Start simple, go deep only if asked

3. **Not asking clarifying questions**
   - Shows you think before coding

4. **Badmouthing technologies**
   - "I chose X for this use case" not "Y is terrible"

5. **Going silent while thinking**
   - Verbalize your thought process

6. **Memorizing without understanding**
   - They can tell. Focus on understanding WHY.

---

## 💪 Confidence Affirmations

**Read these before your interview:**

✅ I built a full-stack application from scratch
✅ I integrated multiple external APIs successfully
✅ I implemented authentication and database management
✅ I can explain every technical decision I made
✅ I solved real problems (concurrency, data consistency)
✅ I learned new technologies to build this
✅ I'm prepared for both high-level and deep technical questions
✅ It's okay not to know everything - I can learn
✅ My project demonstrates real engineering skills
✅ I've got this! 🚀

---

## 📱 Contact & Resources

### If You Need More Help:
- Review full guide: [INTERVIEW_PREP_GUIDE.md](INTERVIEW_PREP_GUIDE.md)
- Practice questions: [PRACTICE_QUESTIONS.md](PRACTICE_QUESTIONS.md)
- Project README: [README.md](LiteKite-main/README.md)

### Quick Links:
- Flask Docs: https://flask.palletsprojects.com
- React Docs: https://react.dev
- SQLAlchemy: https://docs.sqlalchemy.org
- JWT.io: https://jwt.io

---

**Last Words of Wisdom:**

> The best answer isn't always the most technically perfect one. 
> It's the one that shows:
> 1. You understand the problem
> 2. You can think through solutions
> 3. You consider trade-offs
> 4. You can communicate clearly
> 5. You're excited to learn more

**You built this. You understand it. Now go show them what you know! 💪**

Good luck! 🍀
