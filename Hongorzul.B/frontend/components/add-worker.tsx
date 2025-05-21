"use client";
import * as React from "react";
import { useState, useEffect } from "react";
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
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";

interface Branch {
  branch_id: number; // Adjust the field names according to your API response
  bname: string;
}

export async function fetchBranchs(): Promise<Branch[]> {
  const response = await fetch("http://localhost:8000/branch/"); // Adjust the endpoint if necessary
  if (!response.ok) {
    throw new Error("Failed to fetch branches");
  }

  return response.json();
}

interface Role {
  role_id: number; // Adjust field names based on your API response
  role_name: string;
}

export async function fetchRoles(): Promise<Role[]> {
  const response = await fetch("http://localhost:8000/role/"); // Adjust endpoint if necessary
  if (!response.ok) {
    throw new Error("Failed to fetch roles");
  }

  return response.json();
}

export function WorkerAdd() {
  const router = useRouter();
  const [firstName, setFirstName] = useState("");
  const [lastName, setLastName] = useState("");
  const [phone, setPhone] = useState("");
  const [roleId, setRoleId] = useState("");
  const [branchId, setBranchId] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);
  const [branches, setBranches] = useState<Branch[]>([]);
  const [selectedBranch, setSelectedBranch] = useState<string | null>(null);
  const [roles, setRoles] = useState<Role[]>([]);
  const [selectedRole, setSelectedRole] = useState<string>("");

  useEffect(() => {
    // Fetch roles on component mount
    fetchRoles()
      .then((data) => setRoles(data))
      .catch((error) => console.error("Error fetching roles:", error));
  }, []);

  useEffect(() => {
    async function getBranches() {
      try {
        const branchData = await fetchBranchs();
        setBranches(branchData);
      } catch (error) {
        console.error(error);
      }
    }

    getBranches();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    const workerData = {
      wfirst: firstName,
      wname: lastName,
      wphone: phone,
      role_id: roleId,
      branch_id: branchId,
    };

    try {
      const response = await fetch("http://127.0.0.1:8000/add_worker/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRFToken": getCsrfToken(),
        },
        body: JSON.stringify(workerData),
      });

      const result = await response.json();
      if (response.ok) {
        setSuccessMessage(result.message);
        setFirstName("");
        setLastName("");
        setPhone("");
        setRoleId("");
        setBranchId("");
        router.push("/worker");
      } else {
        setError(result.error || "Something went wrong.");
      }
    } catch (error) {
      setError("An error occurred while adding the worker.");
    }
  };

  const getCsrfToken = () => {
    const csrfToken = document.cookie.match(/csrftoken=([\w-]+)/);
    return csrfToken ? csrfToken[1] : "";
  };

  return (
    <Card className="w-[350px] ml-96">
      <CardHeader>
        <CardTitle>Ажилтан нэмэх</CardTitle>
        <CardDescription>
          Ажилтаны дэлгэрэнгүй мэдээллийг доор оруулна уу.
        </CardDescription>
      </CardHeader>
      <CardContent>
        <form onSubmit={handleSubmit}>
          <div className="grid w-full items-center gap-4">
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="firstName">Овог</Label>
              <Input
                id="firstName"
                placeholder="Овогоо оруулна уу"
                value={firstName}
                onChange={(e) => setFirstName(e.target.value)}
              />
            </div>
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="lastName">Нэр</Label>
              <Input
                id="lastName"
                placeholder="Нэрээ оруулна уу"
                value={lastName}
                onChange={(e) => setLastName(e.target.value)}
              />
            </div>
            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="phone">Утасны дугаар</Label>
              <Input
                id="phone"
                placeholder="Утасны дугаараа оруулна уу"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
              />
            </div>

            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="role">Албан тушаал</Label>
              <Select onValueChange={(value) => setRoleId(value)}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Албан тушаалаа сонгоно уу" />
                </SelectTrigger>
                <SelectContent>
                  {roles.map((role) => (
                    <SelectItem key={role.role_id} value={String(role.role_id)}>
                      {role.role_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="flex flex-col space-y-1.5">
              <Label htmlFor="branchId">Салбар</Label>
              <Select onValueChange={(value) => setBranchId(value)}>
                <SelectTrigger className="w-[180px]">
                  <SelectValue placeholder="Салбар сонгох" />
                </SelectTrigger>
                <SelectContent>
                  {branches.map((branch) => (
                    <SelectItem
                      key={branch.branch_id}
                      value={String(branch.branch_id)}
                    >
                      {branch.bname}
                    </SelectItem>
                  ))}
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
