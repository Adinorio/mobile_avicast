# Default Login Credentials

For development and testing purposes, the app includes three predefined user accounts with unique passwords.

## Predefined User Accounts

### 1. Field Researcher
**User ID:** `24-0925-001`  
**Password:** `password123`  
**Role:** Researcher + User  
**Email:** `researcher@avicast.org`

### 2. Bird Observer  
**User ID:** `24-0925-002`  
**Password:** `password456`  
**Role:** Observer + User  
**Email:** `observer@avicast.org`

### 3. Data Analyst
**User ID:** `24-0925-003`  
**Password:** `password789`  
**Role:** Analyst + User  
**Email:** `analyst@avicast.org`

## Features

- **User Isolation:** Each user has completely separate data
- **Bird Counting:** User-specific bird counts and sites
- **Notes:** User-specific notes and attachments
- **Data Persistence:** All data saved locally per user

## Usage

1. Open the app
2. Go to the login screen
3. Enter one of the User ID and Password combinations above
4. Tap "Sign In"
5. Each user will see only their own data

## Security Features

✅ **Unique Passwords:** Each user has a different password  
✅ **Data Isolation:** Users cannot access each other's data  
✅ **Authentication Required:** Must login to access any features  
✅ **Session Management:** User context maintained throughout app usage  

## Security Note

⚠️ **IMPORTANT:** These are development credentials only.  
- Remove or change these credentials before production deployment
- Implement proper authentication in production
- Use secure password hashing and token-based authentication
- Consider implementing password complexity requirements

## Custom Users

You can also create new user accounts using the sign-up feature with any User ID (except the predefined ones above). 