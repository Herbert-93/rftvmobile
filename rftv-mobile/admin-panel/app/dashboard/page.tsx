"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

function Card({ label, value }: { label: string; value: string | number }) {
  return (
    <div className="bg-white rounded-2xl border border-line p-5 shadow-sm">
      <div className="font-sora font-extrabold text-2xl text-navy">{value}</div>
      <div className="font-inter text-sm text-slate mt-1">{label}</div>
    </div>
  );
}

export default function OverviewPage() {
  const [stats, setStats] = useState({ channels: 0, programs: 0, users: 0, donations: 0 });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    (async () => {
      try {
        const [channels, programs, users, donations] = await Promise.all([
          api.get("/channels"),
          api.get("/programs"),
          api.get("/users"),
          api.get("/donations"),
        ]);
        setStats({
          channels: channels.length,
          programs: programs.length,
          users: users.length,
          donations: donations.length,
        });
      } catch (err: any) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  return (
    <div>
      <h1 className="font-sora font-extrabold text-2xl text-navy mb-1">Overview</h1>
      <p className="font-inter text-sm text-slate mb-6">A snapshot of what's live on RF TV Mobile.</p>

      {error && <p className="text-ember mb-4">{error}</p>}
      {loading ? (
        <p className="text-slate font-inter">Loading…</p>
      ) : (
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <Card label="Channels" value={stats.channels} />
          <Card label="Scheduled programs" value={stats.programs} />
          <Card label="Registered users" value={stats.users} />
          <Card label="Donation records" value={stats.donations} />
        </div>
      )}
    </div>
  );
}
