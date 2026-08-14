"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

type AppUser = { uid: string; name?: string; email?: string; phone?: string; isAdmin?: boolean; createdAt?: string };

export default function UsersPage() {
  const [users, setUsers] = useState<AppUser[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        setUsers(await api.get("/users"));
      } catch (err: any) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  return (
    <div>
      <h1 className="font-sora font-extrabold text-2xl text-navy mb-1">Users</h1>
      <p className="font-inter text-sm text-slate mb-6">
        Everyone who has signed in to the RF TV Mobile app. To make someone an admin, run the{" "}
        <code className="bg-cream2 px-1.5 py-0.5 rounded">npm run set-admin</code> script in the backend with their email.
      </p>

      {error && <p className="text-ember mb-4">{error}</p>}

      {loading ? (
        <p className="text-slate font-inter">Loading…</p>
      ) : (
        <table className="w-full bg-white border border-line rounded-2xl overflow-hidden text-sm">
          <thead className="bg-cream2 text-left text-slate font-inter">
            <tr>
              <th className="p-3">Name</th>
              <th className="p-3">Email</th>
              <th className="p-3">Phone</th>
              <th className="p-3">Admin</th>
              <th className="p-3">Joined</th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) => (
              <tr key={u.uid} className="border-t border-line">
                <td className="p-3 font-semibold text-navy">{u.name || "—"}</td>
                <td className="p-3 text-slate">{u.email || "—"}</td>
                <td className="p-3 text-slate">{u.phone || "—"}</td>
                <td className="p-3">{u.isAdmin ? "Yes" : "No"}</td>
                <td className="p-3 text-slate">{u.createdAt ? new Date(u.createdAt).toLocaleDateString() : "—"}</td>
              </tr>
            ))}
            {users.length === 0 && (
              <tr>
                <td colSpan={5} className="p-6 text-center text-slate">No users yet.</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}
