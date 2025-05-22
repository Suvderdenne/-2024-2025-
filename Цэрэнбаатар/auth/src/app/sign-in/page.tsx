"use client";

import {
  Card,
  CardHeader,
  CardContent,
  CardTitle,
  CardDescription,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { TriangleAlert } from "lucide-react";
import { FcGoogle } from "react-icons/fc";
import { FaGithub } from "react-icons/fa";

import Link from "next/link";
import { signIn } from "next-auth/react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";
import React, { useState } from "react";

const SignIn = () => {
  const [email, setEmail] = useState<string>("");
  const [password, setPassword] = useState<string>("");
  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string>("");
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setPending(true);
    const res = await signIn("credentials", {
      redirect: false,
      email,
      password,
    });

    if (res?.ok) {
      toast.success("Login successful");
      router.push("/");
    } else if (res?.status === 401) {
      setError("Invalid credentials");
      setPending(false);
    } else {
      setError("Something went wrong");
      setPending(false);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-muted px-4">
      <Card className="w-full max-w-md shadow-lg rounded-2xl">
        <CardHeader className="text-center space-y-1">
          <CardTitle className="text-2xl font-semibold">НЭВТРЭХ</CardTitle>
          
        </CardHeader>
        <CardContent className="space-y-4">
          {!!error && (
            <div className="bg-red-100 text-red-700 p-3 rounded-md flex items-center gap-2 text-sm">
              <TriangleAlert className="w-4 h-4" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-3">
            <Input
              type="И-мэйл"
              placeholder="И-мэйл"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              disabled={pending}
              required
            />
            <Input
              type="password"
              placeholder="Нууц үг"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              disabled={pending}
              required
            />
            <Button className="w-full" type="submit" disabled={pending}>
              {pending ? "Signing in..." : "Нэвтрэх"}
            </Button>
          </form>

          <Separator />

          <p className="text-sm text-center text-muted-foreground mt-4">
            {"Та бүртгэл үүсгээгүй бол "}
            <Link href="/sign-up" className="text-blue-600 hover:underline">
              Бүртгүүлнэ үү
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
};

export default SignIn;
