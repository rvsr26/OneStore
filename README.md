# 🛍️ OneStore - AI-Powered E-Commerce Super App

**OneStore** is a cutting-edge, full-featured E-Commerce application built with **Flutter** and **Firebase**. It redefines the shopping experience with **AI-powered assistance**, voice commands, real-time order tracking, and a stunning, fully dynamic dark mode interface.

---

## 🚀 Features

### 🧠 **AI & Smart Features**
* **AI Shopping Assistant:** An intelligent chatbot to help users find products and styling tips.
* **Voice Search:** Integrated Speech-to-Text for hands-free product searching.
* **Smart Recommendations:** "Picked for You" section tailored to user behavior.
* **Virtual Try-On (UI):** Ready-to-integrate UI for AR product visualization.
* **Fit Prediction:** AI-generated tags for sizing and review sentiment analysis.

### 🛒 **Shopping Experience**
* **Dynamic Catalog:** Browse Clothes, Shoes, and Electronics with powerful filtering and sorting.
* **Advanced Search:** Text and voice search with persistent history.
* **Smart Cart:**
    * **Gamified Free Delivery:** Visual progress bar incentivizing higher cart value.
    * **Coupon System:** Apply discount codes instantly.
    * **Swipe-to-Remove:** Intuitive gestures for cart management.
* **Wishlist:** Save favorites permanently, synced across devices via Firestore.

### 💳 **Checkout & Orders**
* **Address Management:** Add, edit, and select multiple delivery addresses.
* **Flexible Payments:** Integration with **Razorpay** (Online) and Cash on Delivery (COD).
* **Real-time Order Tracking:** Visual vertical timeline (Placed → Packed → Shipped → Delivered).
* **Order History:** Comprehensive list of past orders with detailed status.
* **Invoicing:** Generate and download PDF invoices for any order.

### 🎨 **UI / UX**
* **Dynamic Dark Mode:** The entire app adapts to system themes with optimized color palettes.
* **Interactive Imagery:** Swipeable product galleries with zoom capabilities.
* **Profile Management:** Upload profile pictures using Camera or Gallery (Firebase Storage).
* **Polished Animations:** Hero transitions, shimmer loading effects, and smooth navigation.

---

## 🛠️ Tech Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | Flutter (Dart) |
| **State Management** | Provider (MultiProvider) |
| **Authentication** | Firebase Auth (Email/Password) |
| **Database** | Cloud Firestore (Real-time updates) |
| **Storage** | Firebase Storage (Profile images) |
| **Payments** | Razorpay Flutter |
| **Voice Search** | `speech_to_text` |
| **Local Storage** | `shared_preferences` |

---

## 📸 Screenshots

<div align="center">

| **Sign In** | **Home Page** | **Notifications** |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/82b24548-6326-4907-a997-f19c4a9c99e6" width="250"> | <img src="https://github.com/user-attachments/assets/683510a7-6ac1-41de-b498-54f0e82c521f" width="250"> | <img src="https://github.com/user-attachments/assets/bce2baee-c2e5-4085-b6d7-701c2633b88f" width="250"> |

| **Cart** | **Payment** | **Profile** |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/3af129d1-a2dc-42fe-8757-29e386b5c728" width="250"> | <img src="https://github.com/user-attachments/assets/ea4ab286-80b0-45d0-9759-4d96ce8fbb5d" width="250"> | <img src="https://github.com/user-attachments/assets/3af78976-61a8-4737-97fe-1881ec969056" width="250"> |

| **Wishlist** | **Settings** | **AI Assistant** |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/cc3f3fae-f45f-4dcb-84f5-3295f8c0ad38" width="250"> | <img src="https://github.com/user-attachments/assets/74c176e3-db00-4f67-8d6f-0610f5deff5d" width="250"> | <img src="https://github.com/user-attachments/assets/67cd7f4e-48af-4bec-b9d4-895bc816388c" width="250"> |

</div>

---

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites
* Flutter SDK (3.0+)
* Android Studio / VS Code
* Firebase Account

### Installation

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/rvsr/OneStore.git](https://github.com/rvsr/OneStore.git)
    cd OneStore
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Firebase Setup**
    * Create a new project on the [Firebase Console](https://console.firebase.google.com/).
    * Register an Android App with the package name: `com.example.onlineshopping`.
    * Download `google-services.json` and place it in the `android/app/` directory.
    * Enable the following services in Firebase Console:
        * **Authentication** (Email/Password provider)
        * **Cloud Firestore** (Create database)
        * **Storage** (For image uploads)

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 📂 Project Structure

```bash
lib/
├── main.dart                # 🏁 Application Entry Point & Theme Config
├── firebase_options.dart    # 🔥 Firebase Configuration
├── models/                  # 📦 Data Models
│   ├── product.dart         
│   ├── cart_item.dart       
│   ├── user.dart            
│   └── review.dart          
├── providers/               # 🧠 State Management (Provider)
│   ├── cart_provider.dart   
│   ├── auth_provider.dart   
│   ├── product_provider.dart
│   └── theme_provider.dart  
├── screens/                 # 📱 UI Screens
│   ├── login_page.dart      
│   ├── product_list.dart    
│   ├── product_detail.dart  
│   ├── cart_page.dart       
│   ├── checkout_page.dart   
│   ├── profile_page.dart    
│   └── order_tracking_page.dart 
├── services/                # 🌐 External Services & API Calls
│   ├── firestore_service.dart 
│   ├── ai_service.dart      
│   ├── razorpay_service.dart
│   └── invoice_service.dart 
└── widgets/                 # 🧩 Reusable UI Components
