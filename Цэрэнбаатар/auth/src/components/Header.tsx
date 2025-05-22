"use client"; // This marks it as a client component

import { SessionProvider } from "next-auth/react";
import UserButton from "@/components/user-button";

export default function Header() {
  return (
    <SessionProvider>
      <UserButton />
    </SessionProvider>
  );
}
