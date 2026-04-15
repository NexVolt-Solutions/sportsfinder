# Login Troubleshooting Guide

## Changes Made

### 1. **Enhanced API Service** ✅
**File:** `lib/core/Network/api_service.dart`

**What was fixed:**
- ✅ Added 30-second timeout to prevent hanging requests
- ✅ Proper error handling for different HTTP status codes (400, 401, 422)
- ✅ Network error detection (no internet connection)
- ✅ Better error messages for all failure scenarios

**Key improvements:**
```dart
// Now handles:
// 400 Bad Request → "Bad request: {message}"
// 401 Unauthorized → "Unauthorized: Invalid credentials"
// 422 Validation Error → "Validation error: {message}"
// Network offline → "Network error: No internet connection"
// Timeout → "Request timeout: Server took too long"
```

---

### 2. **Fixed Login Repository Response Parsing** ✅
**File:** `lib/Data/Repositories/login_repository.dart`

**What was fixed:**
- ✅ Now handles BOTH `snake_case` AND `camelCase` response keys
- ✅ Fallback keys for different API response formats
- ✅ Better debugging to show exact response keys received

**Key improvements:**
```dart
// Handles all these response formats:
final accessTokenFromResponse = 
  response['access_token'] ??      // Snake case
  response['accessToken'] ??        // Camel case
  response['token'] ??              // Short form
  '';                               // Fallback
```

---

### 3. **Fixed Splash Screen Logic** ✅
**File:** `lib/feature/view/SplashScreen/SplashScreenViewModel/splash_screen_view_model.dart`

**What was fixed:**
- ✅ Now checks if user is already logged in (has access token)
- ✅ Routes to correct screen based on login + onboarding status
- ✅ Respects onboarding completion flag

**Routing Logic:**
```
Splash Screen (3 seconds)
    ↓
Check Access Token
    ├─ Token found & Onboarding done → Home (BottomBar)
    ├─ Token found & Onboarding pending → Skill Level
    └─ No token found → Onboarding
```

---

### 4. **Improved Login ViewModel Error Handling** ✅
**File:** `lib/feature/view/Auth/Login/login_viewmodel.dart`

**What was fixed:**
- ✅ Better error messages for users (not technical stacktraces)
- ✅ Specific handling for network, timeout, and credential errors
- ✅ Debug info to see exact token values received

**Error Messages:**
```
Network issue → "Network error: Please check your internet connection"
Wrong credentials → "Invalid email or password"
Server timeout → "Request timeout: Server is not responding"
No token received → "Login failed: No authentication token received"
```

---

## How to Test Login Flow

### **Step 1: Check Console Logs**
When you tap Login, open the Flutter console and look for:

```
========== LOGIN PROCESS STARTED ==========
Form validation passed ✓
Calling Login API...
Email: user@example.com

========== LOGIN API REQUEST ==========
Endpoint: /api/v1/auth/login

========== LOGIN API RESPONSE ==========
Raw Response: {access_token: "xyz123", ...}
Response Keys: [access_token, refresh_token, token_type, message]

Access Token: xyz123... ✓
========== LOGIN API COMPLETED ==========
```

---

### **Step 2: Debug Common Issues**

#### **Issue: "No access token received"**
```
✓ Check API response format - does it match your backend?
✓ Verify endpoint: /api/v1/auth/login
✓ Check if backend actually sends access_token in response
```

#### **Issue: "Invalid email or password"**
```
✓ Verify credentials are correct
✓ Check if backend validation is working
✓ Look at API response for validation errors
```

#### **Issue: Network/Timeout Errors**
```
✓ Check internet connection
✓ Verify baseUrl = "https://api.sportfinding.com" is correct
✓ Check if backend server is running
✓ Verify firewall/VPN isn't blocking
```

#### **Issue: Login appears to succeed but no navigation**
```
✓ Check if onboarding_completed flag is set properly
✓ Verify SkillLevelScreen and BottomBarScreen exist
✓ Check console for navigation errors
```

---

## Key Debug Console Points

Look for these log messages to understand the flow:

| Log Message | Meaning |
|---|---|
| `ACCESS TOKEN RECEIVED` | Login API worked ✓ |
| `NO ACCESS TOKEN RECEIVED` | Backend didn't return token |
| `NO INTERNET CONNECTION` | Network issue |
| `REQUEST TIMEOUT` | Server not responding |
| `INVALID CREDENTIALS` | Email/password wrong |
| `SAVING TOKENS` | Token storage working |
| `USER LOGGED IN AND ONBOARDING COMPLETED: YES` | Go to Home |
| `USER LOGGED IN BUT ONBOARDING NOT COMPLETED: NO` | Go to Skill Level |

---

## API Response Format Expected

The backend API should return (pick ONE format):

**Format 1: Snake Case** (RECOMMENDED)
```json
{
  "access_token": "eyJhbGc...",
  "refresh_token": "token123...",
  "token_type": "Bearer",
  "message": "Login successful"
}
```

**Format 2: Camel Case**
```json
{
  "accessToken": "eyJhbGc...",
  "refreshToken": "token123...",
  "tokenType": "Bearer",
  "message": "Login successful"
}
```

**Format 3: Short**
```json
{
  "token": "eyJhbGc...",
  "token_type": "Bearer"
}
```

---

## Testing Credentials

When testing login:
```
Email: test@sportfinding.com
Password: Test@123
```

Replace with actual test credentials for your backend.

---

## Next Steps If Still Not Working

1. **Inspect actual API response:**
   - Add network interceptor or use Postman to test `/api/v1/auth/login` endpoint
   - Log the raw response JSON to see exact format

2. **Check backend logs:**
   - See if login request is even reaching the backend
   - Check for validation errors

3. **Verify configurations:**
   - baseUrl in ApiService
   - Endpoint path format
   - Request/response data structure

4. **Enable Flutter DevTools:**
   - Use Network tab to see actual HTTP requests
   - Inspect response headers and body

---

## Debugging Checklist

- [ ] Can you reach the login screen?
- [ ] Do you see console logs when tapping Login?
- [ ] What is the exact error message shown?
- [ ] Check console logs for API response format
- [ ] Verify backend API is running
- [ ] Test API endpoint with Postman/curl
- [ ] Check firewall/VPN/network issues
- [ ] Verify credentials are correct
- [ ] Check database has user with those credentials

