import { ok } from "assert";
import { error } from "console";
import { NextRequest, NextResponse } from "next/server";

type LoginSchema = { email: string, password: string };
type LoginResponse = { isSuccess: boolean, message: string, data: string }
const URL_API: string = process.env.NEXT_PUBLIC_API_BASE!;

export async function POST(req: Request) {
    try {
        const { email, password } = await req.json();
        if (!email || !password) return NextResponse.json({ ok: false, error: "Email or password is missing" })
        const upstream = await fetch(URL_API, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ email, password })
        });

        if (!upstream.ok) return NextResponse.json({ ok: false, error: "Failed while signing up" });

        const data: LoginResponse = await upstream.json();

        const result = NextResponse.json({ ok: true });
        const token: string = data?.data as string;
        console.log(token);
        result.cookies.set("auth", token, {
            httpOnly: true,
            sameSite: 'lax',
            secure: process.env.NODE_ENV === "production",
            path: "/",
            maxAge: 60 * 60 * 24 * 7,

        })
        return result;

    }
    catch (e: any) {
        return NextResponse.json({ ok: false, error: `${e?.message}?? "Failed" ` })
    }
}