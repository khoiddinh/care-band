# CareBand

CareBand is a lightweight, secure hospital patient identification system that uses NFC bracelets and QR codes to retrieve, view, and update patient information instantly.  
Built for speed, security, and a seamless user experience.

**NOTE:** for full functionality, build the branch new_flow
## Features

- **NFC Bracelet Scanning**: Quickly scan a patient's NFC-enabled bracelet to access medical records.
- **QR Code Backup**: Scan a QR code as an alternative way to retrieve patient information.
- **Add New Patients**: Create new patient records and automatically generate a unique QR code.
- **Update Patient Information**: Modify allergies, medical history, and personal data on the fly.
- **View Patient Details**: Instant display of allergies, history, and critical information.
- **Authentication**: Hospital staff securely log in via email/password (Firebase Authentication).
- **Smooth UX**: Custom haptics, SwiftUI animations, and a clean design.
- **Offline-resilient Frontend**: Local loading animations and responsive feedback.

## Tech Stack

| Layer               | Technology  |
|---------------------|--------------|
| Language            | Swift 5.9    |
| Framework           | SwiftUI (iOS 17+) |
| Backend             | Firebase (Auth, Firestore, Cloud Functions) |
| NFC Integration     | CoreNFC      |
| QR Code Scanning    | AVFoundation (custom UIViewControllerRepresentable) |
| API Communication   | URLSession REST calls |
| Authentication      | Firebase Authentication (email/password) |
| Data Storage        | Firebase Firestore (NoSQL) |
| Server Functions    | Firebase Cloud Functions (Node.js / JavaScript) |
| Animation & Haptics | SwiftUI animations + UIKit UIImpactFeedbackGenerator |

## Key Components

- **SwiftUI Frontend**: Modern SwiftUI architecture with @Observable view models and NavigationStack.
- **Firebase Backend**:
  - `addOrUpdatePatient`: Adds new or updates existing patient records.
  - `getPatientRecord`: Fetches patient data securely based on UUID.
  - `findPatient`: Retrieves patient records based on UUID, SSN, or DOB.
- **NFC + QR Scanner**: Seamless patient lookup via physical bracelet or printed QR backup.

## Setup Instructions

1. Clone this repository into Xcode.
2. Install the Firebase iOS SDK (via Swift Package Manager or manually).
3. Add your `GoogleService-Info.plist` file to your project.
4. Configure Firestore rules and deploy Cloud Functions:
    ```bash
    firebase deploy --only functions
    ```
5. Update `Info.plist` with required permissions:
    ```xml
    <key>NFCReaderUsageDescription</key>
    <string>Used for scanning patient NFC bracelets</string>
    <key>NSCameraUsageDescription</key>
    <string>Used for scanning QR codes for patient lookup</string>
    ```
6. Build and run on a real device (NFC scanning requires a physical iPhone).

## Security

- **Authentication**: All API calls require a valid Firebase Authentication token.
- **HTTPS Only**: All data transmissions are encrypted over HTTPS.
- **Role-Based Access**: Only authenticated users can access or modify patient information.

## Contributors

- **Khoi Dinh** – Developer
- **Lawrence Yang** - Designer
- Additional support from Firebase open-source documentation and Vly.ai (ideation assistance).

