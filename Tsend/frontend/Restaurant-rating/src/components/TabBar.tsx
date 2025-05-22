
import { Link, useLocation } from "react-router-dom";
import { Home, Search, Star, User } from "lucide-react";
import { cn } from "@/lib/utils";

const TabBar = () => {
  const location = useLocation();
  const pathname = location.pathname;
  
  const tabs = [
    {
      name: "Нүүр",
      path: "/",
      icon: Home,
    },
    {
      name: "Миний үнэлгээ",
      path: "/my-reviews",
      icon: Star,
    },
    {
      name: "Профайл",
      path: "/profile",
      icon: User,
    },
  ];
  
  return (
    <div className="fixed bottom-0 left-0 right-0 border-t bg-background z-10">
      <div className="flex justify-around items-center h-16">
        {tabs.map((tab) => {
          const isActive = tab.path === "/" ? pathname === "/" : pathname.startsWith(tab.path);
          return (
            <Link
              key={tab.path}
              to={tab.path}
              className={cn(
                "flex flex-col items-center justify-center w-full h-full",
                isActive ? "text-primary" : "text-muted-foreground"
              )}
            >
              <tab.icon className="h-5 w-5 mb-1" />
              <span className="text-xs">{tab.name}</span>
            </Link>
          );
        })}
      </div>
    </div>
  );
};

export default TabBar;
