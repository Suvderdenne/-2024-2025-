import { useParams, useNavigate } from "react-router-dom";
import { useAuth } from "../contexts/AuthContext";
import { useState, useEffect } from "react";
import { fetchRestaurantDetail, fetchComments, addComment } from "../components/api";
import { Review } from "../types/restaurant";
import { Button } from "../components/ui/button";
import { Card, CardContent } from "../components/ui/card";
import { ArrowLeft, Clock, Phone, Star, StarHalf, ZoomIn, MapPin } from "lucide-react";
import { getPriceRangeString, getStarRating } from "../utils/ratingUtils";
import ReviewItem from "../components/ReviewItem";
import ReviewForm from "../components/ReviewForm";
import { toast } from "sonner";

const RestaurantDetail = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [restaurant, setRestaurant] = useState<any>(null);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);

        const restaurantData = await fetchRestaurantDetail(id!);
        const commentsData = await fetchComments(id!);

        setRestaurant(restaurantData);
        setReviews(Array.isArray(commentsData) ? commentsData : []);
      } catch (err) {
        console.error("Алдаа:", err);
        setError("Өгөгдөл татахад алдаа гарлаа!");
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchData();
    }
  }, [id]);

  const handleReviewSubmit = async (newReview: {
    restaurantId: string;
    rating: number;
    text: string;
    address?: string;
  }) => {
    try {
      const token = localStorage.getItem('authToken');
      if (!token) {
        toast.error("Нэвтэрч орно уу!");
        navigate('/login');
        return;
      }
  
      const response = await fetch(`http://localhost:8000/api/restaurants/${newReview.restaurantId}/comments/`, {
        method: 'POST',
        headers: {
          'Authorization': `Token ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          restaurant: newReview.restaurantId,
          rating: newReview.rating,
          text: newReview.text,
          address: newReview.address || restaurant.address1
        })
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(errorData.error || 'Failed to add comment');
      }

      const addedReview = await response.json();
      setReviews((prev) => [addedReview, ...prev]);
      toast.success("Сэтгэгдэл амжилттай нэмэгдлээ!");
    } catch (err: any) {
      console.error("Сэтгэгдэл нэмэхэд алдаа гарлаа:", err);
      toast.error(err.message || "Сэтгэгдэл нэмэхэд алдаа гарлаа!");
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center h-screen">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="container mx-auto py-10 px-4 text-center">
        <div className="text-red-500 mb-4">{error}</div>
        <Button onClick={() => window.location.reload()}>
          Дахин оролдох
        </Button>
      </div>
    );
  }

  if (!restaurant) {
    return (
      <div className="container mx-auto py-10 px-4 text-center">
        <h2 className="text-2xl font-bold mb-4">Хоолны газар олдсонгүй</h2>
        <Button onClick={() => navigate("/")}>Буцах</Button>
      </div>
    );
  }

  const stars = getStarRating(restaurant.rating || 0);
  const fullStars = Math.max(0, stars.full || 0);
  const halfStar = stars.half || false;
  const emptyStars = Math.max(0, stars.empty || 0);

  return (
    <div className="container mx-auto py-10 px-4">
      <Button
        variant="ghost"
        onClick={() => navigate("/")}
        className="mb-6 flex items-center"
      >
        <ArrowLeft className="mr-2 h-4 w-4" /> Буцах
      </Button>

      <div className="mb-6">
        <h1 className="text-3xl font-bold mb-2">{restaurant.name}</h1>
        <div className="flex items-center mb-4">
          <div className="flex items-center text-amber-500 mr-4">
            {Array(fullStars).fill(0).map((_, i) => (
              <Star key={`full-${i}`} className="h-5 w-5 fill-current" />
            ))}
            {halfStar && <StarHalf className="h-5 w-5 fill-current" />}
            {Array(emptyStars).fill(0).map((_, i) => (
              <Star key={`empty-${i}`} className="h-5 w-5" />
            ))}
            <span className="ml-1 text-black">
              {restaurant.rating ? restaurant.rating.toFixed(1) : "N/A"}
            </span>
          </div>
          <span className="text-muted-foreground">
            {reviews.length} сэтгэгдэл
          </span>
          <span className="mx-2">•</span>
          <span>{restaurant.cuisine}</span>
          <span className="mx-2">•</span>
          <span>{getPriceRangeString(restaurant.priceRange)}</span>
        </div>
        {restaurant.address && <p className="text-muted-foreground">{restaurant.address}</p>}
        
        {restaurant.popular_dishes && (
          <div className="mt-6 mb-6">
            <h2 className="text-xl font-bold mb-2">Хоолны цэсүүд</h2>
            <div className="bg-white p-4 rounded-lg shadow-sm border">
              <p className="text-left text-muted-foreground whitespace-pre-line">
                {restaurant.popular_dishes}
              </p>
            </div>
          </div>
        )}

        <div className="flex flex-wrap gap-4 mt-3">
          {restaurant.phone && (
            <div className="flex items-center text-sm">
              <Phone className="h-4 w-4 mr-2" />
              <span>{restaurant.phone}</span>
            </div>
          )}
          {restaurant.opening_hours && (
            <div className="flex items-center text-sm">
              <Clock className="h-4 w-4 mr-2" />
              <span>{restaurant.opening_hours}</span>
            </div>
          )}
        </div>
      </div>

      {/* Restaurant Images Gallery */}
      <div className="mb-10">
        <h2 className="text-2xl font-bold mb-4">Рестораны зурагнууд</h2>
        {restaurant.additional_images?.length > 0 ? (
          <div className="relative">
            <div className="flex overflow-x-auto pb-4 space-x-4 snap-x snap-mandatory">
              {restaurant.additional_images.map((img: any, index: number) => {
                let imageSrc;
                if (img.image.startsWith('http') || img.image.startsWith('data:')) {
                  imageSrc = img.image;
                } else {
                  const cleanPath = img.image.replace(/^\/+/, '');
                  imageSrc = `http://localhost:8000/media/${cleanPath}`;
                }
                return (
                  <div key={index} className="flex-shrink-0 w-4/5 md:w-1/2 lg:w-1/3 snap-center">
                    <div className="relative group aspect-video rounded-xl overflow-hidden shadow-lg">
                      <img
                        src={imageSrc}
                        alt={`${restaurant.name} - Зураг ${index + 1}`}
                        className="w-full h-full object-cover transition-transform duration-300 group-hover:scale-105"
                        onError={(e) => {
                          const target = e.target as HTMLImageElement;
                          target.src = '/placeholder.svg';
                          target.className = 'w-full h-full object-contain p-4 bg-gray-100';
                        }}
                      />
                      <div className="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-all duration-300 flex items-center justify-center">
                        <ZoomIn className="text-white opacity-0 group-hover:opacity-100 transition-opacity duration-300" size={32} />
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
            <div className="flex justify-center mt-4 space-x-2">
              {restaurant.additional_images.map((_, index) => (
                <button 
                  key={index}
                  className="w-2 h-2 rounded-full bg-gray-300 hover:bg-gray-500 transition-colors"
                  aria-label={`Зураг ${index + 1} руу шилжих`}
                />
              ))}
            </div>
          </div>
        ) : (
          <div className="bg-gray-100 rounded-lg p-8 text-center">
            <p className="text-gray-500">Зураг байхгүй байна</p>
          </div>
        )}
      </div>

      {/* Menu Section */}
      {restaurant.menu && restaurant.menu.length > 0 && (
        <div className="mb-10">
          <h2 className="text-2xl font-bold mb-6">Цэс</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {restaurant.menu.map((item) => (
              <div key={item.id} className="flex gap-4 p-4 bg-white rounded-lg shadow-sm">
                {item.image && (
                  <div className="w-24 h-24 flex-shrink-0">
                    <img
                      src={`data:image/jpeg;base64,${item.image}`}
                      alt={item.name}
                      className="w-full h-full object-cover rounded"
                    />
                  </div>
                )}
                <div className="flex-1">
                  <div className="flex justify-between items-start">
                    <h3 className="font-medium text-lg">{item.name}</h3>
                    <span className="font-semibold">{item.price}₮</span>
                  </div>
                  {item.description && (
                    <p className="text-muted-foreground mt-1">{item.description}</p>
                  )}
                  {item.category && (
                    <span className="inline-block mt-2 px-2 py-1 text-xs bg-gray-100 rounded-full">
                      {item.category}
                    </span>
                  )}
                </div>
              </div>
            ))}
          </div>
        </div>
      )}

      <div className="mb-10">
        <div className="mb-8 p-6 bg-white rounded-lg shadow-sm border">
          <h3 className="text-lg font-medium mb-4">Сэтгэгдэл үлдээх</h3>
          <ReviewForm 
            restaurantId={restaurant.id}
            onReviewSubmit={handleReviewSubmit}
          />
        </div>

        {reviews.length > 0 ? (
          <div className="grid gap-6">
            {reviews.map((review) => (
              <div key={review.id} className="p-6 bg-white rounded-xl shadow-md hover:shadow-lg transition-shadow duration-300">
                <div className="flex items-start gap-4">
                  <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-600">
                    {review.user_name?.charAt(0).toUpperCase() || 'U'}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <span className="font-medium">{review.user_name || 'Unknown'}</span>
                      <span className="text-muted-foreground text-sm">
                        {new Date(review.created_at).toLocaleDateString()}
                      </span>
                    </div>
                    <div className="flex items-center gap-1 mb-2">
                      {Array(5).fill(0).map((_, i) => (
                        <Star 
                          key={i} 
                          className={`h-4 w-4 ${i < review.rating ? 'fill-amber-500 text-amber-500' : 'text-gray-300'}`}
                        />
                      ))}
                    </div>
                    <p className="text-gray-800">{review.text}</p>
                    {review.address && (
                      <p className="text-sm text-gray-500 mt-2">
                        <MapPin className="inline h-3 w-3 mr-1" />
                        {review.address}
                      </p>
                    )}
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="p-6 bg-white rounded-lg shadow-sm border text-center">
            <p className="text-muted-foreground">
              Одоогоор сэтгэгдэл алга байна. Анхны сэтгэгдлийг үлдээгээрэй!
            </p>
          </div>
        )}
      </div>
    </div>
  );
};

export default RestaurantDetail;
