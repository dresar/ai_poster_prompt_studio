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
  Image as ImageIcon,
} from "lucide-react";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { StorageCdnModal } from "@/components/StorageCdnModal";

export const Route = createFileRoute("/_admin")({
  component: AdminLayout,
});

const tabs = [
  { to: "/dashboard", label: "Ringkasan", icon: LayoutDashboard, color: "bg-[var(--nb-yellow)] text-black" },
  { to: "/media", label: "Media CDN", icon: ImageIcon, color: "bg-indigo-500 text-white" },
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

import {
  getStoredNotifications,
  saveStoredNotifications,
  requestNotificationPermission,
  getBrowserNotificationPermission,
  triggerAppNotification,
  AppNotificationItem,
} from "@/lib/browserNotifications";

function NotificationBell() {
  const [notifications, setNotifications] = useState<AppNotificationItem[]>([]);
  const [permission, setPermission] = useState<NotificationPermission>("default");

  const refreshNotifs = () => {
    setNotifications(getStoredNotifications());
    setPermission(getBrowserNotificationPermission());
  };

  useEffect(() => {
    refreshNotifs();
    const handleUpdate = () => refreshNotifs();
    window.addEventListener("notifications_updated", handleUpdate);
    return () => window.removeEventListener("notifications_updated", handleUpdate);
  }, []);

  const unreadCount = notifications.filter((n) => !n.isRead).length;

  const handleEnableBrowserNotif = async () => {
    const perm = await requestNotificationPermission();
    setPermission(perm);
  };

  const handleMarkAllRead = () => {
    const updated = notifications.map((n) => ({ ...n, isRead: true }));
    saveStoredNotifications(updated);
    setNotifications(updated);
  };

  const handleClearAll = () => {
    saveStoredNotifications([]);
    setNotifications([]);
  };

  const formatRelativeTime = (isoString: string) => {
    try {
      const diffMs = Date.now() - new Date(isoString).getTime();
      const diffMins = Math.floor(diffMs / 60000);
      if (diffMins < 1) return "Baru saja";
      if (diffMins < 60) return `${diffMins} mnt yang lalu`;
      const diffHours = Math.floor(diffMins / 60);
      if (diffHours < 24) return `${diffHours} jam yang lalu`;
      return new Date(isoString).toLocaleDateString("id-ID");
    } catch (_) {
      return "Baru saja";
    }
  };

  return (
    <Popover>
      <PopoverTrigger asChild>
        <button className="relative nb-border nb-shadow-sm rounded-[var(--radius)] bg-white p-1.5 md:p-2 nb-press transition-transform">
          <Bell className="w-4 h-4 md:w-4 md:h-4" />
          {unreadCount > 0 && (
            <span className="absolute -top-1 -right-1 bg-red-500 text-white text-[8px] md:text-[9px] font-bold w-4 h-4 flex items-center justify-center rounded-full nb-border animate-pulse">
              {unreadCount}
            </span>
          )}
        </button>
      </PopoverTrigger>
      <PopoverContent className="w-80 md:w-96 p-0 nb-border shadow-[4px_4px_0_0_rgba(0,0,0,1)] rounded-[var(--radius)]" align="end" sideOffset={8}>
        {/* Header */}
        <div className="flex items-center justify-between p-3 border-b-2 border-black bg-[var(--nb-yellow)] rounded-t-[calc(var(--radius)-2px)]">
          <div className="flex items-center gap-2">
            <Bell className="w-4 h-4 text-black" />
            <h3 className="font-bold text-xs md:text-sm uppercase">Notifikasi Sistem</h3>
          </div>
          {notifications.length > 0 && (
            <button
              onClick={handleMarkAllRead}
              className="text-[10px] font-mono font-bold hover:underline flex items-center gap-1 text-black"
            >
              <Check className="w-3 h-3" /> Tandai Dibaca
            </button>
          )}
        </div>

        {/* Browser Permission Banner */}
        {permission !== "granted" && (
          <div className="p-2.5 bg-blue-50 border-b-2 border-black flex items-center justify-between gap-2">
            <div className="text-[10px] font-mono text-blue-900 leading-tight">
              Aktifkan <strong>Notifikasi Browser</strong> untuk menerima alert real-time.
            </div>
            <button
              onClick={handleEnableBrowserNotif}
              className="nb-border bg-blue-600 hover:bg-blue-700 text-white px-2 py-1 text-[9px] font-bold uppercase rounded shrink-0"
            >
              Izinkan
            </button>
          </div>
        )}

        {/* Notification List */}
        <div className="max-h-72 overflow-y-auto bg-white flex flex-col divide-y divide-gray-100">
          {notifications.length === 0 ? (
            <div className="p-8 text-center font-mono text-xs text-gray-500 flex flex-col items-center gap-2">
              <Bell className="w-6 h-6 text-gray-300" />
              <span>Tidak ada notifikasi</span>
            </div>
          ) : (
            notifications.map((item) => (
              <div
                key={item.id}
                className={`p-3 hover:bg-gray-50 transition-colors flex gap-2.5 items-start ${
                  !item.isRead ? "bg-yellow-50/60" : ""
                }`}
              >
                <div
                  className={`w-2 h-2 rounded-full mt-1.5 shrink-0 border border-black ${
                    item.type === "success"
                      ? "bg-green-500"
                      : item.type === "error"
                      ? "bg-red-500"
                      : item.type === "warning"
                      ? "bg-orange-500"
                      : "bg-blue-500"
                  }`}
                />
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between gap-1">
                    <p className="text-xs font-bold truncate text-black">{item.title}</p>
                    <span className="text-[9px] font-mono text-gray-400 shrink-0">
                      {formatRelativeTime(item.createdAt)}
                    </span>
                  </div>
                  <p className="text-[10px] font-mono text-gray-600 mt-0.5 leading-snug break-words">
                    {item.message}
                  </p>
                </div>
              </div>
            ))
          )}
        </div>

        {/* Footer */}
        {notifications.length > 0 && (
          <div className="p-2 border-t-2 border-black bg-gray-50 rounded-b-[calc(var(--radius)-2px)] flex items-center justify-between px-3">
            <span className="text-[9px] font-mono text-gray-500">
              Browser Web Notification API
            </span>
            <button
              onClick={handleClearAll}
              className="text-[10px] font-mono text-red-600 font-bold hover:underline"
            >
              Hapus Semua
            </button>
          </div>
        )}
      </PopoverContent>
    </Popover>
  );
}

function UserProfileDropdown({ user, logout }: { user: any; logout: () => void }) {
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <button className="nb-border nb-shadow-sm bg-[var(--nb-yellow)] hover:bg-yellow-400 p-1.5 md:p-2 rounded-[var(--radius)] flex items-center gap-2 nb-press cursor-pointer">
          <div className="w-5 h-5 rounded-full bg-black text-white flex items-center justify-center font-bold text-[10px]">
            {user?.email?.[0]?.toUpperCase() || "A"}
          </div>
          <span className="hidden lg:inline text-xs font-bold font-mono text-black max-w-[120px] truncate">
            {user?.email?.split("@")[0] || "Admin"}
          </span>
        </button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" sideOffset={6} className="w-56 p-2 nb-border shadow-[4px_4px_0_0_#000] bg-white rounded-[var(--radius)] font-mono text-xs space-y-1">
        <DropdownMenuLabel className="p-2 bg-gray-50 border-b border-black/10 rounded">
          <p className="font-bold text-black truncate">{user?.email}</p>
          <span className="inline-block mt-1 bg-black text-white text-[9px] font-bold uppercase px-1.5 py-0.5 rounded border border-black">
            {user?.role}
          </span>
        </DropdownMenuLabel>
        <DropdownMenuItem asChild className="p-2 cursor-pointer rounded hover:bg-yellow-100 flex items-center gap-2 font-bold">
          <Link to="/settings">
            <Settings className="w-3.5 h-3.5" /> Pengaturan Studio
          </Link>
        </DropdownMenuItem>
        <DropdownMenuItem asChild className="p-2 cursor-pointer rounded hover:bg-pink-100 flex items-center gap-2 font-bold">
          <Link to="/users">
            <Users className="w-3.5 h-3.5" /> Kelola User
          </Link>
        </DropdownMenuItem>
        <DropdownMenuSeparator className="my-1 border-t border-black/10" />
        <DropdownMenuItem
          onClick={logout}
          className="p-2 cursor-pointer rounded bg-red-500 hover:bg-red-600 text-white font-bold flex items-center gap-2"
        >
          <LogOut className="w-3.5 h-3.5" /> Keluar Console
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
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
      <aside className="hidden md:flex w-64 bg-white border-r-[3px] border-black flex-col sticky top-0 h-screen shadow-[4px_0_0_0_#000] z-20">
        {/* Sidebar Header / Logo */}
        <div className="p-4 border-b-[3px] border-black flex items-center justify-between bg-[var(--nb-yellow)]">
          <div className="flex items-center gap-2.5">
            <div className="nb-border bg-white rounded-[var(--radius)] p-1.5 shadow-[2px_2px_0_0_rgba(0,0,0,1)]">
              <Palette className="w-5 h-5 text-black" strokeWidth={2.5} />
            </div>
            <div>
              <h1 className="font-bold text-xs uppercase tracking-wider leading-none">Studio Admin</h1>
              <p className="text-[9px] font-mono text-muted-foreground mt-0.5">CONSOLE PANEL</p>
            </div>
          </div>
        </div>

        {/* Sidebar Navigation */}
        <nav className="flex-1 overflow-y-auto p-3 space-y-2">
          {tabs.map((t) => {
            const active = location.pathname === t.to;
            const Icon = t.icon;
            return (
              <Link
                key={t.to}
                to={t.to}
                className={[
                  "w-full nb-border nb-press rounded-[var(--radius)] px-3 py-2 font-bold uppercase text-xs flex items-center gap-2.5 transition-all",
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
        <div className="p-3 border-t-[3px] border-black bg-gray-50">
          <button
            onClick={logout}
            className="w-full nb-border nb-shadow-sm nb-press rounded-[var(--radius)] bg-red-500 text-white px-3 py-2 font-bold uppercase text-xs flex items-center justify-center gap-2"
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
            <h1 className="text-[11px] font-bold uppercase tracking-wider leading-none">Admin</h1>
          </div>

          <div className="flex items-center gap-2">
            <StorageCdnModal
              triggerBtn={
                <button className="nb-border nb-shadow-sm rounded-[var(--radius)] bg-indigo-500 text-white px-2 py-1 font-bold uppercase text-xs flex items-center gap-1">
                  <ImageIcon className="w-3.5 h-3.5" />
                  <span className="text-[10px]">Media</span>
                </button>
              }
            />
            <UserProfileDropdown user={user} logout={logout} />
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

      {/* 3. MAIN CONTENT CONTAINER WITH TOP DESKTOP HEADER */}
      <div className="flex-1 flex flex-col min-w-0">
        {/* DESKTOP TOP HEADER */}
        <header className="hidden md:flex items-center justify-between px-6 py-3 bg-white border-b-[3px] border-black shadow-[0_3px_0_0_#000] sticky top-0 z-10">
          <div className="flex items-center gap-2">
            <span className="font-bold text-xs uppercase tracking-wider bg-black text-white px-2 py-0.5 rounded border border-black">
              CONSOLE
            </span>
            <span className="text-xs font-bold uppercase font-mono text-gray-700">Studio Admin Panel</span>
          </div>

          <div className="flex items-center gap-3">
            {/* Quick Access Media CDN Modal Button */}
            <StorageCdnModal
              triggerBtn={
                <button className="nb-border nb-shadow-sm rounded-[var(--radius)] bg-indigo-500 hover:bg-indigo-600 text-white px-3 py-1.5 font-bold uppercase text-xs flex items-center gap-1.5 nb-press">
                  <ImageIcon className="w-3.5 h-3.5 text-white" />
                  <span>Media CDN</span>
                </button>
              }
            />

            {/* Profile Avatar & Dropdown Menu */}
            <UserProfileDropdown user={user} logout={logout} />

            <NotificationBell />
          </div>
        </header>

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
