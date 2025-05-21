// columns.tsx or wherever the columns are defined
import { ColumnDef } from "@tanstack/react-table";
import { MoreHorizontal, ArrowUpDown } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { fetchDeleteService } from "@/lib/server";

export type Service = {
  service_id: string; // service_id is a string
  sname: string;
  sprice: string;
  sduration: string;
  lastSeen: string;
};

const handleDelete = async (serviceId: string) => {
  try {
    await fetchDeleteService(serviceId); // Pass the serviceId as string
    // Optionally, trigger a refresh or update state after deletion
  } catch (error) {
    console.error("Failed to delete service:", error);
    // Optionally handle the error (e.g., show a toast notification)
  }
};

export const columns: ColumnDef<Service>[] = [
  {
    accessorKey: "sname",
    header: ({ column }) => (
      <Button
        variant="ghost"
        onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
      >
        Name
        <ArrowUpDown className="ml-2 h-4 w-4" />
      </Button>
    ),
  },
  {
    accessorKey: "sprice",
    header: "Price",
  },
  {
    accessorKey: "sduration",
    header: "Duration",
  },
  {
    accessorKey: "lastSeen",
    header: "Last seen",
    cell: ({ row }) => {
      const date = new Date(row.getValue("lastSeen"));
      const formatted = date.toLocaleDateString();
      return <div className="font-medium">{formatted}</div>;
    },
  },
  {
    id: "actions",
    cell: ({ row }) => {
      const service = row.original;

      return (
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button variant="ghost" className="h-8 w-8 p-0">
              <span className="sr-only">Open menu</span>
              <MoreHorizontal className="h-4 w-4" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem>Edit</DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem onClick={() => handleDelete(service.service_id)}>
              Delete
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      );
    },
  },
];
