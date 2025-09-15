"use client"


import { useRouter } from "next/navigation";
import Script from "next/script";
import { useEffect } from "react";
import { useRef, useState } from "react";
import { Button, Spinner } from "react-bootstrap";

const NEXT_PUBLIC_FACEBOOK_CLIENT_ID = process.env.NEXT_PUBLIC_FACEBOOK_APP_ID!;
const PUBLIC_API_BASE = process.env.NEXT_PUBLIC_API_BASE!;


export default function FacebookButton() {
    const btnRef = useRef<HTMLDivElement | null>(null);
    const router = useRouter();
    const [ready, setReady] = useState(false);
    const [loading, setLoading] = useState(false);
    const [err, setErr] = useState<string | null>(null);

    useEffect(() => {
        if (typeof window === "undefined") return;
        if (window.FB) { setReady(true); return; }
        window.fbAsyncInit = function () {
            window.FB.init({
                appId: NEXT_PUBLIC_FACEBOOK_CLIENT_ID,
                cookie: true,
                xfbml: false,
                version: "v23.0"
            })
        }
        setReady(true);

    })
    const onSubmit = async () => {
        if (!ready || !window.FB) return;
        setLoading(true); setErr(null);

        window.FB.login(async (response: any) => {
            try {
                const accessToken = response.authResponse.accessToken as string;
                if (!accessToken) { setErr("Login canceled"); setLoading(false); return; }

                console.log("Access token", accessToken);

                const upstream = await fetch(`${PUBLIC_API_BASE}/api/auth/login-facebook`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    credentials: "include",
                    body: JSON.stringify({ accessToken })
                })
                const res: LoginResponse = await upstream.json();
                if (!upstream.ok || !res.isSuccess) {
                    setErr(res?.message || "Login facebook failed");
                    setLoading(false);
                    return;
                }
                router.replace('/dashboard')
            }
            catch (e: any) {
                setErr(e?.message);
            }

        }
            , { scope: "email", return_scoopes: true }

        )
    }

    return (
        <>

            <Script src="https://connect.facebook.net/en_US/sdk.js"
                strategy="afterInteractive"
                onLoad={() => {
                    window.FB.fbAsyncInit = function () {
                        window.FB.init({
                            appId: NEXT_PUBLIC_FACEBOOK_CLIENT_ID,
                            cookie: true,
                            xfbml: false,
                            version: "v23.0"
                        })
                        setReady(true)
                    };
                }}
            >
            </Script>
            <div className="flex flex-col items-center gap-3 border mt-2 rounded">
                <Button
                    className="btn-facebook d-flex align-items-center justify-content-center gap-2 w-100"
                    onClick={onSubmit}
                    disabled={!ready || loading}
                    aria-label="Continue with Facebook"
                    aria-busy={loading}
                >
                    <span>{loading ? "Connecting…" : "Continue with Facebook"}</span>
                </Button>
                {!!err && <div className="text-red-600 text-sm">{err}</div>}
            </div>

        </>


    )
}