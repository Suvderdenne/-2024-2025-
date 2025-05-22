import { useEffect, useState } from "react";
import { useAuth } from "../contexts/AuthContext";
import { Button } from "../components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "../components/ui/card";
import { Star } from "lucide-react";
import { useNavigate } from "react-router-dom";
import { toast } from "sonner";
import { format } from "date-fns";
import { Restaurant } from "../types/restaurant";

interface Review {
  id: number;
  restaurant: Restaurant;
  restaurant_name?: string;
  restaurant_image?: string;
  rating: number;
  text: string;
  created_at: string;
}

const MyReviews = () => {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchReviews = async () => {
      try {
        const token = localStorage.getItem('authToken');
        if (!token) {
          toast.error("Нэвтэрч орно уу!");
          navigate('/login');
          return;
        }

        const response = await fetch('http://localhost:8000/api/reviews/my/', {
          headers: {
            'Authorization': `Token ${token}`
          }
        });

        if (!response.ok) {
          throw new Error('Failed to fetch reviews');
        }

        const { data } = await response.json();
        console.log('API response data:', data); // Debug log
        setReviews(data || []);
      } catch (error) {
        toast.error("Үнэлгээ авахад алдаа гарлаа");
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    if (user) {
      fetchReviews();
    }
  }, [user, navigate]);

  if (loading) {
    return <div className="flex justify-center py-8">Ачаалж байна...</div>;
  }

  if (reviews.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-8">
        <h2 className="text-xl font-semibold mb-4">Таны үнэлгээ олдсонгүй</h2>
        <Button onClick={() => navigate('/restaurants')}>
          Ресторан үнэлэх
        </Button> 
      </div>
    );
  }

  return (
    <div className="container py-8">
      <h1 className="text-2xl font-bold mb-6">Миний үнэлгээ</h1>
      <div className="grid gap-4">
        {reviews.map((review) => (
          <Card key={review.id} className="group relative overflow-hidden rounded-2xl shadow-lg border border-gray-200 h-72 transition-all duration-300 hover:shadow-xl">
            {/* Background image with gradient overlay */}
            <div className="absolute inset-0">
              {review.restaurant?.image || review.restaurant_image ? (
                <img
                  src={
                    review.restaurant?.image?.startsWith('http')
                      ? review.restaurant.image
                      : review.restaurant?.image
                        ? `http://localhost:8000${review.restaurant.image.startsWith('/') ? '' : '/'}${review.restaurant.image}`
                        : review.restaurant_image?.startsWith('http')
                          ? review.restaurant_image
                          : `http://localhost:8000${review.restaurant_image?.startsWith('/') ? '' : '/'}${review.restaurant_image}`
                  }
                  alt={review.restaurant_name || review.restaurant?.name}
                  className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-105"
                  onError={(e) => {
                    e.currentTarget.onerror = null;
                    e.currentTarget.src = '';
                    e.currentTarget.parentElement?.classList.add('bg-gradient-to-br', 'from-amber-500', 'to-red-600');
                  }}
                />
              ) : (
                <div className="absolute inset-0 bg-gradient-to-br from-amber-500 to-red-600"></div>
              )}
              
              {/* Dark overlay with blur */}
              <div className="absolute inset-0 bg-gradient-to-t from-black/80 via-black/50 to-black/30 backdrop-blur-[1px]"></div>
            </div>

            {/* Review content */}
            <div className="relative h-full flex flex-col justify-end p-6 z-10">
              <CardHeader className="p-0">
                <div className="flex justify-between items-start">
                  <CardTitle className="text-white text-xl font-bold">
                    {review.restaurant_name || review.restaurant?.name}
                  </CardTitle>
                  <div className="flex items-center bg-white/20 backdrop-blur-sm rounded-full px-3 py-1">
                    {[...Array(5)].map((_, i) => (
                      <Star
                        key={i}
                        className={`h-4 w-4 ${i < review.rating ? 'fill-amber-300 text-amber-300' : 'text-gray-400'}`}
                      />
                    ))}
                    <span className="ml-1 text-sm font-bold text-white">
                      {review.rating.toFixed(1)}
                    </span>
                  </div>
                </div>
                <div className="text-sm text-amber-100 mt-1">
                  {format(new Date(review.created_at), 'yyyy-MM-dd HH:mm')}
                </div>
              </CardHeader>
              
              <CardContent className="p-0 pt-4">
                <div className="bg-white/10 backdrop-blur-sm rounded-lg p-4">
                  <p className="text-white line-clamp-3 text-sm leading-relaxed">
                    {review.text}
                  </p>
                </div>
              </CardContent>
            </div>
          </Card>
        
        ))}
      </div>
    </div>
  );
};

export default MyReviews;
