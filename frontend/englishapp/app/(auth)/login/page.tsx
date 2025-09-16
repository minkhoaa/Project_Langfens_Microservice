"use client"

import FacebookButton from "@/app/components/facebook-button";
import GoogleButton from "@/app/components/google-button";
import { useRouter } from "next/navigation";
import React, { useState } from "react"
import { setAccessToken } from "@/app/lib/auth-client";
import { Button, Card, Container, Form } from "react-bootstrap"

const API_BASE = process.env.NEXT_PUBLIC_API_BASE;
if (!API_BASE) console.log("Missing NEXT_PUBLIC_API_BASE");

type LoginSchema = { email: string, password: string };
type LoginResponse = { isSuccess: boolean, message: string, data: any }

export default function LoginPage() {
    const [data, setData] = useState<LoginSchema>({ email: "", password: "" })
    const [isLoading, setIsLoading] = useState<boolean>(false);
    const [error, setError] = useState<string | null>(null);
    const router = useRouter();

    async function obSumbit(e: React.FormEvent<HTMLFormElement>) {

        e.preventDefault();
        setIsLoading(true);
        setError(null);
        try {
            const upstream = await fetch(`/api/auth/login`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify(data),
                credentials: "include"
            })
            console.log("upstream", upstream)
            const response: LoginResponse = await upstream.json();

            console.log("data", response)
            if (!upstream.ok || !response?.isSuccess) {
                setError(response?.message || "Login failed");
                return;
            }
            // Lưu access token vào bộ nhớ tạm để call API ngay
            setAccessToken(response.data);
            router.replace("/dashboard");
        }
        catch (e: any) {
            setError(e?.message)
        }
        finally {
            setIsLoading(false)
        }
    }
    return (
        <div className="min-vh-100 d-flex align-items-center justify-content-center bg-light">
            <Container >
                <Card className="shadow-sm border-0 rounded-4 mx-auto max-w-110">
                    <Card.Body className="p-4 p-md-5 max-w-2xl" >
                        <h1 className="fs-4 fw-semibold text-center mb-4">Login</h1>
                        <Form onSubmit={obSumbit} noValidate>
                            <Form.Group className="mb-3">
                                <Form.Label>
                                    Email
                                </Form.Label>
                                <Form.Control type="email"
                                    required
                                    placeholder="you@example.com"
                                    value={data.email}
                                    onChange={(e) => setData((f) => ({ ...f, email: e.target.value }))}
                                    autoComplete="email"
                                >
                                </Form.Control>
                            </Form.Group>
                            <Form.Group>
                                <Form.Label>
                                    Password
                                </Form.Label>
                                <Form.Control type="password"
                                    required
                                    placeholder="***"
                                    value={data.password}
                                    onChange={(e) => setData((f) => ({ ...f, password: e.target.value }))}
                                >

                                </Form.Control>
                            </Form.Group>
                            <Form.Group>
                                <Button className="mt-3" type="submit" disabled={isLoading}>
                                    {isLoading ? (<div>Logging</div>) : (<div>Log in</div>)}
                                </Button>
                                {!!error && <div className="text-red-600 mt-2">{error}</div>}
                            </Form.Group>
                            <Form.Group>
                                <div className="mt-3">
                                    <GoogleButton />



                                    {/* yêu cầu https cho đăng nhập facebook */}
                                    <FacebookButton />
                                </div>
                            </Form.Group>
                        </Form>
                    </Card.Body>
                </Card>
            </Container>


        </div>
    )
}
