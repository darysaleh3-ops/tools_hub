// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

// Your web app's Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyB9QM1Vsivtkg-Acb6ySvlz7KfqmUWnICc",
    authDomain: "tools-hub-app.firebaseapp.com",
    projectId: "tools-hub-app",
    storageBucket: "tools-hub-app.firebasestorage.app",
    messagingSenderId: "959542949884",
    appId: "1:959542949884:web:0e575cb04e97c0a1526479",
    measurementId: "G-CF2C87FFZ7"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);
