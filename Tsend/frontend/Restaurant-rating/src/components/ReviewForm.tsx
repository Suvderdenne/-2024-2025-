import { useEffect, useState } from "react";
import { Button } from "../components/ui/button";
import { Textarea } from "../components/ui/textarea";
import { Label } from "../components/ui/label";
import { Input } from "../components/ui/input";
import StarRating from "./StarRating";
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "../components/ui/card";
import { toast } from "sonner";
import { Loader2 } from "lucide-react";

interface Restaurant {
  id: string;
  name: string;
  image: string;
  description: string;
  location: string;  // Changed from address to location
}

interface ReviewFormProps {
  restaurantId: string;
  onReviewSubmit: (review: {
    restaurantId: string;
    rating: number;
    text: string;
    address?: string;
  }) => void;
}

const ReviewForm = ({ restaurantId, onReviewSubmit }: ReviewFormProps) => {
  const [rating, setRating] = useState(5);
  const [comment, setComment] = useState("");
  const [address, setAddress] = useState("");
  const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchRestaurant = async () => {
      try {
        setLoading(true);
        setError(null);
        const response = await fetch(`http://localhost:8000/api/restaurants/${restaurantId}/`);
        if (!response.ok) {
          throw new Error("Failed to fetch restaurant");
        }
        const data = await response.json();
        setRestaurant(data);
      } catch (error) {
        setError("Рестораны мэдээлэл авахад алдаа гарлаа");
        toast.error("Рестораны мэдээлэл авахад алдаа гарлаа");
      } finally {
        setLoading(false);
      }
    };

    if (restaurantId) {
      fetchRestaurant();
    }
  }, [restaurantId]);

  const resetForm = () => {
    setRating(5);
    setComment("");
    setAddress("");
  };

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
  
    if (!restaurantId) {
      toast.error("Рестораны ID олдсонгүй!");
      setSubmitting(false);
      return;
    }
  
    if (rating <= 0) {
      toast.error("Үнэлгээгээ сонгоно уу");
      setSubmitting(false);
      return;
    }
  
    if (!comment.trim()) {
      toast.error("Сэтгэгдлээ оруулна уу");
      setSubmitting(false);
      return;
    }
  
    try {
      await onReviewSubmit({
        restaurantId,
        rating,
        text: comment,
        address: restaurant?.location || address,
      });
      resetForm();
      toast.success("Таны сэтгэгдэл амжилттай нэмэгдлээ!");
    } catch (error) {
      toast.error("Сэтгэгдэл нэмэхэд алдаа гарлаа");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return <p>Ачааллаж байна...</p>;
  }

  return (
    <Card className="shadow-xl rounded-2xl border border-gray-200 bg-white">
      {restaurant && (
        <CardHeader className="flex items-center gap-4 bg-gray-100 rounded-t-2xl px-6 py-4">
          <img
            src={restaurant.image}
            alt={restaurant.name}
            className="w-16 h-16 rounded-full object-cover border"
          />
          <div>
            <CardTitle className="text-lg font-semibold text-gray-800">
              {restaurant.name}
            </CardTitle>
            <p className="text-sm text-gray-600">{restaurant.description}</p>
          </div>
        </CardHeader>
      )}

      <form onSubmit={handleSubmit}>
        <CardContent className="space-y-5 px-6 py-4">
          <div className="space-y-1">
            <Label>Үнэлгээ</Label>
            <StarRating initialRating={rating} onChange={setRating} size="lg" />
            {rating <= 0 && <p className="text-red-500 text-xs">Үнэлгээгээ сонгоно уу</p>}
          </div>

          <div className="space-y-1">
            <Label>Хаяг</Label>
            {restaurant?.location ? (
              <p className="text-sm text-gray-600">{restaurant.location}</p>
            ) : (
              <Input
                value={address}
                onChange={(e) => setAddress(e.target.value)}
                placeholder="Хаягаа оруулна уу..."
                className="w-full"
              />
            )}
          </div>

          <div className="space-y-1">
            <Label htmlFor="comment">Сэтгэгдэл</Label>
            <Textarea
              id="comment"
              value={comment}
              onChange={(e) => setComment(e.target.value)}
              placeholder="Хоолны газрын талаар сэтгэгдлээ бичнэ үү..."
              rows={4}
              className="w-full rounded-md border px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            {!comment.trim() && <p className="text-red-500 text-xs">Сэтгэгдлээ оруулна уу</p>}
          </div>
        </CardContent>

        <CardFooter className="px-6 py-4">
          <Button
            type="submit"
            disabled={!comment.trim() || rating <= 0 || submitting}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 rounded-md"
          >
            {submitting ? (
              <Loader2 className="h-4 w-4 animate-spin" />
            ) : (
              "Сэтгэгдэл нэмэх"
            )}
          </Button>
        </CardFooter>
      </form>
    </Card>
  );
};

export default ReviewForm;
