# Firebase Setup Guide

## Overview
This app now uses Firebase for backend services including Authentication, Firestore Database, and Cloud Storage.

## 🔥 New Features Implemented

### 1. **Firebase Authentication** (Section 11: Cloud/Firebase Features)
- User registration with email and password
- Secure login/logout functionality
- Password validation (minimum 6 characters)
- Authentication state persistence
- Beautiful auth screen with gradient design
- Error handling with user-friendly messages

### 2. **Firebase Cloud Storage** (Section 11: Cloud/Firebase Features)
- Upload images for grocery items
- Take photos with camera or choose from gallery
- Images stored in Firebase Storage with organized structure
- Image preview in list and edit screens
- Optional image removal
- Automatic image deletion when items are removed

### 3. **Cloud Firestore** (Section 11: Cloud/Firebase Features)
- Real-time database with automatic synchronization
- User-specific grocery lists (multi-user support)
- Hierarchical data structure: `users/{userId}/groceries/{itemId}`
- Server-side timestamps
- Automatic data refresh
- Better querying capabilities (ordered by creation date)

### 4. **Major Feature Extension** (Section 12: Major Feature Extension)
This combines all three Firebase features into a complete workflow:
- User creates account → Signs in → Adds grocery item → Uploads image → Stores in Firestore
- Complete integration of Authentication + Storage + Database
- Real-time sync across devices for the same user
- Secure, scalable multi-user architecture

## 🚀 Setup Instructions

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., "shopping-list-app")
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Enable Firebase Services

#### Authentication
1. In Firebase Console, go to **Authentication** → **Get Started**
2. Click **Sign-in method** tab
3. Enable **Email/Password**
4. Save

#### Firestore Database
1. Go to **Firestore Database** → **Create database**
2. Choose **Start in test mode** (for development)
3. Select a location (choose one close to your users)
4. Click **Enable**

#### Cloud Storage
1. Go to **Storage** → **Get Started**
2. Start in **test mode** (for development)
3. Click **Done**

### Step 3: Configure Flutter App

1. Install FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Run FlutterFire configure:
```bash
cd /Users/rstoffel/Dev/school/mobile_app/shopping
flutterfire configure
```

3. Select your Firebase project
4. Choose platforms (iOS, Android, macOS, Web)
5. This will generate `lib/firebase_options.dart` with your configuration

### Step 4: iOS Configuration (if targeting iOS)

1. Open `ios/Runner.xcworkspace` in Xcode
2. Ensure bundle ID matches Firebase
3. Update `ios/Runner/Info.plist` if needed

### Step 5: Android Configuration (if targeting Android)

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/`
3. Ensure `android/app/build.gradle` has Firebase dependencies

### Step 6: Security Rules

#### Firestore Rules
Go to Firestore → Rules and update:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

#### Storage Rules
Go to Storage → Rules and update:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own images
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📱 How to Use the App

### First Time Setup
1. Launch the app
2. Click "Don't have an account? Sign up"
3. Enter email and password
4. Click "Sign Up"

### Adding Items with Images
1. Tap the "Add Item" button
2. Tap the image placeholder to add a photo
3. Choose "Take a Photo" or "Choose from Gallery"
4. Fill in item details (name, quantity, category)
5. Click "Add Item"

### Managing Your List
- **Search**: Tap search icon to filter by name or category
- **Edit**: Tap any item to edit details or change image
- **Delete**: Swipe left or right on an item to delete
- **Refresh**: Pull down to refresh the list
- **Sign Out**: Tap menu (⋮) → Sign Out

## 🏗️ Project Structure

```
lib/
├── main.dart                      # App entry point with Firebase initialization
├── firebase_options.dart          # Firebase configuration (auto-generated)
├── models/
│   ├── category.dart             # Category enum and model
│   └── grocery_item.dart         # Grocery item model with imageUrl
├── screens/
│   └── auth_screen.dart          # Login/Signup screen
├── services/
│   ├── auth_service.dart         # Firebase Authentication service
│   ├── firestore_service.dart    # Cloud Firestore service
│   └── storage_service.dart      # Cloud Storage service
├── widgets/
│   ├── grocery_list.dart         # Main list screen with real-time updates
│   └── new_item.dart             # Add/Edit item form with image picker
└── data/
    └── categories.dart           # Category definitions
```

## 🔒 Security Features

- Email/password authentication required
- User-specific data isolation
- Firestore security rules prevent unauthorized access
- Storage rules prevent access to other users' images
- Secure token-based authentication

## 📊 Database Schema

### Firestore Structure
```
users (collection)
  └── {userId} (document)
      └── groceries (collection)
          └── {itemId} (document)
              ├── name: string
              ├── quantity: number
              ├── category: string
              ├── imageUrl: string (optional)
              └── createdAt: timestamp
```

### Storage Structure
```
users/
  └── {userId}/
      └── groceries/
          └── {itemId}.jpg
```

## 🎨 UI Improvements

- Beautiful gradient auth screen
- Image thumbnails in list view
- Smooth Hero animations
- Real-time updates without refresh
- Loading states and error handling
- User profile display in menu
- Confirmation dialogs for sign out

## 🐛 Troubleshooting

### "Firebase not initialized"
- Make sure you ran `flutterfire configure`
- Check that `firebase_options.dart` exists

### "Permission denied" errors
- Update Firestore and Storage security rules
- Ensure user is authenticated

### Images not uploading
- Check Storage rules
- Verify image picker permissions in iOS Info.plist
- Ensure internet connection

### Can't sign in
- Check Firebase Authentication is enabled
- Verify email/password format
- Check console for error messages

## 📚 Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Cloud Firestore](https://firebase.google.com/docs/firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)
- [Cloud Storage](https://firebase.google.com/docs/storage)

## 🎓 Learning Outcomes

This implementation demonstrates:
- ✅ Firebase Authentication integration
- ✅ Cloud Firestore real-time database
- ✅ Cloud Storage for file uploads
- ✅ User-specific data management
- ✅ Image picking and uploading workflow
- ✅ Real-time data synchronization
- ✅ Security rules implementation
- ✅ Multi-platform Firebase configuration
- ✅ Error handling and user feedback
- ✅ Complete authentication flow

**Time Investment**: 4-6 hours (as per Section 11-12 requirements)
**Skills Used**: Firebase Auth, Firestore, Storage, Image Picker, Async/Await, Stream builders, Security rules

