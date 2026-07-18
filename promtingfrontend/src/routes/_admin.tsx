import { createFileRoute, Link, Outlet, useNavigate, useLocation } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { tokenStore } from "@/lib/api";
import {
  LayoutDashboard,
  KeyRound,
  Settings,
  Palette,
  Ticket,
  ScrollText,
  LogOut,
  Menu,
  X,
  Users,
  Layers,
  UserRound,
  FileText,
  Bell,
  Check,
} from "lucide-react";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";

export const Route = createFileRoute("/_admin")({
  component: AdminLayout,
});

const tabs = [
  { to: "/dashboard", label: "Ringkasan", icon: LayoutDashboard, color: "bg-[var(--nb-yellow)] text-black" },
  { to: "/users", label: "Kelola User", icon: Users, color: "bg-[var(--nb-pink)] text-white" },
  { to: "/keys", label: "Kunci & API", icon: KeyRound, color: "bg-[var(--nb-blue)] text-white" },
  { to: "/styles", label: "Pustaka Gaya", icon: Palette, color: "bg-[var(--nb-pink)] text-white" },
  { to: "/characters", label: "Karakter", icon: UserRound, color: "bg-purple-400 text-white" },
  { to: "/templates", label: "Templates", icon: FileText, color: "bg-teal-400 text-white" },
  { to: "/dropdowns", label: "Dropdown Opsi", icon: Layers, color: "bg-orange-400 text-white" },
  { to: "/vouchers", label: "Voucher & Kredit", icon: Ticket, color: "bg-[var(--nb-green)] text-black" },
  { to: "/settings", label: "Pengaturan", short: "Atur", icon: Settings, color: "bg-white text-black" },
  { to: "/form-infos", label: "Info Form", short: "Form", icon: FileText, color: "bg-blue-400 text-white" },
  { to: "/logs", label: "Audit Log", short: "Log", icon: ScrollText, color: "bg-black text-white" },
] as const;

function NotificationBell() {
  const [unread] = useState(3);
  
  return (
    <Popover>
      <PopoverTrigger asChild>
        <button className="relative nb-border nb-shadow-sm rounded-[var(--radius)] bg-white p-1.5 md:p-2 nb-press transition-transform">
          <Bell className="w-4 h-4 md:w-5 md:h-5" />
          {unread > 0 && (
            <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[8px] md:text-[10px] font-bold w-4 h-4 md:w-5 md:h-5 flex items-center justify-center rounded-full nb-border">
              {unread}
            </span>
          )}
        </button>
      </PopoverTrigger>
      <PopoverContent className="w-72 md:w-80 p-0 nb-border shadow-[4px_4px_0_0_rgba(0,0,0,1)] rounded-[var(--radius)]" align="end" sideOffset={8}>
        <div className="flex items-center justify-between p-3 border-b-2 border-black bg-[var(--nb-yellow)] rounded-t-[calc(var(--radius)-2px)]">
          <h3 className="font-bold text-xs md:text-sm uppercase">Notifikasi</h3>
          <button className="text-[10px] font-mono hover:underline flex items-center gap-1"><Check className="w-3 h-3"/> Tandai dibaca</button>
        </div>
        <div className="max-h-64 overflow-y-auto bg-white flex flex-col">
          {[1, 2, 3].map((i) => (
            <div key={i} className="p-3 border-b-2 border-black/10 hover:bg-gray-50 transition-colors flex gap-3 items-start last:border-b-0">
              <div className="w-2 h-2 rounded-full bg-red-500 mt-1.5 shrink-0 border border-black" />
              <div>
                <p className="text-xs md:text-sm font-bold leading-tight">Pengguna baru mendaftar</p>
                <p className="text-[10px] md:text-xs text-muted-foreground mt-0.5 leading-tight">user_{i}@example.com telah bergabung ke platform.</p>
                <span className="text-[8px] md:text-[10px] font-mono text-muted-foreground mt-1 block">2 menit yang lalu</span>
              </div>
            </div>
          ))}
        </div>
        <div className="p-2 border-t-2 border-black bg-gray-50 rounded-b-[calc(var(--radius)-2px)] text-center">
          <button className="text-[10px] md:text-xs font-bold uppercase hover:underline">Lihat Semua</button>
        </div>
      </PopoverContent>
    </Popover>
  );
}


function AdminLayout() {
  const navigate = useNavigate();
  const location = useLocation();
  const [user, setUser] = useState<any>(null);
  const [ready, setReady] = useState(false);
  const [open, setOpen] = useState(false);

  useEffect(() => {
    const t = tokenStore.access;
    const u = tokenStore.user;
    if (!t || !u || u.role !== "ADMIN") {
      navigate({ to: "/login" });
      return;
    }
    setUser(u);
    setReady(true);
  }, [navigate]);

  useEffect(() => setOpen(false), [location.pathname]);

  if (!ready) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[var(--nb-bg)]">
        <div className="nb-border nb-shadow bg-white rounded-[var(--radius)] px-6 py-4 font-bold uppercase">
          Memeriksa sesi…
        </div>
      </div>
    );
  }

  function logout() {
    tokenStore.clear();
    navigate({ to: "/login" });
  }

  return (
    <div className="min-h-screen bg-[var(--nb-bg)] flex flex-col md:flex-row">
      {/* 1. DESKTOP SIDEBAR */}
      <aside className="hidden md:flex w-72 bg-white border-r-[3px] border-black flex-col sticky top-0 h-screen shadow-[4px_0_0_0_#000] z-20">
        {/* Sidebar Header / Logo */}
        <div className="p-4 md:p-5 border-b-[3px] border-black flex items-center justify-between bg-[var(--nb-yellow)]">
          <div className="flex items-center gap-3">
            <div className="nb-border bg-white rounded-[var(--radius)] p-1.5 md:p-2 shadow-[2px_2px_0_0_rgba(0,0,0,1)]">
              <Palette className="w-5 h-5 md:w-6 md:h-6 text-black" strokeWidth={2.5} />
            </div>
            <div>
              <h1 className="font-bold text-xs md:text-sm uppercase tracking-wider leading-none">Studio Admin</h1>
              <p className="text-[9px] md:text-[10px] font-mono text-muted-foreground mt-0.5">CONSOLE PANEL</p>
            </div>
          </div>
          <NotificationBell />
        </div>

        {/* User Card */}
        <div className="p-4 border-b-2 border-black/10 bg-gray-50 flex flex-col gap-1">
          <span className="text-xs font-mono text-muted-foreground block truncate">Logged in as:</span>
          <span className="text-xs font-bold text-black truncate">{user?.email}</span>
          <span className="inline-self-start mt-1 text-[9px] bg-black text-white font-mono uppercase font-bold px-2 py-0.5 rounded border border-black w-max">
            {user?.role}
          </span>
        </div>

        {/* Sidebar Navigation */}
        <nav className="flex-1 overflow-y-auto p-4 space-y-2.5">
          {tabs.map((t) => {
            const active = location.pathname === t.to;
            const Icon = t.icon;
            return (
              <Link
                key={t.to}
                to={t.to}
                className={[
                  "w-full nb-border nb-press nb-press-hover rounded-[var(--radius)] px-4 py-2.5 font-bold uppercase text-xs flex items-center gap-3 transition-all",
                  active
                    ? "nb-shadow bg-black text-white border-black"
                    : `nb-shadow-sm ${t.color} hover:translate-x-1`,
                ].join(" ")}
              >
                <Icon className="w-4 h-4 shrink-0" />
                <span>{t.label}</span>
              </Link>
            );
          })}
        </nav>

        {/* Sidebar Logout Footer */}
        <div className="p-4 border-t-[3px] border-black bg-gray-50">
          <button
            onClick={logout}
            className="w-full nb-border nb-shadow-sm nb-press nb-press-hover rounded-[var(--radius)] bg-red-500 text-white px-4 py-2.5 font-bold uppercase text-xs flex items-center justify-center gap-2"
          >
            <LogOut className="w-4 h-4" /> Keluar Console
          </button>
        </div>
      </aside>

      {/* 2. MOBILE HEADER & STICKY NAVIGATION */}
      <header className="md:hidden sticky top-0 z-30 bg-white border-b-[3px] border-black shadow-[0_3px_0_0_rgba(0,0,0,1)]">
        <div className="px-3 py-2 flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="nb-border bg-[var(--nb-yellow)] rounded-[var(--radius)] p-1 shadow-[1.5px_1.5px_0_0_rgba(0,0,0,1)]">
              <Palette className="w-3.5 h-3.5" strokeWidth={2.5} />
            </div>
            <div className="flex flex-col">
              <h1 className="text-[11px] font-bold uppercase tracking-wider leading-none">Admin</h1>
              <p className="text-[8px] font-mono text-muted-foreground truncate max-w-[100px]">{user?.email}</p>
            </div>
          </div>
          <div className="flex items-center gap-2">
            <NotificationBell />
            <button
              onClick={() => setOpen((v) => !v)}
              className="nb-border nb-shadow-sm rounded-[var(--radius)] bg-white p-1.5 nb-press active:scale-95 transition-transform"
              aria-label="Menu"
            >
              {open ? <X className="w-4 h-4" /> : <Menu className="w-4 h-4" />}
            </button>
          </div>
        </div>
      </header>

      {/* Backdrop for Mobile Drawer */}
      {open && (
        <div
          className="fixed inset-0 z-40 bg-black/60 md:hidden"
          onClick={() => setOpen(false)}
        />
      )}

      {/* Mobile Drawer (Sidebar) */}
      <div
        className={[
          "fixed top-0 bottom-0 left-0 z-50 w-64 bg-[var(--nb-bg)] border-r-[3px] border-black transition-transform duration-300 ease-in-out md:hidden flex flex-col shadow-[8px_0_0_0_#000]",
          open ? "translate-x-0" : "-translate-x-full",
        ].join(" ")}
      >
        <div className="p-3 border-b-[3px] border-black flex items-center justify-between bg-[var(--nb-yellow)]">
          <div className="flex items-center gap-2">
            <div className="nb-border bg-white rounded-[var(--radius)] p-1 shadow-[1.5px_1.5px_0_0_rgba(0,0,0,1)]">
              <Palette className="w-3.5 h-3.5" strokeWidth={2.5} />
            </div>
            <span className="font-bold text-[11px] uppercase tracking-wider">Menu Admin</span>
          </div>
          <button
            onClick={() => setOpen(false)}
            className="nb-border nb-shadow-sm rounded-[var(--radius)] bg-white p-1"
          >
            <X className="w-3.5 h-3.5" />
          </button>
        </div>

        <div className="p-3 border-b-2 border-black/10 bg-gray-50 flex flex-col">
          <span className="text-[10px] font-mono text-muted-foreground">Logged in as:</span>
          <span className="text-[11px] font-bold text-black truncate">{user?.email}</span>
        </div>

        <div className="flex-1 overflow-y-auto p-3 space-y-2">
          {(tabs as readonly any[]).map((t) => {
            const active = location.pathname === t.to;
            const Icon = t.icon;
            return (
              <Link
                key={t.to}
                to={t.to}
                onClick={() => setOpen(false)}
                className={[
                  "w-full nb-border nb-press rounded-[var(--radius)] px-3 py-2 font-bold uppercase text-[10px] flex items-center gap-2",
                  active
                    ? "nb-shadow bg-black text-white border-black"
                    : `nb-shadow-sm ${t.color}`,
                ].join(" ")}
              >
                <Icon className="w-3.5 h-3.5 shrink-0" />
                <span>{t.short || t.label}</span>
              </Link>
            );
          })}
        </div>

        <div className="p-3 border-t-[3px] border-black bg-white">
          <button
            onClick={logout}
            className="w-full nb-border nb-shadow-sm nb-press rounded-[var(--radius)] bg-red-500 text-white px-3 py-2 font-bold uppercase text-[10px] flex items-center justify-center gap-2"
          >
            <LogOut className="w-3.5 h-3.5" /> Keluar
          </button>
        </div>
      </div>

      {/* 3. MAIN CONTENT CONTAINER */}
      <div className="flex-1 flex flex-col min-w-0">
        <main className="p-3 sm:p-5 md:p-8 flex-1 w-full max-w-7xl mx-auto overflow-x-hidden">
          <Outlet />
        </main>

        <footer className="py-6 border-t-2 border-black/10 bg-white/50">
          <p className="text-center text-xs font-mono text-muted-foreground">
            Studio Prompt · Admin Console
          </p>
        </footer>
      </div>
    </div>
  );
}
