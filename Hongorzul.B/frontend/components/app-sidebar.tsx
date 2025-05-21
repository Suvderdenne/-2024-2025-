"use client";
import {
  Calendar,
  Settings,
  User,
  Users,
  MapPin,
  Award, // Role icon
  Clipboard, // Service icon
} from "lucide-react";

import {
  Sidebar,
  SidebarContent,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from "@/components/ui/sidebar";
import { useRouter } from "next/navigation";
import { logout } from "@/lib/server";
import { Button } from "@/components/ui/button";

const items = [
  {
    title: "Төлөвлөгөө",
    url: "calendar",
    icon: Calendar,
  },
  {
    title: "Үйлчлүүлэгч",
    url: "customer",
    icon: User,
  },
  {
    title: "Ажилтан",
    url: "worker",
    icon: Users,
  },
  {
    title: "Салбар",
    url: "branch",
    icon: MapPin,
  },
  {
    title: "Албан тушаал",
    url: "role",
    icon: Award,
  },
  {
    title: "Үйлчилгээ",
    url: "service",
    icon: Clipboard,
  },
  {
    title: "Тохиргоо",
    url: "#",
    icon: Settings,
  },
];

export function AppSidebar() {
  const router = useRouter();
  const handleLogout = () => {
    logout();
    router.push("/login");
  };
  return (
    <Sidebar>
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupLabel>Application</SidebarGroupLabel>
          <SidebarGroupContent>
            <SidebarMenu>
              {items.map((item) => (
                <SidebarMenuItem key={item.title}>
                  <SidebarMenuButton asChild>
                    <a href={item.url}>
                      <item.icon />
                      <span>{item.title}</span>
                    </a>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
              <SidebarMenuItem>
                <SidebarMenuButton asChild>
                  <Button onClick={handleLogout}>Гарах</Button>
                </SidebarMenuButton>
              </SidebarMenuItem>
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>
    </Sidebar>
  );
}
