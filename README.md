# FaceFit AR

> Real-time AR face filter app for iOS — built with ARKit, SceneKit & SwiftUI

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2016+-blue.svg)](https://developer.apple.com/ios/)
[![ARKit](https://img.shields.io/badge/ARKit-Face%20Tracking-green.svg)](https://developer.apple.com/arkit/)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%2B%20Firestore-yellow.svg)](https://firebase.google.com)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM-purple.svg)]()

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎭 **4 AR Filters** | Sunglasses, Devil Horns, Crown, Neon Mask — rendered as 3D SceneKit geometry |
| 😃 **Expression-Reactive** | Filters respond to facial expressions (smile → crown glows, wink → lens glint, brow raise → horns grow) |
| 📸 **Photo Capture** | Tap to capture photos with filters overlaid via `ARSCNView.snapshot()` |
| 🎬 **Video Recording** | Hold to record video — frame-by-frame capture at 30fps with `AVAssetWriter` |
| 🔐 **Firebase Auth** | Email/password authentication with session persistence |
| 📊 **Smart Filter Sorting** | Filters reorder by usage frequency per user (updates each session) |
| ✨ **Particle Effects** | Crown sparkles and expression-triggered visual effects via `SCNParticleSystem` |

---

## 🏗️ Architecture

```
FaceFitAR/
├── Models/             # Data structures (AppUser, FilterModel, FilterType)
├── ViewModels/         # Business logic (AuthVM, CameraVM, MediaVM)
├── Views/
│   ├── Auth/           # Login & Sign Up screens
│   ├── Camera/         # AR camera, filter selector, AR bridge
│   ├── Gallery/        # Photo & video preview screens
│   └── Components/     # Reusable UI (InputField, PrimaryButton)
├── Services/           # Firebase, PhotoLibrary, VideoRecording
├── Filters/            # 3D filter node with expression reactivity
└── Extensions/         # Color theme & design system
```

**Pattern**: MVVM — Views bind to `@Published` ViewModel properties. Views never touch ARKit or Firebase directly.

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **UI** | SwiftUI | Declarative interface with reactive data binding |
| **AR** | ARKit | TrueDepth face tracking (1220-vertex mesh, 52 blend shapes) |
| **3D** | SceneKit | Filter geometry rendering with Metal-backed GPU acceleration |
| **Video** | AVAssetWriter + CADisplayLink | Frame-by-frame AR recording at 30fps |
| **Auth** | Firebase Auth | Email/password with auto session restore |
| **Database** | Cloud Firestore | User profiles & filter usage analytics |
| **Photos** | PhotoKit | Save captured media to device library |

---

## 🎭 Filters & Expression Reactivity

| Filter | 3D Geometry | Expression Trigger |
|--------|------------|-------------------|
| 🕶️ **Sunglasses** | Planes, Torus, Cylinder | Wink → lens glint flash · Smile → purple tint |
| 😈 **Devil Horns** | Cones, Planes | Raise eyebrows → horns grow 15% |
| 👑 **Crown** | Torus, Pyramids, Spheres + Particles | Smile → jewels glow red-gold · Sparkle particles |
| 🎭 **Neon Mask** | Planes, Torus, Cylinder | Cheek puff → neon pulse · Jaw open → scale up |

---

## 📱 Screenshots

> Run the app and add your screenshots here

---

## 🚀 Getting Started

### Prerequisites
- **Xcode 15+**
- **iOS 16+** device with **TrueDepth camera** (iPhone X or later)
- **Firebase project** with Auth & Firestore enabled

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/YOUR_USERNAME/FaceFit-AR.git
   cd FaceFit-AR
   ```

2. **Add Firebase config**
   - Download `GoogleService-Info.plist` from [Firebase Console](https://console.firebase.google.com)
   - Place it in the `FaceFitAR/` directory

3. **Open in Xcode**
   ```bash
   open FaceFitAR.xcodeproj
   ```

4. **Build & run** on a physical device (face tracking requires TrueDepth camera)

> ⚠️ **Note**: AR face tracking does **not** work on the iOS Simulator. You must use a physical iPhone X or later.

---

## 📐 User Flow

```
App Launch → Firebase session check
    ├── Authenticated → Camera View (AR + filters)
    └── Not authenticated → Login Screen
                               ├── Sign In → Camera View
                               └── Sign Up → Create Account → Camera View

Camera View:
    ├── Tap filter → Apply 3D filter + log usage to Firestore
    ├── Tap capture button → Photo → Preview (Save/Share/Retake)
    ├── Hold capture button → Video Recording → Preview (Save/Share/Discard)
    └── Sign Out → Login Screen
```

---

## 🔑 Key Technical Decisions

| Decision | Rationale |
|----------|-----------|
| **ARKit over Vision** | ARKit provides 3D face mesh + blend shapes; Vision only does 2D detection |
| **SceneKit over RealityKit** | `snapshot()` for capture, programmatic geometry, simpler API |
| **`snapshot()` over ReplayKit** | Captures AR content + filters only, not UI elements |
| **Firestore over CoreData** | Cloud sync, cross-device persistence, no backend needed |
| **Session-only sort** | Filter order updates on app launch, not mid-session, to avoid user confusion |

---

## 📄 License

This project is for educational/internship submission purposes.

---

<p align="center">
  Built with ❤️ using ARKit, SceneKit & SwiftUI
</p>
