import { NextRequest, NextResponse } from "next/server";

export function middleware(req: NextRequest) {
    const { pathname, search } = req.nextUrl;
    if (
        req.method === "OPTIONS" ||               // preflight CORS
        pathname.startsWith("/api") ||            // route API
        pathname.startsWith("/_next") ||          // static next
        pathname.startsWith("/favicon") ||
        pathname === "/sitemap.xml" ||
        pathname === "/robots.txt" ||
        pathname.startsWith("/login") ||
        pathname.startsWith("/register") ||
        pathname.startsWith("/forgot-password")
    ) {
        return NextResponse.next();
    }

    const refresh_token = req.cookies.get(`refresh_token`)?.value;

    if (refresh_token) {

        NextResponse.next();

    }
    const loginUrl = new URL('/login', req.url);
    loginUrl.searchParams.set("next", pathname + search);
    return NextResponse.redirect(loginUrl);
}