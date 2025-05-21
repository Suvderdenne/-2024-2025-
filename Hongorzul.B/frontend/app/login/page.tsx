"use client";

import { useRouter } from "next/navigation";
import React, { useState } from "react";
import { login } from "@/lib/server"; // Adjust this path according to your project structure
import Image from "next/image";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";

const Page = () => {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const router = useRouter();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await login(username, password); // Replace with your API call or logic
      router.push("/"); // Redirect to the homepage after successful login
    } catch (error) {
      alert("Login failed. Please check your credentials.");
    }
  };

  return (
    <div style={{ display: "flex", marginLeft: 100 }}>
      <div style={{ flex: 1 }}>
        <Image
          src="/how-to-create-a-work-plan-e1706711984544.png" // Relative to the public folder
          alt="Description of the image"
          width={800} // Desired width
          height={700} // Desired height
        />
      </div>
      <div
        style={{
          alignItems: "center",
          justifyContent: "center",
          backgroundColor: "#f4f4f5",
          flex: 1,
          marginLeft: 100,
          alignContent: "center",
        }}
      >
        <div
          className="card shadow-lg p-4 bg-white"
          style={{
            maxWidth: "400px",
            width: "100%",
            height: 300,
            marginLeft: 65,
            borderRadius: "8px",
            backgroundColor: "black",
          }}
        >
          <h1 style={{ color: "white", marginLeft: 160, paddingTop: 50 }}>
            Login
          </h1>
          <form onSubmit={handleLogin} style={{ marginLeft: 50 }}>
            {/* Username Input */}
            <div className="mb-3">
              <Label htmlFor="username" style={{ color: "white" }}>
                Username:
              </Label>
              <Input
                type="text"
                id="username"
                placeholder="Enter your username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </div>

            {/* Password Input */}
            <div className="mb-3" style={{ marginTop: 15 }}>
              <Label htmlFor="password" style={{ color: "white" }}>
                Password:
              </Label>
              <Input
                type="password"
                id="password"
                placeholder="Enter your password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>

            {/* Submit Button */}
            <div
              className="d-grid mb-3"
              style={{ marginTop: 40, marginLeft: 130 }}
            >
              <Button variant="secondary" type="submit">
                Login
              </Button>
            </div>

            {/* Link to Register */}
            <div
              className="text-center mt-3"
              style={{ paddingTop: 10, marginLeft: 50 }}
            >
              <small style={{ color: "white" }}>
                Don't have an account?{" "}
                <a href="/register" style={{ color: "white" }}>
                  Register here
                </a>
              </small>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Page;
