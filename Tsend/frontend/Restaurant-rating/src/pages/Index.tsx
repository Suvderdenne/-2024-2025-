import RestaurantList from "@/components/RestaurantList";

const Index = () => {
  return (
    <div className="min-h-screen relative overflow-hidden">
      {/* Food background with overlay */}
      <div className="absolute inset-0 z-0">
        <div className="absolute inset-0 bg-black/50"></div> {/* Dark overlay for readability */}
        <div 
          className="absolute inset-0 bg-cover bg-center bg-no-repeat" 
          style={{ 
            backgroundImage: "url('https://images.unsplash.com/photo-1512621776951-a57141f2eefd?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2000&q=80')",
            filter: "blur(1px)"
          }}
        ></div>
        
        {/* Floating food particles */}
        <div className="particles">
          {[...Array(12)].map((_, i) => (
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
          <h1 className="text-3xl md:text-4xl font-bold mb-2 text-white drop-shadow-lg">
            Хоолны газруудын үнэлгээ
          </h1>
          <p className="text-lg text-white/90 drop-shadow-md">
            Шилдэг хоолны газруудыг олж үнэлгээ өгөөрэй
          </p>
        </div>
        <div className="bg-black/20 backdrop-blur-sm rounded-xl p-6 border border-white/10 shadow-xl animate-scale-in">
          <RestaurantList />
        </div>
      </div>
    </div>
  );
};

export default Index;
