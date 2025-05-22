import React, { useEffect, useState } from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "@/contexts/AuthContext";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Settings, LogOut, Star, Clock, Heart } from "lucide-react";
import { toast } from "sonner";

const API_BASE_URL = "http://127.0.0.1:8000/api";

const Profile = () => {
  const { user, logout } = useAuth();
  const [stats, setStats] = useState<null | { ratings: number; visits: number; favorites: number }>(null);

  const token = localStorage.getItem("authToken");
  if (!token) {
    console.error("Токен байхгүй байна. Хэрэглэгчийг login хуудас руу чиглүүлж байна.");
    return <Navigate to="/login" replace />;
  }

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const token = localStorage.getItem("authToken");
        if (!token) return;

        const response = await fetch(`${API_BASE_URL}/stats/`, {
          headers: { Authorization: `Token ${token}` },
        });

        if (response.ok) {
          const data = await response.json();
          setStats(data);
        } else {
          toast.error('Статистикийг татаж чадсангүй');
        }
      } catch (error) {
        toast.error('Статистик татахад алдаа гарлаа');
      }
    };
    fetchStats();
  }, []);

  const handleLogout = () => {
    logout();
  };

  if (!stats) {
    return <div>Ачааллаж байна...</div>;
  }

  return (
    <div
      className="min-h-screen bg-cover bg-center relative"
      style={{
        backgroundImage:
          "url('https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=1400&q=80')",
      }}
    >
      {/* Overlay for dark effect */}
      <div className="absolute inset-0 bg-black bg-opacity-50 backdrop-blur-sm z-0" />

      {/* Profile Content */}
      <div className="relative z-10 container max-w-md mx-auto py-12 px-4 text-white">
        <div className="flex flex-col items-center mb-8">
          <Avatar className="h-24 w-24 mb-4 border-4 border-white shadow-md">
            <AvatarImage src={user?.avatar || "https://github.com/shadcn.png"} alt={user?.name || "User"} />
            <AvatarFallback>{user?.name?.slice(0, 2).toUpperCase() || "NA"}</AvatarFallback>
          </Avatar>
          <h1 className="text-3xl font-bold">{user?.name || "Нэргүй хэрэглэгч"}</h1>
          <p className="text-sm opacity-80">{user?.email || "Имэйл байхгүй"}</p>
        </div>

        <div className="space-y-4 mb-8">
          <Card className="bg-white bg-opacity-90 shadow-xl backdrop-blur-sm">
            <CardHeader className="pb-2">
              <CardTitle className="text-gray-800">Статистик</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid grid-cols-3 gap-4 text-center text-gray-800">
                <div>
                  <Star className="h-5 w-5 mx-auto mb-1 text-yellow-500" />
                  <p className="font-bold">{stats.ratings}</p>
                  <p className="text-xs text-muted-foreground">Үнэлгээ</p>
                </div>
                <div>
                  <Clock className="h-5 w-5 mx-auto mb-1 text-blue-500" />
                  <p className="font-bold">{stats.visits}</p>
                  <p className="text-xs text-muted-foreground">Зочилсон</p>
                </div>
                <div>
                  <Heart className="h-5 w-5 mx-auto mb-1 text-red-500" />
                  <p className="font-bold">{stats.favorites}</p>
                  <p className="text-xs text-muted-foreground">Дуртай</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>

        <div className="space-y-3">
          <Button variant="secondary" className="w-full justify-start bg-white bg-opacity-80 text-gray-900 hover:bg-opacity-100">
            <Settings className="mr-2 h-4 w-4" />
            Тохиргоо
          </Button>
          <Button
            variant="secondary"
            className="w-full justify-start bg-white bg-opacity-80 text-red-600 hover:text-red-700"
            onClick={handleLogout}
          >
            <LogOut className="mr-2 h-4 w-4" />
            Гарах
          </Button>
        </div>
      </div>
    </div>
  );
};

export default Profile;
