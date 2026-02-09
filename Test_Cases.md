# Meal 4 U - Comprehensive Test Case Table

This document contains a full suite of test cases covering all functionalities, validations, and conditions of the "Meal 4 U" application. Use this for your QA process and Viva demonstration.

## 1. Authentication Module

| ID | Test Scenario | Pre-Conditions | Test Steps | Test Data | Expected Result | Actual Result |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-001** | Verify Login with Valid Credentials | User is on Login Screen | 1. Enter valid email.<br>2. Enter valid password.<br>3. Tap "LOGIN". | Email: `test@example.com`<br>Pass: `123456` | User is redirected to **Home Screen**. | |
| **TC-002** | Verify Login with Invalid Email Format | User is on Login Screen | 1. Enter invalid email.<br>2. Enter valid password.<br>3. Tap "LOGIN". | Email: `testexample`<br>Pass: `123456` | Error message: "Please enter a valid email". | |
| **TC-003** | Verify Login with Empty Fields | User is on Login Screen | 1. Leave fields empty.<br>2. Tap "LOGIN". | - | Error messages: "Please enter your email", "Please enter your password". | |
| **TC-004** | Verify Login with Short Password | User is on Login Screen | 1. Enter valid email.<br>2. Enter password < 6 chars.<br>3. Tap "LOGIN". | Email: `test@example.com`<br>Pass: `123` | Error message: "Password must be at least 6 characters". | |
| **TC-005** | Verify Registration with Valid Data | User is on Register Screen | 1. Enter Name, Email, Password.<br>2. Confirm Password.<br>3. Tap "REGISTER". | Name: `John`<br>Email: `new@test.com`<br>Pass: `123456` | Success message: "Account created! Please login." redirects to Login. | |
| **TC-006** | Verify Registration Password Mismatch | User is on Register Screen | 1. Enter Password.<br>2. Enter different Confirm Password.<br>3. Tap "REGISTER". | Pass: `123456`<br>Confirm: `654321` | Error message: "Passwords do not match". | |

## 2. Product Browsing & Navigation

| ID | Test Scenario | Pre-Conditions | Test Steps | Test Data | Expected Result | Actual Result |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-007** | Verify Bottom Navigation | User Logged In | 1. Tap "Cart".<br>2. Tap "Orders".<br>3. Tap "Profile".<br>4. Tap "Home". | - | Application switches tabs smoothly without crashing. | |
| **TC-008** | Verify Pull-to-Refresh | User on Home Screen | 1. Pull down the meal list.<br>2. Release. | - | Loading spinner appears, data refreshes from API. | |
| **TC-009** | Verify Navigate to Item Details | User on Home Screen | 1. Tap on any meal card. | - | Redirects to **Item Detail Screen** showing correct meal info. | |

## 3. Cart Management

| ID | Test Scenario | Pre-Conditions | Test Steps | Test Data | Expected Result | Actual Result |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-010** | Add Item to Cart | User on Item Detail | 1. Select Quantity (e.g., 2).<br>2. Tap "ADD TO CART". | Qty: 2 | Snackbar appears: "Added to cart". Cart badge updates. | |
| **TC-011** | Verify Cart Calculations | Items in Cart | 1. Go to Cart Page.<br>2. Check Subtotal and Total. | Item Price: $10<br>Delivery: $3 | Subtotal = $20 (2x$10). Total = $23. | |
| **TC-012** | Update Quantity in Cart | Items in Cart | 1. Tap "+" button on an item.<br>2. Tap "-" button. | - | Quantity increases/decreases. Subtotal updates immediately. | |
| **TC-013** | Remove Item from Cart | Items in Cart | 1. Tap "Remove" text. | - | Item removed from list. Subtotal updates. | |
| **TC-014** | Verify Offline Persistence (Mobile) | Items in Cart | 1. Force close the app.<br>2. Reopen app.<br>3. Go to Cart. | - | Items previously added are still visible (loaded from SQLite). | |
| **TC-015** | Verify Empty Cart Checkout | Cart is Empty | 1. Observe "PROCEED TO CHECKOUT" button. | - | Button is **Disabled** (Greyed out). | |

## 4. Order Processing (Checkout)

| ID | Test Scenario | Pre-Conditions | Test Steps | Test Data | Expected Result | Actual Result |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-016** | Verify GPS Location Fetch | User on Checkout | 1. Tap GPS Icon.<br>2. Allow Permission (if asked). | - | "Detected Location" field populates with Lat/Long coordinates. | |
| **TC-017** | Verify Checkout Form Validation | User on Checkout | 1. Leave Address/City/Zip empty.<br>2. Tap "PLACE ORDER". | - | Error messages appear under required fields. | |
| **TC-018** | Place Successful Order | Cart has Items | 1. Fill Address, City, Zip.<br>2. Tap "PLACE ORDER". | Addr: `123 Main`<br>City: `Colombo`<br>Zip: `1000` | Redirects to **Confirmation Screen** ("Order Confirmed"). | |
| **TC-019** | Verify Order History Update | Order Placed | 1. Go to "Orders" tab. | - | New order appears at the top of the list. | |

## 5. User Profile & Settings

| ID | Test Scenario | Pre-Conditions | Test Steps | Test Data | Expected Result | Actual Result |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-020** | Verify User Data Load | User Logged In | 1. Go to "Profile" tab. | - | Shows correct Name and Email fetched from backend. | |
| **TC-021** | Verify Manual Dark Mode | User on Profile | 1. Toggle "Dark Mode" switch ON. | - | App theme changes to Dark Mode immediately. Sensor is ignored. | |
| **TC-022** | Verify Logout | User Logged In | 1. Tap "Logout" button. | - | Redirects to **Login Screen**. Auth token cleared. | |

## 6. System & Sensors

| ID | Test Scenario | Pre-Conditions | Test Steps | Test Data | Expected Result | Actual Result |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **TC-023** | detailed Light Sensor Auto-switch | Manual Mode OFF | 1. Cover phone sensor (make it dark).<br>2. Shine light on sensor. | Lux < 10 (Dark)<br>Lux > 10 (Light) | App automatically switches theme (Dark <-> Light). | |
| **TC-024** | Verify No Internet Alert | App Running | 1. Turn off WiFi/Data. | - | Red Snackbar appears: "No Internet Connection". | |
| **TC-025** | Verify Internet Reconnect | No Internet | 1. Turn on WiFi/Data. | - | Red Snackbar disappears. | |
