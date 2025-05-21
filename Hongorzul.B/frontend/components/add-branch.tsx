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

export function BranchAdd() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [location, setLocation] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const customerData = { bname: name, blocation: location };

    try {
      const response = await fetch("http://127.0.0.1:8000/add_branch/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          // Include CSRF token if necessary (assuming you're using Django's CSRF protection)
          "X-CSRFToken": getCsrfToken(), // Add logic to retrieve CSRF token
        },
        body: JSON.stringify(customerData),
      });

      const result = await response.json();
      console.log(result, "ujuyghujhy");
      if (response.ok) {
        setSuccessMessage(result.message);
        setName("");
        setLocation("");
        router.push("/branch");
      } else {
        setError(result.error || "Something went wrong.");
      }
    } catch (error) {
      setError("An error occurred while adding the customer.");
    }
  };

  const getCsrfToken = () => {
    const csrfToken = document.cookie.match(/csrftoken=([\w-]+)/);
    return csrfToken ? csrfToken[1] : "";
  };

  return (
    <Card className="w-[350px] ml-96">
      <CardHeader>
        <CardTitle>Салбар нэмэх</CardTitle>
        <CardDescription>
          Салбарын дэлгэрэнгүй мэдээллийг доор оруулна уу.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit}>
          <div className="grid w-full items-center gap-4">
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="Name">Салбарын нэр</Label>
              <Input
                id="Name"
                placeholder="Салбарын нэрээ оруулна уу"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </div>
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="location">Байрлал</Label>
              <Input
                id="location"
                placeholder="Хаягаа дэлгэрэнгүй оруулна уу"
                value={location}
                onChange={(e) => setLocation(e.target.value)}
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
            <Button variant="outline">Буцах</Button>
            <Button type="submit">Хадгалах</Button>
          </CardFooter>
        </form>
      </CardContent>
    </Card>
  );
}
