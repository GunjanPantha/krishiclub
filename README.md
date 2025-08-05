# krishiclub

This is a Flutter project designed to connect farmers and buyers.

## Features

* **User Authentication:** Users can register and login. The app supports a "Remember Me" feature to save login credentials.
* **Role Selection:** During registration, users can choose their role as either a 'Farmer' or a 'Buyer'.
* **Crop Management (for Farmers):** Farmers can upload details about their crops, including a name, quantity, address from a predefined list, and an image. They can also view and delete their own posts from their profile page.
* **Browse (for all users):** All crop listings are displayed on the home page. Users can tap on a listing to view more details, including a larger image.
* **User List:** There is a separate page to view a list of all users who have registered as a 'Farmer'.
* **Profile Page:** Users can view their profile details, including their username, email, role, and a profile image.
* **Theme Switching:** The app includes a settings page where users can toggle between a light and a dark theme.

## Technologies

* **Flutter**: The primary framework used for building the cross-platform application.
* **Firebase**:
    * **Firebase Auth**: For user authentication, including email/password login and registration.
    * **Cloud Firestore**: A NoSQL database used to store user information and crop details.
    * **Firebase Storage**: Used for storing image files for crops and user profiles.
* **Provider**: For state management throughout the application.
* **Image Picker & Cropper**: To handle image selection from the gallery or camera and to allow cropping.
* **Shared Preferences**: To store simple key-value data on the device, such as for the "Remember Me" functionality.
