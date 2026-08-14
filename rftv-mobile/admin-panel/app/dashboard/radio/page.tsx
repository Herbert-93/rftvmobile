"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

export default function RadioPage() {
  const [form, setForm] = useState({ isLive: false, headline: "", message: "", launchLabel: "", streamUrl: "" });
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    (async () => {
      try {
        const data = await api.get("/radio");
        setForm({ ...form, ...data });
      } catch (err: any) {
        setError(err.message);
      } finally {
        setLoading(false);
      }
    })();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setError(null);
    setSaved(false);
    try {
      await api.put("/radio", form);
      setSaved(true);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div>
      <h1 className="font-sora font-extrabold text-2xl text-navy mb-1">RF Radio</h1>
      <p className="font-inter text-sm text-slate mb-6">Controls what the mobile app's Radio tab shows.</p>

      {error && <p className="text-ember mb-4">{error}</p>}
      {loading ? (
        <p className="text-slate font-inter">Loading…</p>
      ) : (
        <form onSubmit={handleSubmit} className="bg-white border border-line rounded-2xl p-6 max-w-xl space-y-4">
          <label className="flex items-center gap-2 text-sm font-inter text-navy">
            <input
              type="checkbox"
              checked={form.isLive}
              onChange={(e) => setForm({ ...form, isLive: e.target.checked })}
            />
            Radio is live (turns off the "coming soon" screen)
          </label>

          <div>
            <label className="block text-xs font-semibold text-slate mb-1">Headline</label>
            <input
              value={form.headline}
              onChange={(e) => setForm({ ...form, headline: e.target.value })}
              className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate mb-1">Message</label>
            <textarea
              value={form.message}
              onChange={(e) => setForm({ ...form, message: e.target.value })}
              rows={3}
              className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate mb-1">Launch label</label>
            <input
              value={form.launchLabel}
              onChange={(e) => setForm({ ...form, launchLabel: e.target.value })}
              placeholder="Launching Q4 2026"
              className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            />
          </div>

          <div>
            <label className="block text-xs font-semibold text-slate mb-1">Stream URL (once live)</label>
            <input
              value={form.streamUrl}
              onChange={(e) => setForm({ ...form, streamUrl: e.target.value })}
              placeholder="https://stream.rftv.com/radio"
              className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            />
          </div>

          <button type="submit" disabled={saving} className="bg-navy text-white font-sora font-bold rounded-lg px-4 py-2 text-sm">
            {saving ? "Saving…" : "Save"}
          </button>
          {saved && <span className="text-sky text-sm ml-3">Saved.</span>}
        </form>
      )}
    </div>
  );
}
