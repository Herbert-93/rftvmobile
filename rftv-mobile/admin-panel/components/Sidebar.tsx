"use client";

import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { signOut } from "firebase/auth";
import { auth } from "@/lib/firebase";

const NAV = [
  { href: "/dashboard", label: "Overview" },
  { href: "/dashboard/channels", label: "Channels" },
  { href: "/dashboard/programs", label: "Programs" },
  { href: "/dashboard/radio", label: "Radio" },
  { href: "/dashboard/donations", label: "Donations" },
  { href: "/dashboard/users", label: "Users" },
];

export default function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();

  return (
    <aside className="w-60 shrink-0 min-h-screen bg-navy text-white flex flex-col">
      <div className="px-6 py-6">
        <div className="font-sora font-extrabold text-xl">
          RF<span className="text-cyan">tv</span>
        </div>
        <div className="font-inter text-[10px] tracking-widest text-slateLight mt-1">ADMIN PANEL</div>
      </div>
      <nav className="flex-1 px-3 space-y-1">
        {NAV.map((item) => {
          const active = pathname === item.href;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`block rounded-xl px-3 py-2.5 font-inter text-sm font-medium transition ${
                active ? "bg-white/15 text-white" : "text-white/70 hover:bg-white/10 hover:text-white"
              }`}
            >
              {item.label}
            </Link>
          );
        })}
      </nav>
      <div className="px-3 pb-6">
        <button
          onClick={async () => {
            await signOut(auth);
            router.push("/login");
          }}
          className="w-full text-left rounded-xl px-3 py-2.5 font-inter text-sm font-medium text-white/70 hover:bg-white/10 hover:text-white"
        >
          Log out
        </button>
      </div>
    </aside>
  );
}
