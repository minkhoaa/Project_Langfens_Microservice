
"use client"
import { read } from "fs";
import { useRouter } from "next/navigation";
import Script from "next/script";
import { useEffect, useRef, useState } from "react";
import { setAccessToken } from "@/app/lib/auth-client";
import { any } from "zod";

const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID!;
const PUBLIC_API_BASE = process.env.NEXT_PUBLIC_API_BASE!;


type LoginResponse = { isSuccess: boolean, message: string, data: any }

export default function GoogleButton() {

    const router = useRouter();
    const btnRef = useRef<HTMLDivElement>(null);
    const [ready, setReady] = useState(false);
    const [loading, setLoading] = useState(false);
    const [err, setErr] = useState<string | null>(null);
    useEffect(() => {
        if (!ready || !window.google) return;

        window.google.accounts.id.initialize({
            client_id: clientId,
            ux_mode: "popup",
            auto_select: false,
            itp_support: true,
            callback: async ({ credential }: any) => {
                try {
                    console.log("Credentail", credential)
                    setLoading(true);
                    setErr(null);
                    const res = await fetch(`/api/auth/login-google`, {
                        method: "POST",
                        headers: { "Content-Type": "application/json" },
                        credentials: "include",
                        body: JSON.stringify({ idToken: credential })
                    })

                    const response: LoginResponse = await res.json();
                    if (!res.ok || !response.isSuccess) {
                        console.log(response);
                        return;
                    }
                    // Lưu access token để dùng ngay
                    setAccessToken(response.data);
                    router.replace("/dashboard");
                }
                catch (e: any) {
                    setErr(e.message ?? "Login failed");
                }
                finally {
                    setLoading(false);
                }
            }
        });

        if (btnRef.current) {
            window.google.accounts.id.renderButton(btnRef.current, {
                type: "standard",
                theme: "outline",
                size: "large",
                width: 320
            });
            console.log()
        }
    }, [ready])

    return (

        <>
            <Script
                src="https://accounts.google.com/gsi/client"
                strategy="afterInteractive"
                onLoad={() => setReady(true)}

            >
            </Script>

            <div className="flex flex-col items-center gap-3">
                <div ref={btnRef}>
                    {loading && <p> Loading</p>}
                    {err && <p className="text-red-600 text-sm">{err}</p>}
                </div>
            </div>
        </>
    )
}
