"use client";

import {
  Card,
  CardHeader,
  CardContent,
  CardTitle,
  CardDescription
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Separator } from "@/components/ui/separator";
import { FcGoogle } from "react-icons/fc";
import { FaGithub } from "react-icons/fa";
import { TriangleAlert } from "lucide-react";
import Link from "next/link";
import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { toast } from "sonner";

const SignUp = () => {
  const [form, setForm] = useState({
    lastname: "",
    firstname: "",
    phone: "",
    email: "",
    password: "",
    confirmPassword: "",
  });

  const [pending, setPending] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setPending(true);

    const res = await fetch("/api/auth/signup", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(form),
    });

    const data = await res.json();

    if (res.ok) {
      setPending(false);
      toast.success(data.message);
      router.push("/sign-in");
    } else {
      setError(data.message || "Something went wrong");
      setPending(false);
    }
  };

  return (
    <div className="flex items-center justify-center min-h-screen bg-muted px-4">
      <Card className="w-full max-w-md shadow-lg rounded-2xl">
        <CardHeader className="space-y-1 text-center">
          <CardTitle className="text-2xl font-semibold">БҮРТГҮҮЛЭХ</CardTitle>
          
        </CardHeader>
        <CardContent className="space-y-4">
          {!!error && (
            <div className="bg-red-100 text-red-700 p-3 rounded-md flex items-center gap-2 text-sm">
              <TriangleAlert className="w-4 h-4" />
              <span>{error}</span>
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-3">
            <div className="grid grid-cols-2 gap-3">
              <Input
                type="text"
                placeholder="Овог"
                value={form.firstname}
                onChange={(e) => setForm({ ...form, firstname: e.target.value })}
                disabled={pending}
                required
              />
              <Input
                type="text"
                placeholder="Нэр"
                value={form.lastname}
                onChange={(e) => setForm({ ...form, lastname: e.target.value })}
                disabled={pending}
                required
              />
            </div>
            <Input
              type="text"
              placeholder="Утасны дугаар"
              value={form.phone}
              onChange={(e) => setForm({ ...form, phone: e.target.value })}
              disabled={pending}
              required
            />
            <Input
              type="email"
              placeholder="И-мэйл"
              value={form.email}
              onChange={(e) => setForm({ ...form, email: e.target.value })}
              disabled={pending}
              required
            />
            <Input
              type="password"
              placeholder="Нууц үг"
              value={form.password}
              onChange={(e) => setForm({ ...form, password: e.target.value })}
              disabled={pending}
              required
            />
            <Input
              type="password"
              placeholder="Нууц үгээ батлах"
              value={form.confirmPassword}
              onChange={(e) => setForm({ ...form, confirmPassword: e.target.value })}
              disabled={pending}
              required
            />
            <Button className="w-full" type="submit" disabled={pending}>
              {pending ? "Creating account..." : "Бүргүүлэх"}
            </Button>
          </form>

          <Separator />

          <p className="text-sm text-center text-muted-foreground mt-2">
            Та бүртгэлтэй юу?{" "}
            <Link href="/sign-in" className="text-blue-600 hover:underline">
              Нэвтрэх
            </Link>
          </p>
        </CardContent>
      </Card>
    </div>
  );
};

export default SignUp;
