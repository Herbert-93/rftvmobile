"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

type Channel = {
  id: string;
  name: string;
  category: string;
  isLive: boolean;
  order: number;
  viewerCount?: number;
};

const CATEGORIES = ["All", "News", "Series", "Faith", "Kids", "Sports"];

const emptyForm = { name: "", category: "News", isLive: false, order: 1 };

export default function ChannelsPage() {
  const [channels, setChannels] = useState<Channel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState<any>(emptyForm);
  const [editingId, setEditingId] = useState<string | null>(null);

  async function load() {
    setLoading(true);
    try {
      setChannels(await api.get("/channels"));
    } catch (err: any) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    load();
  }, []);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);
    try {
      if (editingId) {
        await api.put(`/channels/${editingId}`, form);
      } else {
        await api.post("/channels", form);
      }
      setForm(emptyForm);
      setEditingId(null);
      load();
    } catch (err: any) {
      setError(err.message);
    }
  }

  function startEdit(c: Channel) {
    setEditingId(c.id);
    setForm({ name: c.name, category: c.category, isLive: c.isLive, order: c.order });
  }

  async function remove(id: string) {
    if (!confirm("Delete this channel?")) return;
    try {
      await api.delete(`/channels/${id}`);
      load();
    } catch (err: any) {
      setError(err.message);
    }
  }

  return (
    <div>
      <h1 className="font-sora font-extrabold text-2xl text-navy mb-1">Channels</h1>
      <p className="font-inter text-sm text-slate mb-6">Channels shown on the Home and Live TV screens.</p>

      {error && <p className="text-ember mb-4">{error}</p>}

      <form onSubmit={handleSubmit} className="bg-white border border-line rounded-2xl p-5 mb-8 grid grid-cols-2 md:grid-cols-5 gap-3 items-end">
        <div className="col-span-2">
          <label className="block text-xs font-semibold text-slate mb-1">Name</label>
          <input
            required
            value={form.name}
            onChange={(e) => setForm({ ...form, name: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            placeholder="RF TV1"
          />
        </div>
        <div>
          <label className="block text-xs font-semibold text-slate mb-1">Category</label>
          <select
            value={form.category}
            onChange={(e) => setForm({ ...form, category: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
          >
            {CATEGORIES.map((c) => (
              <option key={c} value={c}>{c}</option>
            ))}
          </select>
        </div>
        <div>
          <label className="block text-xs font-semibold text-slate mb-1">Order</label>
          <input
            type="number"
            value={form.order}
            onChange={(e) => setForm({ ...form, order: Number(e.target.value) })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
          />
        </div>
        <div className="flex items-center gap-4">
          <label className="flex items-center gap-2 text-sm font-inter text-navy">
            <input
              type="checkbox"
              checked={form.isLive}
              onChange={(e) => setForm({ ...form, isLive: e.target.checked })}
            />
            Live now
          </label>
        </div>
        <div className="col-span-2 md:col-span-5 flex gap-2">
          <button type="submit" className="bg-navy text-white font-sora font-bold rounded-lg px-4 py-2 text-sm">
            {editingId ? "Save changes" : "Add channel"}
          </button>
          {editingId && (
            <button
              type="button"
              onClick={() => {
                setEditingId(null);
                setForm(emptyForm);
              }}
              className="border border-line rounded-lg px-4 py-2 text-sm font-inter"
            >
              Cancel
            </button>
          )}
        </div>
      </form>

      {loading ? (
        <p className="text-slate font-inter">Loading…</p>
      ) : (
        <table className="w-full bg-white border border-line rounded-2xl overflow-hidden text-sm">
          <thead className="bg-cream2 text-left text-slate font-inter">
            <tr>
              <th className="p-3">Name</th>
              <th className="p-3">Category</th>
              <th className="p-3">Order</th>
              <th className="p-3">Live</th>
              <th className="p-3"></th>
            </tr>
          </thead>
          <tbody>
            {channels.map((c) => (
              <tr key={c.id} className="border-t border-line">
                <td className="p-3 font-semibold text-navy">{c.name}</td>
                <td className="p-3 text-slate">{c.category}</td>
                <td className="p-3 text-slate">{c.order}</td>
                <td className="p-3">
                  {c.isLive ? (
                    <span className="bg-ember text-white text-xs font-bold rounded-full px-2 py-1">LIVE</span>
                  ) : (
                    <span className="text-slateLight text-xs">—</span>
                  )}
                </td>
                <td className="p-3 text-right space-x-3">
                  <button onClick={() => startEdit(c)} className="text-sky font-semibold">Edit</button>
                  <button onClick={() => remove(c.id)} className="text-ember font-semibold">Delete</button>
                </td>
              </tr>
            ))}
            {channels.length === 0 && (
              <tr>
                <td colSpan={5} className="p-6 text-center text-slate">No channels yet — add one above.</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}
