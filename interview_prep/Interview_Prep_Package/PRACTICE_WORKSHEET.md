# Interview Practice Worksheet

## 📝 Instructions
1. **Don't look at the prep guides while answering**
2. **Write your answers below each question**
3. **Time yourself** - aim for time limits shown
4. **Record yourself** answering out loud
5. **After answering, compare with the prep guides**
6. **Iterate** - answer again after reviewing

---

## 🟢 LEVEL 1: Warm-Up Questions (30-60 seconds each)

### Q1: Tell me about your project in 30 seconds.
**Time yourself:______**

*Your Answer:*

<br><br><br>

**Self-Grade:** ⭐ ⭐ ⭐ ⭐ ⭐

**What to improve:**

---

### Q2: What's your tech stack?
**Time yourself:______**

*Your Answer:*

<br><br><br>

**Did you mention all of these?**
- [ ] React + TypeScript
- [ ] Vite
- [ ] Tailwind CSS / Shadcn UI
- [ ] Flask
- [ ] PostgreSQL
- [ ] SQLAlchemy
- [ ] JWT
- [ ] Google Gemini AI
- [ ] yfinance

---

### Q3: Why did you choose Flask over Django or FastAPI?
**Time yourself:______**

*Your Answer:*

<br><br><br>

**Key points to cover:**
- [ ] Lightweight and flexible
- [ ] Good for API-only applications
- [ ] Rich ecosystem (extensions)
- [ ] Personal familiarity

---

### Q4: What database do you use and why PostgreSQL?
**Time yourself:______**

*Your Answer:*

<br><br><br>

**Bonus points if you mentioned:**
- [ ] ACID compliance (important for financial transactions)
- [ ] Robust and reliable
- [ ] Good SQLAlchemy support
- [ ] Open source

---

### Q5: How many tables in your database and what are they?
**Time yourself:______**

*Your Answer:*

<br><br><br>

**Correct answer checklist:**
- [ ] 3 tables total
- [ ] User
- [ ] Transaction
- [ ] IndianStockTransactions

---

## 🟡 LEVEL 2: Technical Deep Dive (1-2 minutes each)

### Q6: Explain your authentication flow from login to accessing protected routes.
**Time yourself:______**

*Draw a diagram here:*

<br><br><br><br><br>

*Explain in words:*

<br><br><br><br>

**Essential steps to include:**
- [ ] User enters credentials
- [ ] POST /api/login
- [ ] Backend validates with check_password_hash
- [ ] Generate JWT with create_access_token
- [ ] Return token to frontend
- [ ] Store in localStorage
- [ ] Send in Authorization header
- [ ] @jwt_required() validates on backend
- [ ] Extract user_id with get_jwt_identity()

---

### Q7: Walk me through what happens when a user buys a stock.
**Time yourself:______**

*Draw the flow diagram:*

<br><br><br><br><br>

*Explain step-by-step:*

<br><br><br><br><br>

**Critical components:**
- [ ] Frontend: quote API call first
- [ ] Display price to user
- [ ] POST /api/buy with symbol and shares
- [ ] Backend: validate funds (user.cash >= cost)
- [ ] Database transaction (try/except/rollback)
- [ ] Deduct cash from user
- [ ] Create transaction record
- [ ] Commit atomically
- [ ] Return new balance
- [ ] Frontend: show success, update UI

---

### Q8: How do you calculate a user's portfolio?
**Time yourself:______**

*Write the algorithm/pseudocode:*

<br><br><br><br><br>

**Algorithm steps:**
- [ ] Fetch all transactions for user
- [ ] Group by ticker symbol
- [ ] Sum buy shares, subtract sell shares
- [ ] Filter stocks with shares > 0
- [ ] Get current price for each
- [ ] Calculate current_value = shares × price
- [ ] Calculate profit/loss

---

### Q9: What security vulnerabilities exist and how do you prevent them?
**Time yourself:______**

| Vulnerability | How You Prevent It |
|--------------|-------------------|
| SQL Injection | |
| XSS | |
| CSRF | |
| Password Attacks | |
| JWT Theft | |

**Additional measures:**
<br><br><br>

---

### Q10: Explain CORS and why you need it in your application.
**Time yourself:______**

*Your Answer:*

<br><br><br><br>

**Must cover:**
- [ ] What CORS is (Cross-Origin Resource Sharing)
- [ ] Why needed (frontend and backend on different ports/domains)
- [ ] Browser security policy
- [ ] How you configured it (Flask-CORS)
- [ ] Which origins you allow

---

## 🔴 LEVEL 3: System Design & Scaling (2-3 minutes each)

### Q11: How would you scale this application to handle 100,000 concurrent users?
**Time yourself:______**

*Draw your scaling architecture:*

<br><br><br><br><br><br>

*Explain each component:*

**Application Layer:**
<br><br>

**Caching:**
<br><br>

**Database:**
<br><br>

**Frontend:**
<br><br>

**Infrastructure:**
<br><br>

**Checklist of scaling strategies:**
- [ ] Load balancing (multiple Flask instances)
- [ ] Redis caching for stock prices
- [ ] Database read replicas
- [ ] Connection pooling
- [ ] CDN for static assets
- [ ] Async processing (Celery)
- [ ] Database partitioning
- [ ] Rate limiting
- [ ] Monitoring and alerting

---

### Q12: Design a real-time price alert system.
**Time yourself:______**

*Database schema for alerts:*

<br><br><br>

*Architecture diagram:*

<br><br><br><br><br>

*Implementation approach:*

<br><br><br><br>

**Key components:**
- [ ] Price alert table schema
- [ ] Polling vs streaming approach
- [ ] Trigger detection logic
- [ ] Notification delivery method
- [ ] Scalability considerations

---

### Q13: How would you implement real-time portfolio updates?
**Time yourself:______**

*Your Answer:*

<br><br><br><br><br>

**Technologies/approaches to consider:**
- [ ] Current: Polling
- [ ] Better: WebSockets
- [ ] Alternative: Server-Sent Events (SSE)
- [ ] React Query with short staleTime
- [ ] Pros and cons of each

---

### Q14: Explain your testing strategy for this application.
**Time yourself:______**

*Your Answer:*

**Backend Testing:**
<br><br><br>

**Frontend Testing:**
<br><br><br>

**E2E Testing:**
<br><br><br>

**Performance Testing:**
<br><br><br>

---

## 🎯 LEVEL 4: Behavioral Questions (STAR Format)

### Q15: Tell me about a challenging bug you encountered.
**Time yourself:______**

**Situation:**
<br><br>

**Task:**
<br><br>

**Action:**
<br><br>

**Result:**
<br><br>

---

### Q16: What are you most proud of in this project?
**Time yourself:______**

*Your Answer:*

<br><br><br><br>

**Make sure you explain:**
- [ ] What you built
- [ ] Why it was challenging
- [ ] How you solved it
- [ ] What you learned

---

### Q17: What would you do differently if you built this again?
**Time yourself:______**

*List at least 5 improvements:*

1. 
2. 
3. 
4. 
5. 

---

### Q18: How did you learn the technologies in this project?
**Time yourself:______**

*Your Answer:*

<br><br><br><br>

**Demonstrate:**
- [ ] Resourcefulness
- [ ] Documentation reading
- [ ] Problem-solving approach
- [ ] Learning agility

---

## 🔥 LEVEL 5: Curveball Questions

### Q19: What happens if the yfinance API goes down?
**Time yourself:______**

*Your Answer:*

<br><br><br><br>

**Solution components:**
- [ ] Identify the problem
- [ ] Fallback API strategy
- [ ] Caching approach
- [ ] Error handling
- [ ] User communication

---

### Q20: How do you prevent duplicate transactions from a double-click?
**Time yourself:______**

*Your Answer:*

**Frontend:**
<br><br>

**Backend:**
<br><br>

**Database:**
<br><br>

---

### Q21: Explain the difference between authentication and authorization. How do you implement both?
**Time yourself:______**

**Authentication:**
<br><br>

**Authorization:**
<br><br>

**In my project:**
<br><br><br>

---

### Q22: How would you implement a feature to let users share their portfolio publicly?
**Time yourself:______**

*Your Answer:*

<br><br><br><br><br>

**Consider:**
- [ ] Database changes
- [ ] Privacy controls
- [ ] Public URL generation
- [ ] Authentication bypass for public routes
- [ ] What data to show/hide

---

## 📊 Diagram Practice

### Draw from memory (no peeking!):

**1. System Architecture Diagram**
<br><br><br><br><br><br><br><br>

**2. Authentication Flow**
<br><br><br><br><br><br>

**3. Buy Stock Flow**
<br><br><br><br><br><br>

**4. Database Schema with Relationships**
<br><br><br><br><br><br>

---

## 🗣️ Verbal Practice Checklist

Practice saying these OUT LOUD (record yourself!):

### Round 1: Basic Explanations
- [ ] "What is LiteKite?" (30 seconds)
- [ ] "Tech stack overview" (45 seconds)
- [ ] "Why did you choose [technology X]?" (1 min)

### Round 2: Technical Flows
- [ ] "Authentication flow" (2 min)
- [ ] "Buy stock transaction" (2 min)
- [ ] "Portfolio calculation" (2 min)

### Round 3: Advanced Topics
- [ ] "How would you scale this?" (3 min)
- [ ] "Security measures" (2 min)
- [ ] "What would you improve?" (2 min)

**Recording Notes:**
- Filler words count: ______
- Pace (too fast/slow/good): ______
- Clarity (1-10): ______
- Things to improve: 

---

## 💪 Code Snippet Memory Test

### Write these code snippets from memory:

**1. JWT Protected Route Decorator**
```python




```

**2. Password Hashing on Registration**
```python




```

**3. React Protected Route Component**
```typescript




```

**4. Fetch Portfolio with Authentication**
```typescript




```

**5. Database Transaction for Buy Stock**
```python







```

---

## 🎓 Terminology Quiz

Define these in your own words:

**1. JWT:**
<br><br>

**2. ORM (Object-Relational Mapping):**
<br><br>

**3. CORS:**
<br><br>

**4. ACID (database properties):**
<br><br>

**5. REST:**
<br><br>

**6. Migration (database):**
<br><br>

**7. Virtual DOM:**
<br><br>

**8. Context API:**
<br><br>

**9. Hook (React):**
<br><br>

**10. Middleware:**
<br><br>

---

## 🧪 Scenario-Based Questions

### Scenario 1: User reports they're seeing someone else's portfolio
**How would you debug this?**

*Your Answer:*

<br><br><br><br>

---

### Scenario 2: Database query is taking 5 seconds to load portfolio
**How would you optimize it?**

*Your Answer:*

<br><br><br><br>

---

### Scenario 3: Users can buy fractional shares (0.5 shares)
**What changes are needed?**

*Your Answer:*

Database:
<br>

Backend:
<br>

Frontend:
<br>

---

### Scenario 4: You need to add a "watchlist" feature (save stocks without buying)
**Design this feature end-to-end**

*Your Answer:*

Database Schema:
<br><br>

API Endpoints:
<br><br>

Frontend Components:
<br><br>

---

## 📈 Progress Tracking

### Day 1: ___/___/___
**Questions practiced:** 
**Confidence level (1-10):** 
**Weak areas:**

---

### Day 2: ___/___/___
**Questions practiced:** 
**Confidence level (1-10):** 
**Improvements noticed:**

---

### Day 3: ___/___/___
**Questions practiced:** 
**Confidence level (1-10):** 
**Weak areas:**

---

### Day 4: ___/___/___
**Questions practiced:** 
**Confidence level (1-10):** 
**Improvements noticed:**

---

### Day 5: ___/___/___
**Questions practiced:** 
**Confidence level (1-10):** 
**Weak areas:**

---

### Day 6: ___/___/___
**Questions practiced:** 
**Confidence level (1-10):** 
**Improvements noticed:**

---

### Day 7 - Final Review: ___/___/___
**Questions practiced:** 
**Confidence level (1-10):** 
**Ready for interview:** YES / NEED MORE PRACTICE

---

## 🎯 Mock Interview Self-Assessment

### Full Mock Interview (60 minutes)

**Date:** ___/___/___

**Questions asked (list them):**
1. 
2. 
3. 
4. 
5. 

**Questions I answered well:**
<br><br>

**Questions I struggled with:**
<br><br>

**Technical gaps identified:**
<br><br>

**Non-technical areas to improve (communication, confidence, etc.):**
<br><br>

**Action items before real interview:**
1. 
2. 
3. 

---

## ✅ Final Pre-Interview Checklist

**24 Hours Before:**
- [ ] Reviewed all key concepts
- [ ] Practiced elevator pitch 10+ times
- [ ] Can draw architecture from memory
- [ ] Tested project locally (it runs!)
- [ ] Reviewed weak areas from practice
- [ ] Prepared 3-5 questions for interviewer
- [ ] Good night's sleep planned

**1 Hour Before:**
- [ ] Reviewed quick reference sheet
- [ ] Tested camera, mic, internet
- [ ] Closed distracting apps
- [ ] Water ready
- [ ] Calm and confident mindset

**During Interview:**
- [ ] Smile and make eye contact
- [ ] Think out loud
- [ ] Ask clarifying questions
- [ ] Use diagrams when helpful
- [ ] Connect answers to YOUR project
- [ ] Show enthusiasm
- [ ] It's okay to not know everything!

---

## 📝 Notes Section

**Questions I need to research more:**
<br><br><br>

**Interesting topics that came up:**
<br><br><br>

**Resources that helped me:**
<br><br><br>

**Analogies/explanations that work well:**
<br><br><br>

---

## 🎉 Post-Interview Reflection

**Date:** ___/___/___

**How did it go overall?**
<br><br>

**Questions they asked:**
<br><br><br>

**Questions I answered well:**
<br><br>

**Questions I could improve:**
<br><br>

**Unexpected topics:**
<br><br>

**What I learned:**
<br><br>

**For next time:**
<br><br>

---

**Remember:** The goal isn't to be perfect. It's to show:
1. ✅ You understand what you built
2. ✅ You can think through problems
3. ✅ You can communicate clearly
4. ✅ You're eager to learn and grow

**You've got this! 🚀**
