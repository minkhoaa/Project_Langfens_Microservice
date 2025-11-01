let accessToken: string | null = null;
let refreshPromise: Promise<void> | null = null;

export function setAccessToken(t: string | null) { accessToken = t; }
export function getAccessToken() { return accessToken; }

const API_BASE = process.env.NEXT_PUBLIC_API_BASE;


export function RefreshAccessToken() {
    if (!refreshPromise) {
        refreshPromise = fetch(`${API_BASE}/api/auth/refresh`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            credentials: "include"
        })
            .then(async (res) => {
                const data: LoginResponse = await res.json();
                if (!res.ok || !data?.isSuccess) {
                    throw new Error(data?.message || "Refresh failed");
                }
                setAccessToken(data?.data);
            })
            .finally(() => { refreshPromise = null; });
    }
    return refreshPromise!;
}


export async function FetchHelper(path: string, init: RequestInit = {}) {
    const doFetch = async () => {
        const headers = new Headers(init.headers || {});
        console.log(init.credentials);
        headers.set("Authorization", `Bearer ${accessToken}`);
        console.log(getAccessToken());
        return fetch(`${API_BASE}/${path}`, {
            ...init,
            headers: headers,
            credentials: init.credentials ?? "include"
        }
        );
    };
    // Proactively refresh if we don't have an access token yet (dev)
    if (!accessToken) {
        try { await RefreshAccessToken(); } catch { }
    }
    let res = await doFetch();
    console.log(res);
    if (res.status === 401) {
        try {
            await RefreshAccessToken();
        }
        catch (e: any) {
            console.log(e?.message)
        }
        res = await doFetch();
    }

    return res;


}
