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
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

export function ServiceAdd() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [price, setPrice] = useState("");
  const [duration, setDuration] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const customerData = { sname: name, sprice: price, sduration: duration };

    try {
      const response = await fetch("http://127.0.0.1:8000/add_service/", {
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
        setPrice("");
        setDuration("");
        router.push("/service");
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
        <CardTitle>Үйлчилгээ нэмэх</CardTitle>
        <CardDescription>
          Үйлчилгээний дэлгэрэнгүй мэдээллийг доор оруулна уу.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit}>
          <div className="grid w-full items-center gap-4">
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="sname">Үйлчилгээний нэр</Label>
              <Input
                id="sname"
                placeholder="Үйлчилгээний нэрээ оруулна уу"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
            </div>
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="sprice">Үнэ</Label>
              <Input
                id="sprice"
                placeholder="Үнэ оруулна уу"
                value={price}
                onChange={(e) => {
                  const inputValue = e.target.value;
                  // Allow only digits and an optional decimal point
                  if (/^\d*\.?\d*$/.test(inputValue)) {
                    setPrice(inputValue);
                  }
                }}
              />
            </div>
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="sduration">Хугацаа</Label>
              <Select value={duration} onValueChange={setDuration}>
                <SelectTrigger id="sduration" className="w-[300px]">
                  <SelectValue placeholder="Хугацаагаа оруулна уу" />
                </SelectTrigger>
                <SelectContent>
                  <SelectGroup>
                    <SelectItem value="30min">30min</SelectItem>
                    <SelectItem value="1hr">1hr</SelectItem>
                    <SelectItem value="1hr 30min">1hr 30min</SelectItem>
                    <SelectItem value="2hr">2hr</SelectItem>
                  </SelectGroup>
                </SelectContent>
              </Select>
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
