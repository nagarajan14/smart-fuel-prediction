import React, { createContext, useContext, useEffect, useState } from 'react';
import { auth, db, firebaseConfig } from './firebase';
import { 
  onAuthStateChanged, 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword, 
  signOut as firebaseSignOut 
} from 'firebase/auth';
import { doc, setDoc } from 'firebase/firestore';

const AuthContext = createContext();

export const useAuth = () => useContext(AuthContext);

export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(null);
  const [loading, setLoading] = useState(true);

const isMock = firebaseConfig.apiKey === "YOUR_API_KEY";

  // Sign In
  const signIn = async (email, password) => {
    if (isMock) {
      setCurrentUser({ uid: 'mock_123', email, name: 'Mock User' });
      return { uid: 'mock_123', email };
    }
    try {
      const result = await signInWithEmailAndPassword(auth, email, password);
      return result.user;
    } catch (error) {
      console.error("Error in login:", error);
      throw error;
    }
  };

  // Register
  const register = async (name, email, password) => {
    if (isMock) {
      setCurrentUser({ uid: 'mock_123', email, name });
      return { uid: 'mock_123', email };
    }
    try {
      const result = await createUserWithEmailAndPassword(auth, email, password);
      const user = result.user;
      
      if (user) {
        // Create user document in Firestore
        await setDoc(doc(db, 'users', user.uid), {
          id: user.uid,
          email: email,
          name: name,
        });
      }
      return user;
    } catch (error) {
      console.error("Error in registration:", error);
      throw error;
    }
  };

  // Sign out
  const signOut = () => {
    if (isMock) {
      setCurrentUser(null);
      return Promise.resolve();
    }
    return firebaseSignOut(auth);
  };

  useEffect(() => {
    if (isMock) {
      setLoading(false);
      return;
    }
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setCurrentUser(user);
      setLoading(false);
    });

    return unsubscribe;
  }, []);

  const value = {
    currentUser,
    signIn,
    register,
    signOut
  };

  return (
    <AuthContext.Provider value={value}>
      {!loading && children}
    </AuthContext.Provider>
  );
};
