import { useState } from "react";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { restaurants } from "@/data/mockData";
import RestaurantCard from "@/components/RestaurantCard";

const Ratings = () => {
  const [activeTab, setActiveTab] = useState("all");
  
  // In a real app, these would be fetched from an API with user data
  const recentlyRated = restaurants.slice(0, 3);
  const favorites = restaurants.slice(3, 6);
  
  return (
    <div className="min-h-screen relative overflow-hidden">
      {/* Food background with overlay */}
      <div className="absolute inset-0 z-0">
        <div className="absolute inset-0 bg-black/50"></div> {/* Dark overlay for readability */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat" 
          style={{ 
            backgroundImage: "url('https://images.unsplash.com/photo-1543353071-10c8ba85a904?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80')",
            filter: "blur(1px)"
          }}
        ></div>
        
        {/* Floating food particles */}
        <div className="particles">
          {[...Array(10)].map((_, i) => (
            <div 
              key={i} 
              className="particle bg-white rounded-full absolute opacity-30"
              style={{
                top: `${Math.random() * 100}%`,
                left: `${Math.random() * 100}%`,
                width: `${Math.random() * 6 + 2}px`,
                height: `${Math.random() * 6 + 2}px`,
                animationDuration: `${Math.random() * 10 + 5}s`,
                animationDelay: `${Math.random() * 5}s`
              }}
            ></div>
          ))}
        </div>
      </div>

      <div className="container mx-auto py-8 px-4 relative z-10">
        <div className="mb-8 text-center animate-fade-in">
          <h1 className="text-3xl md:text-4xl font-bold mb-2 text-white drop-shadow-lg">Миний үнэлгээнүүд</h1>
          <p className="text-lg text-white/90 drop-shadow-md">
            Таны үнэлсэн хоолны газрууд
          </p>
        </div>
        
        <div className="bg-black/20 backdrop-blur-sm rounded-xl p-6 border border-white/10 shadow-xl animate-scale-in">
          <Tabs defaultValue="all" className="w-full max-w-3xl mx-auto">
            <TabsList className="grid w-full grid-cols-3 mb-6 bg-black/30 border border-white/10">
              <TabsTrigger 
                value="all" 
                onClick={() => setActiveTab("all")}
                className="text-white data-[state=active]:bg-white/20"
              >
                Бүгд
              </TabsTrigger>
              <TabsTrigger 
                value="recent" 
                onClick={() => setActiveTab("recent")}
                className="text-white data-[state=active]:bg-white/20"
              >
                Сүүлийн үеийн
              </TabsTrigger>
              <TabsTrigger 
                value="favorites" 
                onClick={() => setActiveTab("favorites")}
                className="text-white data-[state=active]:bg-white/20"
              >
                Дуртай
              </TabsTrigger>
            </TabsList>
            
            <TabsContent value="all">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {restaurants.slice(0, 6).map((restaurant) => (
                  <RestaurantCard key={restaurant.id} restaurant={restaurant} />
                ))}
              </div>
            </TabsContent>
            
            <TabsContent value="recent">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {recentlyRated.map((restaurant) => (
                  <RestaurantCard key={restaurant.id} restaurant={restaurant} />
                ))}
              </div>
            </TabsContent>
            
            <TabsContent value="favorites">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {favorites.map((restaurant) => (
                  <RestaurantCard key={restaurant.id} restaurant={restaurant} />
                ))}
              </div>
            </TabsContent>
          </Tabs>
        </div>
      </div>
    </div>
  );
};

export default Ratings;
