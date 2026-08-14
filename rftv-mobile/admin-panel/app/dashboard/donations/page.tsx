"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

type PaymentMethod = { id: string; name: string; sub: string; color: string; enabled: boolean };
type DonationRecord = { id: string; userId: string; amount: number; currency: string; paymentMethod: string; status: string; createdAt: string };

export default function DonationsPage() {
  const [presetAmounts, setPresetAmounts] = useState<number[]>([]);
  const [methods, setMethods] = useState<PaymentMethod[]>([]);
  const [records, setRecords] = useState<DonationRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);

  async function load() {
    setLoading(true);
    try {
      const [config, all] = await Promise.all([api.get("/donations/config"), api.get("/donations")]);
      setPresetAmounts(config.presetAmounts || []);
      setMethods(config.paymentMethods || []);
      setRecords(all);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setSaved(false);
    setError(null);
    try {
      await api.put("/donations/config", { presetAmounts, currency: "UGX", paymentMethods: methods });
      setSaved(true);
    } catch (err: any) {
      setError(err.message);
    } finally {
      setSaving(false);
    }
  }

  return (
    <div>
      <h1 className="font-sora font-extrabold text-2xl text-navy mb-1">Donations</h1>
      <p className="font-inter text-sm text-slate mb-6">Amounts and payment methods offered in the Donate screen.</p>

      {error && <p className="text-ember mb-4">{error}</p>}

      {loading ? (
        <p className="text-slate font-inter">Loading…</p>
      ) : (
        <>
          <form onSubmit={handleSave} className="bg-white border border-line rounded-2xl p-6 max-w-2xl space-y-5 mb-8">
            <div>
              <label className="block text-xs font-semibold text-slate mb-1">Preset amounts (UGX, comma separated)</label>
              <input
                value={presetAmounts.join(", ")}
                onChange={(e) =>
                  setPresetAmounts(
                    e.target.value
                      .split(",")
                      .map((s) => Number(s.trim()))
                      .filter((n) => !Number.isNaN(n))
                  )
                }
                className="w-full border border-line rounded-lg px-3 py-2 text-sm"
              />
            </div>

            <div className="space-y-3">
              <label className="block text-xs font-semibold text-slate">Payment methods</label>
              {methods.map((m, i) => (
                <div key={m.id} className="flex items-center gap-3 border border-line rounded-lg p-3">
                  <input
                    type="checkbox"
                    checked={m.enabled}
                    onChange={(e) => {
                      const next = [...methods];
                      next[i] = { ...m, enabled: e.target.checked };
                      setMethods(next);
                    }}
                  />
                  <div className="flex-1">
                    <div className="font-sora font-bold text-sm text-navy">{m.name}</div>
                    <div className="text-xs text-slate">{m.sub}</div>
                  </div>
                </div>
              ))}
            </div>

            <button type="submit" disabled={saving} className="bg-navy text-white font-sora font-bold rounded-lg px-4 py-2 text-sm">
              {saving ? "Saving…" : "Save"}
            </button>
            {saved && <span className="text-sky text-sm ml-3">Saved.</span>}
          </form>

          <h2 className="font-sora font-bold text-lg text-navy mb-3">Recent donation records</h2>
          <table className="w-full bg-white border border-line rounded-2xl overflow-hidden text-sm">
            <thead className="bg-cream2 text-left text-slate font-inter">
              <tr>
                <th className="p-3">Amount</th>
                <th className="p-3">Method</th>
                <th className="p-3">Status</th>
                <th className="p-3">Date</th>
              </tr>
            </thead>
            <tbody>
              {records.map((r) => (
                <tr key={r.id} className="border-t border-line">
                  <td className="p-3 font-semibold text-navy">{r.currency} {r.amount.toLocaleString()}</td>
                  <td className="p-3 text-slate">{r.paymentMethod}</td>
                  <td className="p-3 text-slate capitalize">{r.status}</td>
                  <td className="p-3 text-slate">{new Date(r.createdAt).toLocaleString()}</td>
                </tr>
              ))}
              {records.length === 0 && (
                <tr>
                  <td colSpan={4} className="p-6 text-center text-slate">No donations recorded yet.</td>
                </tr>
              )}
            </tbody>
          </table>
        </>
      )}
    </div>
  );
}
