# 3. Plugins (Meal 4 U)

These are the plugins/dependencies used to develop the Meal 4 U mobile application:

| Plugin | Purpose in Meal 4 U |
| :--- | :--- |
| **Provider** | Used for state management (Cart, Authentication, Theme) to efficiently share data across the app. |
| **http** | To handle REST API calls to the backend server (Login, Register, Fetching Meals, Ordering). |
| **sqflite** | To store the Cart data locally (SQLite database) so it persists even if the app is closed. |
| **path** | Helper package to correctly locate the database file path on the device. |
| **flutter_secure_storage** | To securely store sensitive data like the User's Auth Token (JWT) on the device. |
| **geolocator** | To fetch the user's current GPS location for the delivery address in the Checkout screen. |
| **permission_handler** | To request and check runtime permissions (like Location access) from the user. |
| **light_sensor** | To access the device's ambient light sensor for the "Auto Dark Mode" feature. |
| **connectivity_plus** | To monitor Internet connection status and warn the user if they go offline. |
| **image_picker** | To allow users to pick a profile picture from their gallery or camera. |
| **google_fonts** | To implement the 'Roboto' font family for a consistent and modern typography style. |
| **cupertino_icons** | Provides the standard set of iOS-style icons used by Flutter widgets. |
