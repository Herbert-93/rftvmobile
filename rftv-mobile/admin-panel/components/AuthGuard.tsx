"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { onAuthStateChanged, User } from "firebase/auth";
import { auth } from "@/lib/firebase";

export default function AuthGuard({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const [user, setUser] = useState<User | null | undefined>(undefined);

  useEffect(() => {
    return onAuthStateChanged(auth, async (u) => {
      if (!u) {
        setUser(null);
        router.replace("/login");
        return;
      }
      const token = await u.getIdTokenResult();
      if (!token.claims.admin) {
        setUser(null);
        router.replace("/login");
        return;
      }
      setUser(u);
    });
  }, [router]);

  if (user === undefined) {
    return <div className="min-h-screen flex items-center justify-center text-slate font-inter">Loading…</div>;
  }
  if (!user) return null;

  return <>{children}</>;
}
