# LiteKite - Full Stack Interview Preparation Guide

## 📋 Table of Contents
1. [Project Overview & Elevator Pitch](#elevator-pitch)
2. [System Architecture](#system-architecture)
3. [Tech Stack Deep Dive](#tech-stack)
4. [Key Features Implementation](#key-features)
5. [Database Design](#database-design)
6. [API Endpoints & Flow](#api-endpoints)
7. [Authentication & Security](#authentication-security)
8. [Frontend Architecture](#frontend-architecture)
9. [Common Interview Questions & Answers](#interview-qa)
10. [Interview Tips & Strategy](#interview-tips)

---

## 🎯 Elevator Pitch (30 seconds)

**"LiteKite is a full-stack stock portfolio management platform that allows users to trade stocks with real-time prices. It supports both US and Indian stock markets, features AI-powered portfolio analysis using Google's Gemini API, and provides comprehensive transaction tracking and portfolio visualization."**

### Key Stats to Remember:
- Real-time stock data integration
- Dual market support (US & Indian stocks)
- AI-powered analysis
- $10,000 virtual cash per market
- JWT + Google OAuth authentication

---

## 🏗️ System Architecture

### High-Level Architecture
```
┌─────────────┐      HTTPS/REST      ┌──────────────┐
│   Frontend  │ ◄──────────────────► │   Backend    │
│  (React +   │                      │   (Flask)    │
│    Vite)    │                      │              │
└─────────────┘                      └───────┬──────┘
                                            │
                              ┌─────────────┼──────────────┐
                              │             │              │
                         ┌────▼────┐   ┌────▼────┐   ┌────▼────┐
                         │PostgreSQL│   │ External│   │ Gemini  │
                         │ Database │   │Stock API│   │   AI    │
                         └──────────┘   └─────────┘   └─────────┘
```

### Technology Stack

**Frontend:**
- React 18 with TypeScript
- Vite (build tool)
- Tailwind CSS + Shadcn UI (styling)
- React Router v6 (routing)
- Axios (HTTP client)
- Recharts (data visualization)
- Framer Motion (animations)

**Backend:**
- Flask 3.x (Python web framework)
- SQLAlchemy (ORM)
- Flask-Migrate + Alembic (database migrations)
- Flask-JWT-Extended (authentication)
- Flask-CORS (cross-origin requests)
- PostgreSQL (database)
- yfinance (stock data)
- Pandas (data processing)

**External Services:**
- Google Gemini AI API
- Yahoo Finance API (via yfinance)
- Polygon API
- Finnhub API
- Google OAuth 2.0

---

## 🔑 Key Features Implementation

### 1. **User Authentication**

**Technologies:** JWT, bcrypt, Google OAuth

**How it works:**
```python
# Backend - JWT token generation
access_token = create_access_token(identity=user_id)

# Password hashing
hash = generate_password_hash(password)

# Verification
check_password_hash(user.hash, password)
```

**Frontend Flow:**
```typescript
// AuthContext manages global auth state
- Login → JWT stored in localStorage
- Axios interceptor adds Bearer token to all requests
- Protected routes check isAuthenticated state
```

**Why JWT?**
- Stateless authentication
- Scalable (no server-side session storage)
- Can be easily validated on backend
- Supports expiration

### 2. **Real-Time Stock Data**

**Implementation:**
```python
# Using yfinance for stock data
import yfinance as yf

stock = yf.Ticker(symbol)
data = stock.history(period="1d")
current_price = data['Close'].iloc[-1]
```

**Data Sources:**
- US Stocks: yfinance, Polygon API
- Indian Stocks: yfinance with .NS suffix
- News: Finnhub API
- Fundamentals: Company financials from yfinance

### 3. **Portfolio Management**

**Business Logic:**
```python
# Calculate portfolio for a user
1. Fetch all transactions (buys & sells)
2. Group by ticker symbol
3. Calculate net shares = sum(buy_shares) - sum(sell_shares)
4. Get current price for each holding
5. Calculate total_value = shares × current_price
6. Calculate profit/loss vs purchase price
```

**Database Query:**
```python
transactions = Transaction.query.filter_by(user_id=user_id).all()
# Aggregate shares by ticker
portfolio = {}
for txn in transactions:
    if txn.type == 'buy':
        portfolio[txn.ticker] = portfolio.get(txn.ticker, 0) + txn.shares
    else:
        portfolio[txn.ticker] = portfolio.get(txn.ticker, 0) - txn.shares
```

### 4. **AI-Powered Analysis (Gemini Integration)**

**How it works:**
```python
import google.generativeai as genai

# Configure API
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-pro')

# Generate analysis
prompt = f"Analyze this portfolio: {portfolio_data}"
response = model.generate_content(prompt)
```

**Use Cases:**
- Portfolio risk assessment
- Stock recommendations
- Market insights based on holdings
- Investment strategy suggestions

### 5. **Buy/Sell Transactions**

**Validation Flow:**
```python
# BUY validation:
1. Check if user has sufficient cash
2. Verify stock symbol exists
3. Get current price
4. Calculate total_cost = shares × price
5. Deduct cash from user account
6. Create transaction record

# SELL validation:
1. Check if user owns enough shares
2. Get current price
3. Calculate total_value = shares × price
4. Add cash to user account
5. Create transaction record
```

**Database Transaction (ACID):**
```python
try:
    user.cash -= total_cost
    transaction = Transaction(...)
    db.session.add(transaction)
    db.session.commit()
except:
    db.session.rollback()
```

---

## 💾 Database Design

### Schema

**User Table:**
```sql
- id (PK)
- username (unique)
- fullname
- email (unique)
- phone (unique)
- hash (password)
- cash (default: 10000.00)
- indiancash (default: 10000.00)
- nationality
- google_id (for OAuth)
```

**Transaction Table:**
```sql
- id (PK)
- user_id (FK → User)
- ticker
- name
- shares
- price
- type ('buy' or 'sell')
- time (timestamp)
```

**IndianStockTransactions Table:**
```sql
- Same structure as Transaction
- Separate table for Indian market tracking
```

### Relationships
- One-to-Many: User → Transactions
- Cascade delete: If user deleted, all transactions deleted

### Indexing Strategy
```sql
-- For faster queries
CREATE INDEX idx_user_transactions ON transaction(user_id);
CREATE INDEX idx_ticker ON transaction(ticker);
CREATE INDEX idx_time ON transaction(time DESC);
```

---

## 🔌 API Endpoints

### Authentication
```
POST /api/register          - Create new user
POST /api/login             - Login (returns JWT)
GET  /api/auth/google       - Initiate Google OAuth
GET  /api/auth/callback     - OAuth callback
```

### User
```
GET  /api/user              - Get user details (protected)
PUT  /api/user/profile      - Update profile (protected)
```

### Stock Operations
```
GET  /api/quote/:symbol     - Get stock quote
GET  /api/search            - Search stocks
GET  /api/fundamentals/:sym - Get stock fundamentals
GET  /api/graph/:symbol     - Get historical data
```

### Trading
```
POST /api/buy               - Buy stocks (protected)
POST /api/sell              - Sell stocks (protected)
POST /api/buyindian         - Buy Indian stocks
POST /api/sellindian        - Sell Indian stocks
```

### Portfolio
```
GET  /api/portfolio         - Get user portfolio (protected)
GET  /api/indianportfolio   - Get Indian portfolio
GET  /api/history           - Get transaction history
GET  /api/analyze           - AI portfolio analysis
```

### Request/Response Example

**Buy Stock:**
```json
// Request
POST /api/buy
Headers: Authorization: Bearer <jwt_token>
Body: {
  "symbol": "AAPL",
  "shares": 10
}

// Response
{
  "message": "Successfully purchased 10 shares of AAPL",
  "transaction": {
    "id": 123,
    "ticker": "AAPL",
    "shares": 10,
    "price": 175.50,
    "total": 1755.00,
    "remaining_cash": 8245.00
  }
}
```

---

## 🔐 Authentication & Security

### Security Measures - Detailed Implementation

#### 1. **Password Security: Bcrypt Hashing with Salt**

**Why Bcrypt?**
- Designed to be slow (prevents brute force attacks)
- Automatically handles salting (each password gets unique hash)
- Adaptive - can increase cost factor as computers get faster
- Industry standard for password hashing

**Implementation in My Project:**

```python
# Backend: api/index.py
from werkzeug.security import generate_password_hash, check_password_hash

# REGISTRATION - Creating new user
@app.route('/api/register', methods=['POST'])
def register():
    username = request.json.get('username')
    password = request.json.get('password')
    
    # Generate bcrypt hash with automatic salt
    # Cost factor: 12 rounds (default)
    password_hash = generate_password_hash(password)
    
    # Store ONLY the hash, never plain text
    new_user = User(
        username=username,
        hash=password_hash,  # Stored as: $2b$12$random_salt$hashed_password
        cash=10000.00
    )
    
    db.session.add(new_user)
    db.session.commit()
    
    return jsonify({'message': 'User created successfully'}), 201

# LOGIN - Verifying password
@app.route('/api/login', methods=['POST'])
def login():
    username = request.json.get('username')
    password = request.json.get('password')
    
    # Fetch user from database
    user = User.query.filter_by(username=username).first()
    
    if not user:
        return jsonify({'error': 'Invalid credentials'}), 401
    
    # Verify password against stored hash
    # This securely compares: hash(input_password) == stored_hash
    if not check_password_hash(user.hash, password):
        return jsonify({'error': 'Invalid credentials'}), 401
    
    # Password verified - generate JWT token
    access_token = create_access_token(identity=user.id)
    return jsonify({'access_token': access_token, 'message': 'Login successful'})
```

**What's happening under the hood:**
```
Registration:
Input: "mypassword123"
↓
Bcrypt generates random salt: "X8kd2mQ9pL3s"
↓
Combines: "mypassword123" + "X8kd2mQ9pL3s"
↓
Hashes 12 rounds (2^12 = 4096 iterations)
↓
Stored: "$2b$12$X8kd2mQ9pL3s$hashed_output"
        |   |   |              |
      algo cost salt      actual_hash

Login:
Input: "mypassword123"
↓
Bcrypt extracts salt from stored hash: "X8kd2mQ9pL3s"
↓
Hashes input with same salt and cost
↓
Compares result with stored hash
↓
Match = Login successful
```

**Security Benefits in My Project:**
- ✅ Even if database is leaked, passwords are safe
- ✅ Same password for two users = different hashes (unique salts)
- ✅ Rainbow table attacks are impossible (salt is unique per password)
- ✅ Brute force is very slow (12 rounds = ~200ms per attempt)

**Interview Tip:** Mention you could add:
- Password strength validation (minimum length, complexity)
- Rate limiting on login attempts (prevent brute force)
- Account lockout after failed attempts
- Password history (prevent reuse)

---

#### 2. **JWT Security: Stateless Token Authentication**

**What is JWT?**
JSON Web Token - a compact, self-contained way to securely transmit information between parties as a JSON object.

**Structure:**
```
eyJhbGci0iJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMjMsImV4cCI6MTY0MDk5OTk5OX0.hashed_signature
     │                                    │                                   │
   HEADER                              PAYLOAD                           SIGNATURE
   {"alg":"HS256","typ":"JWT"}        {"user_id":123,"exp":1640999999}   HMACSHA256(...)
```

**Implementation in My Project:**

```python
# Backend: api/index.py
from flask_jwt_extended import JWTManager, create_access_token, jwt_required, get_jwt_identity
import os
from datetime import timedelta

# JWT Configuration
app.config["JWT_SECRET_KEY"] = os.getenv('JWT_SECRET_KEY')  # Never hardcode!
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=24)
jwt = JWTManager(app)

# 1. GENERATE TOKEN (Login)
@app.route('/api/login', methods=['POST'])
def login():
    # ... verify password (see above) ...
    
    # Create JWT token with user ID as identity
    access_token = create_access_token(
        identity=user.id,  # This becomes the "sub" claim in JWT
        additional_claims={
            'username': user.username,
            'email': user.email
        }
    )
    
    # Token automatically includes:
    # - exp (expiration): current_time + 24 hours
    # - iat (issued at): current_time
    # - identity: user.id
    
    return jsonify({
        'access_token': access_token,
        'token_type': 'Bearer'
    })

# 2. PROTECT ROUTES
@app.route('/api/portfolio', methods=['GET'])
@jwt_required()  # This decorator validates the JWT
def portfolio():
    # Extract user ID from validated token
    current_user_id = get_jwt_identity()
    
    # Fetch portfolio for this user
    user = User.query.get(current_user_id)
    transactions = Transaction.query.filter_by(user_id=current_user_id).all()
    
    # ... build portfolio ...
    
    return jsonify(portfolio_data)

# 3. HANDLE INVALID/EXPIRED TOKENS
@jwt.expired_token_loader
def expired_token_callback(jwt_header, jwt_payload):
    return jsonify({
        'error': 'Token has expired',
        'message': 'Please login again'
    }), 401

@jwt.invalid_token_loader
def invalid_token_callback(error):
    return jsonify({
        'error': 'Invalid token',
        'message': 'Token signature verification failed'
    }), 401

@jwt.unauthorized_loader
def missing_token_callback(error):
    return jsonify({
        'error': 'Authorization required',
        'message': 'No token provided'
    }), 401
```

**Frontend Implementation:**

```typescript
// Frontend: src/AuthContext.tsx
import { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';
import { url } from './lib/url';

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider = ({ children }: { children: React.ReactNode }) => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [token, setToken] = useState<string | null>(null);

  // 1. INITIALIZE - Check for existing token on app load
  useEffect(() => {
    const storedToken = localStorage.getItem('authToken');
    if (storedToken) {
      setToken(storedToken);
      setIsAuthenticated(true);
      // Set default header for all axios requests
      axios.defaults.headers.common['Authorization'] = `Bearer ${storedToken}`;
    }
  }, []);

  // 2. LOGIN - Store token and set authenticated
  const login = async (username: string, password: string) => {
    try {
      const response = await axios.post(`${url}/login`, { username, password });
      const { access_token } = response.data;
      
      // Store in localStorage (persists across page refreshes)
      localStorage.setItem('authToken', access_token);
      
      // Update state
      setToken(access_token);
      setIsAuthenticated(true);
      
      // Set Authorization header for all future requests
      axios.defaults.headers.common['Authorization'] = `Bearer ${access_token}`;
      
      return { success: true };
    } catch (error) {
      return { success: false, error: error.response?.data?.error };
    }
  };

  // 3. LOGOUT - Clear token
  const logout = () => {
    localStorage.removeItem('authToken');
    setToken(null);
    setIsAuthenticated(false);
    delete axios.defaults.headers.common['Authorization'];
  };

  // 4. AXIOS INTERCEPTOR - Handle 401 errors globally
  useEffect(() => {
    const interceptor = axios.interceptors.response.use(
      (response) => response,
      (error) => {
        if (error.response?.status === 401) {
          // Token expired or invalid - logout user
          logout();
        }
        return Promise.reject(error);
      }
    );

    return () => axios.interceptors.response.eject(interceptor);
  }, []);

  return (
    <AuthContext.Provider value={{ isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

// 5. PROTECTED ROUTE COMPONENT
export const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated } = useAuth();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return <>{children}</>;
};
```

**Complete JWT Flow in My Project:**

```
1. USER LOGIN
   Frontend: POST /api/login { username, password }
   ↓
   Backend: Verify password with bcrypt
   ↓
   Backend: Generate JWT token with user.id
   ↓
   Backend: Return { access_token: "eyJ..." }
   ↓
   Frontend: Store in localStorage.setItem('authToken', token)
   ↓
   Frontend: Set axios header: Authorization: Bearer eyJ...

2. MAKING AUTHENTICATED REQUESTS
   Frontend: GET /api/portfolio
   ↓
   Axios automatically adds: Authorization: Bearer eyJ...
   ↓
   Backend: @jwt_required() decorator intercepts request
   ↓
   Backend: Validates token signature (using JWT_SECRET_KEY)
   ↓
   Backend: Checks expiration (< 24 hours old?)
   ↓
   Backend: Extracts user_id from token
   ↓
   Backend: Fetch data for that user
   ↓
   Backend: Return portfolio data

3. TOKEN EXPIRATION
   24 hours pass...
   ↓
   Frontend: GET /api/portfolio (with expired token)
   ↓
   Backend: Token validation fails (exp claim exceeded)
   ↓
   Backend: Return 401 Unauthorized
   ↓
   Frontend: Axios interceptor catches 401
   ↓
   Frontend: Logout user, redirect to /login
```

**Security Benefits:**
- ✅ **Stateless:** No server-side session storage needed (scales horizontally)
- ✅ **Self-contained:** All info in token, no database lookup needed
- ✅ **Secure:** Signed with secret key, can't be tampered with
- ✅ **Expiration:** Auto-expires after 24 hours
- ✅ **Cross-domain:** Works with CORS (unlike cookies with SameSite=Strict)

**Interview Tip:** Mention potential improvements:
- Use refresh tokens (short-lived access token + long-lived refresh token)
- Store in httpOnly cookies instead of localStorage (more secure)
- Token blacklist for logout (requires Redis)
- Role-based claims (admin vs regular user)

---

#### 3. **CORS Configuration: Cross-Origin Resource Sharing**

**Why CORS is Needed:**

```
Development Setup:
Frontend: http://localhost:5173  (Vite dev server)
Backend:  http://localhost:5000  (Flask server)
          ↓
Different ports = Different origins = Blocked by browser!
```

**Without CORS:**
```javascript
// Frontend tries to fetch
fetch('http://localhost:5000/api/portfolio')

// Browser blocks:
❌ CORS policy: No 'Access-Control-Allow-Origin' header present
```

**Implementation in My Project:**

```python
# Backend: api/index.py
from flask_cors import CORS
import os

# Get frontend URL from environment
FRONTEND_URL = os.getenv('FRONTEND_URL', 'http://localhost:5173')

# Configure CORS
CORS(app, 
     resources={
         r"/api/*": {  # Only allow CORS on /api/* routes
             "origins": FRONTEND_URL,  # Only this origin allowed
             "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
             "allow_headers": ["Content-Type", "Authorization"],
             "supports_credentials": True,  # Allow cookies/auth headers
             "max_age": 3600  # Cache preflight requests for 1 hour
         }
     })

# For multiple environments:
# Development: http://localhost:5173
# Production: https://litekite.vercel.app
```

**How CORS Works - The Preflight Request:**

```
1. SIMPLE REQUEST (GET with no custom headers):
   Browser → Backend: GET /api/portfolio
   Backend → Browser: 
     Access-Control-Allow-Origin: http://localhost:5173
     (data)
   ✅ Request allowed

2. COMPLEX REQUEST (POST with Authorization header):
   
   Step 1 - Preflight (Browser automatically sends):
   Browser → Backend: OPTIONS /api/buy
     Origin: http://localhost:5173
     Access-Control-Request-Method: POST
     Access-Control-Request-Headers: Authorization, Content-Type
   
   Backend → Browser: 
     Access-Control-Allow-Origin: http://localhost:5173
     Access-Control-Allow-Methods: GET, POST, PUT, DELETE
     Access-Control-Allow-Headers: Authorization, Content-Type
     Access-Control-Max-Age: 3600
   
   Step 2 - Actual Request:
   Browser → Backend: POST /api/buy
     Authorization: Bearer eyJ...
     Content-Type: application/json
     { "symbol": "AAPL", "shares": 10 }
   
   Backend → Browser:
     Access-Control-Allow-Origin: http://localhost:5173
     { "message": "Success" }
   ✅ Request allowed
```

**Production Configuration:**

```python
# For production deployment
FRONTEND_URLS = [
    'https://litekite.vercel.app',
    'https://www.litekite.vercel.app'
]

CORS(app, 
     resources={r"/api/*": {"origins": FRONTEND_URLS}},
     supports_credentials=True)
```

**Security Considerations:**
- ✅ **Never use "*"** (allow all origins) in production
- ✅ **Whitelist specific origins** from environment variables
- ✅ **Limit allowed methods** to only what you use
- ✅ **Supports credentials** required for cookies or auth headers

---

#### 4. **Session Security: Secure Cookie Configuration**

**Implementation in My Project:**

```python
# Backend: api/index.py
from flask import session
import os

# Session configuration for OAuth and CSRF protection
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')  # Signs session cookies
app.config['SESSION_COOKIE_SECURE'] = True  # HTTPS only
app.config['SESSION_COOKIE_HTTPONLY'] = True  # No JavaScript access
app.config['SESSION_COOKIE_SAMESITE'] = 'None'  # Allow cross-origin (for OAuth)

# For Google OAuth callback
@app.route('/api/auth/google')
def google_login():
    # Store state in session for CSRF protection
    session['oauth_state'] = generate_random_state()
    redirect_uri = url_for('google_callback', _external=True)
    return google.authorize_redirect(redirect_uri)

@app.route('/api/auth/callback')
def google_callback():
    # Verify state to prevent CSRF
    if request.args.get('state') != session.get('oauth_state'):
        return jsonify({'error': 'Invalid state'}), 400
    
    token = google.authorize_access_token()
    user_info = google.parse_id_token(token)
    
    # Create/login user, generate JWT
    access_token = create_access_token(identity=user.id)
    
    # Clear OAuth session data
    session.pop('oauth_state', None)
    
    return jsonify({'access_token': access_token})
```

**Cookie Flags Explained:**

| Flag | Purpose | My Setting |
|------|---------|------------|
| **Secure** | Only sent over HTTPS | ✅ True (production) |
| **HttpOnly** | No JavaScript access | ✅ True |
| **SameSite** | Cross-site behavior | None (for OAuth redirect) |
| **Domain** | Cookie scope | Auto (current domain) |
| **Path** | URL path scope | / (entire site) |
| **Max-Age** | Cookie expiration | Session (until browser closes) |

**Why SameSite=None?**
```
OAuth Flow crosses sites:
Frontend (litekite.vercel.app) 
  → Google (accounts.google.com) 
  → Backend callback (api.litekite.com)

SameSite=Strict would block the callback!
SameSite=None allows it (with Secure flag required)
```

**Security Benefits:**
- ✅ **Secure flag:** Prevents man-in-the-middle attacks on HTTP
- ✅ **HttpOnly flag:** Prevents XSS attacks from stealing cookies
- ✅ **SameSite=None + Secure:** Allows OAuth while maintaining security

---

#### 5. **Input Validation: Multi-Layer Protection**

**A. Backend Validation - All User Inputs**

```python
# Backend: api/index.py
from flask import request
import re

@app.route('/api/buy', methods=['POST'])
@jwt_required()
def buy():
    user_id = get_jwt_identity()
    
    # 1. VALIDATE PRESENCE
    symbol = request.json.get('symbol')
    if not symbol:
        return jsonify({'error': 'Stock symbol is required'}), 400
    
    shares = request.json.get('shares')
    if not shares:
        return jsonify({'error': 'Number of shares is required'}), 400
    
    # 2. VALIDATE TYPE
    try:
        shares = int(shares)
    except ValueError:
        return jsonify({'error': 'Shares must be a number'}), 400
    
    # 3. VALIDATE RANGE
    if shares <= 0:
        return jsonify({'error': 'Shares must be positive'}), 400
    
    if shares > 10000:
        return jsonify({'error': 'Maximum 10,000 shares per transaction'}), 400
    
    # 4. VALIDATE FORMAT (stock symbol)
    if not re.match(r'^[A-Z]{1,5}$', symbol.upper()):
        return jsonify({'error': 'Invalid stock symbol format'}), 400
    
    # 5. SANITIZE INPUT (prevent XSS)
    symbol = symbol.strip().upper()
    
    # 6. VALIDATE BUSINESS LOGIC
    user = User.query.get(user_id)
    quote = lookup(symbol)
    
    if not quote:
        return jsonify({'error': 'Invalid stock symbol'}), 404
    
    total_cost = shares * quote['price']
    
    if user.cash < total_cost:
        return jsonify({
            'error': 'Insufficient funds',
            'available': user.cash,
            'required': total_cost
        }), 400
    
    # All validations passed - proceed with transaction
    # ...
```

**B. SQL Injection Prevention - SQLAlchemy ORM**

```python
# ❌ VULNERABLE (Raw SQL with string concatenation)
def get_user_vulnerable(username):
    query = f"SELECT * FROM users WHERE username = '{username}'"
    result = db.engine.execute(query)
    # Attacker inputs: "admin' OR '1'='1"
    # Query becomes: SELECT * FROM users WHERE username = 'admin' OR '1'='1'
    # Returns all users!

# ✅ SAFE (SQLAlchemy ORM - Parameterized)
def get_user_safe(username):
    user = User.query.filter_by(username=username).first()
    # SQLAlchemy automatically escapes inputs
    # Creates: SELECT * FROM users WHERE username = ?
    # Parameters: ['username_value']
    return user

# ✅ SAFE (Raw SQL with parameters)
def get_user_raw_safe(username):
    query = text("SELECT * FROM users WHERE username = :username")
    result = db.session.execute(query, {"username": username})
    # PostgreSQL safely handles parameterization
```

**C. XSS Prevention - React Auto-Escaping**

```typescript
// Frontend: src/pages/Portfolio.tsx

// ✅ SAFE - React automatically escapes
const Portfolio = () => {
  const [stocks, setStocks] = useState([]);
  
  return (
    <div>
      {stocks.map(stock => (
        <div key={stock.ticker}>
          <h3>{stock.ticker}</h3>  {/* Auto-escaped */}
          <p>{stock.name}</p>       {/* Auto-escaped */}
          {/* If stock.name = "<script>alert('xss')</script>" */}
          {/* React renders: &lt;script&gt;alert('xss')&lt;/script&gt; */}
        </div>
      ))}
    </div>
  );
};

// ❌ DANGEROUS - Bypasses React escaping
const DangerousComponent = ({ html }) => {
  return <div dangerouslySetInnerHTML={{ __html: html }} />;
  // Only use this for trusted, sanitized HTML!
};

// ✅ SAFE - If you must render HTML, sanitize first
import DOMPurify from 'dompurify';

const SafeHTMLComponent = ({ html }) => {
  const sanitized = DOMPurify.sanitize(html);
  return <div dangerouslySetInnerHTML={{ __html: sanitized }} />;
};
```

**Validation Strategy Summary:**

| Layer | What | Where | Example |
|-------|------|-------|---------|
| **Frontend** | UX validation | React forms | Required fields, number inputs |
| **Backend** | Security validation | Flask routes | Type, range, format checks |
| **Database** | Constraints | PostgreSQL | NOT NULL, UNIQUE, CHECK |
| **ORM** | SQL injection prevention | SQLAlchemy | Parameterized queries |

---

#### 6. **Environment Variables: Secure Configuration Management**

**File Structure:**

```
LiteKite-Backend/
├── .env                    # Local development (NOT committed)
├── .env.example            # Template (committed)
├── .gitignore              # Ignores .env
└── api/
    └── index.py            # Reads from .env
```

**My .env File (Development):**

```bash
# Database
DATABASE_URL=postgresql://localhost/litekite_dev

# JWT Secret (generate with: python -c "import secrets; print(secrets.token_hex(32))")
JWT_SECRET_KEY=8f42a73054b1749f8f58848be5e6502c42f5e3c1a78d3c8e9f10d8a4b5c6e7f8

# External APIs
GEMINI_API_KEY=AIzaSyBxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
POLYGON_API_KEY=PKxxxxxxxxxxxxxxxxxxxxx
FINNHUB_API_KEY=cbxxxxxxxxxxxxxxxxxxxxxx

# Google OAuth
GOOGLE_CLIENT_ID=123456789-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-xxxxxxxxxxxxxxxxxxxxxxxxxx
GOOGLE_REDIRECT_URI=http://localhost:5000/api/auth/callback

# Frontend (for CORS)
FRONTEND_URL=http://localhost:5173

# Flask
SECRET_KEY=dev-secret-key-change-in-production
FLASK_ENV=development
```

**My .env.example (Committed to Git):**

```bash
# Database
DATABASE_URL=postgresql://user:password@localhost/dbname

# JWT Secret
JWT_SECRET_KEY=your-secret-key-here

# External APIs
GEMINI_API_KEY=your-gemini-key
POLYGON_API_KEY=your-polygon-key

# Google OAuth
GOOGLE_CLIENT_ID=your-client-id
GOOGLE_CLIENT_SECRET=your-client-secret

# Frontend
FRONTEND_URL=http://localhost:5173
```

**Loading Environment Variables:**

```python
# Backend: api/index.py
import os
from dotenv import load_dotenv

# Load .env file
load_dotenv()

# Access variables
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL')
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY')

GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
FRONTEND_URL = os.getenv('FRONTEND_URL')

# Validation - Ensure critical vars exist
if not app.config['JWT_SECRET_KEY']:
    raise ValueError("JWT_SECRET_KEY environment variable is not set!")

# Different configs for dev/prod
ENV = os.getenv('FLASK_ENV', 'production')

if ENV == 'development':
    app.config['DEBUG'] = True
    app.config['SESSION_COOKIE_SECURE'] = False  # Allow HTTP
else:
    app.config['DEBUG'] = False
    app.config['SESSION_COOKIE_SECURE'] = True  # Require HTTPS
```

**Frontend Environment Variables:**

```bash
# LiteKite-Frontend/.env.local
VITE_BACKEND_URL=http://localhost:5000/api
VITE_GOOGLE_CLIENT_ID=123456789-xxxxxxxx.apps.googleusercontent.com
```

```typescript
// Frontend: src/lib/url.ts
export const url = import.meta.env.VITE_BACKEND_URL || 'http://localhost:5000/api';

// Usage in components
import { url } from '@/lib/url';
const response = await axios.get(`${url}/portfolio`);
```

**.gitignore Configuration:**

```gitignore
# Environment variables
.env
.env.local
.env.*.local

# Python
__pycache__/
*.pyc
venv/

# Node
node_modules/
.env.local

# IDE
.vscode/
.idea/

# Never commit these!
*.pem
*.key
secrets.json
```

**Production Deployment (Vercel/Railway):**

```bash
# Railway (Backend)
railway variables set DATABASE_URL="postgres://..."
railway variables set JWT_SECRET_KEY="production-secret"
railway variables set GEMINI_API_KEY="..."

# Vercel (Frontend)
vercel env add VITE_BACKEND_URL
# Input: https://api.litekite.com
```

**Security Best Practices I Follow:**

| Practice | Implementation |
|----------|----------------|
| **Never commit secrets** | .env in .gitignore |
| **Different keys per environment** | dev.env, prod.env |
| **Rotate secrets regularly** | Change JWT_SECRET quarterly |
| **Strong secret generation** | `secrets.token_hex(32)` |
| **Environment validation** | Raise error if missing |
| **Least privilege** | Each service only gets keys it needs |

**Interview Tip:** If asked "What if .env was accidentally committed?"
1. Immediately rotate all secrets (generate new keys)
2. Update production environment variables
3. Use `git filter-branch` or BFG Repo-Cleaner to remove from history
4. Force push to remote
5. Notify team and services affected

---

### OAuth 2.0 Flow

```
1. User clicks "Login with Google"
2. Frontend → GET /api/auth/google
3. Backend redirects to Google consent page
4. User approves
5. Google → GET /api/auth/callback with code
6. Backend exchanges code for user info
7. Create/login user, generate JWT
8. Redirect to frontend with token
```

---

## 🎨 Frontend Architecture

### Component Structure

```
src/
├── components/          # Reusable UI components
│   ├── ui/             # Shadcn base components
│   ├── BuyDialog.tsx   # Buy stock modal
│   ├── SellDialog.tsx  # Sell stock modal
│   ├── Graph.tsx       # Stock charts
│   └── Navbar.tsx      # Navigation
├── pages/              # Route pages
│   ├── Portfolio.tsx
│   ├── Login.tsx
│   └── Trade.tsx
├── lib/                # Utilities
│   ├── utils.ts
│   └── url.ts          # API base URL
├── hooks/              # Custom hooks
└── AuthContext.tsx     # Global auth state
```

### State Management

**Context API for Auth:**
```typescript
AuthContext provides:
- isAuthenticated: boolean
- login(username, password)
- logout()
- register(username, password)
- setAuthToken(token)
```

**Local State with useState:**
- Component-level data (forms, modals)
- Portfolio data (fetched from API)

**Why not Redux?**
- App complexity doesn't require it
- Context API sufficient for auth
- Most data fetched fresh from API

### Routing Strategy

```typescript
// Protected Route HOC
<ProtectedRoute>
  {isAuthenticated ? <Component /> : <Navigate to="/login" />}
</ProtectedRoute>

// Routes
/              → LandingPage (public)
/login         → Login (public)
/portfolio     → Portfolio (protected)
/buy           → Buy (protected)
/sell          → Sell (protected)
```

### API Communication

```typescript
// axios instance with interceptors
axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

// Error handling
try {
  const response = await axios.get(`${url}/portfolio`);
} catch (error) {
  if (error.response?.status === 401) {
    // Redirect to login
  }
  // Show error toast
}
```

---

## 💬 Common Interview Questions & Answers

### Basic Questions

**Q1: Walk me through your project.**

**A:** "LiteKite is a full-stack stock trading platform I built. On the backend, I used Flask with PostgreSQL to handle user authentication, stock transactions, and portfolio management. The frontend is built with React and TypeScript using Vite as the build tool. Users can trade both US and Indian stocks with real-time prices, view their portfolio with interactive charts using Recharts, and get AI-powered analysis through the Gemini API. I implemented JWT-based authentication with Google OAuth support, and used SQLAlchemy for database operations with proper migrations."

**Q2: Why did you choose Flask over Django or FastAPI?**

**A:** "I chose Flask because:
1. It's lightweight and gives me more control over the architecture
2. I only needed RESTful APIs, not a full MVC framework like Django
3. Flask-SQLAlchemy provides excellent ORM capabilities
4. Great ecosystem with Flask-JWT-Extended, Flask-CORS, etc.
5. I'm familiar with Flask and it's perfect for this scale

If I were building this today, I might consider FastAPI for automatic API documentation and type hints, but Flask serves my needs well."

**Q3: How do you handle user authentication?**

**A:** "I use a dual approach:
1. **Traditional login:** Username/password with bcrypt hashing. On successful login, Flask-JWT-Extended generates an access token that's sent to the frontend and stored in localStorage.
2. **Google OAuth:** Using Authlib, I redirect users to Google for authentication, receive a code on callback, exchange it for user info, and generate a JWT token.

All protected routes use the @jwt_required decorator, and the frontend includes the Bearer token in the Authorization header for every authenticated request."

**Q4: How do you fetch real-time stock prices?**

**A:** "I use the yfinance library which pulls data from Yahoo Finance:
```python
stock = yf.Ticker('AAPL')
data = stock.history(period='1d')
current_price = data['Close'].iloc[-1]
```

For Indian stocks, I append '.NS' or '.BO' suffix for NSE/BSE exchanges. I also have fallback APIs like Polygon and Finnhub for additional data and news."

**Q5: Explain your database schema.**

**A:** "I have three main tables:
1. **User:** Stores user credentials, separate cash balances for US and Indian markets (default $10,000 each), and OAuth IDs
2. **Transaction:** Records every buy/sell with user_id (foreign key), ticker, shares, price, type, and timestamp
3. **IndianStockTransactions:** Separate table for Indian market to keep data organized

The relationship is one-to-many from User to Transactions. I use indexes on user_id and ticker for faster queries."

### Intermediate Questions

**Q6: How do you calculate a user's portfolio?**

**A:** "The portfolio calculation involves:
1. Query all transactions for the user
2. Aggregate by ticker: `net_shares = SUM(buy_shares) - SUM(sell_shares)`
3. Fetch current price for each stock
4. Calculate current value: `shares × current_price`
5. Calculate profit/loss: `current_value - total_invested`
6. Return portfolio with metrics

I optimize this with SQL aggregation rather than Python loops:
```python
from sqlalchemy import func
totals = db.session.query(
    Transaction.ticker,
    func.sum(case((Transaction.type=='buy', Transaction.shares), else_=-Transaction.shares))
).group_by(Transaction.ticker).all()
```"

**Q7: How do you ensure data consistency in buy/sell operations?**

**A:** "I use database transactions with rollback on error:
```python
try:
    # Validate user has enough cash/shares
    if user.cash < total_cost:
        return error
    
    # Update user balance
    user.cash -= total_cost
    
    # Create transaction record
    txn = Transaction(...)
    db.session.add(txn)
    
    # Commit atomically
    db.session.commit()
except Exception as e:
    db.session.rollback()
    return error
```

This ensures ACID properties - either both operations succeed or both fail."

**Q8: How does the Gemini AI integration work?**

**A:** "I use Google's Generative AI SDK:
1. User clicks 'Analyze Portfolio'
2. Backend fetches portfolio data
3. I construct a prompt with portfolio details, current prices, and context
4. Send to Gemini API via `genai.GenerativeModel('gemini-pro').generate_content()`
5. Parse response and return insights to frontend

The AI provides investment advice, risk assessment, and diversification suggestions based on the user's holdings."

**Q9: How do you handle CORS in your application?**

**A:** "I configured Flask-CORS to allow requests from my frontend origin:
```python
CORS(app, 
     resources={r'/api/*': {'origins': FRONTEND_URL}},
     supports_credentials=True)
```

This allows my React app to make cross-origin requests while maintaining security. I also set proper session cookie flags (Secure, HttpOnly, SameSite) for production."

**Q10: Explain your frontend routing strategy.**

**A:** "I use React Router v6 with protected routes:
```typescript
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated } = useAuth();
  return isAuthenticated ? children : <Navigate to='/login' />;
};
```

Public routes like landing page and login are accessible to all. Protected routes (portfolio, buy, sell) check authentication status from AuthContext. If not authenticated, users are redirected to login."

### Advanced Questions

**Q11: How would you scale this application to handle 1 million users?**

**A:** "Several strategies:

**Backend:**
1. **Caching:** Redis for stock prices (refresh every 5s), user sessions
2. **Database:** 
   - Read replicas for portfolio queries
   - Partitioning transactions table by date
   - Connection pooling with pgBouncer
3. **Load balancing:** Multiple Flask instances behind Nginx
4. **Async processing:** Celery for heavy tasks like portfolio analysis
5. **CDN:** Serve static assets via CloudFlare

**Frontend:**
1. Code splitting and lazy loading
2. Service workers for offline support
3. Virtualized lists for large transaction history

**Infrastructure:**
- Containerize with Docker
- Kubernetes for orchestration
- Auto-scaling based on load
- Separate microservices for trading, analytics, user management"

**Q12: Security vulnerabilities and how you prevent them?**

**A:** 
1. **SQL Injection:** Using SQLAlchemy ORM with parameterized queries
2. **XSS:** React automatically escapes content, and I sanitize user inputs
3. **CSRF:** SameSite cookies and JWT tokens (stateless)
4. **Password attacks:** Bcrypt with salt, rate limiting on login attempts
5. **JWT vulnerabilities:** Short expiration, secret rotation, HTTPS only
6. **API abuse:** Rate limiting middleware, input validation
7. **Sensitive data:** Environment variables, no secrets in code, .gitignore for .env

I would add:
- CAPTCHA for registration
- 2FA for high-value accounts
- Security headers (CSP, X-Frame-Options)
- Regular dependency audits with `pip audit`"

**Q13: How would you implement real-time portfolio updates?**

**A:** "Current: Polling (frontend fetches every 30s)

**Better approaches:**

1. **WebSockets:**
```python
# Flask-SocketIO
@socketio.on('subscribe_portfolio')
def handle_subscription(user_id):
    join_room(f'user_{user_id}')
    # Emit updates when prices change
```

2. **Server-Sent Events (SSE):**
```python
@app.route('/api/stream/portfolio')
def stream_portfolio():
    def generate():
        while True:
            data = get_portfolio_updates()
            yield f'data: {json.dumps(data)}\n\n'
            time.sleep(5)
    return Response(generate(), mimetype='text/event-stream')
```

3. **React Query with short staleTime** for automatic refetching

I'd choose WebSockets for bidirectional communication and real-time price updates."

**Q14: Database migration strategy - rollback scenario?**

**A:** "I use Alembic via Flask-Migrate:

**Migration workflow:**
```bash
# Create migration
flask db migrate -m "description"

# Review auto-generated migration
# Edit versions/xxxxx.py if needed

# Apply
flask db upgrade

# Rollback
flask db downgrade -1
```

**Best practices:**
1. Always review auto-generated migrations
2. Test migrations in staging first
3. Backup database before prod migrations
4. Keep migrations small and atomic
5. Never modify applied migrations - create new ones

**Rollback scenario:**
```python
# In migration file
def upgrade():
    op.add_column('user', sa.Column('verified', sa.Boolean))

def downgrade():
    op.drop_column('user', 'verified')
```"

**Q15: How would you test this application?**

**A:** 
**Backend Testing:**
```python
# Unit tests
def test_buy_stock():
    user = User(cash=10000)
    response = buy_stock(user, 'AAPL', 10)
    assert user.cash < 10000
    assert response.status_code == 200

# Integration tests
def test_buy_endpoint():
    token = login('testuser', 'password')
    response = client.post('/api/buy',
                           headers={'Authorization': f'Bearer {token}'},
                           json={'symbol': 'AAPL', 'shares': 10})
    assert response.json['remaining_cash'] > 0
```

**Frontend Testing:**
```typescript
// Jest + React Testing Library
test('BuyDialog submits correctly', () => {
  render(<BuyDialog />);
  fireEvent.change(screen.getByPlaceholderText('Symbol'), {
    target: { value: 'AAPL' }
  });
  fireEvent.click(screen.getByText('Buy'));
  expect(mockAxios.post).toHaveBeenCalledWith('/api/buy', ...);
});
```

**E2E Testing:**
- Playwright/Cypress for user flows
- Test: Register → Login → Buy Stock → View Portfolio → Sell

**Performance Testing:**
- Locust for load testing
- Monitor response times under load"

### System Design Questions

**Q16: Design the database schema for handling 100K concurrent transactions.**

**A:** 
**Optimized Schema:**
```sql
-- Partitioned transactions table
CREATE TABLE transactions (
    id BIGSERIAL,
    user_id INTEGER NOT NULL,
    ticker VARCHAR(10),
    shares INTEGER,
    price DECIMAL(10,2),
    type VARCHAR(4),
    created_at TIMESTAMP DEFAULT NOW()
) PARTITION BY RANGE (created_at);

-- Monthly partitions
CREATE TABLE transactions_2024_01 PARTITION OF transactions
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

-- Indexes
CREATE INDEX CONCURRENTLY idx_user_txn ON transactions(user_id, created_at DESC);
CREATE INDEX idx_ticker ON transactions(ticker) WHERE created_at > NOW() - INTERVAL '1 year';

-- Materialized view for portfolio
CREATE MATERIALIZED VIEW user_portfolios AS
SELECT 
    user_id,
    ticker,
    SUM(CASE WHEN type='buy' THEN shares ELSE -shares END) as total_shares
FROM transactions
GROUP BY user_id, ticker;

CREATE UNIQUE INDEX ON user_portfolios(user_id, ticker);

-- Refresh strategy
REFRESH MATERIALIZED VIEW CONCURRENTLY user_portfolios;
```

**Additional optimizations:**
- Write-ahead logging
- Connection pooling (max 100 connections)
- Read replicas for queries
- Async commit for better throughput"

**Q17: API rate limiting implementation?**

**A:** 
```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app,
    key_func=get_remote_address,
    storage_uri="redis://localhost:6379"
)

# Apply limits
@app.route('/api/quote')
@limiter.limit("100 per minute")
def get_quote():
    ...

@app.route('/api/buy')
@limiter.limit("10 per minute")
@jwt_required()
def buy_stock():
    ...

# User-specific limits
@limiter.limit("1000 per day", key_func=lambda: get_jwt_identity())
```

**Distributed rate limiting:**
- Use Redis for centralized counter
- Sliding window algorithm
- Return 429 with Retry-After header"

**Q18: Monitoring and observability strategy?**

**A:** 
**Logging:**
```python
import logging
from pythonjsonlogger import jsonlogger

logger = logging.getLogger()
handler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter()
handler.setFormatter(formatter)
logger.addHandler(handler)

# Structured logging
logger.info('Stock purchased', extra={
    'user_id': user_id,
    'ticker': 'AAPL',
    'shares': 10,
    'price': 175.50,
    'transaction_id': txn.id
})
```

**Metrics (Prometheus):**
- Request count, latency, error rate
- Database connection pool utilization
- Active users, total trades
- Custom: Portfolio value distribution

**Tracing (Jaeger):**
- Track request flow: Frontend → API → Database
- Identify bottlenecks

**Alerts:**
- High error rate (>5%)
- Slow queries (>1s)
- Database connections exhausted
- Failed external API calls"

---

## 🎯 Interview Tips & Strategy

### How to Answer Technical Questions

**1. Use the STAR Method:**
- **S**ituation: Context of the problem
- **T**ask: What you needed to accomplish
- **A**ction: What you did
- **R**esult: Outcome and learnings

**Example:**
*"When implementing buy/sell transactions (S), I needed to ensure data consistency (T). I used database transactions with try-catch blocks and rollback on failure (A). This prevented scenarios where a user's cash was deducted but the transaction wasn't recorded (R)."*

**2. Think Out Loud:**
- Don't go silent when thinking
- Verbalize your thought process
- Draw diagrams if needed
- Ask clarifying questions

**3. Start Broad, Then Deep:**
```
Level 1: "I used JWT for authentication"
Level 2: "JWT tokens are generated on login, stored in localStorage, and sent via Authorization header"
Level 3: "I chose JWT because it's stateless and scalable. The token contains user_id, is signed with HS256, expires in 24h, and includes refresh token rotation for security"
```

**4. Admit What You Don't Know:**
- "I haven't implemented that, but here's how I would approach it..."
- "That's interesting, I'd research X, Y, Z to solve that"
- Shows honesty and problem-solving ability

**5. Connect to Your Project:**
Always bring the conversation back to YOUR implementation:
- "In LiteKite, I implemented..."
- "When I built the portfolio feature..."
- "I chose to use X because..."

### Common Question Patterns

**"What would you do differently?"**
- WebSocket for real-time updates
- Redis caching layer
- Implement testing (Jest, pytest)
- Add TypeScript to backend (FastAPI)
- Microservices architecture for scale
- CI/CD pipeline

**"Biggest challenge?"**
- Talk about the Indian stock API integration
- Real-time price updates
- Handling race conditions in transactions
- OAuth callback flow debugging

**"How did you learn X?"**
- Official documentation
- Built small prototypes first
- Stack Overflow for specific issues
- Debugging and iteration

### Pre-Interview Checklist

**✅ Know Your Numbers:**
- 3 database tables
- 2 markets (US & Indian)
- $10,000 starting cash per market
- JWT authentication
- 15+ API endpoints
- React 18, Flask 3.x, PostgreSQL

**✅ Rehearse These:**
1. 30-second elevator pitch
2. Authentication flow (diagram it)
3. Buy stock flow end-to-end
4. Database schema
5. Why you chose each technology

**✅ Have Stories Ready:**
- A bug you fixed
- A feature you're proud of
- Something you learned
- A trade-off you made

**✅ Test Your Project:**
- Make sure it runs locally
- Have a demo ready
- Know where each feature is in code
- Can you add a simple feature live?

### Day Before Interview

1. **Code Review:** Read through your main files
2. **Run the App:** Make sure everything works
3. **Prepare Questions:** Have 3-5 questions for them
4. **Environment:** Test camera, mic, internet
5. **Sleep Well:** Your brain needs rest

### During Interview

**DO:**
- ✅ Make eye contact and smile
- ✅ Ask for clarification
- ✅ Use diagrams and examples
- ✅ Mention trade-offs
- ✅ Show enthusiasm for your project

**DON'T:**
- ❌ Memorize answers (sounds robotic)
- ❌ Badmouth technologies
- ❌ Say "it just works" without explaining
- ❌ Lie about what you know
- ❌ Rush through answers

### If You Go Blank

**Pause Strategies:**
1. "That's a great question, let me think for a moment..."
2. "Could you clarify what you mean by X?"
3. "Let me draw this out to explain better"
4. "In my project, I encountered something similar..."
5. Take a sip of water

**Redirect:**
- "I'm not familiar with that specific approach, but in LiteKite I used..."
- "I haven't implemented X, but I understand the concept involves Y and Z"

---

## 📚 Quick Reference Cheat Sheet

### Architecture
- **Pattern:** Client-Server, REST API
- **Frontend:** React SPA with protected routes
- **Backend:** Flask REST API
- **Database:** PostgreSQL with SQLAlchemy ORM
- **Auth:** JWT + Google OAuth 2.0

### Key Technologies
| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | React + TypeScript | UI components |
| Routing | React Router v6 | SPA navigation |
| Styling | Tailwind + Shadcn | Responsive design |
| Charts | Recharts | Data visualization |
| Backend | Flask | REST API server |
| ORM | SQLAlchemy | Database operations |
| Auth | JWT-Extended | Token management |
| Database | PostgreSQL | Data persistence |
| Stock Data | yfinance | Real-time prices |
| AI | Google Gemini | Portfolio analysis |

### File Structure to Know
```
Backend:
- api/index.py         → Main Flask app, all endpoints
- api/models.py        → Database models
- api/helpers.py       → Utility functions (lookup, usd)
- api/stock.py         → Stock data fetching
- api/fundamentals.py  → Stock analysis data

Frontend:
- src/App.tsx          → Routes and layout
- src/AuthContext.tsx  → Auth state management
- src/components/BuyDialog.tsx → Stock purchase UI
- src/pages/Portfolio.tsx      → Portfolio display
- src/lib/url.ts       → API base URL
```

### SQL Queries You Might Discuss

**Get Portfolio:**
```sql
SELECT ticker, 
       SUM(CASE WHEN type='buy' THEN shares ELSE -shares END) as net_shares
FROM transactions 
WHERE user_id = ?
GROUP BY ticker
HAVING net_shares > 0;
```

**Transaction History:**
```sql
SELECT * FROM transactions
WHERE user_id = ?
ORDER BY time DESC
LIMIT 50;
```

**Total Invested:**
```sql
SELECT SUM(shares * price) as total
FROM transactions
WHERE user_id = ? AND type = 'buy';
```

### API Flow Examples

**Login Flow:**
```
1. POST /api/login {username, password}
2. Backend: validate credentials
3. Generate JWT token
4. Return {access_token: "eyJ..."}
5. Frontend: store in localStorage
6. Set axios default header
```

**Buy Stock Flow:**
```
1. User enters symbol + shares
2. POST /api/quote {symbol} → get current price
3. Display total cost
4. User confirms
5. POST /api/buy {symbol, shares} with JWT
6. Backend: validate, update DB
7. Return success + updated balance
8. Frontend: refresh portfolio
```

---

## 🚀 Final Confidence Boosters

### You Built This!
- You integrated multiple APIs
- You implemented authentication from scratch
- You designed a database schema
- You built a full-stack application
- You solved real problems (race conditions, data consistency)

### You Know This!
- How data flows from frontend to backend to database
- How authentication works
- How to prevent common security issues
- How to structure a scalable application

### Remember:
> **Interviewers want to see:**
> 1. Can you explain what you built?
> 2. Do you understand WHY you made certain choices?
> 3. Can you think through problems?
> 4. Are you honest about what you don't know?
> 5. Can you learn and improve?

**You've got this! Good luck! 🎯**

---

## 📖 Additional Study Topics (If Asked)

- **React Hooks:** useState, useEffect, useContext, custom hooks
- **TypeScript:** Type safety, interfaces, generics
- **Python Async:** async/await, asyncio for concurrent requests
- **Database Indexing:** B-tree, Hash indexes, when to use
- **Caching Strategies:** Cache-aside, write-through, TTL
- **Docker:** Containerization basics
- **Git Workflow:** Branching, merging, conflict resolution
- **REST Principles:** GET/POST/PUT/DELETE, status codes, idempotency

### Resources for Deep Dives
- Flask documentation: flask.palletsprojects.com
- React docs: react.dev
- SQLAlchemy ORM: docs.sqlalchemy.org
- JWT: jwt.io
- System Design: ByteByteGo, Designing Data-Intensive Applications
