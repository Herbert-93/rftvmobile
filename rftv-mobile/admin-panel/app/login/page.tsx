"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "@/lib/firebase";

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      const cred = await signInWithEmailAndPassword(auth, email, password);
      const tokenResult = await cred.user.getIdTokenResult(true);
      if (!tokenResult.claims.admin) {
        await auth.signOut();
        setError(
          "This account doesn't have admin access yet. Run the set-admin script against this email, then try again."
        );
        setLoading(false);
        return;
      }
      router.push("/dashboard");
    } catch (err: any) {
      setError(err.message || "Could not sign in");
      setLoading(false);
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center px-4">
      <form onSubmit={handleSubmit} className="w-full max-w-sm bg-white rounded-2xl shadow-lg p-8 border border-line">
        <div className="text-center mb-6">
          <div className="font-sora font-extrabold text-2xl text-navy">
            RF<span className="text-sky">tv</span>
          </div>
          <div className="font-inter text-xs tracking-widest text-slate mt-1">ADMIN PANEL</div>
        </div>

        <label className="block text-sm font-semibold text-navy mb-1">Email</label>
        <input
          type="email"
          required
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full border border-line rounded-xl px-3 py-2 mb-4 outline-none focus:border-sky"
          placeholder="you@rftv.com"
        />

        <label className="block text-sm font-semibold text-navy mb-1">Password</label>
        <input
          type="password"
          required
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          className="w-full border border-line rounded-xl px-3 py-2 mb-4 outline-none focus:border-sky"
          placeholder="••••••••"
        />

        {error && <p className="text-ember text-sm mb-4">{error}</p>}

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-navy text-white font-sora font-bold rounded-xl py-3 disabled:opacity-60"
        >
          {loading ? "Signing in…" : "Log in"}
        </button>
      </form>
    </div>
  );
}
