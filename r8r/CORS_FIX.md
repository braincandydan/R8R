# CORS Fix for Google Places API

## Problem
The Google Places API doesn't allow direct browser requests due to CORS (Cross-Origin Resource Sharing) restrictions. This causes the API calls to fail when running the Flutter web app.

## Solution Implemented

### 1. Backend Proxy (Vercel Serverless Function)
Created `/api/places.js` - a serverless function that acts as a proxy between your web app and Google Places API.

**How it works:**
- Web app calls `/api/places` instead of Google API directly
- Serverless function makes the actual API call server-side
- No CORS issues since server-to-server communication is allowed

### 2. Environment Variable Setup
Updated `vercel.json` to:
- Route `/api/*` requests to the serverless functions
- Set up environment variable for the API key
- Configure function memory allocation

### 3. Platform Detection
Updated `PlacesService` to:
- Use proxy for web apps (`kIsWeb = true`)
- Use direct API calls for mobile apps (`kIsWeb = false`)

## Setup Instructions

### 1. Set Environment Variable in Vercel
```bash
# In your Vercel dashboard or CLI:
vercel env add GOOGLE_PLACES_API_KEY
# Enter your Google Places API key when prompted
```

Or via Vercel Dashboard:
1. Go to your project settings
2. Navigate to "Environment Variables"
3. Add `GOOGLE_PLACES_API_KEY` with your API key value

### 2. Deploy the Changes
```bash
# From your project root:
vercel --prod
```

### 3. Test the Fix
1. Visit your deployed app
2. Allow location permissions
3. Check browser console - CORS errors should be gone
4. Real restaurants should load automatically

## How the Proxy Works

### Web App Flow:
```
Flutter Web App → /api/places → Vercel Function → Google Places API → Response
```

### Mobile App Flow:
```
Flutter Mobile → Google Places API directly → Response
```

## API Endpoints

### Nearby Search
```
GET /api/places?type=nearby&lat=49.9033&lng=-119.4911&radius=8000&keyword=chicken+wings
```

### Place Details
```
GET /api/places?type=details&placeId=ChIJ...&fields=name,address,rating
```

## Error Handling
The proxy includes:
- CORS headers for browser compatibility
- Input validation
- Error forwarding from Google API
- Proper HTTP status codes

## Testing

### Web (should work now):
- No CORS errors in browser console
- API calls go through `/api/places`
- Real restaurant data loads

### Mobile (unchanged):
- Direct API calls to Google Places
- Same functionality as before

## Fallback Behavior
If the API fails for any reason:
1. Error is logged to console
2. App falls back to mock restaurant data
3. User can toggle between real/mock data via menu

## Cost Impact
- Serverless functions: Free tier covers most usage
- Google Places API: Same cost as before
- No additional charges for the proxy

The CORS issue is now fixed! Your web app should be able to load real restaurants without browser security errors.
