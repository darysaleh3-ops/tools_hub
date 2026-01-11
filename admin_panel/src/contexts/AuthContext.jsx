import { createContext, useContext, useEffect, useState } from 'react';
import { auth, db } from '../firebase.config';
import { onAuthStateChanged, signInWithEmailAndPassword, signOut } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';

const AuthContext = createContext();

export function useAuth() {
    return useContext(AuthContext);
}

export function AuthProvider({ children }) {
    const [currentUser, setCurrentUser] = useState(null);
    const [isAdmin, setIsAdmin] = useState(false);
    const [loading, setLoading] = useState(true);

    async function login(email, password) {
        return signInWithEmailAndPassword(auth, email, password);
    }

    function logout() {
        return signOut(auth);
    }

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, async (user) => {
            setLoading(true);
            if (user) {
                // Check Admin Role from Firestore
                try {
                    const userDoc = await getDoc(doc(db, "users", user.uid));
                    if (userDoc.exists()) {
                        const userData = userDoc.data();
                        // Check for 'admin' role (trimming for safety)
                        const role = String(userData.role || 'user').trim();
                        if (role === 'admin') {
                            setCurrentUser({ ...user, ...userData });
                            setIsAdmin(true);
                        } else {
                            // Not admin
                            console.warn("User is not admin:", role);
                            setCurrentUser(null);
                            setIsAdmin(false);
                            await signOut(auth); // Force logout
                        }
                    } else {
                        setCurrentUser(null);
                        setIsAdmin(false);
                    }
                } catch (error) {
                    console.error("Error fetching user role:", error);
                    setCurrentUser(null);
                    setIsAdmin(false);
                }
            } else {
                setCurrentUser(null);
                setIsAdmin(false);
            }
            setLoading(false);
        });

        return unsubscribe;
    }, []);

    const value = {
        currentUser,
        isAdmin,
        login,
        logout,
        loading
    };

    return (
        <AuthContext.Provider value={value}>
            {!loading && children}
        </AuthContext.Provider>
    );
}
