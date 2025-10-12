"use client";

import { FetchHelper } from "@/app/lib/auth-client";
import { useRouter } from "next/navigation";
import { useState } from "react";

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
        credentials: "include",
      });

      const data: LoginResponse = await upstream.json();
      if (!upstream.ok || !data.isSuccess) {
        setError(upstream.statusText ?? data?.message);
        return;
      }
      router.push("/login");
    } catch (e: any) {
      console.log(e.message);
    } finally {
      setIsLoading(false);
    }
  };

  const onGetMe = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const upstream = await FetchHelper(`api/auth/me`, {
        method: "GET",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
      });

      const data: LoginResponse = await upstream.json();
      if (!upstream.ok || !data.isSuccess) {
        setError(upstream.statusText ?? data?.message);
        return;
      }
      console.log(data);
    } catch (e: any) {
      console.log(e.message);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div>
      Dashboard
      <button
        className="flex border rounded-lg mt-2 text-sm"
        onClick={() => onLogout()}
      >
        Logout
      </button>
      <button
        className="flex border rounded-lg mt-2 text-sm"
        onClick={() => onGetMe()}
      >
        Me
      </button>
    </div>
  );
}
