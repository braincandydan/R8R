# 🚀 R8R App Deployment Guide

## 📋 Prerequisites
- Flutter SDK installed
- Node.js installed (for Vercel CLI)
- Firebase account
- Git repository (GitHub recommended)

## 🔥 Step 1: Firebase Setup

### 1.1 Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Name it "r8r-app" (or your preferred name)
4. Enable Google Analytics (optional)
5. Click "Create project"

### 1.2 Enable Authentication
1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Go to "Sign-in method" tab
4. Enable "Email/Password"
5. Click "Save"

### 1.3 Create Firestore Database
1. Go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode" (for now)
4. Select a location (choose closest to your users)
5. Click "Done"

### 1.4 Enable Storage
1. Go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode"
4. Select same location as Firestore
5. Click "Done"

### 1.5 Get Firebase Config
1. Go to Project Settings (gear icon)
2. Scroll down to "Your apps"
3. Click "Web" icon (</>)
4. Register app with name "r8r-web"
5. Copy the config object

### 1.6 Update Firebase Config
Replace the placeholder values in `lib/firebase_options.dart`:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_API_KEY',
  appId: 'YOUR_ACTUAL_APP_ID',
  messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
  projectId: 'YOUR_ACTUAL_PROJECT_ID',
  authDomain: 'YOUR_ACTUAL_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_ACTUAL_PROJECT_ID.appspot.com',
);
```

## 🌐 Step 2: Vercel Deployment

### 2.1 Install Vercel CLI
```bash
npm install -g vercel
```

### 2.2 Build Flutter Web App
```bash
cd r8r
flutter build web
```

### 2.3 Deploy to Vercel
```bash
# From the r8r directory
vercel --prod
```

### 2.4 Connect to GitHub (Optional)
1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Import your GitHub repository
3. Set build command: `flutter build web`
4. Set output directory: `build/web`
5. Deploy!

## 🔧 Step 3: Firebase Security Rules

### 3.1 Firestore Rules
Go to Firestore > Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Locations are readable by everyone
    match /locations/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Reviews are readable by everyone, writable by authenticated users
    match /reviews/{document} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User profiles are readable by everyone, writable by owner
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### 3.2 Storage Rules
Go to Storage > Rules and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /photos/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 🎯 Step 4: Test Your Deployment

### 4.1 Test PWA Features
1. Open your deployed URL
2. Look for "Install" button in browser
3. Test offline functionality
4. Test on mobile devices

### 4.2 Test Firebase Integration
1. Try creating an account
2. Submit a review
3. Check Firebase Console for data
4. Test photo uploads

## 🔄 Step 5: Continuous Deployment

### 5.1 GitHub Integration
1. Push your code to GitHub
2. Connect Vercel to your repo
3. Every push to main = automatic deployment

### 5.2 Development Workflow
```bash
# Make changes locally
git add .
git commit -m "Add new feature"
git push origin main

# Vercel automatically deploys!
```

## 📱 Step 6: PWA Configuration

### 6.1 Update manifest.json
Located in `web/manifest.json`:

```json
{
  "name": "R8R - Wing & Beer App",
  "short_name": "R8R",
  "description": "The definitive digital hub for chicken wing and beer enthusiasts",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#FF6B35",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

## 🚨 Troubleshooting

### Common Issues:

1. **Firebase not initialized**
   - Check firebase_options.dart has correct config
   - Ensure Firebase.initializeApp() is called

2. **Build fails on Vercel**
   - Check Flutter version compatibility
   - Ensure all dependencies are compatible

3. **PWA not installing**
   - Check manifest.json
   - Ensure service worker is registered
   - Test on HTTPS (required for PWA)

4. **Firebase permissions denied**
   - Check Firestore rules
   - Ensure user is authenticated
   - Check Storage rules

## 🎉 Success!

Your R8R app should now be:
- ✅ Live on the internet
- ✅ PWA installable
- ✅ Connected to Firebase
- ✅ Ready for real users!

## 📞 Support

If you encounter issues:
1. Check Firebase Console for errors
2. Check Vercel deployment logs
3. Test locally with `flutter run -d web-server`
4. Check browser console for errors

Happy coding! 🍗🍺
