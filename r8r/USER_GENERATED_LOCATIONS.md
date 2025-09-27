# User-Generated Locations System

## Overview
Switched from paid Google Places API to a community-driven system where users add and maintain restaurant locations. This eliminates API costs while building a curated database of wing spots.

## How It Works

### 1. User Submissions
- Users can add new restaurants via "Add Location" button
- Form includes: name, address, phone, website, description, tags
- Automatic location detection or manual address entry
- Tag system for categorization (wings, beer, sports-bar, etc.)

### 2. Firebase Storage
Locations stored in Firestore with this structure:
```
/locations/{locationId}
  - id: string (auto-generated)
  - name: string
  - address: string
  - phone: string (optional)
  - website: string (optional)
  - latitude: number
  - longitude: number
  - averageRating: number (calculated from reviews)
  - totalReviews: number (updated when reviews added)
  - createdBy: string (user ID)
  - createdAt: timestamp
  - isVerified: boolean (admin verification)
  - tags: array of strings
  - description: string (optional)
```

### 3. Location Discovery
- **All Locations**: Load all user-submitted locations
- **Nearby Search**: Filter by distance from user's location (50km radius)
- **Search**: Filter by name, address, tags, or description
- **Tag Filtering**: Filter by specific tags like 'wings', 'beer', etc.

## Features Implemented

### ✅ Core System
- **UserLocationService**: Handles Firestore operations
- **Enhanced LocationModel**: Added user fields and tags
- **Distance Calculation**: Haversine formula for nearby search
- **Automatic Rating Updates**: Updates when reviews are added

### ✅ Add Location Screen
- **Form Validation**: Required fields and input validation
- **Location Detection**: GPS location or address geocoding
- **Tag Selection**: Pre-defined tags with multi-select
- **User-Friendly UI**: Clean form with helpful icons

### ✅ Enhanced Search
- **Multi-field Search**: Name, address, tags, description
- **Tag-based Filtering**: Find restaurants by features
- **Real-time Results**: Instant search as you type

### ✅ UI Updates
- **Add Location Button**: Floating action button on location list
- **Tag Display**: Show tags on location cards
- **User Indicators**: Show who added each location
- **Verification Badges**: Visual indicators for verified locations

## Database Structure

### Collections
```
locations/
├── {locationId}/
│   ├── name: "Buffalo Wild Wings"
│   ├── address: "123 Main St, City, State"
│   ├── latitude: 40.7128
│   ├── longitude: -74.0060
│   ├── tags: ["wings", "beer", "sports-bar"]
│   ├── createdBy: "user123"
│   ├── createdAt: timestamp
│   └── ...other fields

reviews/
├── {reviewId}/
│   ├── locationId: "location123"
│   ├── rating: 4.5
│   └── ...review data
```

### Security Rules (Recommended)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Locations: authenticated users can read all, create new
    match /locations/{locationId} {
      allow read: if true; // Public read access
      allow create: if request.auth != null 
        && request.auth.uid == resource.data.createdBy;
      allow update: if request.auth != null 
        && (request.auth.uid == resource.data.createdBy 
            || hasRole('admin'));
    }
  }
}
```

## User Experience

### Adding a Location
1. User clicks "Add Location" button
2. Fills out restaurant details
3. Sets location via GPS or address
4. Selects relevant tags
5. Submits - location appears in community list

### Finding Locations
1. App loads nearby locations automatically
2. User can search by name, tags, or description
3. Filter by specific features (wings, beer, etc.)
4. Sort by distance, rating, or newest

### Review Integration
1. When user creates a review, they can add a new location
2. Location ratings update automatically
3. Popular locations rise to the top

## Cost Benefits

### Before (Google Places API)
- $32 per 1000 nearby searches
- $17 per 1000 place details
- Estimated $5-50/month depending on usage

### After (User-Generated)
- $0 for location data
- Only Firebase costs (generous free tier)
- Estimated $0-5/month for most apps

## Quality Control

### Community Moderation
- Users can report incorrect locations
- Admin verification system for popular spots
- Duplicate detection and merging

### Data Quality
- Required fields ensure basic info
- Address geocoding validates locations
- Tag system maintains consistency

### Spam Prevention
- Require user authentication
- Rate limiting on submissions
- Admin review for suspicious activity

## Future Enhancements

### Phase 1 (Current)
- ✅ Basic location submission
- ✅ Search and filtering
- ✅ Tag system

### Phase 2 (Next)
- [ ] Photo uploads for locations
- [ ] User ratings for location accuracy
- [ ] Duplicate detection and merging
- [ ] Admin verification workflow

### Phase 3 (Advanced)
- [ ] Location suggestions based on reviews
- [ ] Community voting on location details
- [ ] Integration with social features
- [ ] Location analytics and insights

## Migration from Mock Data

The system includes fallback mock data that shows:
- Buffalo Wild Wings
- Wingstop  
- Hooters
- Local Wing House

These appear when no user-submitted locations exist, providing a starting point for the community.

## Benefits

### For Users
- **Free Service**: No API costs passed to users
- **Community Driven**: Local knowledge and preferences
- **Always Growing**: Database expands with user contributions
- **Accurate Info**: Users update what they know

### For Developers
- **No API Costs**: Eliminates Google Places expenses
- **Full Control**: Own the data and features
- **Customizable**: Add app-specific fields and features
- **Scalable**: Firebase handles growth automatically

### For Community
- **Local Focus**: Emphasis on community favorites
- **Quality Over Quantity**: Curated by actual users
- **Collaborative**: Everyone contributes to better data
- **Sustainable**: Self-maintaining system

The user-generated system transforms R8R from an API-dependent app into a community-driven platform where wing enthusiasts build and maintain their own database of great spots!
