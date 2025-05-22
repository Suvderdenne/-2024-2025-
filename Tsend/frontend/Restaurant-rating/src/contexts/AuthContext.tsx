import React, { createContext, useContext, useState, useEffect } from "react";
import { toast } from "sonner";
import { loginUser, registerUser } from "../components/api";
import { useNavigate } from "react-router-dom";

// API үндсэн замыг тодорхойлох
const API_BASE_URL = "http://127.0.0.1:8000/api";

interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
}

interface AuthContextType {
  user: User | null;
  isLoading: boolean;
  login: (email: string, password: string) => Promise<boolean>;
  signup: (name: string, email: string, password: string) => Promise<boolean>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
};

export const AuthProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const navigate = useNavigate();  // Add this line here

  // Хадгалагдсан хэрэглэгчийн мэдээллийг сэргээх
  useEffect(() => {
    const savedUser = localStorage.getItem("user");
    const authToken = localStorage.getItem("authToken");

    if (savedUser && authToken) {
      try {
        setUser(JSON.parse(savedUser));
      } catch (e) {
        console.error("Хадгалагдсан өгөгдлийг боловсруулахад алдаа гарлаа:", e);
        localStorage.removeItem("user");
        localStorage.removeItem("authToken");
      }
    }
    setIsLoading(false);
  }, []);

  // Нэвтрэх функц
  const login = async (email: string, password: string): Promise<boolean> => {
    try {
      const response = await loginUser({ email, password });

      if (!response.token || !response.user_id) {
        throw new Error("Invalid response from server");
      }

      const user = {
        id: response.user_id.toString(),
        name: response.username || email.split('@')[0], // Use username from response if available
        email: email
      };

      setUser(user);
      localStorage.setItem("authToken", response.token);
      localStorage.setItem("user", JSON.stringify(user));
      return true;
    } catch (error) {
      console.error("Login error:", error);
      toast.error("Нэвтрэхэд алдаа гарлаа");
      return false;
    }
  };

  // Бүртгүүлэх функц
  const signup = async (name: string, email: string, password: string): Promise<boolean> => {
    setIsLoading(true);
    try {
      const response = await registerUser({ username: name, email, password });
      if (!response.user || !response.token) {
        throw new Error("Бүртгэлийн өгөгдөл буруу байна");
      }

      const user = {
        id: response.user.id.toString(),
        name: response.user.username,
        email: response.user.email
      };
      const token = response.token;

      setUser(user);
      localStorage.setItem("user", JSON.stringify(user));
      localStorage.setItem("authToken", token);
      toast.success("Бүртгэл амжилттай үүслээ");
      return true;
    } catch (error: any) {
      console.error("Signup error:", error.response?.data || error.message);
      toast.error(error.response?.data?.error || "Бүртгэхэд алдаа гарлаа");
      return false;
    } finally {
      setIsLoading(false);
    }
  };

  // Гарах функц
  const logout = () => {
    // Токеныг устгах
    localStorage.removeItem("authToken");
    // Хэрэглэгчийн мэдээллийг устгах
    setUser(null); // (Хэрэв setUser функцтэй бол)
    // Хуудас руу шилжих
    navigate("/login");
  };

  return (
    <AuthContext.Provider value={{ user, isLoading, login, signup, logout }}>
      {children}
    </AuthContext.Provider>
  );
};
