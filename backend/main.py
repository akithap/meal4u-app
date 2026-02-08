from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, Float, ForeignKey, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
import bcrypt
from datetime import datetime, timedelta
from typing import Optional, List
from jose import jwt, JWTError

# --- Configuration ---
SECRET_KEY = "your_secret_key_here"  # In production, use environment variable
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30
SQLALCHEMY_DATABASE_URL = "sqlite:///./sql_app.db"

# --- Database Setup ---
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# --- Models (Database) ---
class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    full_name = Column(String)

class Meal(Base):
    __tablename__ = "meals"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    category = Column(String)
    price = Column(Float)
    image_url = Column(String)
    description = Column(String)

class Order(Base):
    __tablename__ = "orders"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    total_amount = Column(Float)
    status = Column(String, default="Pending")
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    user = relationship("User")
    items = relationship("OrderItem", back_populates="order")

class OrderItem(Base):
    __tablename__ = "order_items"
    id = Column(Integer, primary_key=True, index=True)
    order_id = Column(Integer, ForeignKey("orders.id"))
    meal_id = Column(Integer, ForeignKey("meals.id"))
    quantity = Column(Integer)
    price_at_time = Column(Float) # Store price in case it changes later
    
    order = relationship("Order", back_populates="items")
    meal = relationship("Meal")

Base.metadata.create_all(bind=engine)

# --- Schemas (Pydantic) ---
class UserCreate(BaseModel):
    email: str
    password: str
    full_name: str

class UserResponse(BaseModel):
    email: str
    full_name: str
    
    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class MealResponse(BaseModel):
    id: int
    title: str
    category: str
    price: float
    image_url: str
    description: str

    class Config:
        from_attributes = True

class OrderItemSchema(BaseModel):
    meal_id: int
    quantity: int

class OrderCreate(BaseModel):
    items: List[OrderItemSchema]
    total_amount: float

class OrderItemResponse(BaseModel):
    meal_id: int
    quantity: int
    price_at_time: float
    meal_title: str # Helper field

class OrderResponse(BaseModel):
    id: int
    total_amount: float
    status: str
    created_at: datetime
    items: List[OrderItemResponse] = []

    class Config:
        from_attributes = True

# --- Security ---
# pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

def verify_password(plain_password, hashed_password):
    # Check password directly with bcrypt
    # Ensure bytes for bcrypt
    try:
        return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
    except ValueError:
        return False

def get_password_hash(password):
    # bcrypt limits to 72 bytes.
    pwd_bytes = password.encode('utf-8')
    if len(pwd_bytes) > 72:
        pwd_bytes = pwd_bytes[:72]
    
    hashed = bcrypt.hashpw(pwd_bytes, bcrypt.gensalt())
    return hashed.decode('utf-8')

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

# --- Dependencies ---
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- App ---
app = FastAPI()

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods
    allow_headers=["*"],  # Allows all headers
)

# --- Endpoints ---

@app.post("/register", response_model=UserResponse)
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    hashed_password = get_password_hash(user.password)
    new_user = User(email=user.email, hashed_password=hashed_password, full_name=user.full_name)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@app.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    # Note: OAuth2PasswordRequestForm expects 'username', so we map email to username
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/users/me", response_model=UserResponse)
async def read_users_me(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    user = db.query(User).filter(User.email == email).first()
    if user is None:
        raise credentials_exception
    return user

async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    return await read_users_me(token, db)

@app.get("/meals", response_model=List[MealResponse])
def get_meals(db: Session = Depends(get_db)):
    meals = db.query(Meal).all()
    # Seed data if empty (for demo purposes)
    if not meals:
        seed_meals = [
           Meal(title='Chickpea Soup', category='Vegan', price=6.00, image_url='https://images.unsplash.com/photo-1547592166-23acbe3b624b?auto=format&fit=crop&w=500&q=60', description='A hearty, nutritious vegan chickpea soup.'),
           Meal(title='Tomato Pizza', category='Cheap Eat', price=4.50, image_url='https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=500&q=60', description='Traditional Italian pizza with fresh tomatoes and basil.'),
           Meal(title='Pasta Carbonara', category='Italian', price=8.75, image_url='https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?auto=format&fit=crop&w=500&q=60', description='Classic creamy carbonara with guanciale and cheese.'),
           Meal(title='Sushi Set', category='Japanese', price=15.00, image_url='https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=500&q=60', description='Chef\'s selection of fresh sushi and sashimi.'),

        ]
        db.add_all(seed_meals)
        db.commit()
        meals = db.query(Meal).all()
        
    return meals

@app.post("/orders", response_model=OrderResponse)
def create_order(order: OrderCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # 1. Create the Order
    new_order = Order(
        user_id=current_user.id,
        total_amount=order.total_amount,
        status="Confirmed"
    )
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    
    # 2. Create Order Items
    for item in order.items:
        # Fetch meal to get current price (and verify it exists)
        meal = db.query(Meal).filter(Meal.id == item.meal_id).first()
        if not meal:
            continue # Skip invalid meals? Or raise error. usage: skip for now.
            
        order_item = OrderItem(
            order_id=new_order.id,
            meal_id=item.meal_id,
            quantity=item.quantity,
            price_at_time=meal.price
        )
        db.add(order_item)
    
    db.commit()
    
    # 3. Construct Response (Helper to populate meal titles manually if needed, or rely on lazy loading)
    # We need to return the items with titles.
    # Re-query properly to ensure relationships are loaded? Or just build manually.
    # Let's simple return the order items
    
    response_items = []
    for db_item in new_order.items:
        response_items.append(OrderItemResponse(
            meal_id=db_item.meal_id,
            quantity=db_item.quantity,
            price_at_time=db_item.price_at_time,
            meal_title=db_item.meal.title if db_item.meal else "Unknown"
        ))
        
    return OrderResponse(
        id=new_order.id,
        total_amount=new_order.total_amount,
        status=new_order.status,
        created_at=new_order.created_at,
        items=response_items
    )

@app.get("/orders", response_model=List[OrderResponse])
def get_orders(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # 1. Fetch orders for current user
    orders = db.query(Order).filter(Order.user_id == current_user.id).all()
    
    # 2. Construct response
    response_orders = []
    for order in orders:
        response_items = []
        for db_item in order.items:
            response_items.append(OrderItemResponse(
                meal_id=db_item.meal_id,
                quantity=db_item.quantity,
                price_at_time=db_item.price_at_time,
                meal_title=db_item.meal.title if db_item.meal else "Unknown"
            ))
            
        response_orders.append(OrderResponse(
            id=order.id,
            total_amount=order.total_amount,
            status=order.status,
            created_at=order.created_at,
            items=response_items
        ))
        
    return response_orders
