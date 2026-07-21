export interface AppNotificationItem {
  id: string;
  title: string;
  message: string;
  type: "info" | "success" | "warning" | "error";
  createdAt: string;
  isRead: boolean;
}

const STORAGE_KEY = "admin_notifications_v1";

const DEFAULT_NOTIFICATIONS: AppNotificationItem[] = [
  {
    id: "notif_1",
    title: "Storage CDN Gateway Aktif",
    message: "Koneksi ke Persistent Gateway https://one.apprentice.cyou/v1 berstatus OK.",
    type: "success",
    createdAt: new Date(Date.now() - 2 * 60 * 1000).toISOString(),
    isRead: false,
  },
  {
    id: "notif_2",
    title: "Sesi Admin Terverifikasi",
    message: "Login berhasil dengan hak akses penuh Admin Console Studio.",
    type: "info",
    createdAt: new Date(Date.now() - 15 * 60 * 1000).toISOString(),
    isRead: false,
  },
  {
    id: "notif_3",
    title: "Sistem AI Gemini 2.5 Flash Ready",
    message: "Endpoint /v1/chat/completions terhubung dan siap memproses prompt.",
    type: "info",
    createdAt: new Date(Date.now() - 45 * 60 * 1000).toISOString(),
    isRead: false,
  },
];

export function getStoredNotifications(): AppNotificationItem[] {
  try {
    const data = localStorage.getItem(STORAGE_KEY);
    if (data) {
      const parsed = JSON.parse(data);
      if (Array.isArray(parsed) && parsed.length > 0) return parsed;
    }
  } catch (_) {}
  return DEFAULT_NOTIFICATIONS;
}

export function saveStoredNotifications(items: AppNotificationItem[]) {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
    window.dispatchEvent(new Event("notifications_updated"));
  } catch (_) {}
}

export async function requestNotificationPermission(): Promise<NotificationPermission> {
  if (typeof window === "undefined" || !("Notification" in window)) {
    return "denied";
  }
  try {
    const permission = await Notification.requestPermission();
    if (permission === "granted") {
      sendBrowserNotification("Notifikasi Browser Diaktifkan! 🎉", {
        body: "Anda akan menerima notifikasi real-time dari Admin Console Studio.",
      });
    }
    return permission;
  } catch (e) {
    return "denied";
  }
}

export function getBrowserNotificationPermission(): NotificationPermission {
  if (typeof window === "undefined" || !("Notification" in window)) {
    return "denied";
  }
  return Notification.permission;
}

export function sendBrowserNotification(title: string, options?: NotificationOptions) {
  if (typeof window === "undefined" || !("Notification" in window)) return;

  if (Notification.permission === "granted") {
    try {
      new Notification(title, {
        icon: "/favicon.ico",
        badge: "/favicon.ico",
        ...options,
      });
    } catch (e) {
      console.error("Browser notification failed", e);
    }
  }
}

export function triggerAppNotification(
  title: string,
  message: string,
  type: "info" | "success" | "warning" | "error" = "info"
) {
  const current = getStoredNotifications();
  const newItem: AppNotificationItem = {
    id: `notif_${Date.now()}_${Math.random().toString(36).substr(2, 4)}`,
    title,
    message,
    type,
    createdAt: new Date().toISOString(),
    isRead: false,
  };
  const updated = [newItem, ...current].slice(0, 30);
  saveStoredNotifications(updated);

  sendBrowserNotification(title, { body: message });
}
