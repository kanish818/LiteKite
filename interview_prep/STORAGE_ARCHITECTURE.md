# 🔐 LiteKite Authentication & Storage Architecture

## Complete Guide: Where Everything is Stored

---

## 📊 Storage Overview Table

| Data Type | Storage Location | Format | Access Method | Security |
|-----------|-----------------|--------|---------------|----------|
| **Plain Password** | ❌ Never Stored | N/A | N/A | Input only, immediately hashed |
| **Hashed Password** | PostgreSQL Database | Bcrypt hash string | SQLAlchemy ORM | Salt + 12 rounds |
| **JWT Secret Key** | Environment Variable | String (64+ chars) | `os.getenv()` | Never committed to Git |
| **JWT Token** | Browser localStorage | JWT string | `localStorage.getItem()` | Signed, 24hr expiration |
| **User Session** | Flask Session (Cookie) | Encrypted cookie | Flask session object | HTTPS only, HttpOnly |
| **Google OAuth State** | Flask Session | Random string | `session['oauth_state']` | CSRF protection |

---

## 1️⃣ PASSWORD STORAGE - Database (PostgreSQL)

### ❌ What is NEVER Stored

```python
# Plain text passwords NEVER touch the database!
password = "mypassword123"  # ❌ This is NEVER stored anywhere
```

### ✅ What IS Actually Stored - Bcrypt Hash

**Location:** PostgreSQL Database → `user` table → `hash` column

**Database Schema:**
```sql
CREATE TABLE user (
    id SERIAL PRIMARY KEY,
    username VARCHAR(80) UNIQUE NOT NULL,
    hash VARCHAR(255) NOT NULL,  -- ⬅️ Password stored HERE as bcrypt hash
    email VARCHAR(120) UNIQUE,
    cash FLOAT DEFAULT 10000.00,
    indiancash FLOAT DEFAULT 10000.00,
    google_id VARCHAR(255) UNIQUE,
    ...
);
```

**Example Database Record:**
```
id: 1
username: "john_doe"
hash: "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyKDkzS8qM/." 
      │   │  │                                                         │
      │   │  └─ Random Salt (16 bytes)                               │
      │   └─ Cost Factor (2^12 = 4096 iterations)                    │
      └─ Algorithm (bcrypt version 2b)                               │
                                                              Actual Hash ─┘
email: "john@example.com"
cash: 10000.00
```

### 🔄 Registration Flow - How Password Gets Stored

```python
# Backend: api/index.py (Line 128-164)
@app.route("/api/register", methods=["POST"])
def register():
    # 1. Receive plain password from frontend
    username = request.json.get("username")  # "john_doe"
    password = request.json.get("password")  # "mypassword123" ⬅️ Plain text INPUT
    
    # 2. Hash the password with bcrypt
    from werkzeug.security import generate_password_hash
    hashed_password = generate_password_hash(password)
    # Result: "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyKDkzS8qM/."
    
    # 3. Store ONLY the hash in database (plain password discarded)
    new_user = User(
        username=username,
        hash=hashed_password,  # ⬅️ Only hash goes to database
        cash=10000.00
    )
    
    # 4. Save to PostgreSQL
    db.session.add(new_user)
    db.session.commit()
    
    # Plain password "mypassword123" is now gone forever!
    # Only the hash exists in database
    
    return jsonify({"message": "User registered successfully!"}), 201
```

### 🔍 Login Flow - How Password is Verified

```python
# Backend: api/index.py (Line 111-125)
@app.route("/api/login", methods=["POST"])
def login():
    # 1. User sends plain password
    username = request.json.get("username")  # "john_doe"
    password = request.json.get("password")  # "mypassword123" ⬅️ Plain text input
    
    # 2. Fetch user from database (includes stored hash)
    user = User.query.filter_by(username=username).first()
    # user.hash = "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyKDkzS8qM/."
    
    # 3. Verify password against stored hash
    from werkzeug.security import check_password_hash
    is_valid = check_password_hash(user.hash, password)
    # This function:
    # - Extracts salt from stored hash
    # - Hashes input password with same salt
    # - Compares result with stored hash
    # - Returns True if match, False otherwise
    
    if not is_valid:
        return jsonify({"error": "Invalid password"}), 401
    
    # 4. If valid, generate JWT token (see next section)
    access_token = create_access_token(identity=str(user.id))
    return jsonify(access_token=access_token)
```

### 🔐 Security Features of Password Storage

**Why this is secure:**
1. **Salt is unique per password:** Two users with "password123" have different hashes
2. **Slow by design:** 12 rounds = ~200ms per hash (prevents brute force)
3. **Rainbow tables useless:** Pre-computed hashes won't work due to salt
4. **Database leak safe:** Even if database is stolen, passwords can't be reversed
5. **No plain text anywhere:** Password only exists in memory during request

**What attackers would see if database leaked:**
```
username: john_doe
hash: $2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyKDkzS8qM/.

Attacker must:
- Try billions of password combinations
- Hash each one with bcrypt (slow!)
- 200ms per attempt = 432 attempts per day = years to crack
```

---

## 2️⃣ JWT SECRET KEY - Environment Variable (Server)

### 📍 Storage Location

**Backend Server Only:**
- Development: `.env` file (NOT committed to Git)
- Production: Environment variable on hosting platform (Railway/Vercel)

### 📄 .env File (Backend)

```bash
# File: LiteKite-Backend-master/.env
# Location: Server filesystem (NOT in database, NOT on frontend)

JWT_SECRET_KEY=8f42a73054b1749f8f58848be5e6502c42f5e3c1a78d3c8e9f10d8a4b5c6e7f8
#              ↑ 64-character random hex string (256 bits)
#              This is used to SIGN all JWT tokens

DATABASE_URL=postgresql://localhost/litekite
GEMINI_API_KEY=AIzaSy...
FRONTEND_URL=http://localhost:5173
```

### 🔧 How It's Loaded in Backend

```python
# Backend: api/index.py (Line 49)
import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Read JWT secret from environment
app.config["JWT_SECRET_KEY"] = os.getenv('JWT_SECRET')
#                                         ↑
#                              Reads: JWT_SECRET from .env file

# This secret key is used to:
# 1. Sign JWT tokens when user logs in
# 2. Verify JWT tokens on protected routes
# 3. Ensure tokens haven't been tampered with
```

### 🛡️ Security: Why Environment Variables?

**Why NOT hardcode in code:**
```python
# ❌ NEVER DO THIS
app.config["JWT_SECRET_KEY"] = "my-secret-123"  # Visible in Git commits!
```

**Why use .env:**
```python
# ✅ CORRECT
app.config["JWT_SECRET_KEY"] = os.getenv('JWT_SECRET')  # Value stays secret
```

**Protection layers:**
1. **.gitignore** prevents committing to Git:
   ```gitignore
   # .gitignore file
   .env
   .env.local
   *.env
   ```

2. **Different keys per environment:**
   ```
   Development:  JWT_SECRET=dev-secret-key-123
   Staging:      JWT_SECRET=staging-secret-key-456
   Production:   JWT_SECRET=8f42a73054b1749f8f58848be5e6502c42f5e3c1a78d3c8e9f10d8a4b5c6e7f8
   ```

3. **Generated randomly:**
   ```bash
   # Generate secure secret
   python -c "import secrets; print(secrets.token_hex(32))"
   # Output: 8f42a73054b1749f8f58848be5e6502c42f5e3c1a78d3c8e9f10d8a4b5c6e7f8
   ```

---

## 3️⃣ JWT TOKEN - Browser localStorage (Frontend)

### 📍 Storage Location

**Client-Side:** User's browser → localStorage → Key: "token"

### 🌐 Browser Storage Details

**Chrome DevTools View:**
```
Application Tab
└─ Storage
   └─ Local Storage
      └─ http://localhost:5173
         └─ token: "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcwOTEyMzQ1NiwianRpIjoiZGU0NjhiN2EtYzI5Mi00OWQ1LWJhMGYtMjZhOWQ4YzVhZmVkIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjEiLCJuYmYiOjE3MDkxMjM0NTYsImV4cCI6MTcwOTIwOTg1Nn0.xDkR6fHbP_8qs7N8XZqW5d4BJ0h0qME9K9W0FZGqLgc"
```

**Physical Location on Disk:**
```
Windows: C:\Users\<username>\AppData\Local\Google\Chrome\User Data\Default\Local Storage\leveldb\
Mac: ~/Library/Application Support/Google/Chrome/Default/Local Storage/
Linux: ~/.config/google-chrome/Default/Local Storage/
```

### 🔄 Complete JWT Token Flow

#### **STEP 1: User Logs In**

```typescript
// Frontend: src/AuthContext.tsx (Line 45-53)

const login = async (username: string, password: string) => {
  // 1. Send credentials to backend
  const response = await axios.post(`${url}/login`, {
    username: "john_doe",
    password: "mypassword123"  // Plain text over HTTPS
  });
  
  // 2. Backend verifies password & generates JWT token
  // Backend returns: { access_token: "eyJhbGc..." }
  
  const { access_token } = response.data;
  // access_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzA5MjA5ODU2fQ.signature"
  
  // 3. Store token in localStorage
  localStorage.setItem("token", `Bearer ${access_token}`);
  //                     ↑ Key    ↑ Value (JWT with Bearer prefix)
  
  // 4. Set default Authorization header for all future requests
  axios.defaults.headers.common['Authorization'] = `Bearer ${access_token}`;
  
  // 5. Update app state
  setIsAuthenticated(true);
};
```

#### **STEP 2: App Initialization (Page Refresh)**

```typescript
// Frontend: src/AuthContext.tsx (Line 28-34)

useEffect(() => {
  // On app load, check if token exists in localStorage
  const storedToken = localStorage.getItem("token");
  //                                         ↑
  //                  Retrieves: "Bearer eyJhbGc..."
  
  if (storedToken) {
    // Token exists - user is still logged in
    setToken(storedToken);
    setIsAuthenticated(true);
    
    // Restore Authorization header
    axios.defaults.headers.common['Authorization'] = storedToken;
  }
}, []); // Runs once on mount
```

#### **STEP 3: Making Authenticated Requests**

```typescript
// Frontend: Any component (e.g., src/pages/Portfolio.tsx)

const fetchPortfolio = async () => {
  // Get token from localStorage
  const token = localStorage.getItem("token");
  // token = "Bearer eyJhbGc..."
  
  // Send request with Authorization header
  const response = await axios.get(`${url}/portfolio`, {
    headers: {
      'Authorization': token
      //                ↑ JWT token sent to backend
    }
  });
  
  // Backend validates token and returns data
  setPortfolio(response.data);
};
```

#### **STEP 4: Backend Validates Token**

```python
# Backend: api/index.py (Line 230+)

@app.route("/api/portfolio")
@jwt_required()  # ⬅️ This decorator validates the JWT token
def portfolio():
    # 1. @jwt_required() extracts token from Authorization header
    #    "Bearer eyJhbGc..." → extracts → "eyJhbGc..."
    
    # 2. Validates token signature using JWT_SECRET_KEY
    #    Checks: HMAC_SHA256(header + payload, JWT_SECRET) == signature
    
    # 3. Checks expiration (exp claim)
    #    If current_time > exp → Returns 401 Unauthorized
    
    # 4. Extracts user_id from token payload
    user_id = get_jwt_identity()  # Gets "sub" claim from JWT
    #         ↑ Returns: "1" (user ID)
    
    # 5. Fetch data for this user
    user = User.query.get(user_id)
    transactions = Transaction.query.filter_by(user_id=user_id).all()
    
    # 6. Return portfolio data
    return jsonify(portfolio_data)
```

#### **STEP 5: User Logs Out**

```typescript
// Frontend: src/AuthContext.tsx (Line 72-77)

const logout = () => {
  // 1. Remove token from localStorage
  localStorage.removeItem("token");
  //                       ↑ Deletes the "token" key
  
  // 2. Clear axios default header
  delete axios.defaults.headers.common['Authorization'];
  
  // 3. Update app state
  setIsAuthenticated(false);
  setUser(null);
  
  // Token is now gone from browser
  // User must login again to get new token
};
```

### 🔍 JWT Token Structure

**What's Inside the Token:**

```
Full Token (what's stored in localStorage):
Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcwOTEyMzQ1NiwianRpIjoiZGU0NjhiN2EtYzI5Mi00OWQ1LWJhMGYtMjZhOWQ4YzVhZmVkIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjEiLCJuYmYiOjE3MDkxMjM0NTYsImV4cCI6MTcwOTIwOTg1Nn0.xDkR6fHbP_8qs7N8XZqW5d4BJ0h0qME9K9W0FZGqLgc
│      │                                               │                                                                                                                                                │
│      └─ HEADER (Base64 encoded)                     └─ PAYLOAD (Base64 encoded)                                                                                                                    └─ SIGNATURE (HMAC-SHA256)

Decoded HEADER:
{
  "alg": "HS256",  // Algorithm: HMAC-SHA256
  "typ": "JWT"     // Type: JSON Web Token
}

Decoded PAYLOAD:
{
  "fresh": false,
  "iat": 1709123456,     // Issued At: Unix timestamp
  "jti": "de468b7a...",  // JWT ID: Unique identifier
  "type": "access",      // Token type
  "sub": "1",            // Subject: User ID ⬅️ THIS IS THE USER!
  "nbf": 1709123456,     // Not Before: Unix timestamp
  "exp": 1709209856      // Expiration: Unix timestamp ⬅️ 24 hours after iat
}

SIGNATURE:
HMACSHA256(
  base64(header) + "." + base64(payload),
  JWT_SECRET_KEY  // From environment variable
)
// Ensures token hasn't been tampered with
```

### 🔐 Security Features of JWT Storage

**✅ What's Secure:**
1. **Token is signed:** Can't be modified without JWT_SECRET_KEY
2. **Expiration:** Auto-expires after 24 hours
3. **HTTPS required:** Token only sent over encrypted connection
4. **Automatic logout on 401:** Axios interceptor removes invalid tokens

**⚠️ Potential Vulnerabilities:**

| Vulnerability | Risk | Mitigation in LiteKite |
|--------------|------|------------------------|
| **XSS (Cross-Site Scripting)** | Malicious JS steals token | ✅ React auto-escapes, CSP headers |
| **Token theft** | If stolen, attacker has access | ⚠️ 24hr expiration limits damage |
| **Man-in-the-middle** | Token intercepted | ✅ HTTPS required in production |
| **No revocation** | Can't invalidate before expiration | ⚠️ Consider token blacklist (Redis) |

**Better Alternative (More Secure):**
```typescript
// Instead of localStorage, use httpOnly cookies
// Backend sets cookie, JavaScript can't access it
// Immune to XSS attacks

// Backend:
response.set_cookie(
  'token', 
  value=access_token,
  httponly=True,  // ⬅️ JavaScript can't read
  secure=True,    // HTTPS only
  samesite='Strict'
)

// Frontend: Cookie automatically sent with requests
// No localStorage.setItem() needed!
```

---

## 4️⃣ USER SESSION - Flask Session (Server-Side Cookie)

### 📍 Storage Location

**Dual Storage:**
1. **Server:** Flask session data encrypted in session cookie
2. **Browser:** Cookie sent with every request to server

### 🍪 Used For OAuth Flow

```python
# Backend: api/index.py (Line 166-176)

@app.route('/api/auth/google')
def google_auth():
    # 1. Generate random state for CSRF protection
    import secrets
    state = secrets.token_urlsafe(16)
    # state = "XPz8K3nR_Q7wLmA9"
    
    # 2. Store state in Flask session (encrypted cookie)
    session['oauth_state'] = state
    #       ↑ Key              ↑ Value
    #   Stored in cookie, encrypted with SECRET_KEY
    
    # 3. Redirect to Google with state
    redirect_uri = url_for('google_callback', _external=True)
    auth_url = google.authorize_redirect(redirect_uri, state=state)
    return jsonify({"auth_url": auth_url})
```

### 🔄 OAuth Callback Verification

```python
# Backend: api/index.py (Line 178-189)

@app.route('/api/auth/google/callback')
def google_callback():
    # 1. Retrieve stored state from session
    stored_state = session.pop('oauth_state')
    #                           ↑ Reads from encrypted cookie
    # stored_state = "XPz8K3nR_Q7wLmA9"
    
    # 2. Verify against state returned by Google
    received_state = request.args.get('state')
    
    if received_state != stored_state:
        # CSRF attack detected! States don't match
        raise ValueError("Invalid state parameter")
    
    # 3. Exchange code for token
    token = google.authorize_access_token()
    userinfo = token.get('userinfo')
    
    # 4. Create JWT token for LiteKite
    access_token = create_access_token(identity=str(user.id))
    
    # 5. Clear OAuth session data
    session.pop('oauth_state', None)
    
    return redirect(f"{frontend_url}?token={access_token}")
```

### 🔐 Session Cookie Configuration

```python
# Backend: api/index.py (Configuration)

app.config['SECRET_KEY'] = os.getenv('SECRET_KEY')  # Signs session cookies
app.config['SESSION_COOKIE_SECURE'] = True          # HTTPS only
app.config['SESSION_COOKIE_HTTPONLY'] = True        # No JavaScript access
app.config['SESSION_COOKIE_SAMESITE'] = 'None'      # Allow cross-origin (OAuth)
```

**Cookie in Browser (Chrome DevTools):**
```
Name: session
Value: eyJvYXV0aF9zdGF0ZSI6IlhQejhLM25SX1E3d0xtQTkifQ.ZiQxNw.hJ3K... (encrypted)
Domain: localhost
Path: /
Expires: Session (when browser closes)
Size: 184
HttpOnly: ✓ (JavaScript can't read)
Secure: ✓ (HTTPS only)
SameSite: None
```

---

## 5️⃣ GOOGLE OAUTH STATE - Temporary Session Storage

### 📍 Storage Location

**Server-Side Session Cookie** (Encrypted, short-lived)

### 🔄 Complete OAuth Flow with Storage

```
STEP 1: User Clicks "Login with Google"
Frontend → Backend: GET /api/auth/google

STEP 2: Backend Generates State
Backend:
  state = "XPz8K3nR_Q7wLmA9"  (random 16-byte string)
  session['oauth_state'] = state  ⬅️ STORED in encrypted session cookie
  
Backend → Browser: Set-Cookie: session=encrypted_data
Backend → Browser: Redirect to Google's OAuth URL

STEP 3: Google Authentication
Browser → Google: Show consent screen
User: Approves
Google → Browser: Redirect to /api/auth/callback?code=abc&state=XPz8K3nR_Q7wLmA9

STEP 4: Backend Verifies State
Browser → Backend: GET /api/auth/callback?code=abc&state=XPz8K3nR_Q7wLmA9
                   Cookie: session=encrypted_data
                   
Backend:
  stored_state = session.pop('oauth_state')  ⬅️ RETRIEVED from cookie
  received_state = request.args.get('state')
  
  if stored_state != received_state:
    # CSRF attack! Reject
  
  # Valid - Exchange code for user info
  # Generate JWT token
  # Clean up session
  session.pop('oauth_state', None)  ⬅️ DELETED (no longer needed)
```

### 🎯 Why Use Session for OAuth State?

**Problem Without State:**
```
Attacker:
1. Starts OAuth flow (gets authorization code)
2. Tricks victim into using attacker's code
3. Victim's account linked to attacker's credentials
```

**Solution With State:**
```
Each user gets unique random state
State stored in their session cookie
Backend verifies: state_in_cookie == state_from_google
If mismatch → CSRF attack detected → Reject
```

---

## 📊 COMPLETE DATA FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            REGISTRATION FLOW                             │
└─────────────────────────────────────────────────────────────────────────┘

Frontend                   Network                   Backend                Database
   │                          │                          │                     │
   │  {username, password}    │                          │                     │
   ├─────────POST /register───┼─────────────────────────>│                     │
   │                          │                          │                     │
   │                          │                          │ generate_password_  │
   │                          │                          │ hash(password)      │
   │                          │                          │     ↓               │
   │                          │                          │ hash = "$2b$12$..." │
   │                          │                          │                     │
   │                          │                          │  User(hash=...)     │
   │                          │                          ├────INSERT INTO────>│
   │                          │                          │     user            │
   │                          │                          │                     │
   │  {message: "Success"}    │                          │                     │
   │<────────200 OK───────────┼──────────────────────────┤                     │
   │                          │                          │                     │

┌─────────────────────────────────────────────────────────────────────────┐
│                              LOGIN FLOW                                  │
└─────────────────────────────────────────────────────────────────────────┘

Frontend                   Network                   Backend                Database
   │                          │                          │                     │
   │                          │                          │                     │
localStorage                 │                          │                     │
    │                         │                          │                     │
    │  {username, password}   │                          │                     │
    ├────────POST /login──────┼─────────────────────────>│                     │
    │                         │                          │                     │
    │                         │                          │  User.query.filter_ │
    │                         │                          │  by(username=...)   │
    │                         │                          │<────SELECT FROM─────┤
    │                         │                          │     user            │
    │                         │                          │                     │
    │                         │                          │ check_password_hash │
    │                         │                          │ (user.hash, pass)   │
    │                         │                          │     ↓               │
    │                         │                          │  ✓ Valid            │
    │                         │                          │                     │
    │                         │                          │ JWT_SECRET_KEY      │
    │                         │                          │<────from .env file  │
    │                         │                          │                     │
    │                         │                          │ create_access_token │
    │                         │                          │ (identity=user.id)  │
    │                         │                          │     ↓               │
    │                         │                          │ token = "eyJhbG..." │
    │                         │                          │                     │
    │  {access_token: "eyJ"}  │                          │                     │
    │<────────200 OK──────────┼──────────────────────────┤                     │
    │                         │                          │                     │
    │ setItem("token",        │                          │                     │
    │         "Bearer eyJ")   │                          │                     │
    └─>localStorage           │                          │                     │
                              │                          │                     │

┌─────────────────────────────────────────────────────────────────────────┐
│                      AUTHENTICATED REQUEST FLOW                          │
└─────────────────────────────────────────────────────────────────────────┘

Frontend                   Network                   Backend                Database
   │                          │                          │                     │
   │ token = getItem("token") │                          │                     │
   │<──localStorage           │                          │                     │
   │                          │                          │                     │
   │  GET /portfolio          │                          │                     │
   │  Authorization: Bearer..│                          │                     │
   ├─────────────────────────┼─────────────────────────>│                     │
   │                          │                          │                     │
   │                          │                          │ @jwt_required()     │
   │                          │                          │ validates token     │
   │                          │                          │                     │
   │                          │                          │ JWT_SECRET_KEY      │
   │                          │                          │<────from .env       │
   │                          │                          │                     │
   │                          │                          │ Verify signature:   │
   │                          │                          │ HMAC(header+payload,│
   │                          │                          │      secret) == sig?│
   │                          │                          │     ↓               │
   │                          │                          │  ✓ Valid            │
   │                          │                          │                     │
   │                          │                          │ Check expiration:   │
   │                          │                          │ now < exp?          │
   │                          │                          │     ↓               │
   │                          │                          │  ✓ Not expired      │
   │                          │                          │                     │
   │                          │                          │ user_id = get_jwt_  │
   │                          │                          │ identity()          │
   │                          │                          │     ↓               │
   │                          │                          │ user_id = "1"       │
   │                          │                          │                     │
   │                          │                          │ Transaction.query.  │
   │                          │                          │ filter_by(user_id=1)│
   │                          │                          │<────SELECT FROM─────┤
   │                          │                          │     transactions    │
   │                          │                          │                     │
   │  {portfolio: [...]}      │                          │                     │
   │<────────200 OK──────────┼──────────────────────────┤                     │
   │                          │                          │                     │
```

---

## 🔒 SECURITY SUMMARY

### ✅ What's Secure in Your Implementation

1. **Passwords:**
   - ✅ Never stored in plain text
   - ✅ Bcrypt with salt (12 rounds)
   - ✅ Database leak won't expose passwords

2. **JWT Secret:**
   - ✅ Stored in environment variables
   - ✅ Never committed to Git
   - ✅ Different per environment

3. **JWT Tokens:**
   - ✅ Signed with secret (tamper-proof)
   - ✅ 24-hour expiration
   - ✅ Automatic logout on expiration

4. **Sessions:**
   - ✅ Encrypted with SECRET_KEY
   - ✅ HttpOnly (XSS protection)
   - ✅ Secure flag (HTTPS only)

### ⚠️ Potential Improvements

1. **JWT in localStorage:**
   - ⚠️ Vulnerable to XSS
   - ✅ Better: httpOnly cookies

2. **No refresh tokens:**
   - ⚠️ User logged out after 24 hours
   - ✅ Better: Add refresh token flow

3. **No token revocation:**
   - ⚠️ Can't invalidate token before expiration
   - ✅ Better: Token blacklist (Redis)

4. **No rate limiting:**
   - ⚠️ Brute force attacks possible
   - ✅ Better: Flask-Limiter

---

## 📚 INTERVIEW TALKING POINTS

### "Where do you store passwords?"

**Perfect Answer:**
"I never store plain text passwords. During registration, I use Werkzeug's `generate_password_hash()` which implements bcrypt with automatic salting. The hash is stored in PostgreSQL's `user.hash` column. On login, `check_password_hash()` verifies the input against the stored hash. Even if the database is compromised, passwords remain secure because bcrypt is computationally expensive to reverse and each password has a unique salt."

### "Where do you store JWT tokens?"

**Perfect Answer:**
"JWT tokens are stored in the browser's localStorage under the key 'token'. After login, the backend generates a signed token that includes the user ID and expiration. The frontend stores it and includes it in the Authorization header of all authenticated requests. The backend validates the token's signature using the JWT_SECRET_KEY from environment variables. For production, I'd consider moving to httpOnly cookies to prevent XSS attacks."

### "How do you protect your secret keys?"

**Perfect Answer:**
"All secrets like JWT_SECRET_KEY, database credentials, and API keys are stored in environment variables via a .env file. I use python-dotenv to load them at runtime. The .env file is in .gitignore so it's never committed to Git. I use different secrets for development, staging, and production environments. For deployment, I set environment variables directly on the hosting platform (Railway, Vercel)."

### "Walk me through the login flow"

**Perfect Answer:**
"When a user logs in, the frontend sends username and password to `/api/login`. The backend queries the database for the user, then uses `check_password_hash()` to verify the password against the stored bcrypt hash. If valid, Flask-JWT-Extended generates a signed JWT token containing the user ID with a 24-hour expiration. This token is returned to the frontend, which stores it in localStorage and includes it in the Authorization header for all subsequent requests. Protected routes use the `@jwt_required()` decorator to validate the token."

---

## 🎯 QUICK REFERENCE

**Password:** PostgreSQL → `user.hash` → Bcrypt hash (never plain text)
**JWT Secret:** `.env` file → `JWT_SECRET_KEY` → Used to sign tokens
**JWT Token:** Browser → `localStorage.token` → Sent in Authorization header
**Session:** Browser → Encrypted cookie → OAuth state (temporary)

**Validation Flow:**
```
User inputs password
    ↓
Frontend → Backend (HTTPS)
    ↓
Backend: check_password_hash(stored_hash, input_password)
    ↓
Valid? → Create JWT token (signed with JWT_SECRET_KEY)
    ↓
Frontend: localStorage.setItem("token", jwt)
    ↓
Future requests: Authorization: Bearer <jwt>
    ↓
Backend: @jwt_required() validates signature & expiration
```

---

**🔐 Security is not a feature, it's a foundation!**
