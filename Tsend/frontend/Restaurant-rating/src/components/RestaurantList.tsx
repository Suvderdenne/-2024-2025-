import { useEffect, useState } from "react";
import { fetchRestaurants } from "./api";
import RestaurantCard from "./RestaurantCard";
import { Input } from "./ui/input";
import { Search } from "lucide-react";

interface Restaurant {
  id: string;
  name: string;
  description: string;
  cuisine: string;
  image: string;
  address1: string;
  address2?: string;
  rating: number;
  priceRange: 1 | 2 | 3 | 4;
}

const RestaurantList = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [restaurants, setRestaurants] = useState<Restaurant[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      setError(null);
      try {
        console.log("Initiating search with term:", searchTerm);
        const data = await fetchRestaurants(searchTerm);
        console.log("Search results received:", {
          term: searchTerm,
          count: data.length,
          sample: data.length > 0 ? data[0] : null
        });
        setRestaurants(data);
      } catch (err: any) {
        console.error("API алдаа:", err);
        setError("Өгөгдөл татахад алдаа гарлаа!");
      } finally {
        setLoading(false);
      }
    };

    // Add debounce to prevent too many API calls while typing
    const debounceTimer = setTimeout(() => {
      fetchData();
    }, 300);

    return () => clearTimeout(debounceTimer);
  }, [searchTerm]);

  // Filter restaurants based on search term (client-side fallback)
  const filteredRestaurants = searchTerm 
    ? restaurants.filter(restaurant => 
        restaurant.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (restaurant.address1 && restaurant.address1.toLowerCase().includes(searchTerm.toLowerCase())) ||
        (restaurant.cuisine && restaurant.cuisine.toLowerCase().includes(searchTerm.toLowerCase()))
      )
    : restaurants;

  if (loading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center text-red-500">
        <p>{error}</p>
        <p>Сервертэй холбогдоход алдаа гарлаа. Дахин оролдоно уу.</p>
      </div>
    );
  }

  if (!restaurants || restaurants.length === 0) {
    return (
      <div className="text-center py-10">
        <h3 className="text-lg font-medium">Хоолны газар олдсонгүй!</h3>
        <p className="text-muted-foreground">
          Өгөгдөл татахад алдаа гарсан эсвэл хоосон байна.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Хайлт хийх хэсэг */}
      <div className="relative">
        <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-muted-foreground h-5 w-5" />
        <Input
          type="text"
          placeholder="Хоолны газар эсвэл хоолны төрлөөр хайх..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="pl-10"
        />
      </div>

      {/* Хайлтын үр дүн */}
      {filteredRestaurants.length === 0 && !loading && !error ? (
        <div className="text-center py-10">
          <h3 className="text-lg font-medium">Хайлтын үр дүн олдсонгүй!</h3>
          <p className="text-muted-foreground">
            Таны хайсан түлхүүр үгэнд тохирох хоолны газар олдсонгүй. Өөр түлхүүр үг ашиглан дахин хайж үзнэ үү.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredRestaurants.map((restaurant) => (
            <RestaurantCard key={restaurant.id} restaurant={restaurant} />
          ))}
        </div>
      )}
    </div>
  );
};

export default RestaurantList;