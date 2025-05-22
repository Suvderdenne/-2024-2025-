import { Review } from "../types/restaurant";
import { Card, CardContent, CardHeader } from "../components/ui/card";
import StarRating from "./StarRating";
import { formatDistanceToNow, parse } from "date-fns";
import { User } from "lucide-react";

interface ReviewItemProps {
  review: Review;
}

const ReviewItem = ({ review }: ReviewItemProps) => {
  const displayName = review.user?.name || review.userName || "Нэргүй хэрэглэгч";
  const { rating = 0, text = "Сэтгэгдэл байхгүй.", date } = review;

  let timeAgo = "Огноо байхгүй.";
  try {
    if (date) {
      const dateObj = parse(date, "yyyy-MM-dd", new Date());
      timeAgo = formatDistanceToNow(dateObj, { addSuffix: true });
    }
  } catch (error) {
    console.error("Огноог боловсруулахад алдаа гарлаа:", error);
  }

  return (
    <Card className="mb-4">
      <CardHeader className="pb-2">
        <div className="flex justify-between items-center">
          <div className="flex items-center gap-2">
            <div className="h-8 w-8 rounded-full bg-primary/10 flex items-center justify-center">
              <User className="h-4 w-4 text-primary" />
            </div>
            <span className="font-medium">{displayName}</span>
          </div>
          <StarRating initialRating={rating} readOnly size="sm" />
        </div>
      </CardHeader>
      <CardContent>
        <p className="text-sm">{text}</p>
        <p className="text-xs text-muted-foreground mt-2">{timeAgo}</p>
      </CardContent>
    </Card>
  );
};

export default ReviewItem;
