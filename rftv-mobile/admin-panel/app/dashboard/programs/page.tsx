"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";

type Channel = { id: string; name: string };
type Program = {
  id: string;
  channelId: string;
  title: string;
  startTime: string;
  endTime: string;
  description?: string;
  videoUrl?: string;
  thumbnailUrl?: string;
  durationMinutes?: number;
};

const emptyForm = {
  channelId: "",
  title: "",
  startTime: "",
  endTime: "",
  description: "",
  videoUrl: "",
  thumbnailUrl: "",
  durationMinutes: "",
};

export default function ProgramsPage() {
  const [programs, setPrograms] = useState<Program[]>([]);
  const [channels, setChannels] = useState<Channel[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [form, setForm] = useState<any>(emptyForm);
  const [editingId, setEditingId] = useState<string | null>(null);

  async function load() {
    setLoading(true);
    try {
      const [p, c] = await Promise.all([api.get("/programs"), api.get("/channels")]);
      setPrograms(p);
      setChannels(c);
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
      const payload = {
        ...form,
        startTime: new Date(form.startTime).toISOString(),
        endTime: new Date(form.endTime).toISOString(),
        durationMinutes: form.durationMinutes ? Number(form.durationMinutes) : undefined,
        videoUrl: form.videoUrl || undefined,
        thumbnailUrl: form.thumbnailUrl || undefined,
        description: form.description || undefined,
      };
      if (editingId) {
        await api.put(`/programs/${editingId}`, payload);
      } else {
        await api.post("/programs", payload);
      }
      setForm(emptyForm);
      setEditingId(null);
      load();
    } catch (err: any) {
      setError(err.message);
    }
  }

  function toLocalInput(iso: string) {
    const d = new Date(iso);
    const pad = (n: number) => String(n).padStart(2, "0");
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
  }

  function startEdit(p: Program) {
    setEditingId(p.id);
    setForm({
      channelId: p.channelId,
      title: p.title,
      startTime: toLocalInput(p.startTime),
      endTime: toLocalInput(p.endTime),
      description: p.description || "",
      videoUrl: p.videoUrl || "",
      thumbnailUrl: p.thumbnailUrl || "",
      durationMinutes: p.durationMinutes ? String(p.durationMinutes) : "",
    });
  }

  async function remove(id: string) {
    if (!confirm("Delete this program?")) return;
    try {
      await api.delete(`/programs/${id}`);
      load();
    } catch (err: any) {
      setError(err.message);
    }
  }

  function channelName(id: string) {
    return channels.find((c) => c.id === id)?.name || id;
  }

  return (
    <div>
      <h1 className="font-sora font-extrabold text-2xl text-navy mb-1">Programs</h1>
      <p className="font-inter text-sm text-slate mb-6">The schedule shown in "Up next" and the program guide.</p>

      {error && <p className="text-ember mb-4">{error}</p>}

      <form onSubmit={handleSubmit} className="bg-white border border-line rounded-2xl p-5 mb-8 grid grid-cols-2 md:grid-cols-5 gap-3 items-end">
        <div>
          <label className="block text-xs font-semibold text-slate mb-1">Channel</label>
          <select
            required
            value={form.channelId}
            onChange={(e) => setForm({ ...form, channelId: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
          >
            <option value="">Select…</option>
            {channels.map((c) => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))}
          </select>
        </div>
        <div className="col-span-2">
          <label className="block text-xs font-semibold text-slate mb-1">Title</label>
          <input
            required
            value={form.title}
            onChange={(e) => setForm({ ...form, title: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            placeholder="RF News Nightly"
          />
        </div>
        <div>
          <label className="block text-xs font-semibold text-slate mb-1">Start</label>
          <input
            required
            type="datetime-local"
            value={form.startTime}
            onChange={(e) => setForm({ ...form, startTime: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
          />
        </div>
        <div>
          <label className="block text-xs font-semibold text-slate mb-1">End</label>
          <input
            required
            type="datetime-local"
            value={form.endTime}
            onChange={(e) => setForm({ ...form, endTime: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
          />
        </div>
        <div className="col-span-2">
          <label className="block text-xs font-semibold text-slate mb-1">Video link (YouTube, Vimeo, direct .mp4/.m3u8…)</label>
          <input
            value={form.videoUrl}
            onChange={(e) => setForm({ ...form, videoUrl: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            placeholder="https://…"
          />
        </div>
        <div className="col-span-2">
          <label className="block text-xs font-semibold text-slate mb-1">Thumbnail image link (optional)</label>
          <input
            value={form.thumbnailUrl}
            onChange={(e) => setForm({ ...form, thumbnailUrl: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            placeholder="https://…"
          />
        </div>
        <div>
          <label className="block text-xs font-semibold text-slate mb-1">Duration (minutes)</label>
          <input
            type="number"
            min="0"
            value={form.durationMinutes}
            onChange={(e) => setForm({ ...form, durationMinutes: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            placeholder="45"
          />
        </div>
        <div className="col-span-2 md:col-span-5">
          <label className="block text-xs font-semibold text-slate mb-1">Description (optional)</label>
          <textarea
            value={form.description}
            onChange={(e) => setForm({ ...form, description: e.target.value })}
            className="w-full border border-line rounded-lg px-3 py-2 text-sm"
            rows={2}
            placeholder="What this movie or program is about…"
          />
        </div>
        <div className="col-span-2 md:col-span-5 flex gap-2">
          <button type="submit" className="bg-navy text-white font-sora font-bold rounded-lg px-4 py-2 text-sm">
            {editingId ? "Save changes" : "Add program"}
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
              <th className="p-3">Channel</th>
              <th className="p-3">Title</th>
              <th className="p-3">Start</th>
              <th className="p-3">End</th>
              <th className="p-3">Duration</th>
              <th className="p-3">Video</th>
              <th className="p-3"></th>
            </tr>
          </thead>
          <tbody>
            {programs.map((p) => (
              <tr key={p.id} className="border-t border-line">
                <td className="p-3 text-slate">{channelName(p.channelId)}</td>
                <td className="p-3 font-semibold text-navy">{p.title}</td>
                <td className="p-3 text-slate">{new Date(p.startTime).toLocaleString()}</td>
                <td className="p-3 text-slate">{new Date(p.endTime).toLocaleString()}</td>
                <td className="p-3 text-slate">{p.durationMinutes ? `${p.durationMinutes} min` : "—"}</td>
                <td className="p-3">
                  {p.videoUrl ? (
                    <span className="text-sky font-semibold">Linked</span>
                  ) : (
                    <span className="text-slate">None</span>
                  )}
                </td>
                <td className="p-3 text-right space-x-3">
                  <button onClick={() => startEdit(p)} className="text-sky font-semibold">Edit</button>
                  <button onClick={() => remove(p.id)} className="text-ember font-semibold">Delete</button>
                </td>
              </tr>
            ))}
            {programs.length === 0 && (
              <tr>
                <td colSpan={7} className="p-6 text-center text-slate">No programs scheduled yet.</td>
              </tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}