import Cookies from "js-cookie";
import { User } from "@/app/(root)/customer/columns";
import { Branch } from "@/app/(root)/branch/columns";
import { Role } from "@/app/(root)/role/columns";
import { Worker } from "@/app/(root)/worker/columns";
import { Service } from "@/app/(root)/service/columns";
import { CalendarType } from "@/app/(root)/calendar/columns";

export async function login(username: string, password: string) {
    const res = await fetch("http://localhost:8000/login/", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            username,
            password,
        }),
    });

    if (res.ok) {
        const data = await res.json();
        Cookies.set("accessToken", data.access);
        Cookies.set("refreshToken", data.refresh);

        return data;
    } else {
        throw new Error("login failed");
    }
}

export function logout() {
    Cookies.remove("accessToken");
    Cookies.remove("refreshToken");
}

export async function register(email: string, username: string, firstName: string, lastName: string, password: string) {
    const res = await fetch("http://localhost:8000/register/", {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            email,
            username,
            password,
            first_name: firstName,
            last_name: lastName,
        }),
    });

    if (res.ok) {
        console.log("gvgh");
    } else {
        throw new Error("register failed");
    }
}

export async function fetchCustomers(): Promise<User[]> {
    const response = await fetch("http://localhost:8000/customer/"); // Adjust the endpoint if necessary
    if (!response.ok) {
        throw new Error("Failed to fetch customers");
    }

    return response.json();
}

export async function fetchBranchs(): Promise<Branch[]> {
    const response = await fetch("http://localhost:8000/branch/"); // Adjust the endpoint if necessary
    if (!response.ok) {
        throw new Error("Failed to fetch customers");
    }

    return response.json();
}

export async function fetchRoles(): Promise<Role[]> {
    const response = await fetch("http://localhost:8000/role/"); // Adjust the endpoint if necessary
    if (!response.ok) {
        throw new Error("Failed to fetch roles");
    }

    return response.json();
}

export async function fetchCalendars({ worker, branch }: { worker?: string; branch?: string }): Promise<CalendarType[]> {
    // Construct the query string based on the provided parameters
    const params = new URLSearchParams();
    if (worker) {
        params.append("worker", worker);
    }
    if (branch) {
        params.append("branch", branch);
    }

    // Include the query string in the API URL
    const url = `http://localhost:8000/calendar-events/?${params.toString()}`;

    const response = await fetch(url); // Adjust the endpoint if necessary
    if (!response.ok) {
        throw new Error("Failed to fetch calendars");
    }

    return response.json();
}

export async function fetchWorkers(): Promise<Worker[]> {
    const response = await fetch("http://localhost:8000/worker/"); // Adjust the endpoint if necessary
    if (!response.ok) {
        throw new Error("Failed to fetch workers");
    }

    return response.json();
}

export async function fetchServices(): Promise<Service[]> {
    const response = await fetch("http://localhost:8000/service/"); // Adjust the endpoint if necessary
    if (!response.ok) {
        throw new Error("Failed to fetch services");
    }

    return response.json();
}

export async function fetchDeleteService(serviceId: string): Promise<void> {
    const response = await fetch(`http://127.0.0.1:8000/delete_service/${serviceId}/`, {
        method: "DELETE",
    });

    if (!response.ok) {
        throw new Error(`Failed to delete service with ID: ${serviceId}`);
    }
}
