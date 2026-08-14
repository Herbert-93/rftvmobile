"use client";

import { auth } from "./firebase";

const RAW_API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:4000";
// Strips any trailing slash so "https://host.com/" + "/channels" doesn't
// become "https://host.com//channels" (a 404 on the server).
const API_URL = RAW_API_URL.replace(/\/+$/, "");

async function authHeaders() {
  const user = auth.currentUser;
  if (!user) throw new Error("Not signed in");
  const token = await user.getIdToken();
  return { Authorization: `Bearer ${token}`, "Content-Type": "application/json" };
}

async function handle(res: Response) {
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new Error(body.error || `Request failed (${res.status})`);
  }
  return res.status === 204 ? null : res.json();
}

export const api = {
  get: async (path: string) => handle(await fetch(`${API_URL}${path}`, { headers: await authHeaders() })),
  post: async (path: string, body: unknown) =>
    handle(await fetch(`${API_URL}${path}`, { method: "POST", headers: await authHeaders(), body: JSON.stringify(body) })),
  put: async (path: string, body: unknown) =>
    handle(await fetch(`${API_URL}${path}`, { method: "PUT", headers: await authHeaders(), body: JSON.stringify(body) })),
  delete: async (path: string) =>
    handle(await fetch(`${API_URL}${path}`, { method: "DELETE", headers: await authHeaders() })),
};