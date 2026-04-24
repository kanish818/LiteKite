# LiteKite Interview Practice Questions

## 🎯 How to Use This Document

1. **Cover the answer** section
2. **Answer out loud** (not in your head!)
3. **Record yourself** if possible - helps identify filler words
4. **Time yourself** - aim for 1-2 minutes per answer
5. **Practice daily** - even 15 minutes helps

---

## 📝 Quick Fire Questions (30 seconds each)

### Round 1: Project Basics

**Q1:** What does LiteKite do?
<details>
<summary>Answer</summary>

"LiteKite is a stock portfolio management platform where users can trade US and Indian stocks with real-time prices, track their portfolio performance, and get AI-powered investment analysis using Google's Gemini API."
</details>

**Q2:** What's your tech stack?
<details>
<summary>Answer</summary>

"Frontend: React with TypeScript, Vite, Tailwind CSS, and Shadcn UI.
Backend: Flask with PostgreSQL, SQLAlchemy ORM, JWT authentication.
External: Google Gemini AI, yfinance for stock data, Google OAuth."
</details>

**Q3:** How many users can your system handle?
<details>
<summary>Answer</summary>

"Currently optimized for medium scale. With caching and database optimizations, it could handle thousands. For 100K+ users, I'd need Redis caching, read replicas, load balancing, and possibly microservices."
</details>

**Q4:** What database do you use and why?
<details>
<summary>Answer</summary>

"PostgreSQL because it's robust, ACID-compliant for financial transactions, has excellent SQLAlchemy support, handles complex queries well, and is open-source with strong community support."
</details>

**Q5:** How do you authenticate users?
<details>
<summary>Answer</summary>

"Two methods: traditional login with bcrypt-hashed passwords generating JWT tokens, and Google OAuth using Authlib. The JWT is stored in localStorage and sent via Authorization header on protected routes."
</details>

---

## 🔍 Deep Dive Questions (2-3 minutes each)

### Authentication & Security

**Q6:** Explain your authentication flow from login button click to viewing portfolio.

<details>
<summary>Detailed Answer</summary>

**Step-by-step flow:**

1. User enters credentials and clicks Login
2. Frontend sends POST to `/api/login` with username and password
3. Backend queries database for user with that username
4. Uses `check_password_hash()` to verify password against stored hash
5. If valid, Flask-JWT-Extended generates access token with `create_access_token(identity=user.id)`
6. Token returned to frontend in response: `{access_token: "eyJ..."}`
7. Frontend stores token in localStorage: `localStorage.setItem('token', token)`
8. AuthContext updates `isAuthenticated` to true
9. User redirected to portfolio page (protected route)
10. Portfolio component calls `/api/portfolio` with Authorization header: `Bearer <token>`
11. Backend `@jwt_required()` decorator validates token
12. Returns portfolio data if valid

**Security considerations:**
- Password never sent in plain text (HTTPS)
- Hash stored in database, not password
- JWT includes expiration
- Token signature prevents tampering
</details>

**Q7:** What security vulnerabilities exist in your app and how do you prevent them?

<details>
<summary>Detailed Answer</summary>

**1. SQL Injection:**
- **Risk:** Malicious SQL in user inputs
- **Prevention:** SQLAlchemy ORM with parameterized queries. Never string concatenation.

**2. XSS (Cross-Site Scripting):**
- **Risk:** Injecting JavaScript into pages
- **Prevention:** React auto-escapes JSX content. Sanitize any dangerouslySetInnerHTML.

**3. CSRF (Cross-Site Request Forgery):**
- **Risk:** Unauthorized actions from malicious sites
- **Prevention:** JWT (stateless), SameSite cookies, CORS configuration

**4. Password Attacks:**
- **Risk:** Brute force, dictionary attacks
- **Prevention:** Bcrypt hashing with salt (computationally expensive), rate limiting on login

**5. JWT Vulnerabilities:**
- **Risk:** Token theft, replay attacks
- **Prevention:** Short expiration, HTTPS only, HttpOnly cookies for refresh tokens, secret key rotation

**6. Injection Attacks in Stock Symbols:**
- **Risk:** Malicious ticker symbols
- **Prevention:** Input validation, regex patterns for valid symbols

**Would add:**
- Rate limiting (Flask-Limiter)
- CAPTCHA on registration
- 2FA for high-value accounts
- Security headers (CSP, X-XSS-Protection)
</details>

---

### Backend Architecture

**Q8:** Walk me through what happens when a user buys a stock.

<details>
<summary>Detailed Answer</summary>

**Frontend (BuyDialog.tsx):**
1. User enters symbol (e.g., "AAPL") and shares (10)
2. First API call: GET `/api/quote/AAPL` to fetch current price
3. Display: "10 shares × $175.50 = $1,755.00"
4. User clicks "Buy"
5. POST `/api/buy` with `{symbol: "AAPL", shares: 10}` and JWT token

**Backend (api/index.py):**
```python
@app.route('/api/buy', methods=['POST'])
@jwt_required()
def buy():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    # Parse request
    symbol = request.json.get('symbol')
    shares = int(request.json.get('shares'))
    
    # Get current price
    quote = lookup(symbol)  # Uses yfinance
    if not quote:
        return error("Invalid symbol")
    
    price = quote['price']
    total_cost = shares * price
    
    # Validate funds
    if user.cash < total_cost:
        return error("Insufficient funds")
    
    # Database transaction
    try:
        user.cash -= total_cost
        txn = Transaction(
            user_id=user_id,
            ticker=symbol,
            shares=shares,
            price=price,
            type='buy'
        )
        db.session.add(txn)
        db.session.commit()
    except:
        db.session.rollback()
        return error("Transaction failed")
    
    return {
        "message": f"Bought {shares} shares of {symbol}",
        "remaining_cash": user.cash
    }
```

**Database Changes:**
- User table: `cash` decreased by $1,755
- Transaction table: New row inserted

**Frontend Response:**
- Show success toast
- Update cash display
- Optionally refresh portfolio
</details>

**Q9:** How do you calculate the user's portfolio?

<details>
<summary>Detailed Answer</summary>

**Approach:**

1. **Fetch all transactions** for the user from database
2. **Aggregate by ticker** to calculate net shares:
   - For each stock, sum all "buy" transactions
   - Subtract all "sell" transactions
   - If net shares > 0, user owns it

```python
@app.route('/api/portfolio')
@jwt_required()
def portfolio():
    user_id = get_jwt_identity()
    
    # Get all transactions
    transactions = Transaction.query.filter_by(user_id=user_id).all()
    
    # Aggregate holdings
    holdings = {}
    for txn in transactions:
        if txn.ticker not in holdings:
            holdings[txn.ticker] = {
                'shares': 0,
                'name': txn.name,
                'total_invested': 0
            }
        
        if txn.type == 'buy':
            holdings[txn.ticker]['shares'] += txn.shares
            holdings[txn.ticker]['total_invested'] += txn.shares * txn.price
        else:  # sell
            holdings[txn.ticker]['shares'] -= txn.shares
            holdings[txn.ticker]['total_invested'] -= txn.shares * txn.price
    
    # Remove stocks with 0 shares
    holdings = {k: v for k, v in holdings.items() if v['shares'] > 0}
    
    # Fetch current prices
    portfolio = []
    for ticker, data in holdings.items():
        quote = lookup(ticker)
        current_value = data['shares'] * quote['price']
        profit_loss = current_value - data['total_invested']
        
        portfolio.append({
            'ticker': ticker,
            'name': data['name'],
            'shares': data['shares'],
            'current_price': quote['price'],
            'current_value': current_value,
            'profit_loss': profit_loss,
            'profit_loss_percent': (profit_loss / data['total_invested']) * 100
        })
    
    return jsonify(portfolio)
```

**Optimization for scale:**
- Use SQL aggregation instead of Python loops:
```sql
SELECT 
    ticker,
    SUM(CASE WHEN type='buy' THEN shares ELSE -shares END) as net_shares,
    SUM(CASE WHEN type='buy' THEN shares*price ELSE -shares*price END) as total_invested
FROM transactions
WHERE user_id = ?
GROUP BY ticker
HAVING net_shares > 0
```

- Cache current prices in Redis (TTL: 5 seconds)
- Materialized view for frequently accessed portfolios
</details>

**Q10:** Explain database migrations and how you use them.

<details>
<summary>Detailed Answer</summary>

**What are migrations?**
Version control for database schema. Instead of manually running SQL, migrations track changes incrementally.

**Setup in my project:**
```bash
# Initialize (done once)
flask db init  # Creates migrations/ folder

# Create migration after model changes
flask db migrate -m "Added indiancash column to User"

# Apply migration
flask db upgrade

# Rollback if needed
flask db downgrade
```

**Example migration file:**
```python
# migrations/versions/xxxxx_.py
def upgrade():
    op.add_column('user', 
        sa.Column('indiancash', sa.Float(), nullable=False, server_default='10000.0'))

def downgrade():
    op.drop_column('user', 'indiancash')
```

**Workflow:**
1. Modify model in `models.py`
2. Generate migration: `flask db migrate`
3. Review auto-generated SQL (important!)
4. Test in development
5. Commit migration file to Git
6. Apply in production with backup first

**Why important?**
- Keeps dev and prod schemas in sync
- Reversible changes
- Team collaboration
- Deployment automation

**Best practices I follow:**
- Never edit applied migrations
- Always review auto-generated code
- Backup before production migrations
- Small, atomic changes
- Descriptive messages
</details>

---

### Frontend Architecture

**Q11:** How does your frontend state management work?

<details>
<summary>Detailed Answer</summary>

**I use a hybrid approach:**

**1. Context API for Authentication (Global State):**
```typescript
// AuthContext.tsx
const AuthContext = createContext<AuthContextType>({
    isAuthenticated: false,
    login: () => {},
    logout: () => {},
    // ...
});

// Provides to entire app
<AuthProvider>
    <App />
</AuthProvider>

// Consumed in components
const { isAuthenticated, logout } = useAuth();
```

**Why Context for auth?**
- Needed across many components
- Changes infrequently
- Avoids prop drilling

**2. Local State with useState (Component State):**
```typescript
// Portfolio.tsx
const [portfolio, setPortfolio] = useState([]);
const [loading, setLoading] = useState(true);

useEffect(() => {
    fetchPortfolio();
}, []);
```

**Why local state?**
- Data specific to one component
- Re-fetched on mount
- Don't need to share between routes

**3. Form State:**
```typescript
// BuyDialog.tsx
const [symbol, setSymbol] = useState('');
const [shares, setShares] = useState(1);
```

**Didn't use Redux because:**
- App complexity doesn't require it
- Most data is fetched fresh from API
- Context API sufficient for shared state
- Smaller bundle size

**If scaling:**
- React Query for server state caching
- Zustand for lightweight global state
- Redux for complex state logic
</details>

**Q12:** How do you handle API calls and errors on the frontend?

<details>
<summary>Detailed Answer</summary>

**API Layer:**
```typescript
// lib/url.ts
const url = import.meta.env.VITE_BACKEND_URL || 'http://localhost:5000/api';

// Portfolio.tsx
import axios from 'axios';
import { useToast } from './hooks/use-toast';

const { toast } = useToast();

const fetchPortfolio = async () => {
    try {
        setLoading(true);
        
        const token = localStorage.getItem('token');
        const response = await axios.get(`${url}/portfolio`, {
            headers: {
                'Authorization': `Bearer ${token}`
            }
        });
        
        setPortfolio(response.data);
    } catch (error) {
        if (error.response?.status === 401) {
            // Token expired or invalid
            logout();
            navigate('/login');
        } else {
            toast({
                title: "Error",
                description: error.response?.data?.message || "Failed to fetch portfolio",
                variant: "destructive"
            });
        }
    } finally {
        setLoading(false);
    }
};
```

**Error Handling Strategy:**

1. **Network Errors:** Show toast notification
2. **401 Unauthorized:** Redirect to login, clear token
3. **400 Bad Request:** Display validation errors
4. **500 Server Error:** "Something went wrong, try again"
5. **Loading States:** Spinners/skeletons while fetching

**Axios Interceptor (could add):**
```typescript
axios.interceptors.request.use(config => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

axios.interceptors.response.use(
    response => response,
    error => {
        if (error.response?.status === 401) {
            // Global logout
        }
        return Promise.reject(error);
    }
);
```

**User Experience:**
- Optimistic updates for better UX
- Retry logic for transient failures
- Graceful degradation
</details>

---

### System Design

**Q13:** How would you scale this to handle 100,000 concurrent users?

<details>
<summary>Detailed Answer</summary>

**Current Bottlenecks:**
1. Single Flask instance
2. Stock price API calls on every request
3. Database queries without caching
4. No CDN for static assets

**Scaling Strategy:**

**1. Application Layer:**
```
Users → Load Balancer → Flask App Instances (5-10)
                      ↓
                   Redis Cache
                      ↓
              PostgreSQL (Primary)
                      ↓
             Read Replicas (2-3)
```

**2. Caching Strategy:**
- **Redis** for:
  - Stock prices (TTL: 5 seconds)
  - User sessions
  - Portfolio calculations (invalidate on trade)
  
```python
import redis
r = redis.Redis()

def get_stock_price(symbol):
    # Check cache first
    cached = r.get(f'price:{symbol}')
    if cached:
        return json.loads(cached)
    
    # Fetch from API
    price = yfinance.Ticker(symbol).info['currentPrice']
    
    # Cache for 5 seconds
    r.setex(f'price:{symbol}', 5, json.dumps(price))
    return price
```

**3. Database Optimization:**
- Connection pooling: pgBouncer (max 100 connections)
- Read replicas for SELECT queries
- Partition transactions table by date
- Materialized views for portfolios
- Indexes on user_id, ticker, created_at

**4. Async Processing:**
```python
# Celery for background tasks
@celery.task
def analyze_portfolio(user_id):
    # AI analysis takes time
    # Process asynchronously
    portfolio = get_portfolio(user_id)
    analysis = gemini.analyze(portfolio)
    cache.set(f'analysis:{user_id}', analysis, ttl=3600)
```

**5. Frontend Optimization:**
- CDN for static assets (CloudFlare)
- Code splitting: `React.lazy()`
- Service worker for offline support
- Compress images and assets
- Virtualized lists for transaction history

**6. Infrastructure:**
```yaml
# Docker Compose
services:
  nginx:  # Load balancer
  flask-1: # App instance 1
  flask-2: # App instance 2
  redis:
  postgres:
  celery:
```

**7. Monitoring:**
- Prometheus + Grafana
- Log aggregation (ELK stack)
- APM (New Relic/DataDog)
- Alerts on error rates, latency

**8. Rate Limiting:**
```python
@limiter.limit("100/minute")
@app.route('/api/quote')
def get_quote():
    ...
```

**Cost Estimate:**
- 10 Flask instances: $500/mo
- PostgreSQL (managed): $200/mo
- Redis: $100/mo
- CDN: $50/mo
- Monitoring: $100/mo
**Total: ~$950/month for 100K users**
</details>

**Q14:** Design a notification system for price alerts.

<details>
<summary>Detailed Answer</summary>

**Requirements:**
- User sets alert: "Notify me if AAPL drops below $170"
- Check prices periodically
- Send notification (email/push)

**Database Schema:**
```sql
CREATE TABLE price_alerts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    ticker VARCHAR(10),
    condition VARCHAR(10),  -- 'above', 'below'
    target_price DECIMAL(10,2),
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Architecture:**

**Option 1: Polling (Simple):**
```python
# Celery periodic task (runs every 5 minutes)
@celery.task(bind=True)
def check_price_alerts(self):
    alerts = PriceAlert.query.filter_by(active=True).all()
    
    for alert in alerts:
        current_price = get_stock_price(alert.ticker)
        
        triggered = False
        if alert.condition == 'below' and current_price < alert.target_price:
            triggered = True
        elif alert.condition == 'above' and current_price > alert.target_price:
            triggered = True
        
        if triggered:
            send_notification(alert.user_id, alert)
            alert.active = False  # One-time alert
            db.session.commit()
```

**Option 2: Streaming (Advanced):**
```python
# WebSocket connection to stock data provider
import websocket

def on_price_update(ws, message):
    data = json.loads(message)
    ticker = data['symbol']
    price = data['price']
    
    # Check if any alerts triggered
    alerts = PriceAlert.query.filter_by(
        ticker=ticker,
        active=True
    ).all()
    
    for alert in alerts:
        if should_trigger(alert, price):
            send_notification(alert.user_id, alert)

ws = websocket.WebSocketApp(
    "wss://stream.polygon.io/stocks",
    on_message=on_price_update
)
```

**Notification Delivery:**
```python
# Email via SendGrid
from sendgrid import SendGridAPIClient

def send_notification(user_id, alert):
    user = User.query.get(user_id)
    
    message = Mail(
        from_email='alerts@litekite.com',
        to_emails=user.email,
        subject=f'Price Alert: {alert.ticker}',
        html_content=f'''
            <p>Your alert for {alert.ticker} was triggered!</p>
            <p>Current price: ${current_price}</p>
            <p>Target: {alert.condition} ${alert.target_price}</p>
        '''
    )
    
    sg = SendGridAPIClient(os.getenv('SENDGRID_API_KEY'))
    sg.send(message)

# Push notification via Firebase Cloud Messaging
import firebase_admin

def send_push_notification(user_id, alert):
    message = messaging.Message(
        notification=messaging.Notification(
            title=f'{alert.ticker} Price Alert',
            body=f'Price is now ${current_price}'
        ),
        token=user.fcm_token
    )
    messaging.send(message)
```

**Scalability Considerations:**
- Use message queue (RabbitMQ) for notification sending
- Batch process alerts by ticker to reduce API calls
- Redis pub/sub for real-time price distribution
- Rate limit notifications (max 10/day per user)

**Frontend UI:**
```typescript
// Add alert dialog
<PriceAlertDialog>
  <Select ticker="AAPL" />
  <Select condition="below" />
  <Input price={170.00} />
  <Button>Create Alert</Button>
</PriceAlertDialog>

// Show active alerts
{alerts.map(alert => (
  <AlertCard key={alert.id}>
    {alert.ticker} {alert.condition} ${alert.target_price}
    <Button onClick={() => deleteAlert(alert.id)}>Delete</Button>
  </AlertCard>
))}
```
</details>

---

## 🧠 Behavioral Questions

**Q15:** Tell me about a challenging bug you encountered in this project.

<details>
<summary>Sample Answer (STAR Method)</summary>

**Situation:**
"When implementing the buy/sell feature, I noticed users could sometimes end up with negative cash balances in edge cases."

**Task:**
"I needed to identify the race condition and ensure transactions were atomic - either fully complete or fully fail."

**Action:**
"I investigated and found that if two requests came in simultaneously, both could read the cash balance before either deducted it. I implemented database transactions with proper locking:

```python
try:
    # Query with lock
    user = User.query.with_for_update().get(user_id)
    
    if user.cash < total_cost:
        return error("Insufficient funds")
    
    user.cash -= total_cost
    transaction = Transaction(...)
    db.session.add(transaction)
    db.session.commit()
except:
    db.session.rollback()
```

I also added frontend debouncing to prevent double-clicks and comprehensive unit tests for concurrent scenarios."

**Result:**
"The bug was eliminated. I learned about database isolation levels, row locking, and the importance of testing edge cases. This made me more careful about concurrent access patterns in other parts of the application."
</details>

**Q16:** What are you most proud of in this project?

<details>
<summary>Sample Answer</summary>

"I'm most proud of the dual-market integration - supporting both US and Indian stocks with separate cash balances. This was challenging because:

1. **Different data sources:** Indian stocks required `.NS` or `.BO` suffixes and had different API quirks
2. **Schema design:** I debated one table vs. two for transactions, ultimately choosing separate tables for cleaner separation
3. **Currency handling:** Ensuring ₹ and $ were displayed correctly, with proper decimal precision
4. **User experience:** Building intuitive tabs to switch between markets without confusion

I researched yfinance documentation extensively, tested with various Indian stock symbols, and created a seamless experience where users can trade in both markets from the same dashboard. It taught me about internationalization, working with external APIs, and thinking through data modeling decisions."
</details>

**Q17:** What would you improve if you had more time?

<details>
<summary>Sample Answer</summary>

"Several things:

**1. Testing Coverage:**
- Add pytest for backend unit and integration tests
- Frontend testing with Jest and React Testing Library
- E2E tests with Playwright

**2. Real-time Updates:**
- WebSocket implementation for live price updates
- Eliminate polling, reduce API calls

**3. Performance:**
- Redis caching layer for stock prices
- Database query optimization with proper indexing
- Frontend code splitting for faster loads

**4. Features:**
- Watchlist functionality
- Price alerts and notifications
- Historical performance charts (1M, 3M, 1Y views)
- Export transactions to CSV

**5. DevOps:**
- Docker containerization
- CI/CD pipeline with GitHub Actions
- Automated deployments to Vercel/Railway
- Comprehensive logging and monitoring

The AI integration works well, but I'd like to expand it with more sophisticated prompts and maybe fine-tune for better financial advice."
</details>

---

## 💡 Tricky Technical Questions

**Q18:** What happens if yfinance API goes down?

<details>
<summary>Answer</summary>

**Current state:** Application would fail to fetch prices, users couldn't trade.

**Solution: Fallback Strategy**

```python
def get_stock_price(symbol):
    try:
        # Primary: yfinance
        stock = yf.Ticker(symbol)
        return stock.info['currentPrice']
    except:
        try:
            # Fallback 1: Polygon API
            response = requests.get(
                f'https://api.polygon.io/v2/last/trade/{symbol}',
                params={'apiKey': POLYGON_API_KEY}
            )
            return response.json()['results']['p']
        except:
            try:
                # Fallback 2: Finnhub
                response = requests.get(
                    f'https://finnhub.io/api/v1/quote',
                    params={'symbol': symbol, 'token': FINNHUB_API_KEY}
                )
                return response.json()['c']
            except:
                # Fallback 3: Cached price (stale data better than none)
                cached = redis.get(f'price:{symbol}:backup')
                if cached:
                    return json.loads(cached)
                
                # Last resort: Disable trading, show error
                raise ServiceUnavailableError("Price data unavailable")

# Cache backup prices daily
@celery.task
def cache_backup_prices():
    for ticker in get_all_tickers():
        price = get_stock_price(ticker)
        redis.setex(f'price:{ticker}:backup', 86400, json.dumps(price))
```

**Additional measures:**
- Circuit breaker pattern
- Monitoring/alerting on API failures
- Graceful degradation (show last known price with warning)
- Status page for users
</details>

**Q19:** How do you prevent a user from buying the same stock twice with one button click?

<details>
<summary>Answer</summary>

**Multiple layers:**

**1. Frontend Debouncing:**
```typescript
const [isSubmitting, setIsSubmitting] = useState(false);

const handleBuy = async () => {
    if (isSubmitting) return;  // Guard clause
    
    setIsSubmitting(true);
    try {
        await axios.post('/api/buy', data);
    } finally {
        setIsSubmitting(false);  // Re-enable after completion
    }
};

<Button disabled={isSubmitting} onClick={handleBuy}>
    {isSubmitting ? 'Processing...' : 'Buy'}
</Button>
```

**2. Backend Idempotency Key:**
```python
@app.route('/api/buy', methods=['POST'])
@jwt_required()
def buy():
    idempotency_key = request.headers.get('X-Idempotency-Key')
    
    # Check if this request already processed
    if redis.exists(f'buy:{idempotency_key}'):
        cached_response = redis.get(f'buy:{idempotency_key}')
        return json.loads(cached_response)
    
    # Process transaction
    result = process_buy(...)
    
    # Cache result for 1 minute
    redis.setex(f'buy:{idempotency_key}', 60, json.dumps(result))
    return result
```

```typescript
// Frontend generates unique key per request
import { v4 as uuidv4 } from 'uuid';

const idempotencyKey = uuidv4();
await axios.post('/api/buy', data, {
    headers: {'X-Idempotency-Key': idempotencyKey}
});
```

**3. Database Constraints:**
```sql
-- Prevent duplicate transactions within 1 second
CREATE UNIQUE INDEX idx_unique_transaction 
ON transactions(user_id, ticker, shares, created_at);
```

**4. UI Feedback:**
- Show loading spinner
- Disable button during request
- Success toast confirms completion
- Clear form after success
</details>

**Q20:** Explain CORS and why you need it.

<details>
<summary>Answer</summary>

**What is CORS?**
Cross-Origin Resource Sharing - a security feature that prevents JavaScript on one domain from accessing resources on another domain.

**Why needed in my app:**
```
Frontend: http://localhost:5173 (Vite dev server)
Backend:  http://localhost:5000 (Flask server)

Different ports = different origins = CORS policy blocks requests
```

**Without CORS:**
Browser blocks API calls with error:
```
Access to XMLHttpRequest at 'http://localhost:5000/api/portfolio' 
from origin 'http://localhost:5173' has been blocked by CORS policy
```

**Solution:**
```python
from flask_cors import CORS

CORS(app, 
     resources={r"/api/*": {
         "origins": ["http://localhost:5173", "https://litekite.vercel.app"],
         "methods": ["GET", "POST", "PUT", "DELETE"],
         "allow_headers": ["Content-Type", "Authorization"]
     }},
     supports_credentials=True)
```

**How it works:**
1. Browser sends preflight OPTIONS request
2. Server responds with allowed origins in `Access-Control-Allow-Origin` header
3. If origin matches, browser allows actual request
4. Otherwise, request blocked

**Production considerations:**
- Don't use `origins: "*"` (security risk)
- Whitelist specific domains
- Use environment variables for origins
- Enable credentials for cookies/auth headers

**Alternative:** API and frontend on same domain using reverse proxy:
```
mydomain.com      → Frontend
mydomain.com/api  → Backend (proxied)
```
</details>

---

## 📊 Quick Mental Models

### Authentication Flow Diagram
You should be able to draw this from memory:

```
   [User]
     |
     | username + password
     ↓
[Frontend Login Form]
     |
     | POST /api/login
     ↓
[Backend @login route]
     |
     | check_password_hash()
     ↓
[Database User table]
     ↓
[Generate JWT token]
     |
     | {access_token: "eyJ..."}
     ↓
[Frontend stores in localStorage]
     |
     | navigate('/portfolio')
     ↓
[Protected Route Component]
     |
     | GET /api/portfolio + Bearer token
     ↓
[Backend @jwt_required()]
     |
     | validate token
     ↓
[Return portfolio data]
```

### Buy Stock Data Flow
```
      [BuyDialog]
           |
    GET /api/quote/:symbol
           ↓
      [Display price]
           |
    User confirms buy
           ↓
    POST /api/buy {symbol, shares}
           ↓
      [Backend]
           |
    Check user.cash >= cost
           |
    db.session.begin()
    user.cash -= cost
    transaction = Transaction(...)
    db.session.add(transaction)
    db.session.commit()
           |
    Return success + new balance
           ↓
      [Frontend]
    Show toast, refresh portfolio
```

### Database Relationships
```
User (1) ←──┐
             │
             │ user_id (FK)
             │
             ├── (Many) Transaction
             │
             └── (Many) IndianStockTransactions
```

---

## 🎤 Mock Interview Questions

Practice answering these out loud in 60 seconds or less:

1. "Why Flask instead of Django?"
2. "How do you prevent SQL injection?"
3. "What's the difference between JWT and session-based auth?"
4. "How does React Context work?"
5. "Explain your component folder structure"
6. "What's SQLAlchemy and why use an ORM?"
7. "How do database migrations work?"
8. "What's the difference between PUT and POST?"
9. "How do you handle errors in async JavaScript?"
10. "Explain the Virtual DOM in React"
11. "What are React hooks you've used?"
12. "How does HTTPS protect data?"
13. "What's the difference between authentication and authorization?"
14. "How would you deploy this application?"
15. "What's your Git workflow?"

---

## 🏋️ Daily Practice Routine

**Day 1-2:** Project Basics
- Memorize elevator pitch
- Practice explaining tech stack
- Draw architecture diagram from memory

**Day 3-4:** Deep Technical
- Authentication flow (draw it)
- Buy/sell transaction flow
- Portfolio calculation algorithm

**Day 5-6:** System Design
- Scaling strategy
- Caching layers
- Database optimization

**Day 7:** Mock Interview
- Record yourself answering all questions
- Review and improve weak areas

**Every Day:**
- Answer 5 questions out loud
- Explain one feature in detail
- Review one file of your code

---

**Pro Tip:** The best preparation is actually understanding your code, not memorizing answers. If you can explain WHY you made each decision, you'll handle any question they throw at you! 🚀
