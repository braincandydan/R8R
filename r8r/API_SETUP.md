# Google Places API Setup Guide

## 1. Get Google Places API Key

### Step 1: Go to Google Cloud Console
1. Visit [Google Cloud Console](https://console.cloud.google.com/)
2. Sign in with your Google account
3. Create a new project or select an existing one

### Step 2: Enable Places API
1. In the left sidebar, go to **APIs & Services** > **Library**
2. Search for "Places API"
3. Click on **Places API** and click **Enable**

### Step 3: Create API Key
1. Go to **APIs & Services** > **Credentials**
2. Click **+ CREATE CREDENTIALS** > **API Key**
3. Copy the generated API key

### Step 4: Restrict API Key (Recommended)
1. Click on your API key to edit it
2. Under **API restrictions**, select **Restrict key**
3. Choose **Places API** from the list
4. Under **Application restrictions**, you can:
   - Select **HTTP referrer** for web apps
   - Select **Android apps** and add your package name
   - Select **iOS apps** and add your bundle identifier

## 2. Configure Your App

### Update the API Key in PlacesService
1. Open `lib/services/places_service.dart`
2. Replace `YOUR_GOOGLE_PLACES_API_KEY` with your actual API key:

```dart
static const String _apiKey = 'AIzaSyC_your_actual_api_key_here';
```

### For Production Apps
Consider using environment variables or secure storage:

```dart
// Using flutter_dotenv (add to pubspec.yaml: flutter_dotenv: ^5.0.2)
import 'package:flutter_dotenv/flutter_dotenv.dart';

static String get _apiKey => dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
```

Then create a `.env` file in your project root:
```
GOOGLE_PLACES_API_KEY=AIzaSyC_your_actual_api_key_here
```

## 3. API Pricing

### Free Tier
- $200 free credit per month
- Places Nearby Search: $32 per 1000 requests
- Place Details: $17 per 1000 requests

### Typical Usage for Wing Restaurant App
- **Places Nearby Search**: 1 request per location search
- **Place Details**: 1 request per restaurant found (up to 20)
- **Monthly estimate**: ~$1-5 for moderate usage

### Cost Optimization Tips
1. Cache results locally
2. Limit search radius
3. Reduce number of place details requests
4. Use session tokens for autocomplete

## 4. Testing the Integration

### Run the App
1. Install dependencies: `flutter pub get`
2. Run the app: `flutter run`
3. Allow location permissions when prompted
4. The app will automatically search for real wing restaurants near you

### Debugging
- Check the debug console for API responses
- Use the menu button to toggle between real and mock data
- Use the refresh button to reload restaurant data

### Common Issues
1. **"Please set your Google Places API key"**: Update the API key in `places_service.dart`
2. **"OVER_QUERY_LIMIT"**: You've exceeded your API quota
3. **"REQUEST_DENIED"**: Check API key restrictions and billing setup
4. **No restaurants found**: Try increasing the search radius or checking your location

## 5. Features Added

### LocationService Enhancements
- ✅ Real restaurant data from Google Places API
- ✅ Fallback to mock data if API fails
- ✅ Toggle between real and mock data
- ✅ Refresh functionality
- ✅ Search for wing chains (Buffalo Wild Wings, Wingstop, etc.)
- ✅ Smart filtering for wing restaurants

### UI Improvements
- ✅ Refresh button to reload restaurant data
- ✅ Menu to toggle data source
- ✅ Better loading states
- ✅ Error handling with graceful fallbacks

### Search Strategy
1. **Chain Search**: Finds popular wing chains first
2. **Keyword Search**: Searches for restaurants with wing/beer keywords
3. **Smart Filtering**: Filters results based on restaurant type and name
4. **Deduplication**: Removes duplicate restaurants
5. **Distance Sorting**: Orders by proximity to user

## 6. Next Steps

### Enhance Search Results
- Add more specific wing restaurant keywords
- Include user reviews and photos
- Add business hours and contact info
- Implement restaurant categories/tags

### Performance Optimizations
- Cache API responses locally
- Implement pagination for large result sets
- Add background refresh functionality
- Store user's favorite locations

### User Experience
- Add restaurant photos from Places API
- Show price level indicators
- Add "Open Now" status
- Implement turn-by-turn directions
