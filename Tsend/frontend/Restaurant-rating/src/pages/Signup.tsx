import React, { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";
import { registerUser } from "@/components/api"; // 🔹 API функцыг импортлох

const Signup = () => {
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!name.trim()) {
      toast.error("Нэрээ оруулна уу");
      return;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      toast.error("Имэйл хаяг буруу байна");
      return;
    }

    if (password.length < 6) {
      toast.error("Нууц үг хамгийн багадаа 6 тэмдэгт байх ёстой");
      return;
    }

    if (password !== confirmPassword) {
      toast.error("Нууц үг таарахгүй байна");
      return;
    }

    setLoading(true);

    try {
      // 🔹 API хүсэлт илгээх
      const response = await registerUser({ username: name, email, password });

      if (response) {
        toast.success("Бүртгэл амжилттай боллоо!");
        setName("");
        setEmail("");
        setPassword("");
        setConfirmPassword("");
        navigate("/login"); // 🔹 Бүртгэл амжилттай болсны дараа нэвтрэх хуудас руу шилжүүлэх
      }
    } catch (error: any) {
      console.error("Бүртгэл хийхэд алдаа гарлаа:", error);
      toast.error(error.message || "Системд алдаа гарлаа");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container max-w-md mx-auto py-8 px-4">
      <div className="mb-6 text-center">
        <h1 className="text-3xl font-bold">Бүртгүүлэх</h1>
        <p className="text-muted-foreground mt-2">
          Аппд бүртгүүлээд үнэлгээ өгч эхлээрэй
        </p>
      </div>

      <Card>
        <form onSubmit={handleSubmit}>
          <CardHeader>
            <CardTitle>Бүртгүүлэх</CardTitle>
            <CardDescription>
              Хэрэглэгчийн мэдээллээ оруулна уу
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Label htmlFor="name">Нэр</Label>
              <Input
                id="name"
                type="text"
                placeholder="Таны нэр"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="email">Имэйл</Label>
              <Input
                id="email"
                type="email"
                placeholder="name@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Нууц үг</Label>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="confirmPassword">Нууц үг баталгаажуулах</Label>
              <Input
                id="confirmPassword"
                type="password"
                value={confirmPassword}
                onChange={(e) => setConfirmPassword(e.target.value)}
                required
              />
            </div>
          </CardContent>
          <CardFooter className="flex flex-col gap-4">
            <Button type="submit" className="w-full" disabled={loading || !name || !email || !password || !confirmPassword}>
              {loading ? "Бүртгэж байна..." : "Бүртгүүлэх"}
            </Button>
            <div className="text-center text-sm">
              Бүртгэлтэй юу?{" "}
              <Link to="/login" className="text-primary hover:underline">
                Нэвтрэх
              </Link>
            </div>
          </CardFooter>
        </form>
      </Card>
    </div>
  );
};

export default Signup;