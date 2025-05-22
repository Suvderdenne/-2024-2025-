import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { toast } from "sonner";

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [errors, setErrors] = useState({ email: "", password: "" });
  const navigate = useNavigate();
  const { login } = useAuth();

  const validateForm = () => {
    const newErrors = { email: "", password: "" };
    let isValid = true;

    if (!email) {
      newErrors.email = "Имэйл хаяг оруулна уу";
      isValid = false;
    }

    if (!password) {
      newErrors.password = "Нууц үг оруулна уу";
      isValid = false;
    }

    setErrors(newErrors);
    return isValid;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validateForm()) return;

    setLoading(true);
    try {
      const success = await login(email, password);
      if (success) {
        navigate("/");
        toast.success("Амжилттай нэвтэрлээ");
      } else {
        toast.error("Имэйл эсвэл нууц үг буруу байна");
      }
    } catch (error) {
      toast.error("Серверийн алдаа гарлаа");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div
      className="relative min-h-screen flex items-center justify-center bg-cover bg-center"
      style={{
        backgroundImage: "url('https://images.unsplash.com/photo-1600891964599-f61ba0e24092?auto=format&fit=crop&w=1740&q=80')",
      }}
    >
      {/* Dark overlay */}
      <div className="absolute inset-0 bg-black/50 backdrop-blur-sm"></div>

      {/* Login Card */}
      <div className="relative z-10 bg-white/20 backdrop-blur-lg rounded-2xl shadow-xl p-8 w-full max-w-sm text-white">
        <h1 className="text-3xl font-bold text-center">Нэвтрэх</h1>
        <p className="text-center text-sm mt-2 mb-6">
          Өөрийн бүртгэлээр нэвтэрч орно уу
        </p>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="email" className="block text-sm font-medium mb-1">
              Имэйл
            </label>
            <Input
              id="email"
              type="email"
              placeholder="name@example.com"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="text-black"
            />
            {errors.email && (
              <p className="text-sm text-red-400">{errors.email}</p>
            )}
          </div>

          <div>
            <label htmlFor="password" className="block text-sm font-medium mb-1">
              Нууц үг
            </label>
            <Input
              id="password"
              type="password"
              placeholder="••••••••"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              className="text-black"
            />
            {errors.password && (
              <p className="text-sm text-red-400">{errors.password}</p>
            )}
          </div>

          <Button
            type="submit"
            className="w-full bg-gray-800 hover:bg-gray-700"
            disabled={loading}
          >
            {loading ? "Нэвтэрч байна..." : "Нэвтрэх"}
          </Button>
        </form>

        <p className="mt-4 text-sm text-center">
          Бүртгэлгүй юу?{" "}
          <Link to="/signup" className="underline text-white font-semibold">
            Бүртгүүлэх
          </Link>
        </p>
      </div>
    </div>
  );
};

export default Login;
