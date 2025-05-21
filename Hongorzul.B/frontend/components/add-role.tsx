"use client";
import * as React from "react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useRouter } from "next/navigation";

export function RoleAdd() {
  const router = useRouter();
  const [roleName, setRoleName] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const roleData = { role_name: roleName };

    try {
      const response = await fetch("http://127.0.0.1:8000/add_role/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRFToken": getCsrfToken(), // Include CSRF token if necessary
        },
        body: JSON.stringify(roleData),
      });

      const result = await response.json();

      if (response.ok) {
        setSuccessMessage(result.message);
        setRoleName(""); // Reset the form
        setError(null);
        router.push("/role"); // Navigate to roles page
      } else {
        setError(result.error || "Something went wrong.");
        setSuccessMessage(null);
      }
    } catch (err) {
      setError("An error occurred while adding the role.");
      setSuccessMessage(null);
    }
  };

  const getCsrfToken = () => {
    const csrfToken = document.cookie.match(/csrftoken=([\w-]+)/);
    return csrfToken ? csrfToken[1] : "";
  };

  return (
    <Card className="w-[350px] ml-96">
      <CardHeader>
        <CardTitle>Албан тушаал нэмэх</CardTitle>
        <CardDescription>
          Албан тушаалын дэлгэрэнгүй мэдээллийг доор оруулна уу.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit}>
          <div className="grid w-full items-center gap-4">
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="roleName">Албан тушаалын нэр</Label>
              <Input
                id="roleName"
                placeholder="Албан тушаалын нэрээ оруулна уу"
                value={roleName}
                onChange={(e) => setRoleName(e.target.value)}
              />
            </div>
            {error && <div className="text-red-500">{error}</div>}
            {successMessage && (
              <div className="text-green-500">{successMessage}</div>
            )}
          </div>
          <CardFooter
            className="flex justify-between"
            style={{ paddingTop: 20 }}
          >
            <Button variant="outline" onClick={() => router.push("/role")}>
              Буцах
            </Button>
            <Button type="submit">Хадгалах</Button>
          </CardFooter>
        </form>
      </CardContent>
    </Card>
  );
}
