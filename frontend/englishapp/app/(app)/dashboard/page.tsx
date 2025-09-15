"use client"

import { useRouter } from "next/navigation";
import React, { useState } from "react";
import { ReactFormState } from "react-dom/client";

const PUBLIC_API_BASE = process.env.NEXT_PUBLIC_API_BASE!;


export default function DashboardPage() {
    const [isLoading, setIsLoading] = useState<boolean>(false);
    const [error, setError] = useState<string | null>(null);
    const router = useRouter();

    const onLogout = async () => {

        setIsLoading(true);
        setError(null);
        try {
            const upstream = await fetch(`${PUBLIC_API_BASE}/api/auth/logout`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                credentials: "include"
            });

            const data: LoginResponse = await upstream.json();
            if (!upstream.ok || !data.isSuccess) {
                setError(upstream.statusText ?? data?.message);
                return;
            }
            router.push("/login")
        }
        catch (e: any) {
            console.log(e.message);
        }
        finally {
            setIsLoading(false);
        }
    }


    return (
        <div>
            Dashboard

            <button className="flex border rounded-lg mt-2 text-sm" onClick={() => onLogout()}>Logout</button>
        </div>
    )
}