"use client";
import { useRouter } from "next/navigation";
import React, { useState } from "react";
import { register } from "@/lib/server";
import Image from "next/image";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";

const Page = () => {
  const [email, setEmail] = useState("");
  const [username, setUsername] = useState("");
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [password, setPassword] = useState("");
  const router = useRouter();
  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await register(email, username, lastName, firstName, password);
      router.push("/login");
    } catch (error) {
      alert("Register failed");
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
            height: 350,
            marginLeft: 65,
            borderRadius: "8px",
            backgroundColor: "black",
          }}
        >
          <h1 style={{ color: "white", marginLeft: 160, paddingTop: 50 }}>
            Register
          </h1>
          <form onSubmit={handleLogin} style={{ marginLeft: 50 }}>
            <div className="mb-3">
              <Label htmlFor="email" style={{ color: "white" }}>
                Email:
              </Label>
              <Input
                type="text"
                id="email"
                placeholder="Enter your email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
              />
            </div>
            <div className="mb-3" style={{ marginTop: 15 }}>
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

            <div className="mb-3" style={{ marginTop: 15 }}>
              <Label htmlFor="username" style={{ color: "white" }}>
                LastName:
              </Label>
              <Input
                type="text"
                id="lastName"
                placeholder="Enter your lastName"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
                required
              />
            </div>

            <div className="mb-3" style={{ marginTop: 15 }}>
              <Label htmlFor="username" style={{ color: "white" }}>
                FirstName:
              </Label>
              <Input
                type="text"
                id="firstName"
                placeholder="Enter your firstName"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
                required
              />
            </div>

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
            <div
              className="d-grid mb-3"
              style={{ marginTop: 40, marginLeft: 130 }}
            >
              <Button variant="secondary" type="submit">
                Register
              </Button>
            </div>
            <div
              className="text-center mt-3"
              style={{ paddingTop: 10, marginLeft: 80 }}
            >
              <small style={{ color: "white" }}>
                Do you have an account?{" "}
                <a href="/login" style={{ color: "white" }}>
                  Login
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
