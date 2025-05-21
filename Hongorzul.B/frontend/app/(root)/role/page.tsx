"use client";
import React, { useEffect, useState } from "react";
import { DataTable } from "@/components/data-table-customer";
import { Role, columns } from "./columns";
import { fetchRoles } from "@/lib/server"; // Adjust the import path
import { Button } from "@/components/ui/button"; // Assuming Button component is located in this path
import Link from "next/link"; // Correct import for Link from Next.js

const RolesTable = () => {
  const [data, setData] = useState<Role[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const loadData = async () => {
      try {
        const role = await fetchRoles();
        setData(role);
      } catch (err) {
        setError(err instanceof Error ? err.message : "An error occurred");
      } finally {
        setLoading(false);
      }
    };

    loadData();
  }, []);

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error}</div>;

  return (
    <section className="py-24">
      <div className="container ml-32 w-[1000px]">
        {/* Set width to 800px */}
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-3xl font-bold">Албан тушаал</h1>
          <Link href="addRole">
            {" "}
            {/* Add the link target here */}
            <Button>Албан тушаал нэмэх</Button>
          </Link>
        </div>
        <DataTable columns={columns} data={data} />
      </div>
    </section>
  );
};

export default RolesTable;
