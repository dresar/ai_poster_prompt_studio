import React, { useState, useEffect } from "react";
import {
  Cloud,
  Upload,
  Copy,
  Check,
  Trash2,
  Settings,
  Image as ImageIcon,
  Key,
  ExternalLink,
  Layers,
  Sparkles,
  RefreshCw,
  Scissors
} from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";

export interface CloudinaryAccount {
  id: number;
  name: string;
  cloudName: string;
  apiKey: string;
  apiSecret: string;
  uploadPreset: string;
  isActive: boolean;
}

export interface UploadedImage {
  id: string;
  url: string;
  publicId: string;
  accountId: number;
  createdAt: string;
  fileName: string;
}

const DEFAULT_ACCOUNTS: CloudinaryAccount[] = [
  { id: 1, name: "Akun 1 (Utama)", cloudName: "", apiKey: "", apiSecret: "", uploadPreset: "", isActive: true },
  { id: 2, name: "Akun 2 (Backup A)", cloudName: "", apiKey: "", apiSecret: "", uploadPreset: "", isActive: false },
  { id: 3, name: "Akun 3 (Backup B)", cloudName: "", apiKey: "", apiSecret: "", uploadPreset: "", isActive: false },
  { id: 4, name: "Akun 4 (Backup C)", cloudName: "", apiKey: "", apiSecret: "", uploadPreset: "", isActive: false },
  { id: 5, name: "Akun 5 (Backup D)", cloudName: "", apiKey: "", apiSecret: "", uploadPreset: "", isActive: false },
];

export function CloudinaryManagerModal({ triggerBtn }: { triggerBtn?: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  const [activeTab, setActiveTab] = useState<"gallery" | "accounts" | "removebg">("gallery");
  const [accounts, setAccounts] = useState<CloudinaryAccount[]>(DEFAULT_ACCOUNTS);
  const [selectedAccountId, setSelectedAccountId] = useState<number>(1);
  const [uploadedImages, setUploadedImages] = useState<UploadedImage[]>([]);
  const [removeBgKey, setRemoveBgKey] = useState<string>("");
  const [isUploading, setIsUploading] = useState(false);
  const [uploadStatus, setUploadStatus] = useState<string>("");
  const [copiedId, setCopiedId] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");

  // Load from localStorage on mount
  useEffect(() => {
    try {
      const savedAccounts = localStorage.getItem("cloudinary_accounts_v1");
      if (savedAccounts) {
        const parsed = JSON.parse(savedAccounts);
        if (Array.isArray(parsed) && parsed.length === 5) {
          setAccounts(parsed);
          const active = parsed.find((a: CloudinaryAccount) => a.isActive);
          if (active) setSelectedAccountId(active.id);
        }
      }

      const savedImages = localStorage.getItem("cloudinary_images_v1");
      if (savedImages) {
        setUploadedImages(JSON.parse(savedImages));
      }

      const savedRbg = localStorage.getItem("removebg_key_v1");
      if (savedRbg) {
        setRemoveBgKey(savedRbg);
      }
    } catch (e) {
      console.error("Failed to load Cloudinary config", e);
    }
  }, []);

  // Save accounts to localStorage
  const saveAccounts = (newAccounts: CloudinaryAccount[]) => {
    setAccounts(newAccounts);
    localStorage.setItem("cloudinary_accounts_v1", JSON.stringify(newAccounts));
  };

  // Save images to localStorage
  const saveImages = (newImages: UploadedImage[]) => {
    setUploadedImages(newImages);
    localStorage.setItem("cloudinary_images_v1", JSON.stringify(newImages));
  };

  // Save Remove.bg key
  const saveRemoveBgKey = (key: string) => {
    setRemoveBgKey(key);
    localStorage.setItem("removebg_key_v1", key);
  };

  const activeAccount = accounts.find((a) => a.id === selectedAccountId) || accounts[0];

  // Cloudinary / Storage CDN Gateway Direct Upload
  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = e.target.files;
    if (!files || files.length === 0) return;

    setIsUploading(true);
    setUploadStatus("Mengunggah gambar ke Storage CDN Gateway (Cloudinary)...");

    const newUploaded: UploadedImage[] = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      try {
        const reader = new FileReader();
        const base64Promise = new Promise<string>((resolve, reject) => {
          reader.onload = () => resolve(reader.result as string);
          reader.onerror = reject;
        });
        reader.readAsDataURL(file);
        const base64Data = await base64Promise;

        const res = await fetch("https://one.apprentice.cyou/v1/storage/upload", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer AR_4c9b2435_929a80d916261b15c582db6fe3e41e52",
          },
          body: JSON.stringify({
            file: base64Data,
            file_name: file.name,
            auto_rotate: true,
            provider: "cloudinary",
          }),
        });

        const data = await res.json();
        if (res.ok && data.success && data.file?.url) {
          const item: UploadedImage = {
            id: data.file.id || `img_${Date.now()}_${i}`,
            url: data.file.url,
            publicId: data.file.file_id || data.file.id,
            accountId: activeAccount?.id || "gateway",
            createdAt: data.file.created_at || new Date().toISOString(),
            fileName: file.name,
          };
          newUploaded.push(item);
        } else {
          console.error("Storage CDN Gateway error:", data);
          alert(`Gagal upload ${file.name}: ${data.message || data.error?.message || "Upload error"}`);
        }
      } catch (err: any) {
        console.error("Storage CDN upload failed", err);
        alert(`Gagal upload ${file.name}: ${err.message}`);
      }
    }

    if (newUploaded.length > 0) {
      const updated = [...newUploaded, ...uploadedImages];
      saveImages(updated);
      setUploadStatus(`Berhasil mengunggah ${newUploaded.length} gambar!`);
    }

    setIsUploading(false);
    // Reset file input
    e.target.value = "";
  };

  const copyToClipboard = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  const deleteImage = (id: string) => {
    if (confirm("Hapus gambar ini dari daftar galeri lokal?")) {
      const updated = uploadedImages.filter((img) => img.id !== id);
      saveImages(updated);
    }
  };

  const filteredImages = uploadedImages.filter((img) => {
    const matchesAccount = img.accountId === selectedAccountId || selectedAccountId === 0;
    const matchesSearch = img.fileName.toLowerCase().includes(searchQuery.toLowerCase()) || img.url.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesAccount && matchesSearch;
  });

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        {triggerBtn || (
          <button className="nb-border nb-shadow-sm rounded-[var(--radius)] bg-[var(--nb-yellow)] hover:bg-yellow-400 text-black px-2.5 py-1.5 md:px-3 md:py-2 font-bold uppercase text-xs flex items-center gap-2 nb-press transition-all">
            <Cloud className="w-4 h-4 text-black" />
            <span className="hidden sm:inline">Cloudinary (5 Akun)</span>
          </button>
        )}
      </DialogTrigger>

      <DialogContent className="max-w-4xl w-[95vw] max-h-[90vh] flex flex-col p-0 nb-border shadow-[6px_6px_0_0_#000] bg-white rounded-[var(--radius)] overflow-hidden">
        {/* Header */}
        <DialogHeader className="p-4 bg-[var(--nb-yellow)] border-b-[3px] border-black flex flex-row items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="nb-border bg-white p-1.5 rounded-[var(--radius)] shadow-[2px_2px_0_0_#000]">
              <Cloud className="w-5 h-5 text-black" />
            </div>
            <div>
              <DialogTitle className="font-bold text-sm md:text-base uppercase tracking-wider">
                Cloudinary Manager & Multi-Account
              </DialogTitle>
              <p className="text-[10px] md:text-xs font-mono text-black/70">
                Kelola 5 Akun Cloudinary + Remove.bg & Galeri Gambar
              </p>
            </div>
          </div>
        </DialogHeader>

        {/* Tab Selector */}
        <div className="flex border-b-2 border-black bg-gray-100 p-1.5 gap-2 overflow-x-auto">
          <button
            onClick={() => setActiveTab("gallery")}
            className={`px-3 py-1.5 rounded-[var(--radius)] font-bold text-xs uppercase flex items-center gap-2 border-2 border-black transition-all ${
              activeTab === "gallery" ? "bg-black text-white shadow-[2px_2px_0_0_#000]" : "bg-white text-black hover:bg-gray-200"
            }`}
          >
            <ImageIcon className="w-3.5 h-3.5" /> Galeri Gambar ({uploadedImages.length})
          </button>
          <button
            onClick={() => setActiveTab("accounts")}
            className={`px-3 py-1.5 rounded-[var(--radius)] font-bold text-xs uppercase flex items-center gap-2 border-2 border-black transition-all ${
              activeTab === "accounts" ? "bg-black text-white shadow-[2px_2px_0_0_#000]" : "bg-white text-black hover:bg-gray-200"
            }`}
          >
            <Settings className="w-3.5 h-3.5" /> Atur 5 Akun Cloudinary
          </button>
          <button
            onClick={() => setActiveTab("removebg")}
            className={`px-3 py-1.5 rounded-[var(--radius)] font-bold text-xs uppercase flex items-center gap-2 border-2 border-black transition-all ${
              activeTab === "removebg" ? "bg-purple-600 text-white shadow-[2px_2px_0_0_#000]" : "bg-white text-black hover:bg-purple-50"
            }`}
          >
            <Scissors className="w-3.5 h-3.5" /> Remove.bg API
          </button>
        </div>

        {/* Body Content */}
        <div className="flex-1 overflow-y-auto p-4 md:p-6 space-y-4">
          {/* TAB 1: GALLERY & UPLOAD */}
          {activeTab === "gallery" && (
            <div className="space-y-4">
              {/* Account Selector & Upload Action Bar */}
              <div className="nb-border bg-gray-50 p-4 rounded-[var(--radius)] shadow-[3px_3px_0_0_#000] flex flex-col md:flex-row gap-3 items-stretch md:items-center justify-between">
                <div className="flex items-center gap-2">
                  <label className="font-bold text-xs uppercase whitespace-nowrap">Pilih Akun:</label>
                  <select
                    value={selectedAccountId}
                    onChange={(e) => setSelectedAccountId(Number(e.target.value))}
                    className="nb-border bg-white px-3 py-1.5 font-bold text-xs rounded-[var(--radius)] shadow-[2px_2px_0_0_#000]"
                  >
                    <option value={0}>Semua Akun (1 - 5)</option>
                    {accounts.map((acc) => (
                      <option key={acc.id} value={acc.id}>
                        {acc.name} {acc.cloudName ? `(${acc.cloudName})` : "- Belum Diatur"}
                      </option>
                    ))}
                  </select>
                </div>

                <div className="flex items-center gap-2">
                  <input
                    type="text"
                    placeholder="Cari file..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="nb-border bg-white px-3 py-1.5 text-xs font-mono rounded-[var(--radius)] w-full md:w-48"
                  />
                  <label className="nb-border bg-[var(--nb-blue)] hover:bg-blue-600 text-white px-4 py-2 font-bold text-xs uppercase rounded-[var(--radius)] shadow-[2px_2px_0_0_#000] cursor-pointer flex items-center gap-2 nb-press shrink-0">
                    <Upload className="w-4 h-4" />
                    Upload File
                    <input
                      type="file"
                      accept="image/*"
                      multiple
                      className="hidden"
                      onChange={handleFileUpload}
                      disabled={isUploading}
                    />
                  </label>
                </div>
              </div>

              {isUploading && (
                <div className="nb-border bg-yellow-100 p-3 rounded-[var(--radius)] text-xs font-bold flex items-center gap-2">
                  <RefreshCw className="w-4 h-4 animate-spin text-black" />
                  {uploadStatus}
                </div>
              )}

              {/* Image Grid */}
              {filteredImages.length === 0 ? (
                <div className="text-center py-12 border-2 border-dashed border-black rounded-[var(--radius)] bg-gray-50">
                  <ImageIcon className="w-12 h-12 text-gray-400 mx-auto mb-2" />
                  <p className="font-bold text-sm uppercase">Belum ada gambar di galeri</p>
                  <p className="text-xs text-muted-foreground mt-1">
                    Upload gambar langsung ke Cloudinary menggunakan tombol Upload File di atas.
                  </p>
                </div>
              ) : (
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
                  {filteredImages.map((img) => {
                    const accName = accounts.find((a) => a.id === img.accountId)?.name || `Akun ${img.accountId}`;
                    return (
                      <div
                        key={img.id}
                        className="nb-border bg-white rounded-[var(--radius)] overflow-hidden shadow-[3px_3px_0_0_#000] flex flex-col group"
                      >
                        <div className="relative aspect-square bg-gray-100 overflow-hidden border-b-2 border-black">
                          <img
                            src={img.url}
                            alt={img.fileName}
                            className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                          />
                          <span className="absolute top-1 left-1 bg-black text-white text-[8px] font-mono px-1.5 py-0.5 rounded font-bold">
                            {accName}
                          </span>
                        </div>
                        <div className="p-2 space-y-1 bg-white">
                          <p className="text-[10px] font-bold truncate" title={img.fileName}>
                            {img.fileName}
                          </p>
                          <div className="flex items-center gap-1">
                            <button
                              onClick={() => copyToClipboard(img.url, img.id)}
                              className="flex-1 nb-border bg-[var(--nb-yellow)] hover:bg-yellow-400 text-black py-1 px-2 text-[10px] font-bold uppercase rounded flex items-center justify-center gap-1"
                            >
                              {copiedId === img.id ? (
                                <>
                                  <Check className="w-3 h-3 text-green-700" /> Copied!
                                </>
                              ) : (
                                <>
                                  <Copy className="w-3 h-3" /> Salin URL
                                </>
                              )}
                            </button>
                            <button
                              onClick={() => deleteImage(img.id)}
                              className="nb-border bg-red-500 hover:bg-red-600 text-white p-1 rounded"
                              title="Hapus"
                            >
                              <Trash2 className="w-3 h-3" />
                            </button>
                          </div>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}
            </div>
          )}

          {/* TAB 2: 5 CLOUDINARY ACCOUNTS CONFIG */}
          {activeTab === "accounts" && (
            <div className="space-y-4">
              <div className="nb-border bg-blue-50 p-3 rounded-[var(--radius)] text-xs border-black">
                <p className="font-bold uppercase mb-1">☁️ Konfigurasi 5 Akun Cloudinary Multiple</p>
                <p className="text-muted-foreground text-[11px]">
                  Masukkan Cloud Name, API Key, API Secret, dan Upload Preset untuk 5 Akun Cloudinary kamu. Kamu dapat berpindah akun aktif kapan saja.
                </p>
              </div>

              <div className="space-y-4">
                {accounts.map((acc, idx) => (
                  <div
                    key={acc.id}
                    className={`nb-border p-4 rounded-[var(--radius)] shadow-[3px_3px_0_0_#000] space-y-3 transition-colors ${
                      acc.isActive ? "bg-yellow-50 border-black" : "bg-white"
                    }`}
                  >
                    <div className="flex items-center justify-between border-b-2 border-black/10 pb-2">
                      <div className="flex items-center gap-2">
                        <span className="bg-black text-white font-mono text-xs px-2 py-0.5 rounded font-bold">
                          #{acc.id}
                        </span>
                        <input
                          type="text"
                          value={acc.name}
                          onChange={(e) => {
                            const updated = [...accounts];
                            updated[idx].name = e.target.value;
                            saveAccounts(updated);
                          }}
                          className="font-bold text-sm bg-transparent border-b border-dashed border-black px-1 focus:outline-none"
                        />
                      </div>
                      <button
                        onClick={() => {
                          const updated = accounts.map((a) => ({ ...a, isActive: a.id === acc.id }));
                          saveAccounts(updated);
                          setSelectedAccountId(acc.id);
                        }}
                        className={`px-3 py-1 text-xs font-bold uppercase rounded-[var(--radius)] border-2 border-black ${
                          acc.isActive
                            ? "bg-green-500 text-white shadow-[2px_2px_0_0_#000]"
                            : "bg-gray-100 text-black hover:bg-gray-200"
                        }`}
                      >
                        {acc.isActive ? "✓ Akun Aktif" : "Set Aktif"}
                      </button>
                    </div>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
                      <div>
                        <label className="font-bold block mb-1">Cloud Name *</label>
                        <input
                          type="text"
                          placeholder="mis: dresar_cloud"
                          value={acc.cloudName}
                          onChange={(e) => {
                            const updated = [...accounts];
                            updated[idx].cloudName = e.target.value.trim();
                            saveAccounts(updated);
                          }}
                          className="w-full nb-border bg-white px-3 py-1.5 font-mono text-xs rounded"
                        />
                      </div>
                      <div>
                        <label className="font-bold block mb-1">Upload Preset (Unsigned)</label>
                        <input
                          type="text"
                          placeholder="mis: ml_default / preset_studio"
                          value={acc.uploadPreset}
                          onChange={(e) => {
                            const updated = [...accounts];
                            updated[idx].uploadPreset = e.target.value.trim();
                            saveAccounts(updated);
                          }}
                          className="w-full nb-border bg-white px-3 py-1.5 font-mono text-xs rounded"
                        />
                      </div>
                      <div>
                        <label className="font-bold block mb-1">API Key</label>
                        <input
                          type="text"
                          placeholder="mis: 123456789012345"
                          value={acc.apiKey}
                          onChange={(e) => {
                            const updated = [...accounts];
                            updated[idx].apiKey = e.target.value.trim();
                            saveAccounts(updated);
                          }}
                          className="w-full nb-border bg-white px-3 py-1.5 font-mono text-xs rounded"
                        />
                      </div>
                      <div>
                        <label className="font-bold block mb-1">API Secret</label>
                        <input
                          type="password"
                          placeholder="mis: secret_xxx"
                          value={acc.apiSecret}
                          onChange={(e) => {
                            const updated = [...accounts];
                            updated[idx].apiSecret = e.target.value.trim();
                            saveAccounts(updated);
                          }}
                          className="w-full nb-border bg-white px-3 py-1.5 font-mono text-xs rounded"
                        />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* TAB 3: REMOVE.BG CONFIG */}
          {activeTab === "removebg" && (
            <div className="space-y-4">
              <div className="nb-border bg-purple-50 p-4 rounded-[var(--radius)] shadow-[3px_3px_0_0_#000] border-black space-y-3">
                <div className="flex items-center gap-2">
                  <Scissors className="w-5 h-5 text-purple-700" />
                  <h3 className="font-bold text-sm uppercase">Konfigurasi Remove.bg Background Removal API</h3>
                </div>
                <p className="text-xs text-muted-foreground leading-relaxed">
                  Remove.bg digunakan untuk menghapus latar belakang gambar secara otomatis. Masukkan API Key resmi dari dashboard Remove.bg kamu.
                </p>

                <div className="space-y-2 pt-2">
                  <label className="font-bold text-xs uppercase block">Remove.bg API Key:</label>
                  <input
                    type="password"
                    placeholder="mis: xxxxxxxxxxxxxxxxxxxxxxxx"
                    value={removeBgKey}
                    onChange={(e) => saveRemoveBgKey(e.target.value.trim())}
                    className="w-full nb-border bg-white px-3 py-2 font-mono text-xs rounded-[var(--radius)] shadow-[2px_2px_0_0_#000]"
                  />
                  {removeBgKey && (
                    <p className="text-[10px] font-mono text-green-700 font-bold">
                      ✓ API Key tersimpan secara lokal.
                    </p>
                  )}
                </div>

                <div className="pt-2 text-[11px] bg-white p-3 nb-border rounded border-black space-y-1">
                  <p className="font-bold">📖 Dokumentasi Penggunaan Remove.bg:</p>
                  <ul className="list-disc list-inside text-muted-foreground space-y-1">
                    <li>Dapatkan API Key gratis di <a href="https://www.remove.bg/api" target="_blank" rel="noreferrer" className="text-purple-600 underline font-bold">remove.bg/api</a></li>
                    <li>API Key ini digunakan khusus untuk endpoint pemotongan background, terpisah dari AI Gateway & Cloudinary.</li>
                  </ul>
                </div>
              </div>
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>
  );
}
