# Technology Stack Interview Q&A - Topic by Topic

## 📚 Complete Coverage of Your Tech Stack

This document organizes interview questions and answers by specific technologies in your LiteKite project. Master each topic individually for comprehensive preparation.

---

# 🎨 FRONTEND TECHNOLOGIES

## 1. HTML & CSS Fundamentals

### Q1: What is semantic HTML and why did you use it?
**Answer:**
Semantic HTML uses meaningful tags that describe their content (like `<header>`, `<nav>`, `<main>`, `<article>`, `<section>`) instead of generic `<div>` tags.

**Why I used it:**
- **Accessibility:** Screen readers understand page structure better
- **SEO:** Search engines can better index content
- **Maintainability:** Code is more readable and self-documenting
- **Best practices:** Modern web development standard

**Example from my project:**
```html
<nav>
  <header>LiteKite Navigation</header>
  <main>
    <section className="portfolio">
      <article className="stock-card">...</article>
    </section>
  </main>
</nav>
```

### Q2: Explain the box model.
**Answer:**
The CSS box model describes how elements are sized and spaced:

```
┌─────────────────────────────┐
│         Margin              │
│  ┌──────────────────────┐   │
│  │      Border          │   │
│  │  ┌────────────────┐  │   │
│  │  │   Padding      │  │   │
│  │  │  ┌──────────┐  │  │   │
│  │  │  │ Content  │  │  │   │
│  │  │  └──────────┘  │  │   │
│  │  └────────────────┘  │   │
│  └──────────────────────┘   │
└─────────────────────────────┘
```

- **Content:** The actual content (text, images)
- **Padding:** Space inside the border, around content
- **Border:** Line around the padding
- **Margin:** Space outside the border

**Total width = content + padding + border + margin**

### Q3: What's the difference between inline, block, and inline-block?
**Answer:**

| Property | Width/Height | Line Break | Examples |
|----------|--------------|------------|----------|
| **inline** | No | No | `<span>`, `<a>`, `<strong>` |
| **block** | Yes | Yes (new line) | `<div>`, `<p>`, `<h1>` |
| **inline-block** | Yes | No | Custom elements |

**Example:**
```css
/* My button styling */
.button {
  display: inline-block; /* Allows width/height but stays inline */
  padding: 10px 20px;
  margin: 5px;
}
```

### Q4: Explain CSS specificity.
**Answer:**
Specificity determines which CSS rule applies when multiple rules target the same element.

**Hierarchy (highest to lowest):**
1. **Inline styles:** `style="color: red"` (1000 points)
2. **IDs:** `#header` (100 points)
3. **Classes, attributes, pseudo-classes:** `.button`, `[type="text"]`, `:hover` (10 points)
4. **Elements, pseudo-elements:** `div`, `::before` (1 point)

**Example:**
```css
/* Specificity: 1 (element) */
button { color: blue; }

/* Specificity: 10 (class) - WINS */
.primary-button { color: red; }

/* Specificity: 100 (ID) - WINS OVER BOTH */
#buy-button { color: green; }
```

**In my project:** I use Tailwind CSS classes which have equal specificity, so order matters. I use `!important` sparingly for overrides.

### Q5: What are CSS preprocessors? Do you use any?
**Answer:**
CSS preprocessors (Sass, Less, Stylus) extend CSS with features like variables, nesting, mixins, and functions.

**I don't use preprocessors because:**
- I use **Tailwind CSS** which provides utility classes
- **CSS Variables (Custom Properties)** handle dynamic values
- Modern CSS has native features like `calc()`, `clamp()`
- Tailwind's JIT compiler is fast enough

**However, if scaling required it:**
```scss
// SCSS example
$primary-color: #3498db;

.button {
  background: $primary-color;
  &:hover {
    background: darken($primary-color, 10%);
  }
}
```

### Q6: Explain flexbox vs grid.
**Answer:**

**Flexbox (1-dimensional):**
- For **rows OR columns** (one direction)
- Content-driven layout
- Good for: Navigation bars, button groups, centering

```css
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
```

**Grid (2-dimensional):**
- For **rows AND columns** simultaneously
- Layout-driven design
- Good for: Page layouts, dashboards, galleries

```css
.portfolio-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}
```

### Q7: How do you make a website responsive?
**Answer:**

**My approach:**

1. **Mobile-first design:**
   ```css
   /* Base styles for mobile */
   .container { width: 100%; }
   
   /* Tablet */
   @media (min-width: 768px) {
     .container { width: 750px; }
   }
   
   /* Desktop */
   @media (min-width: 1024px) {
     .container { width: 1000px; }
   }
   ```

2. **Flexible units:**
   - `%`, `em`, `rem`, `vh`, `vw` instead of `px`
   - `max-width` instead of fixed `width`

3. **Responsive images:**
   ```css
   img {
     max-width: 100%;
     height: auto;
   }
   ```

4. **Tailwind responsive classes:**
   ```jsx
   <div className="w-full md:w-1/2 lg:w-1/3">
   ```

---

## 2. JavaScript Fundamentals

### Q1: Explain var, let, and const.
**Answer:**

| Keyword | Scope | Reassignable | Hoisting | Temporal Dead Zone |
|---------|-------|--------------|----------|-------------------|
| `var` | Function | ✅ Yes | Yes (undefined) | ❌ No |
| `let` | Block | ✅ Yes | No | ✅ Yes |
| `const` | Block | ❌ No | No | ✅ Yes |

**Examples:**
```javascript
// var - function scoped
function test() {
  if (true) {
    var x = 10;
  }
  console.log(x); // 10 (accessible outside block!)
}

// let - block scoped
function test2() {
  if (true) {
    let y = 10;
  }
  console.log(y); // ReferenceError: y is not defined
}

// const - cannot reassign
const user = { name: 'John' };
user.name = 'Jane'; // ✅ OK (mutating object)
user = {}; // ❌ Error (reassigning)
```

**In my project:** I use `const` by default, `let` when reassignment needed, never `var`.

### Q2: What are arrow functions and how do they differ from regular functions?
**Answer:**

**Syntax:**
```javascript
// Regular function
function add(a, b) {
  return a + b;
}

// Arrow function
const add = (a, b) => a + b;
```

**Key differences:**

1. **`this` binding:**
   ```javascript
   // Regular function - 'this' is dynamic
   const obj = {
     count: 0,
     increment: function() {
       setTimeout(function() {
         this.count++; // 'this' is window/undefined
       }, 100);
     }
   };
   
   // Arrow function - 'this' is lexical
   const obj2 = {
     count: 0,
     increment: function() {
       setTimeout(() => {
         this.count++; // 'this' is obj2 ✅
       }, 100);
     }
   };
   ```

2. **No `arguments` object:**
   ```javascript
   function regular() {
     console.log(arguments); // ✅ Works
   }
   
   const arrow = () => {
     console.log(arguments); // ❌ ReferenceError
   };
   ```

3. **Cannot be constructors:**
   ```javascript
   const Person = (name) => { this.name = name; };
   new Person('John'); // ❌ TypeError
   ```

**In my project:** I use arrow functions for callbacks, event handlers, and functional components.

### Q3: Explain promises and async/await.
**Answer:**

**Promise:**
Represents eventual completion (or failure) of an asynchronous operation.

```javascript
// Creating a promise
const fetchData = () => {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      const data = { name: 'AAPL', price: 175.50 };
      resolve(data); // Success
      // reject(new Error('Failed')); // Failure
    }, 1000);
  });
};

// Using promises
fetchData()
  .then(data => console.log(data))
  .catch(error => console.error(error))
  .finally(() => console.log('Done'));
```

**Async/Await:**
Syntactic sugar over promises, makes async code look synchronous.

```javascript
// Same function with async/await
const getData = async () => {
  try {
    const data = await fetchData();
    console.log(data);
  } catch (error) {
    console.error(error);
  } finally {
    console.log('Done');
  }
};
```

**In my project:**
```typescript
// Fetching portfolio
const fetchPortfolio = async () => {
  try {
    setLoading(true);
    const response = await axios.get(`${url}/portfolio`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    setPortfolio(response.data);
  } catch (error) {
    toast({ title: "Error", description: error.message });
  } finally {
    setLoading(false);
  }
};
```

### Q4: What is event bubbling and capturing?
**Answer:**

**Event Propagation has 3 phases:**

1. **Capturing (top-down):** Event travels from root to target
2. **Target:** Event reaches the target element
3. **Bubbling (bottom-up):** Event bubbles back up to root

```html
<div id="grandparent">
  <div id="parent">
    <button id="child">Click</button>
  </div>
</div>
```

```javascript
// Bubbling (default)
document.getElementById('child').addEventListener('click', () => {
  console.log('Child clicked');
});
document.getElementById('parent').addEventListener('click', () => {
  console.log('Parent clicked');
});

// Output when button clicked:
// Child clicked
// Parent clicked (bubbled up!)

// Capturing (set 3rd parameter to true)
document.getElementById('parent').addEventListener('click', () => {
  console.log('Parent captured');
}, true);

// Stop propagation
element.addEventListener('click', (e) => {
  e.stopPropagation(); // Prevents bubbling
});
```

### Q5: Explain closures.
**Answer:**

A closure is a function that has access to variables in its outer (enclosing) function's scope, even after the outer function has returned.

```javascript
function createCounter() {
  let count = 0; // Private variable
  
  return {
    increment: () => ++count,
    decrement: () => --count,
    get: () => count
  };
}

const counter = createCounter();
counter.increment(); // 1
counter.increment(); // 2
counter.get(); // 2
console.log(counter.count); // undefined (private!)
```

**Use cases:**
- Data privacy/encapsulation
- Factory functions
- Event handlers
- Callbacks

**In my project:**
```typescript
// Custom hook using closure
const useDebounce = (value, delay) => {
  const [debouncedValue, setDebouncedValue] = useState(value);
  
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedValue(value); // Closure over 'value'
    }, delay);
    
    return () => clearTimeout(timer); // Cleanup
  }, [value, delay]);
  
  return debouncedValue;
};
```

### Q6: What is the difference between `==` and `===`?
**Answer:**

**`==` (Loose equality):** Type coercion, then comparison
**`===` (Strict equality):** No type coercion, same type AND value

```javascript
// == (loose)
5 == '5'      // true (string converted to number)
null == undefined  // true
0 == false    // true
'' == false   // true

// === (strict)
5 === '5'     // false (different types)
null === undefined  // false
0 === false   // false
'' === false  // false

// Always use === for predictable behavior!
const price = 0;
if (price === 0) { // ✅ Correct
  console.log('Free');
}
if (price == '') { // ❌ Confusing (true!)
  console.log('This also runs!');
}
```

**In my project:** I always use `===` and `!==` for comparisons.

### Q7: Explain the spread operator and destructuring.
**Answer:**

**Spread Operator (`...`):**
Expands iterables (arrays, objects) into individual elements.

```javascript
// Arrays
const arr1 = [1, 2, 3];
const arr2 = [...arr1, 4, 5]; // [1, 2, 3, 4, 5]

// Copying array
const copy = [...arr1]; // New array

// Objects
const user = { name: 'John', age: 30 };
const updatedUser = { ...user, age: 31 }; // { name: 'John', age: 31 }

// Function arguments
const numbers = [1, 2, 3];
Math.max(...numbers); // 3
```

**Destructuring:**
Extracts values from arrays/objects into variables.

```javascript
// Array destructuring
const [first, second, ...rest] = [1, 2, 3, 4, 5];
// first = 1, second = 2, rest = [3, 4, 5]

// Object destructuring
const user = { name: 'John', age: 30, city: 'NYC' };
const { name, age } = user;
// name = 'John', age = 30

// With renaming
const { name: userName, age: userAge } = user;

// With defaults
const { country = 'USA' } = user;
```

**In my project:**
```typescript
// AuthContext
const { isAuthenticated, login, logout } = useAuth();

// API response
const { data: portfolio } = await axios.get('/portfolio');

// Props destructuring
const BuyDialog = ({ symbol, onClose, onSuccess }) => {
  // ...
};
```

---

## 3. TypeScript

### Q1: What is TypeScript and why use it?
**Answer:**

TypeScript is a **superset of JavaScript** that adds static typing.

**Benefits:**

1. **Type Safety:**
   ```typescript
   // JavaScript - no error until runtime
   function add(a, b) {
     return a + b;
   }
   add(5, '10'); // '510' (bug!)
   
   // TypeScript - error at compile time
   function add(a: number, b: number): number {
     return a + b;
   }
   add(5, '10'); // ❌ Error: string not assignable to number
   ```

2. **Better IDE support:** Autocomplete, refactoring, intellisense

3. **Documentation:** Types serve as inline documentation

4. **Catches bugs early:** Before runtime

5. **Better refactoring:** IDE knows all usages

**In my project:**
```typescript
interface Portfolio {
  ticker: string;
  shares: number;
  current_price: number;
  profit_loss: number;
}

const fetchPortfolio = async (): Promise<Portfolio[]> => {
  const response = await axios.get<Portfolio[]>('/api/portfolio');
  return response.data;
};
```

### Q2: Explain interfaces vs types in TypeScript.
**Answer:**

**Interface:**
```typescript
interface User {
  id: number;
  name: string;
  email?: string; // Optional
}

// Extending
interface Admin extends User {
  permissions: string[];
}

// Declaration merging (can reopen)
interface User {
  age: number;
}
```

**Type:**
```typescript
type User = {
  id: number;
  name: string;
  email?: string;
};

// Union types
type Status = 'success' | 'error' | 'loading';

// Intersection
type Admin = User & {
  permissions: string[];
};

// Cannot be reopened
```

**When to use:**
- **Interface:** For object shapes, React props, API contracts
- **Type:** For unions, intersections, primitives, tuples

**In my project:**
```typescript
// Interface for component props
interface BuyDialogProps {
  open: boolean;
  onClose: () => void;
  onSuccess: (data: Transaction) => void;
}

// Type for state
type LoadingState = 'idle' | 'loading' | 'success' | 'error';
```

### Q3: What are generics?
**Answer:**

Generics allow creating reusable components that work with any type.

```typescript
// Without generics - specific type
function getFirst(arr: number[]): number {
  return arr[0];
}

// With generics - any type
function getFirst<T>(arr: T[]): T {
  return arr[0];
}

const firstNumber = getFirst<number>([1, 2, 3]); // 1
const firstName = getFirst<string>(['a', 'b', 'c']); // 'a'

// Type inference (TypeScript figures it out)
const first = getFirst([1, 2, 3]); // number
```

**In my project:**
```typescript
// API response wrapper
interface ApiResponse<T> {
  data: T;
  message: string;
  status: number;
}

// Usage
const portfolioResponse: ApiResponse<Portfolio[]> = await fetchData();
const userResponse: ApiResponse<User> = await fetchUser();

// Generic hook
function useLocalStorage<T>(key: string, initialValue: T) {
  const [value, setValue] = useState<T>(() => {
    const stored = localStorage.getItem(key);
    return stored ? JSON.parse(stored) : initialValue;
  });
  
  return [value, setValue] as const;
}
```

### Q4: What is type assertion?
**Answer:**

Type assertion tells TypeScript to trust you about a variable's type.

```typescript
// Syntax 1: as
const input = document.getElementById('username') as HTMLInputElement;
input.value = 'John';

// Syntax 2: angle bracket (not in JSX)
const input2 = <HTMLInputElement>document.getElementById('username');

// Common use case: API responses
interface User {
  id: number;
  name: string;
}

const response = await fetch('/api/user');
const user = await response.json() as User;

// Non-null assertion (!)
const element = document.getElementById('app')!; // Trust me, it exists!
```

**Caution:** Type assertions don't change runtime behavior. You're telling TS "trust me", so be careful!

**In my project:**
```typescript
// Event handlers
const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
  e.preventDefault();
  const formData = new FormData(e.currentTarget);
  const symbol = formData.get('symbol') as string;
};

// Environment variables
const API_URL = import.meta.env.VITE_BACKEND_URL as string;
```

---

## 4. React Fundamentals

### Q1: What is React and why use it?
**Answer:**

React is a **JavaScript library for building user interfaces**, created by Facebook.

**Key features:**

1. **Component-based:** Reusable UI pieces
2. **Virtual DOM:** Efficient updates
3. **Declarative:** Describe UI, React handles updates
4. **Unidirectional data flow:** Predictable state management
5. **Large ecosystem:** Router, state management, UI libraries

**Why I chose React:**
- Industry standard (high demand)
- Great developer experience
- Strong community and resources
- Works well with TypeScript
- Excellent tooling (Vite, DevTools)

**Example:**
```typescript
// Component-based
const StockCard = ({ ticker, price }) => (
  <div className="card">
    <h3>{ticker}</h3>
    <p>${price}</p>
  </div>
);

// Reusable
<StockCard ticker="AAPL" price={175.50} />
<StockCard ticker="GOOGL" price={142.30} />
```

### Q2: Explain the Virtual DOM.
**Answer:**

**Virtual DOM** is a lightweight JavaScript representation of the real DOM.

**How it works:**

1. **Initial render:** React creates virtual DOM tree
2. **State change:** New virtual DOM created
3. **Diffing:** React compares old vs new virtual DOM
4. **Reconciliation:** Calculate minimal changes needed
5. **Update:** Apply only necessary changes to real DOM

```
State Change
     ↓
New Virtual DOM
     ↓
Diff with Old Virtual DOM
     ↓
Calculate Changes (Reconciliation)
     ↓
Batch Update Real DOM (efficient!)
```

**Why it's fast:**
- Real DOM manipulation is slow
- Virtual DOM operations are in-memory (fast)
- Batches multiple updates
- Only updates what changed

**Example:**
```jsx
// Only the price updates, not the entire card
const [price, setPrice] = useState(175.50);

return (
  <div className="card">
    <h3>AAPL</h3> {/* Doesn't re-render */}
    <p>${price}</p> {/* Only this updates! */}
  </div>
);
```

### Q3: What are React hooks? Explain useState and useEffect.
**Answer:**

**Hooks** allow using state and lifecycle features in functional components.

**useState:**
Adds state to functional components.

```typescript
const [count, setCount] = useState(0);
//     ^value  ^setter    ^initial value

// Update state
setCount(count + 1); // Direct value
setCount(prev => prev + 1); // Function (safer for async)

// In my project
const [portfolio, setPortfolio] = useState<Portfolio[]>([]);
const [loading, setLoading] = useState(false);
```

**useEffect:**
Handles side effects (API calls, subscriptions, timers).

```typescript
useEffect(() => {
  // Effect code (runs after render)
  fetchData();
  
  // Cleanup (optional)
  return () => {
    cleanup();
  };
}, [dependencies]); // When to re-run
```

**Dependency array:**
```typescript
// Run once on mount
useEffect(() => {
  fetchPortfolio();
}, []); // Empty array

// Run when 'symbol' changes
useEffect(() => {
  fetchStockPrice(symbol);
}, [symbol]);

// Run on every render (usually avoid!)
useEffect(() => {
  console.log('Rendered');
}); // No array
```

**In my project:**
```typescript
const Portfolio = () => {
  const [portfolio, setPortfolio] = useState([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const data = await axios.get('/api/portfolio');
        setPortfolio(data);
      } catch (error) {
        console.error(error);
      } finally {
        setLoading(false);
      }
    };
    
    fetchData();
  }, []); // Fetch once on mount
  
  return loading ? <Spinner /> : <PortfolioList data={portfolio} />;
};
```

### Q4: Explain useContext and Context API.
**Answer:**

**Context API** solves prop drilling - passing props through many levels.

**Without Context (Prop Drilling):**
```typescript
// Bad - passing through many components
<App user={user}>
  <Header user={user}>
    <Navbar user={user}>
      <UserMenu user={user} /> {/* Finally used here */}
    </Navbar>
  </Header>
</App>
```

**With Context:**
```typescript
// 1. Create context
const AuthContext = createContext<AuthContextType | undefined>(undefined);

// 2. Provider component
export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  
  const login = async (username, password) => {
    // Login logic
    setUser(userData);
    setIsAuthenticated(true);
  };
  
  const logout = () => {
    setUser(null);
    setIsAuthenticated(false);
  };
  
  return (
    <AuthContext.Provider value={{ user, isAuthenticated, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};

// 3. Custom hook for easy access
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};

// 4. Wrap app
<AuthProvider>
  <App />
</AuthProvider>

// 5. Use anywhere in tree
const Navbar = () => {
  const { user, logout } = useAuth(); // No prop drilling!
  return <button onClick={logout}>Logout {user.name}</button>;
};
```

**In my project:**
I use Context for authentication state across the entire app.

### Q5: What are controlled vs uncontrolled components?
**Answer:**

**Controlled Components:**
Form data controlled by React state (recommended).

```typescript
const [email, setEmail] = useState('');

<input
  type="email"
  value={email} // State controls value
  onChange={(e) => setEmail(e.target.value)} // Update state
/>

// State is single source of truth
console.log(email); // Always current value
```

**Uncontrolled Components:**
Form data controlled by DOM (using refs).

```typescript
const emailRef = useRef<HTMLInputElement>(null);

<input type="email" ref={emailRef} />

// Get value when needed
const handleSubmit = () => {
  console.log(emailRef.current?.value);
};
```

**Comparison:**

| Aspect | Controlled | Uncontrolled |
|--------|-----------|--------------|
| Data source | React state | DOM |
| Validation | Immediate | On submit |
| Conditional rendering | Easy | Hard |
| Default values | `value` prop | `defaultValue` prop |
| Use case | Most forms | Simple forms, file inputs |

**In my project:**
```typescript
// Controlled - BuyDialog
const [symbol, setSymbol] = useState('');
const [shares, setShares] = useState(1);

<input
  value={symbol}
  onChange={(e) => setSymbol(e.target.value.toUpperCase())}
  placeholder="Stock Symbol"
/>
```

### Q6: Explain React lifecycle methods and their hook equivalents.
**Answer:**

**Class Component Lifecycle:**
```typescript
class Portfolio extends Component {
  // Mounting
  componentDidMount() {
    this.fetchData();
  }
  
  // Updating
  componentDidUpdate(prevProps, prevState) {
    if (prevProps.userId !== this.props.userId) {
      this.fetchData();
    }
  }
  
  // Unmounting
  componentWillUnmount() {
    this.cleanup();
  }
}
```

**Functional Component with Hooks:**
```typescript
const Portfolio = ({ userId }) => {
  // componentDidMount + componentDidUpdate
  useEffect(() => {
    fetchData();
  }, [userId]); // Re-run when userId changes
  
  // componentWillUnmount
  useEffect(() => {
    return () => {
      cleanup(); // Cleanup function
    };
  }, []);
};
```

**Common patterns:**

```typescript
// Mount only
useEffect(() => {
  console.log('Component mounted');
}, []);

// Update only (skip initial render)
const isFirstRender = useRef(true);
useEffect(() => {
  if (isFirstRender.current) {
    isFirstRender.current = false;
    return;
  }
  console.log('Component updated');
}, [dependency]);

// Mount + Unmount
useEffect(() => {
  const subscription = subscribe();
  return () => subscription.unsubscribe();
}, []);
```

### Q7: What is prop drilling and how do you avoid it?
**Answer:**

**Prop Drilling:** Passing props through multiple levels to reach deeply nested components.

**Problem:**
```typescript
// Level 1
const App = () => {
  const [user, setUser] = useState(null);
  return <Dashboard user={user} setUser={setUser} />;
};

// Level 2 (doesn't use props, just passes)
const Dashboard = ({ user, setUser }) => {
  return <Sidebar user={user} setUser={setUser} />;
};

// Level 3 (doesn't use props, just passes)
const Sidebar = ({ user, setUser }) => {
  return <UserProfile user={user} setUser={setUser} />;
};

// Level 4 (finally uses it!)
const UserProfile = ({ user, setUser }) => {
  return <div>{user.name}</div>;
};
```

**Solutions:**

**1. Context API (my approach):**
```typescript
const UserContext = createContext();

const App = () => {
  const [user, setUser] = useState(null);
  return (
    <UserContext.Provider value={{ user, setUser }}>
      <Dashboard />
    </UserContext.Provider>
  );
};

const UserProfile = () => {
  const { user } = useContext(UserContext); // Direct access!
  return <div>{user.name}</div>;
};
```

**2. Component Composition:**
```typescript
const App = () => {
  const [user, setUser] = useState(null);
  return (
    <Dashboard>
      <Sidebar>
        <UserProfile user={user} setUser={setUser} />
      </Sidebar>
    </Dashboard>
  );
};

// Dashboard and Sidebar don't need user props
const Dashboard = ({ children }) => <div>{children}</div>;
```

**3. State Management (Redux, Zustand):**
For larger apps with complex state.

### Q8: What are React keys and why are they important?
**Answer:**

**Keys** help React identify which items changed, added, or removed in lists.

**Without keys (bad):**
```typescript
const stocks = ['AAPL', 'GOOGL', 'MSFT'];

// ❌ React can't track which item is which
{stocks.map(stock => (
  <StockCard stock={stock} />
))}
```

**With index as key (acceptable but not ideal):**
```typescript
// ⚠️ OK for static lists, bad for dynamic
{stocks.map((stock, index) => (
  <StockCard key={index} stock={stock} />
))}

// Problem: If list reorders, indices change
// [AAPL, GOOGL, MSFT] → remove AAPL → [GOOGL, MSFT]
// Key 0 was AAPL, now it's GOOGL (React confused!)
```

**With unique IDs (best):**
```typescript
// ✅ Best practice
const portfolio = [
  { id: 1, ticker: 'AAPL', shares: 10 },
  { id: 2, ticker: 'GOOGL', shares: 5 },
];

{portfolio.map(item => (
  <StockCard key={item.id} data={item} />
))}
```

**Rules:**
- Keys must be unique among siblings
- Keys must be stable (not random)
- Keys should be predictable

**In my project:**
```typescript
{portfolio.map(stock => (
  <div key={stock.ticker}> {/* Ticker is unique */}
    <h3>{stock.ticker}</h3>
    <p>{stock.shares} shares</p>
  </div>
))}
```

---

## 5. React Router

### Q1: How does React Router work?
**Answer:**

React Router enables client-side routing - navigation without page reloads.

**Setup:**
```typescript
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';

const App = () => (
  <BrowserRouter>
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/portfolio" element={<Portfolio />} />
      <Route path="/buy" element={<Buy />} />
      <Route path="/info/:ticker" element={<StockInfo />} />
      <Route path="*" element={<NotFound />} />
    </Routes>
  </BrowserRouter>
);
```

**Navigation:**
```typescript
import { Link, useNavigate } from 'react-router-dom';

// Declarative navigation
<Link to="/portfolio">View Portfolio</Link>

// Programmatic navigation
const navigate = useNavigate();
const handleSubmit = () => {
  // After successful action
  navigate('/portfolio');
};
```

**URL Parameters:**
```typescript
// Route definition
<Route path="/info/:ticker" element={<StockInfo />} />

// Access params
import { useParams } from 'react-router-dom';

const StockInfo = () => {
  const { ticker } = useParams(); // { ticker: 'AAPL' }
  return <div>Info for {ticker}</div>;
};
```

**In my project:**
```typescript
<Routes>
  <Route path="/" element={<LandingPage />} />
  <Route path="/login" element={<Login />} />
  <Route path="/portfolio" element={
    <ProtectedRoute><Portfolio /></ProtectedRoute>
  } />
  <Route path="/info/:stock" element={<Info />} />
</Routes>
```

### Q2: How do you implement protected routes?
**Answer:**

Protected routes require authentication to access.

**Implementation:**
```typescript
// ProtectedRoute component
const ProtectedRoute = ({ children }: { children: React.ReactNode }) => {
  const { isAuthenticated } = useAuth();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return children;
};

// Usage
<Route path="/portfolio" element={
  <ProtectedRoute>
    <Portfolio />
  </ProtectedRoute>
} />

// Or redirect with state (return to original page after login)
const ProtectedRoute = ({ children }) => {
  const { isAuthenticated } = useAuth();
  const location = useLocation();
  
  if (!isAuthenticated) {
    return <Navigate to="/login" state={{ from: location }} replace />;
  }
  
  return children;
};

// In Login component
const Login = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const from = location.state?.from?.pathname || '/portfolio';
  
  const handleLogin = async () => {
    await login();
    navigate(from, { replace: true }); // Return to intended page
  };
};
```

**In my project:**
All trading and portfolio routes are protected.

---

## 6. Tailwind CSS

### Q1: What is Tailwind CSS and why use it?
**Answer:**

Tailwind is a **utility-first CSS framework** providing low-level utility classes.

**Traditional CSS:**
```css
.button {
  background-color: #3490dc;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
  font-weight: bold;
}
```

**Tailwind:**
```html
<button class="bg-blue-500 text-white px-4 py-2 rounded font-bold">
  Click me
</button>
```

**Benefits:**

1. **No context switching:** HTML and styles in one place
2. **No naming hassle:** No `.btn`, `.btn-primary`, `.btn-large`
3. **Responsive built-in:** `md:`, `lg:` prefixes
4. **Consistent design system:** Pre-defined spacing, colors
5. **Small bundle size:** Only used classes included (PurgeCSS)
6. **Fast development:** No CSS file switching

**Responsive:**
```html
<!-- Mobile: full width, Desktop: half width -->
<div class="w-full md:w-1/2 lg:w-1/3">
```

**States:**
```html
<!-- Hover, focus, active -->
<button class="bg-blue-500 hover:bg-blue-700 focus:ring-2 active:bg-blue-900">
```

**In my project:**
```tsx
<Card className="p-6 hover:shadow-lg transition-shadow">
  <h2 className="text-2xl font-bold text-gray-800 mb-4">
    Portfolio
  </h2>
  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
    {stocks.map(...)}
  </div>
</Card>
```

### Q2: What is the difference between Tailwind and Bootstrap?
**Answer:**

| Aspect | Tailwind | Bootstrap |
|--------|----------|-----------|
| **Approach** | Utility-first | Component-based |
| **Customization** | Highly customizable | Pre-defined components |
| **File size** | Smaller (unused purged) | Larger |
| **Learning curve** | Steeper initially | Easier to start |
| **Flexibility** | Very flexible | More opinionated |
| **Design** | Build from scratch | Pre-made look |

**Bootstrap:**
```html
<button class="btn btn-primary btn-lg">Button</button>
```

**Tailwind:**
```html
<button class="bg-blue-500 text-white px-6 py-3 rounded-lg">
  Button
</button>
```

**Why I chose Tailwind:**
- More control over design
- Doesn't look "Bootstrap-y"
- Better with component libraries (Shadcn UI)
- Modern development approach

---

# 🔧 BACKEND TECHNOLOGIES

## 7. Python Fundamentals

### Q1: Explain Python data types.
**Answer:**

**Primitive types:**
```python
# Numbers
integer = 42
floating = 3.14
complex_num = 3 + 4j

# Strings
name = "LiteKite"
multiline = """Multi
line string"""

# Boolean
is_authenticated = True
```

**Collections:**
```python
# List (mutable, ordered)
stocks = ['AAPL', 'GOOGL', 'MSFT']
stocks.append('TSLA')

# Tuple (immutable, ordered)
coordinates = (10.5, 20.3)

# Set (mutable, unordered, unique)
unique_tickers = {'AAPL', 'GOOGL', 'AAPL'}  # {'AAPL', 'GOOGL'}

# Dictionary (key-value pairs)
portfolio = {
    'AAPL': 10,
    'GOOGL': 5,
    'MSFT': 8
}
```

**In my project:**
```python
# User model
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)  # int
    cash = db.Column(db.Float, default=10000.00)  # float
    username = db.Column(db.String(80))  # str
    
# Transaction list
transactions = Transaction.query.all()  # list
```

### Q2: What are list comprehensions?
**Answer:**

Concise way to create lists.

**Traditional:**
```python
# Create list of squares
squares = []
for i in range(10):
    squares.append(i ** 2)
```

**List comprehension:**
```python
squares = [i ** 2 for i in range(10)]

# With condition
even_squares = [i ** 2 for i in range(10) if i % 2 == 0]

# Nested
matrix = [[i * j for j in range(3)] for i in range(3)]
```

**Dictionary comprehension:**
```python
# Create dict from list
prices = ['AAPL:175', 'GOOGL:142']
price_dict = {p.split(':')[0]: float(p.split(':')[1]) for p in prices}
# {'AAPL': 175.0, 'GOOGL': 142.0}
```

**In my project:**
```python
# Calculate portfolio
holdings = {
    txn.ticker: sum([t.shares for t in transactions if t.ticker == txn.ticker])
    for txn in transactions
}

# Filter buy transactions
buys = [txn for txn in transactions if txn.type == 'buy']
```

### Q3: Explain *args and **kwargs.
**Answer:**

**`*args`:** Variable number of positional arguments (tuple)
**`**kwargs`:** Variable number of keyword arguments (dict)

```python
# *args
def sum_all(*args):
    return sum(args)

sum_all(1, 2, 3)  # 6
sum_all(1, 2, 3, 4, 5)  # 15

# **kwargs
def create_user(**kwargs):
    return {
        'username': kwargs.get('username'),
        'email': kwargs.get('email'),
        'age': kwargs.get('age', 18)  # Default
    }

create_user(username='john', email='john@example.com')

# Both
def api_request(method, url, *args, **kwargs):
    print(f"{method} {url}")
    print(f"Positional: {args}")
    print(f"Keyword: {kwargs}")

api_request('GET', '/api/portfolio', 'arg1', timeout=30, headers={'Auth': 'token'})
```

**In my project:**
```python
def lookup(symbol, *args, **kwargs):
    # Flexible API call
    response = requests.get(api_url, params=kwargs)
    return response.json()
```

### Q4: What are Python decorators?
**Answer:**

Decorators modify or enhance functions/methods without changing their code.

**Basic decorator:**
```python
def uppercase_decorator(func):
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        return result.upper()
    return wrapper

@uppercase_decorator
def greet(name):
    return f"hello, {name}"

print(greet("john"))  # "HELLO, JOHN"
```

**With arguments:**
```python
def repeat(times):
    def decorator(func):
        def wrapper(*args, **kwargs):
            for _ in range(times):
                result = func(*args, **kwargs)
            return result
        return wrapper
    return decorator

@repeat(3)
def say_hello():
    print("Hello!")

say_hello()  # Prints "Hello!" 3 times
```

**In my project (Flask):**
```python
from flask_jwt_extended import jwt_required

@app.route('/api/portfolio')
@jwt_required()  # Decorator ensures user is authenticated
def portfolio():
    user_id = get_jwt_identity()
    return get_portfolio(user_id)

# Custom decorator
def requires_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        auth = request.authorization
        if not auth or not check_auth(auth.username, auth.password):
            return authenticate()
        return f(*args, **kwargs)
    return decorated

@app.route('/admin')
@requires_auth
def admin_panel():
    return render_template('admin.html')
```

### Q5: Explain Python's GIL (Global Interpreter Lock).
**Answer:**

**GIL** is a mutex that protects access to Python objects, preventing multiple threads from executing Python bytecode simultaneously.

**Impact:**
- ✅ Good for I/O-bound tasks (network, file operations)
- ❌ Bad for CPU-bound tasks (can't use multiple cores effectively)

**Solutions:**

**1. Threading (I/O-bound):**
```python
from threading import Thread

# Good for I/O (API calls)
def fetch_stock(symbol):
    data = requests.get(f'/api/{symbol}')
    return data

threads = [Thread(target=fetch_stock, args=(s,)) for s in stocks]
for t in threads:
    t.start()
```

**2. Multiprocessing (CPU-bound):**
```python
from multiprocessing import Pool

# For heavy computation
def analyze_data(data):
    # CPU intensive
    return complex_calculation(data)

with Pool(processes=4) as pool:
    results = pool.map(analyze_data, datasets)
```

**3. Async/Await (I/O-bound):**
```python
import asyncio

async def fetch_multiple_stocks(symbols):
    tasks = [fetch_stock(s) for s in symbols]
    return await asyncio.gather(*tasks)
```

**In my project:**
I use Flask (synchronous) which is fine for current scale. For heavy loads, I'd use async (FastAPI) or background workers (Celery).

---

## 8. Flask Framework

### Q1: What is Flask and why did you choose it?
**Answer:**

Flask is a **micro web framework** for Python.

**Characteristics:**
- **Micro:** Minimal core, modular extensions
- **Lightweight:** ~2000 lines of code
- **Flexible:** No forced structure
- **WSGI-based:** Standard Python web interface

**Why I chose Flask:**

1. **Perfect for APIs:** No template engine overhead
2. **Extensible:** Flask-SQLAlchemy, Flask-JWT, Flask-CORS
3. **Learning:** Understand web fundamentals
4. **Lightweight:** Don't need Django's batteries
5. **Fast development:** Quick to set up and iterate

**Alternative comparison:**
- **Django:** Too heavy for API-only, includes admin, ORM, templates
- **FastAPI:** Great, but I'm more familiar with Flask
- **Express.js:** Would require Node.js knowledge

**Basic Flask app:**
```python
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/api/hello', methods=['GET'])
def hello():
    name = request.args.get('name', 'World')
    return jsonify({'message': f'Hello, {name}!'})

if __name__ == '__main__':
    app.run(debug=True)
```

### Q2: Explain Flask routing and HTTP methods.
**Answer:**

**Routing** maps URLs to functions.

```python
# GET (retrieve data)
@app.route('/api/portfolio', methods=['GET'])
def get_portfolio():
    data = Portfolio.query.all()
    return jsonify(data)

# POST (create data)
@app.route('/api/buy', methods=['POST'])
def buy_stock():
    data = request.json
    symbol = data.get('symbol')
    shares = data.get('shares')
    # Create transaction
    return jsonify({'message': 'Success'}), 201

# PUT (update/replace data)
@app.route('/api/user/<int:id>', methods=['PUT'])
def update_user(id):
    user = User.query.get(id)
    user.email = request.json.get('email')
    db.session.commit()
    return jsonify({'message': 'Updated'})

# DELETE (remove data)
@app.route('/api/transaction/<int:id>', methods=['DELETE'])
def delete_transaction(id):
    txn = Transaction.query.get(id)
    db.session.delete(txn)
    db.session.commit()
    return jsonify({'message': 'Deleted'})

# Multiple methods
@app.route('/api/stock', methods=['GET', 'POST'])
def stock():
    if request.method == 'GET':
        return get_stocks()
    else:
        return create_stock()
```

**URL parameters:**
```python
# Path parameters
@app.route('/api/quote/<symbol>')
def quote(symbol):
    price = get_price(symbol)
    return jsonify({'symbol': symbol, 'price': price})

# Query parameters
@app.route('/api/search')
def search():
    query = request.args.get('q')
    limit = request.args.get('limit', 10, type=int)
    results = search_stocks(query, limit)
    return jsonify(results)
```

**In my project:**
```python
@app.route('/api/buy', methods=['POST'])
@jwt_required()
def buy():
    user_id = get_jwt_identity()
    symbol = request.json.get('symbol')
    shares = int(request.json.get('shares'))
    
    # Business logic
    # ...
    
    return jsonify({'message': 'Success', 'remaining_cash': user.cash})
```

### Q3: How do you handle errors in Flask?
**Answer:**

**Method 1: Try-except blocks:**
```python
@app.route('/api/buy', methods=['POST'])
def buy():
    try:
        # Business logic
        result = process_purchase()
        return jsonify(result), 200
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': 'Server error'}), 500
```

**Method 2: Error handlers:**
```python
@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    db.session.rollback()  # Rollback any failed transactions
    return jsonify({'error': 'Internal server error'}), 500

# Custom exception
class InsufficientFundsError(Exception):
    pass

@app.errorhandler(InsufficientFundsError)
def handle_insufficient_funds(error):
    return jsonify({'error': str(error)}), 400
```

**Method 3: abort():**
```python
from flask import abort

@app.route('/api/user/<int:id>')
def get_user(id):
    user = User.query.get(id)
    if not user:
        abort(404, description="User not found")
    return jsonify(user)
```

**In my project:**
```python
@app.route('/api/buy', methods=['POST'])
@jwt_required()
def buy():
    try:
        user_id = get_jwt_identity()
        user = User.query.get(user_id)
        
        symbol = request.json.get('symbol')
        if not symbol:
            return jsonify({'error': 'Symbol required'}), 400
        
        shares = int(request.json.get('shares'))
        quote = lookup(symbol)
        if not quote:
            return jsonify({'error': 'Invalid symbol'}), 400
        
        total_cost = shares * quote['price']
        if user.cash < total_cost:
            return jsonify({'error': 'Insufficient funds'}), 400
        
        # Process purchase
        # ...
        
        return jsonify({'message': 'Success'}), 200
        
    except ValueError:
        return jsonify({'error': 'Invalid shares'}), 400
    except Exception as e:
        db.session.rollback()
        return jsonify({'error': 'Server error'}), 500
```

### Q4: Explain Flask blueprints.
**Answer:**

**Blueprints** organize Flask apps into modules.

**Why use:**
- Large apps with many routes
- Separate concerns (auth, api, admin)
- Reusable components

**Example:**

```python
# auth_blueprint.py
from flask import Blueprint, request, jsonify

auth_bp = Blueprint('auth', __name__, url_prefix='/auth')

@auth_bp.route('/login', methods=['POST'])
def login():
    # Login logic
    return jsonify({'token': 'xxx'})

@auth_bp.route('/register', methods=['POST'])
def register():
    # Register logic
    return jsonify({'message': 'User created'})

# api_blueprint.py
api_bp = Blueprint('api', __name__, url_prefix='/api')

@api_bp.route('/portfolio')
@jwt_required()
def portfolio():
    return jsonify(get_portfolio())

# app.py
from flask import Flask
from auth_blueprint import auth_bp
from api_blueprint import api_bp

app = Flask(__name__)
app.register_blueprint(auth_bp)
app.register_blueprint(api_bp)

# Routes available:
# /auth/login
# /auth/register
# /api/portfolio
```

**In my project:**
I don't use blueprints (all routes in index.py) because the app is small enough. If scaling, I'd organize into:
- `auth_bp` - Login, register, OAuth
- `trading_bp` - Buy, sell, quote
- `portfolio_bp` - Portfolio, history, analysis

### Q5: How does Flask-SQLAlchemy work?
**Answer:**

**Flask-SQLAlchemy** is an ORM (Object-Relational Mapping) that maps Python classes to database tables.

**Setup:**
```python
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://user:pass@localhost/db'
db = SQLAlchemy(app)
```

**Define models:**
```python
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True)
    cash = db.Column(db.Float, default=10000.00)
    
    # Relationship
    transactions = db.relationship('Transaction', backref='user', lazy=True)

class Transaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    ticker = db.Column(db.String(10), nullable=False)
    shares = db.Column(db.Integer, nullable=False)
    price = db.Column(db.Float, nullable=False)
    type = db.Column(db.String(4), nullable=False)  # 'buy' or 'sell'
    time = db.Column(db.DateTime, default=datetime.utcnow)
```

**CRUD operations:**
```python
# Create
user = User(username='john', email='john@example.com')
db.session.add(user)
db.session.commit()

# Read
user = User.query.filter_by(username='john').first()
all_users = User.query.all()
user_by_id = User.query.get(1)

# Update
user = User.query.get(1)
user.cash = 15000.00
db.session.commit()

# Delete
user = User.query.get(1)
db.session.delete(user)
db.session.commit()

# Queries
transactions = Transaction.query.filter_by(user_id=1).all()
buy_txns = Transaction.query.filter_by(type='buy').limit(10).all()
recent = Transaction.query.order_by(Transaction.time.desc()).all()
```

**In my project:**
```python
@app.route('/api/buy', methods=['POST'])
@jwt_required()
def buy():
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    # Create transaction
    transaction = Transaction(
        user_id=user_id,
        ticker=symbol,
        shares=shares,
        price=price,
        type='buy'
    )
    
    user.cash -= total_cost
    db.session.add(transaction)
    db.session.commit()
    
    return jsonify({'message': 'Success'})
```

---

## 9. RESTful API Design

### Q1: What is REST?
**Answer:**

**REST (Representational State Transfer)** is an architectural style for designing networked applications.

**Key principles:**

1. **Stateless:** Each request contains all information needed
2. **Client-Server:** Separation of concerns
3. **Cacheable:** Responses can be cached
4. **Uniform Interface:** Standard methods (GET, POST, etc.)
5. **Layered System:** Client can't tell if connected directly to server

**REST vs SOAP:**
- REST: Lightweight, JSON, stateless
- SOAP: Heavy, XML, can be stateful

**HTTP methods:**
- **GET:** Retrieve data (idempotent, safe)
- **POST:** Create data
- **PUT:** Update/replace data (idempotent)
- **PATCH:** Partial update
- **DELETE:** Remove data (idempotent)

**In my project:**
```python
# RESTful endpoints
GET    /api/portfolio          # Get portfolio
GET    /api/quote/:symbol      # Get stock quote
POST   /api/buy                # Create transaction (buy)
POST   /api/sell               # Create transaction (sell)
GET    /api/history            # Get transaction history
DELETE /api/transaction/:id    # Delete transaction
```

### Q2: Explain HTTP status codes.
**Answer:**

**Categories:**
- **1xx:** Informational
- **2xx:** Success
- **3xx:** Redirection
- **4xx:** Client error
- **5xx:** Server error

**Common codes:**

| Code | Meaning | Use Case |
|------|---------|----------|
| **200** | OK | Successful GET, PUT |
| **201** | Created | Successful POST |
| **204** | No Content | Successful DELETE |
| **400** | Bad Request | Invalid input |
| **401** | Unauthorized | Authentication required |
| **403** | Forbidden | Authenticated but not authorized |
| **404** | Not Found | Resource doesn't exist |
| **409** | Conflict | Duplicate entry |
| **500** | Internal Server Error | Server crash |
| **503** | Service Unavailable | Server overloaded |

**In my project:**
```python
# 200 - Success
@app.route('/api/portfolio')
def portfolio():
    data = get_portfolio()
    return jsonify(data), 200

# 201 - Created
@app.route('/api/buy', methods=['POST'])
def buy():
    # Create transaction
    return jsonify({'message': 'Created'}), 201

# 400 - Bad Request
if not symbol:
    return jsonify({'error': 'Symbol required'}), 400

# 401 - Unauthorized
@jwt_required()  # Returns 401 if no valid token

# 404 - Not Found
user = User.query.get(id)
if not user:
    return jsonify({'error': 'User not found'}), 404

# 500 - Server Error
except Exception as e:
    return jsonify({'error': 'Internal error'}), 500
```

### Q3: How do you version APIs?
**Answer:**

**Method 1: URL path (most common):**
```python
@app.route('/api/v1/portfolio')
def portfolio_v1():
    return jsonify(data)

@app.route('/api/v2/portfolio')
def portfolio_v2():
    return jsonify(enhanced_data)
```

**Method 2: Query parameter:**
```python
@app.route('/api/portfolio')
def portfolio():
    version = request.args.get('version', '1')
    if version == '2':
        return jsonify(enhanced_data)
    return jsonify(data)
```

**Method 3: Header:**
```python
@app.route('/api/portfolio')
def portfolio():
    version = request.headers.get('API-Version', '1')
    if version == '2':
        return jsonify(enhanced_data)
    return jsonify(data)
```

**Best practices:**
- Don't break existing clients
- Support old versions for transition period
- Document deprecation timeline
- Use semantic versioning (major.minor.patch)

**In my project:**
Currently v1 implied (no versioning). If I add v2:
```
/api/v1/portfolio  # Old clients
/api/v2/portfolio  # New clients with additional features
```

### Q4: How do you handle authentication in REST APIs?
**Answer:**

**Methods:**

**1. Token-based (JWT - my approach):**
```python
# Login endpoint
@app.route('/api/login', methods=['POST'])
def login():
    username = request.json.get('username')
    password = request.json.get('password')
    
    user = User.query.filter_by(username=username).first()
    if user and check_password_hash(user.hash, password):
        access_token = create_access_token(identity=user.id)
        return jsonify({'access_token': access_token})
    
    return jsonify({'error': 'Invalid credentials'}), 401

# Protected endpoint
@app.route('/api/portfolio')
@jwt_required()
def portfolio():
    user_id = get_jwt_identity()  # Extract from token
    return jsonify(get_portfolio(user_id))
```

**2. Session-based:**
```python
from flask import session

@app.route('/login', methods=['POST'])
def login():
    # Validate credentials
    session['user_id'] = user.id
    return jsonify({'message': 'Logged in'})

@app.route('/portfolio')
def portfolio():
    if 'user_id' not in session:
        return jsonify({'error': 'Unauthorized'}), 401
    # ...
```

**3. OAuth 2.0 (Google login - also in my project):**
```python
@app.route('/api/auth/google')
def google_auth():
    redirect_uri = url_for('google_callback', _external=True)
    return google.authorize_redirect(redirect_uri)

@app.route('/api/auth/callback')
def google_callback():
    token = google.authorize_access_token()
    user_info = google.parse_id_token(token)
    # Create or login user
    access_token = create_access_token(identity=user.id)
    return jsonify({'access_token': access_token})
```

**4. API Keys:**
```python
@app.route('/api/data')
def get_data():
    api_key = request.headers.get('X-API-Key')
    if not validate_api_key(api_key):
        return jsonify({'error': 'Invalid API key'}), 401
    # ...
```

**Why JWT:**
- Stateless (scales horizontally)
- Self-contained (no DB lookup)
- Works across domains
- Mobile-friendly

---

## 10. Database & SQL

### Q1: What is a database index and why use it?
**Answer:**

An **index** is a data structure that improves query speed at the cost of write speed and storage.

**How it works:**
Like a book index - instead of reading every page, jump to relevant pages.

**Without index:**
```sql
SELECT * FROM transactions WHERE user_id = 123;
-- Full table scan: O(n)
-- Checks EVERY row
```

**With index:**
```sql
CREATE INDEX idx_user_id ON transactions(user_id);

SELECT * FROM transactions WHERE user_id = 123;
-- Index lookup: O(log n)
-- Jumps directly to relevant rows
```

**Types:**

**1. B-Tree Index (default):**
```sql
CREATE INDEX idx_ticker ON transactions(ticker);
-- Good for: =, <, >, BETWEEN, ORDER BY
```

**2. Unique Index:**
```sql
CREATE UNIQUE INDEX idx_email ON users(email);
-- Enforces uniqueness
```

**3. Composite Index:**
```sql
CREATE INDEX idx_user_ticker ON transactions(user_id, ticker);
-- Good for queries on both columns
SELECT * FROM transactions WHERE user_id = 1 AND ticker = 'AAPL';
```

**Trade-offs:**
- ✅ Faster reads
- ❌ Slower writes (index must be updated)
- ❌ More storage

**When to index:**
- Foreign keys
- Columns in WHERE clauses
- Columns in ORDER BY
- Columns in JOIN conditions

**In my project:**
```sql
CREATE INDEX idx_user_transactions ON transactions(user_id);
CREATE INDEX idx_ticker ON transactions(ticker);
CREATE INDEX idx_time ON transactions(time DESC);

-- Now this query is fast:
SELECT * FROM transactions 
WHERE user_id = 1 
ORDER BY time DESC 
LIMIT 50;
```

### Q2: Explain SQL JOINs.
**Answer:**

**JOINs** combine rows from multiple tables.

**Tables:**
```sql
-- users
id | username
1  | john
2  | jane

-- transactions  
id | user_id | ticker | shares
1  | 1       | AAPL   | 10
2  | 1       | GOOGL  | 5
3  | 2       | MSFT   | 8
```

**INNER JOIN (only matching rows):**
```sql
SELECT users.username, transactions.ticker, transactions.shares
FROM users
INNER JOIN transactions ON users.id = transactions.user_id;

-- Result:
username | ticker | shares
john     | AAPL   | 10
john     | GOOGL  | 5
jane     | MSFT   | 8
```

**LEFT JOIN (all from left table, matching from right):**
```sql
SELECT users.username, transactions.ticker
FROM users
LEFT JOIN transactions ON users.id = transactions.user_id;

-- Result (if user 3 exists with no transactions):
username | ticker
john     | AAPL
john     | GOOGL
jane     | MSFT
bob      | NULL    ← User with no transactions
```

**RIGHT JOIN (opposite of LEFT JOIN):**
```sql
SELECT users.username, transactions.ticker
FROM users
RIGHT JOIN transactions ON users.id = transactions.user_id;
-- All transactions, even if user deleted
```

**FULL OUTER JOIN (all from both):**
```sql
SELECT users.username, transactions.ticker
FROM users
FULL OUTER JOIN transactions ON users.id = transactions.user_id;
-- All users AND all transactions
```

**In my project:**
```python
# SQLAlchemy ORM handles joins
user = User.query.get(1)
transactions = user.transactions  # Relationship does the JOIN

# Manual join
results = db.session.query(User, Transaction)\
    .join(Transaction, User.id == Transaction.user_id)\
    .filter(User.username == 'john')\
    .all()
```

### Q3: What are database transactions and ACID properties?
**Answer:**

A **transaction** is a sequence of operations performed as a single logical unit.

**ACID properties:**

**1. Atomicity (All or nothing):**
```sql
BEGIN TRANSACTION;
UPDATE users SET cash = cash - 1000 WHERE id = 1;
INSERT INTO transactions (...) VALUES (...);
COMMIT;  -- Both succeed or both fail
```

**2. Consistency (Valid state always):**
```sql
-- Constraint: cash >= 0
UPDATE users SET cash = cash - 1000 WHERE id = 1;
-- If cash would be negative, transaction fails
```

**3. Isolation (Concurrent transactions don't interfere):**
```sql
-- User 1: Buys stock
-- User 2: Buys same stock
-- Both transactions isolated (work independently)
```

**4. Durability (Changes persist):**
```sql
COMMIT;
-- Even if server crashes, transaction is saved
```

**In my project:**
```python
@app.route('/api/buy', methods=['POST'])
def buy():
    try:
        # Transaction starts
        user.cash -= total_cost
        transaction = Transaction(...)
        db.session.add(transaction)
        
        db.session.commit()  # Atomic commit
        # Both operations succeed together
        
    except Exception as e:
        db.session.rollback()  # All or nothing
        return error
```

**Isolation levels:**
- **READ UNCOMMITTED:** Can see uncommitted changes (dirty reads)
- **READ COMMITTED:** Only see committed changes
- **REPEATABLE READ:** Same read twice = same result
- **SERIALIZABLE:** Full isolation (slowest)

### Q4: Explain normalization.
**Answer:**

**Normalization** organizes data to reduce redundancy.

**Example - Denormalized (bad):**
```sql
transactions
id | username | email           | ticker | shares | price
1  | john     | john@email.com  | AAPL   | 10     | 175.50
2  | john     | john@email.com  | GOOGL  | 5      | 142.30
-- User data repeated! What if john changes email?
```

**Normalized (good):**
```sql
users
id | username | email
1  | john     | john@email.com

transactions
id | user_id | ticker | shares | price
1  | 1       | AAPL   | 10     | 175.50
2  | 1       | GOOGL  | 5      | 142.30
-- User data stored once, referenced by ID
```

**Normal forms:**

**1NF (First Normal Form):**
- No repeating groups
- Atomic values (no arrays in cells)

**2NF:**
- 1NF + No partial dependencies
- All non-key columns depend on entire primary key

**3NF (most common):**
- 2NF + No transitive dependencies
- Non-key columns don't depend on other non-key columns

**In my project:**
```sql
-- 3NF structure
users                  -- User info
  id (PK)
  username
  email
  cash

transactions           -- Transaction records
  id (PK)
  user_id (FK → users)
  ticker
  shares
  price
  type
  time

-- Clean, no redundancy
```

**When to denormalize:**
- Read-heavy applications
- Performance critical
- Acceptable staleness

### Q5: What is SQL injection and how do you prevent it?
**Answer:**

**SQL Injection:** Malicious SQL code inserted through user input.

**Vulnerable code:**
```python
# ❌ NEVER DO THIS
username = request.form.get('username')
password = request.form.get('password')

query = f"SELECT * FROM users WHERE username='{username}' AND password='{password}'"
db.execute(query)

# Attacker inputs:
# username: admin' --
# Query becomes:
# SELECT * FROM users WHERE username='admin' --' AND password=''
# -- comments out the rest, bypasses password check!
```

**Prevention:**

**1. Parameterized queries (ORM):**
```python
# ✅ SQLAlchemy (my approach)
user = User.query.filter_by(username=username).first()
# SQLAlchemy escapes input automatically
```

**2. Prepared statements:**
```python
# ✅ Raw SQL with parameters
cursor.execute(
    "SELECT * FROM users WHERE username = %s AND password = %s",
    (username, password)  # Safely escaped
)
```

**3. Input validation:**
```python
# ✅ Validate before using
import re

def validate_username(username):
    if not re.match(r'^[a-zA-Z0-9_]+$', username):
        raise ValueError('Invalid username')
    return username
```

**4. Escape special characters:**
```python
# ✅ If you must use dynamic SQL
from pymysql import escape_string
safe_username = escape_string(username)
```

**In my project:**
```python
# Always use ORM or parameterized queries
user = User.query.filter_by(username=username).first()

# Never string concatenation
# ❌ query = f"SELECT * FROM users WHERE id={user_id}"
```

### Q6: Explain database migrations.
**Answer:**

**Migrations** version control for database schema changes.

**Why needed:**
- Track schema evolution
- Apply changes consistently across environments
- Rollback if needed
- Team collaboration

**Example - Adding a column:**

**Without migrations:**
```sql
-- Manually run on dev, staging, prod
ALTER TABLE users ADD COLUMN phone VARCHAR(20);
-- Error-prone, easy to forget
```

**With migrations (Alembic/Flask-Migrate):**

```bash
# 1. Change model
# models.py
class User(db.Model):
    phone = db.Column(db.String(20))  # New field

# 2. Generate migration
flask db migrate -m "add phone to users"

# Creates migration file:
# migrations/versions/abc123_add_phone.py
def upgrade():
    op.add_column('users', sa.Column('phone', sa.String(20)))

def downgrade():
    op.drop_column('users', 'phone')

# 3. Apply migration
flask db upgrade

# 4. Rollback if needed
flask db downgrade
```

**In my project:**
```bash
# Migration history
migrations/versions/
  bc57a1902231_init.py                    # Initial tables
  6a8e85c9a723_added_indian_stock_txn.py # Added Indian stocks table
  d0ba1b92a1f2_cash_is_non_null.py       # Made cash non-nullable

# Apply all pending
flask db upgrade

# Rollback one version
flask db downgrade -1
```

**Best practices:**
- Review auto-generated migrations
- Test on copy of production data
- Backup before production migration
- Keep migrations small and atomic
- Never edit applied migrations

---

## 11. Authentication & Security

### Q1: How do you hash passwords securely?
**Answer:**

**NEVER store plain text passwords!**

**Bad:**
```python
# ❌ NEVER
user.password = request.form.get('password')
db.session.commit()
# If database leaked, all passwords exposed!
```

**Good (Bcrypt - my approach):**
```python
from werkzeug.security import generate_password_hash, check_password_hash

# Registration
password = request.form.get('password')
hash = generate_password_hash(password)  # Bcrypt with salt
user.hash = hash
db.session.commit()

# Login
user = User.query.filter_by(username=username).first()
if user and check_password_hash(user.hash, password):
    # Password correct
    login_user(user)
```

**Why Bcrypt:**
- **Slow by design:** Prevents brute force
- **Automatic salting:** Each hash unique
- **Adaptive:** Can increase rounds as computers get faster

**Salt:**
Random data added to password before hashing.

```
Password: "mypassword"
Salt: "X8kd2mQ9"
Hash: bcrypt("mypassword" + "X8kd2mQ9")

Two users with "mypassword" have different hashes!
```

**Other options:**
- **Argon2:** Winner of password hashing competition (more secure)
- **PBKDF2:** Good, but slower than Bcrypt
- **Scrypt:** Memory-hard, resistant to hardware attacks

**In my project:**
```python
@app.route('/api/register', methods=['POST'])
def register():
    username = request.json.get('username')
    password = request.json.get('password')
    
    # Hash password (salted automatically)
    hash = generate_password_hash(password)
    
    user = User(username=username, hash=hash)
    db.session.add(user)
    db.session.commit()
    
    return jsonify({'message': 'User created'})
```

### Q2: What is JWT and how does it work?
**Answer:**

**JWT (JSON Web Token):** Compact, URL-safe token for authentication.

**Structure:**
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoxMjN9.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV
     |                                    |                  |
   Header                              Payload          Signature
```

**Header:**
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

**Payload (claims):**
```json
{
  "user_id": 123,
  "exp": 1640000000,  // Expiration
  "iat": 1639900000   // Issued at
}
```

**Signature:**
```
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret_key
)
```

**Flow:**

**1. Login:**
```python
from flask_jwt_extended import create_access_token

@app.route('/api/login', methods=['POST'])
def login():
    # Validate credentials
    access_token = create_access_token(identity=user.id)
    return jsonify({'access_token': access_token})
```

**2. Frontend stores token:**
```typescript
localStorage.setItem('token', access_token);
```

**3. Include in requests:**
```typescript
axios.get('/api/portfolio', {
  headers: { 'Authorization': `Bearer ${access_token}` }
});
```

**4. Backend validates:**
```python
from flask_jwt_extended import jwt_required, get_jwt_identity

@app.route('/api/portfolio')
@jwt_required()  # Validates signature, expiration
def portfolio():
    user_id = get_jwt_identity()  # Extract user_id from token
    return jsonify(get_portfolio(user_id))
```

**Benefits:**
- **Stateless:** No session storage needed
- **Scalable:** Works across multiple servers
- **Self-contained:** All info in token
- **Cross-domain:** Works with CORS

**Security:**
- Use HTTPS only
- Short expiration (15-60 minutes)
- Refresh token for renewal
- Store securely (not in localStorage for sensitive apps)

**In my project:**
```python
app.config["JWT_SECRET_KEY"] = os.getenv('JWT_SECRET')
jwt = JWTManager(app)

# Login returns JWT
access_token = create_access_token(identity=user.id)

# All protected routes use @jwt_required()
```

### Q3: What is CORS and why is it needed?
**Answer:**

**CORS (Cross-Origin Resource Sharing):** Security feature that controls which domains can access your API.

**Same-Origin Policy:**
Browser blocks requests to different origins (domain, protocol, or port).

```
Frontend: http://localhost:5173
Backend:  http://localhost:5000

Different ports = different origins = Blocked by default!
```

**Without CORS:**
```javascript
// Frontend tries to fetch
fetch('http://localhost:5000/api/portfolio')
// ❌ Error: CORS policy blocks request
```

**Solution - Enable CORS:**
```python
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # Allow all origins (dev only!)

# Production - specific origins
CORS(app, resources={
    r"/api/*": {
        "origins": ["https://myapp.com", "https://www.myapp.com"],
        "methods": ["GET", "POST", "PUT", "DELETE"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
})
```

**How it works:**

**1. Preflight request (OPTIONS):**
```
Browser → Server: OPTIONS /api/portfolio
Headers:
  Origin: http://localhost:5173
  Access-Control-Request-Method: POST
  Access-Control-Request-Headers: Authorization

Server → Browser:
  Access-Control-Allow-Origin: http://localhost:5173
  Access-Control-Allow-Methods: GET, POST
  Access-Control-Allow-Headers: Authorization
```

**2. Actual request:**
```
Browser → Server: POST /api/portfolio
Headers:
  Origin: http://localhost:5173
  Authorization: Bearer xxx

Server → Browser:
  Access-Control-Allow-Origin: http://localhost:5173
  (response data)
```

**In my project:**
```python
FRONTEND_URL = os.getenv('FRONTEND_URL')  # https://litekite.vercel.app

CORS(app, resources={
    r"/api/*": {
        "origins": FRONTEND_URL
    }
}, supports_credentials=True)  # Allow cookies/auth headers
```

**Simple CORS (GET, POST with simple headers):**
No preflight, just Access-Control-Allow-Origin header.

**Preflighted CORS (PUT, DELETE, custom headers):**
Browser sends OPTIONS first, then actual request.

---

## 12. Git & Version Control

### Q1: Explain the basic Git workflow.
**Answer:**

**Local workflow:**
```bash
# 1. Initialize repository
git init

# 2. Check status
git status

# 3. Stage changes
git add file.txt           # Specific file
git add .                  # All changes

# 4. Commit
git commit -m "Add user authentication"

# 5. View history
git log
git log --oneline --graph  # Pretty view
```

**Remote workflow:**
```bash
# 1. Clone repository
git clone https://github.com/username/repo.git

# 2. Create branch
git checkout -b feature/buy-stocks

# 3. Make changes, commit
git add .
git commit -m "Implement buy stock feature"

# 4. Push to remote
git push origin feature/buy-stocks

# 5. Create pull request on GitHub

# 6. After merge, update main
git checkout main
git pull origin main
```

**In my project:**
```bash
# Feature development
git checkout -b feature/indian-stocks
# ... code changes ...
git add .
git commit -m "feat: Add Indian stock trading support"
git push origin feature/indian-stocks

# After PR approved
git checkout main
git pull
git branch -d feature/indian-stocks  # Delete local branch
```

### Q2: What is the difference between git merge and git rebase?
**Answer:**

**Merge:** Combines branches with a merge commit.

```bash
git checkout main
git merge feature/login

# Creates merge commit
#     A---B---C  (main)
#          \
#           D---E  (feature/login)
#                \
#                 F  (merge commit)
```

**Rebase:** Re-applies commits on top of another branch.

```bash
git checkout feature/login
git rebase main

# Moves feature commits after main
#     A---B---C  (main)
#              \
#               D'---E'  (feature/login, rebased)
# Linear history, no merge commit
```

**When to use:**

**Merge:**
- ✅ Public branches
- ✅ Preserve exact history
- ✅ Shared feature branches

**Rebase:**
- ✅ Private branches
- ✅ Clean, linear history
- ✅ Before creating PR

**Golden rule:** Never rebase public/shared branches!

**In my project:**
```bash
# Clean up feature branch before PR
git checkout feature/ai-analysis
git rebase main  # Get latest main changes
git push --force-with-lease  # Update remote

# Merge feature to main
git checkout main
git merge feature/ai-analysis
git push
```

### Q3: How do you resolve merge conflicts?
**Answer:**

**Conflict occurs when:**
Same lines changed in both branches.

**Example:**
```bash
git merge feature/new-feature

# Output:
Auto-merging file.txt
CONFLICT (content): Merge conflict in file.txt
Automatic merge failed; fix conflicts and then commit the result.
```

**file.txt:**
```
<<<<<<< HEAD (current branch)
const price = 100;
=======
const price = 150;
>>>>>>> feature/new-feature (merging branch)
```

**Resolution:**

**1. Decide which to keep:**
```javascript
// Option 1: Keep HEAD
const price = 100;

// Option 2: Keep feature
const price = 150;

// Option 3: Keep both or write new
const defaultPrice = 100;
const salePrice = 150;
```

**2. Mark as resolved:**
```bash
git add file.txt
git commit -m "Resolve merge conflict in file.txt"
```

**VS Code conflict markers:**
- "Accept Current Change" (HEAD)
- "Accept Incoming Change" (feature)
- "Accept Both Changes"
- "Compare Changes"

**In my project:**
```bash
# Merge main into feature
git checkout feature/portfolio-redesign
git merge main

# Conflict in Portfolio.tsx
# Open in VS Code, resolve conflicts
# Accept current changes for component structure
# Accept incoming changes for API calls

git add src/pages/Portfolio.tsx
git commit -m "Merge main into feature/portfolio-redesign"
```

### Q4: What is .gitignore?
**Answer:**

**.gitignore** tells Git which files to ignore (not track).

**Common ignored files:**
- Sensitive data (API keys, passwords)
- Build artifacts
- Dependencies
- OS files
- IDE files

**Example .gitignore:**
```gitignore
# Environment variables
.env
.env.local

# Python
__pycache__/
*.pyc
*.pyo
venv/
.venv/

# Node
node_modules/
dist/
build/
*.log

# IDE
.vscode/
.idea/
*.swp

# OS
.DS_Store
Thumbs.db

# Database
*.sqlite
*.db
```

**In my project:**
```gitignore
# Backend
.env
__pycache__/
*.pyc
venv/
instance/
.pytest_cache/

# Frontend
node_modules/
dist/
.env.local
.vite/

# Sensitive
*.pem
*.key
config/secrets.json

# Don't ignore
!.gitkeep  # Force include empty folders
```

**Add existing file to gitignore:**
```bash
# File already tracked, now ignore it
git rm --cached .env  # Remove from tracking
echo ".env" >> .gitignore
git commit -m "Stop tracking .env"
```

---

## 13. Testing (Concepts)

### Q1: What are the types of testing?
**Answer:**

**1. Unit Testing:**
Test individual functions/components in isolation.

```python
# test_helpers.py
import unittest
from helpers import usd

class TestHelpers(unittest.TestCase):
    def test_usd_formatting(self):
        self.assertEqual(usd(100), "$100.00")
        self.assertEqual(usd(1234.56), "$1,234.56")
        self.assertEqual(usd(0), "$0.00")
```

**2. Integration Testing:**
Test multiple components working together.

```python
# test_api.py
def test_buy_stock():
    # Setup
    client = app.test_client()
    token = login('testuser', 'password')
    
    # Test
    response = client.post('/api/buy',
        headers={'Authorization': f'Bearer {token}'},
        json={'symbol': 'AAPL', 'shares': 10}
    )
    
    # Assert
    assert response.status_code == 200
    assert response.json['remaining_cash'] > 0
```

**3. End-to-End Testing:**
Test entire user flow (browser automation).

```javascript
// Cypress/Playwright
test('User can buy stock', async () => {
  await page.goto('http://localhost:5173/login');
  await page.fill('#username', 'testuser');
  await page.fill('#password', 'password');
  await page.click('button[type=submit]');
  
  await page.goto('/buy');
  await page.fill('#symbol', 'AAPL');
  await page.fill('#shares', '10');
  await page.click('button:has-text("Buy")');
  
  await expect(page.locator('.toast')).toContainText('Success');
});
```

**4. Performance Testing:**
Load testing, stress testing.

```python
# Locust
from locust import HttpUser, task

class StockUser(HttpUser):
    @task
    def get_portfolio(self):
        self.client.get("/api/portfolio")
    
    @task(3)  # 3x more frequent
    def get_quote(self):
        self.client.get("/api/quote/AAPL")
```

### Q2: What is TDD (Test-Driven Development)?
**Answer:**

**TDD:** Write tests before code.

**Red-Green-Refactor cycle:**

**1. Red (write failing test):**
```python
def test_calculate_portfolio_value():
    portfolio = [
        {'ticker': 'AAPL', 'shares': 10, 'price': 175.50},
        {'ticker': 'GOOGL', 'shares': 5, 'price': 142.30}
    ]
    assert calculate_portfolio_value(portfolio) == 2467.50

# Run: FAILED (function doesn't exist yet)
```

**2. Green (write minimal code to pass):**
```python
def calculate_portfolio_value(portfolio):
    total = 0
    for stock in portfolio:
        total += stock['shares'] * stock['price']
    return total

# Run: PASSED
```

**3. Refactor (improve code):**
```python
def calculate_portfolio_value(portfolio):
    return sum(stock['shares'] * stock['price'] for stock in portfolio)

# Run: PASSED (still works)
```

**Benefits:**
- Ensures code is testable
- Clarifies requirements
- Prevents regressions
- Living documentation

---

## 14. Deployment & DevOps (Concepts)

### Q1: What is CI/CD?
**Answer:**

**CI (Continuous Integration):**
Automatically test code when pushed.

**CD (Continuous Deployment/Delivery):**
Automatically deploy passing code.

**Example GitHub Actions:**
```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.9
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        pytest
    
    - name: Deploy (if main branch and tests pass)
      if: github.ref == 'refs/heads/main'
      run: |
        # Deploy to production
```

**Benefits:**
- Catch bugs early
- Automated deployments
- Consistent process
- Fast feedback

### Q2: What is Docker?
**Answer:**

**Docker:** Containerization platform - package app with dependencies.

**Dockerfile:**
```dockerfile
# Frontend
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

RUN npm run build

EXPOSE 3000
CMD ["npm", "start"]
```

```dockerfile
# Backend
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 5000
CMD ["flask", "run", "--host=0.0.0.0"]
```

**Docker Compose:**
```yaml
version: '3.8'

services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - VITE_API_URL=http://localhost:5000
  
  backend:
    build: ./backend
    ports:
      - "5000:5000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db/dbname
    depends_on:
      - db
  
  db:
    image: postgres:14
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**Run:**
```bash
docker-compose up
```

**Benefits:**
- Consistent environments (dev = staging = prod)
- Easy setup (one command)
- Isolation (no dependency conflicts)
- Scalable (multiple containers)

---

# 🎯 Final Tips

## How to Study This Document

1. **First pass:** Read each section, understand concepts
2. **Second pass:** Answer questions out loud without looking
3. **Third pass:** Write code examples from memory
4. **Practice:** Implement concepts in small projects

## Interview Preparation

**For each topic:**
- Understand the "what" (concept)
- Know the "why" (use cases)
- Explain the "how" (implementation)
- Discuss "trade-offs" (alternatives)

**Connect to your project:**
Always relate answers to your LiteKite implementation:
- "In my project, I used..."
- "I chose X over Y because..."
- "If I were to scale this, I'd..."

## Quick Reference

| Topic | Key Technologies |
|-------|------------------|
| Frontend | React, TypeScript, Tailwind CSS, React Router |
| Backend | Python, Flask, SQLAlchemy |
| Database | PostgreSQL, SQL |
| Auth | JWT, bcrypt, OAuth 2.0 |
| APIs | REST, HTTP methods, status codes |
| Tools | Git, npm, pip, Vite |
| Testing | Jest (frontend), pytest (backend) |
| Deployment | Vercel (frontend), Railway/Render (backend) |

---

**Good luck with your interview! 🚀**

Remember: Understanding beats memorization. Know WHY you made each technical decision, and you'll handle any question confidently!
