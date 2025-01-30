# Chat Application -- **INCOMPLETE HAVE TO ADD VIDEO FEATURE CORRECTLY IN WEBRTC BRANCH

A **real-time chat application** built using **Flutter** and **Firebase Realtime Database**, designed for seamless and efficient communication. This app includes features such as secure user authentication, real-time messaging, and profile management, all wrapped in a responsive and user-friendly UI.

## Features

- **User Authentication**:
  - Secure user login and registration implemented with Firebase .
  - User credentials are securely stored, ensuring data privacy.

- **Real-time Messaging**:
  - Messages are synced in real-time across users using Firebase Realtime Database.
  - Efficient data handling ensures a smooth chat experience without delays.

- **Profile Management**:
  - Users can manage their profile details, such as username and profile picture.

- **Interactive UI**:
  - The app is designed with a clean and intuitive interface built using Flutter.
  - Provides a smooth user experience with responsive layouts.

- **Data Consistency**:
  - Ensures data synchronization and accurate updates when navigating between screens.

## Project Structure

The project follows a modular structure for scalability and maintainability:

- **lib**
  - `main.dart`: Entry point of the application.
  - `pages/`: This have all the other dart files like other screen or logic dart files

## How It Works

1. **Authentication**:
   - Users sign up or log in by clicking the icon on the top corner which redirect the user to login screen.
   - Once the user is logged in the user can add friend(if the friend exist).
   - Then on clicking it the user will be redirected to chat screen.

2. **Real-time Messaging**:
   - Messages are stored in Firebase Realtime Database under structured nodes.
   - The app listens for updates in real time and displays messages instantly in the chat interface.

3. **Profile Management**:
   - User profile data (e.g., name, profile picture) is stored and retrieved from Firebase.
   - Users can edit their profile, and the changes are reflected across the app.

4. **Navigation and Data Transfer**:
   - Uses Flutter’s `Navigator` for seamless screen transitions.
   - Data is passed between screens using models and state management.

## Prerequisites

- **Flutter SDK**: Ensure that Flutter is installed and configured on your system.
- **Firebase Project**: Set up a Firebase project and enable Authentication and Realtime Database.

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/ShashiSingh8434/Chat-Application.git
   cd Chat-Application
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Add the `google-services.json` file (for Android) and `GoogleService-Info.plist` (for iOS) to the respective directories.

4. Run the app:
   ```bash
   flutter run
   ```

## Video Sample

Here is a sample video of this project :

https://github.com/user-attachments/assets/dd6783cc-9d4b-4b4d-a217-9b47f8f47c77

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests to improve the app.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

-----

Happy coding! 🚀


