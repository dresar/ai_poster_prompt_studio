import { createFileRoute } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import {
  Image as ImageIcon,
  Upload,
  Copy,
  Trash2,
  ExternalLink,
  RefreshCw,
  Search,
  Check,
  Info,
  Loader2,
  HardDrive,
  Filter,
  X
} from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { toast } from "sonner";
import { triggerAppNotification } from "@/lib/browserNotifications";

export const Route = createFileRoute("/_admin/media")({
  component: AdminMediaPage,
});

export interface StorageCdnFile {
  id: string;
  provider: string;
  url: string;
  file_id?: string;
  file_name?: string;
  file_size?: number;
  mime_type?: string;
  width?: number;
  height?: number;
  auto_rotated?: boolean;
  created_at?: string;
}

const GATEWAY_KEY = "AR_4c9b2435_929a80d916261b15c582db6fe3e41e52";
const BASE_URL = "https://one.apprentice.cyou/v1";

function AdminMediaPage() {
  const [files, setFiles] = useState<StorageCdnFile[]>([]);
  const [loading, setLoading] = useState(false);
  const [uploading, setUploading] = useState(false);
  const [uploadProgress, setUploadProgress] = useState("");
  const [search, setSearch] = useState("");
  const [providerFilter, setProviderFilter] = useState("cloudinary");
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [totalItems, setTotalItems] = useState(0);
  const [selectedFile, setSelectedFile] = useState<StorageCdnFile | null>(null);
  const [copiedId, setCopiedId] = useState<string | null>(null);

  const fetchFiles = async (targetPage = page) => {
    setLoading(true);
    try {
      const querySearch = encodeURIComponent(search.trim());
      const queryProvider = providerFilter !== "all" ? providerFilter : "";
      const res = await fetch(
        `${BASE_URL}/storage/list?page=${targetPage}&limit=36&provider=${queryProvider}&search=${querySearch}`,
        {
          headers: { Authorization: `Bearer ${GATEWAY_KEY}` },
        }
      );
      const data = await res.json();
      if (res.ok && data.items) {
        setFiles(data.items);
        if (data.pagination) {
          setPage(data.pagination.page);
          setTotalPages(data.pagination.total_pages);
          setTotalItems(data.pagination.total);
        }
      } else {
        toast.error(data.message || "Gagal memuat berkas CDN", { duration: 2000 });
      }
    } catch (err: any) {
      toast.error(`Gagal koneksi gateway: ${err.message}`, { duration: 2000 });
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchFiles(1);
  }, [providerFilter]);

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    fetchFiles(1);
  };

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const inputFiles = e.target.files;
    if (!inputFiles || inputFiles.length === 0) return;

    setUploading(true);
    setUploadProgress(`Mengunggah 0/${inputFiles.length} berkas...`);
    let successCount = 0;

    for (let i = 0; i < inputFiles.length; i++) {
      const file = inputFiles[i];
      setUploadProgress(`Mengunggah (${i + 1}/${inputFiles.length}): ${file.name}`);

      try {
        const reader = new FileReader();
        const base64Promise = new Promise<string>((resolve, reject) => {
          reader.onload = () => resolve(reader.result as string);
          reader.onerror = reject;
        });
        reader.readAsDataURL(file);
        const base64Data = await base64Promise;

        const res = await fetch(`${BASE_URL}/storage/upload`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${GATEWAY_KEY}`,
          },
          body: JSON.stringify({
            file: base64Data,
            file_name: file.name,
            auto_rotate: true,
            provider: "cloudinary",
          }),
        });

        const data = await res.json();
        if (res.ok && data.success) {
          successCount++;
        } else {
          toast.error(`Gagal upload ${file.name}: ${data.message || "Gateway Error"}`, { duration: 2000 });
        }
      } catch (err: any) {
        toast.error(`Error upload ${file.name}: ${err.message}`, { duration: 2000 });
      }
    }

    setUploading(false);
    setUploadProgress("");
    e.target.value = "";
    if (successCount > 0) {
      toast.success(`Berhasil mengunggah ${successCount} berkas ke CDN!`, { duration: 2000 });
      triggerAppNotification(
        "Upload CDN Berhasil! 📸",
        `Sebanyak ${successCount} media telah disimpan secara permanen di Storage CDN Gateway.`,
        "success"
      );
      fetchFiles(1);
    }
  };

  const copyToClipboard = (url: string, id: string) => {
    navigator.clipboard.writeText(url);
    setCopiedId(id);
    toast.success("URL CDN berhasil disalin!", { duration: 2000 });
    setTimeout(() => setCopiedId(null), 2000);
  };

  const handleDeleteFile = async (id: string, e?: React.MouseEvent) => {
    if (e) e.stopPropagation();
    if (!confirm("Apakah Anda yakin ingin menghapus berkas CDN ini dari database?")) return;

    try {
      const res = await fetch(`${BASE_URL}/storage/files/${id}`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${GATEWAY_KEY}` },
      });
      const data = await res.json();
      if (res.ok && data.success) {
        toast.success("Berkas CDN berhasil dihapus", { duration: 2000 });
        triggerAppNotification(
          "Berkas Terhapus 🗑️",
          `Berkas CDN ID ${id} telah dihapus dari persisten storage.`,
          "warning"
        );
        setFiles((prev) => prev.filter((f) => f.id !== id));
        if (selectedFile?.id === id) setSelectedFile(null);
      } else {
        toast.error(data.message || "Gagal menghapus berkas", { duration: 2000 });
      }
    } catch (err: any) {
      toast.error(`Error hapus berkas: ${err.message}`, { duration: 2000 });
    }
  };

  return (
    <div className="p-4 md:p-6 max-w-7xl mx-auto space-y-6">
      {/* Compact Page Header */}
      <div className="nb-border nb-shadow bg-[var(--nb-yellow)] rounded-[var(--radius)] p-3 md:p-4 flex flex-row items-center justify-between gap-3">
        <div className="flex items-center gap-2.5">
          <div className="nb-border bg-white p-2 rounded-[var(--radius)] shadow-[2px_2px_0_0_#000]">
            <HardDrive className="w-5 h-5 text-black" />
          </div>
          <div>
            <h1 className="text-sm md:text-base font-bold uppercase tracking-wider">
              Media CDN
            </h1>
          </div>
        </div>

        <label className="nb-border nb-shadow bg-black hover:bg-gray-800 text-white px-3 py-2 text-xs font-bold uppercase rounded-[var(--radius)] cursor-pointer flex items-center gap-1.5 whitespace-nowrap nb-press">
          <Upload className="w-3.5 h-3.5 text-[var(--nb-yellow)]" />
          <span className="hidden sm:inline">{uploading ? "Uploading..." : "Upload Massal Media"}</span>
          <span className="sm:hidden">{uploading ? "..." : "Upload"}</span>
          <input
            type="file"
            multiple
            accept="image/*"
            onChange={handleFileUpload}
            disabled={uploading}
            className="hidden"
          />
        </label>
      </div>

      {uploading && (
        <div className="nb-border bg-blue-100 text-blue-900 px-4 py-3 text-xs font-mono rounded-[var(--radius)] flex items-center gap-3">
          <Loader2 className="w-5 h-5 animate-spin text-blue-700" />
          <span className="font-bold">{uploadProgress}</span>
        </div>
      )}

      {/* Filter & Toolbar */}
      <div className="nb-border nb-shadow bg-white rounded-[var(--radius)] p-4 space-y-3">
        <div className="flex flex-col md:flex-row gap-3 items-center justify-between">
          <form onSubmit={handleSearchSubmit} className="flex gap-2 w-full md:w-auto flex-1">
            <div className="relative flex-1">
              <Search className="w-4 h-4 absolute left-3 top-3 text-gray-500" />
              <input
                type="text"
                placeholder="Cari berdasarkan nama berkas..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="w-full pl-9 pr-4 py-2 text-xs font-mono bg-gray-50 nb-border rounded-[var(--radius)] focus:outline-none"
              />
            </div>
            <button
              type="submit"
              className="nb-border nb-shadow bg-black text-white px-4 py-2 text-xs font-bold uppercase rounded-[var(--radius)] hover:bg-gray-800"
            >
              Cari
            </button>
          </form>

          <div className="flex flex-wrap items-center gap-2 w-full md:w-auto">
            <div className="flex items-center gap-1.5 bg-gray-100 p-1 rounded-[var(--radius)] nb-border">
              <Filter className="w-3.5 h-3.5 text-gray-600 ml-1" />
              <select
                value={providerFilter}
                onChange={(e) => setProviderFilter(e.target.value)}
                className="bg-transparent text-xs font-mono font-bold focus:outline-none cursor-pointer pr-2"
              >
                <option value="cloudinary">Cloudinary Provider</option>
                <option value="imagekit">ImageKit Provider</option>
                <option value="uploadcare">Uploadcare Provider</option>
                <option value="all">Semua Provider</option>
              </select>
            </div>

            <button
              onClick={() => fetchFiles(page)}
              disabled={loading}
              className="nb-border nb-shadow bg-white hover:bg-gray-50 text-black px-3 py-2 text-xs font-bold uppercase rounded-[var(--radius)] flex items-center gap-1.5"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? "animate-spin" : ""}`} />
              Refresh
            </button>
          </div>
        </div>

        <div className="flex items-center justify-between text-xs font-mono text-gray-600 pt-2 border-t border-gray-200">
          <span>Total Berkas Terdaftar: <strong className="text-black">{totalItems}</strong></span>
          <span>Halaman {page} dari {totalPages}</span>
        </div>
      </div>

      {/* Main Full-Width Media Grid */}
      <div className="w-full">
        {loading ? (
          <div className="nb-border bg-white rounded-[var(--radius)] p-12 text-center font-mono text-xs text-gray-500 flex flex-col items-center gap-3">
            <Loader2 className="w-8 h-8 animate-spin text-black" />
            <span>Memuat daftar berkas CDN dari Storage Gateway...</span>
          </div>
        ) : files.length === 0 ? (
          <div className="nb-border bg-white rounded-[var(--radius)] p-12 text-center font-mono text-xs text-gray-500 flex flex-col items-center gap-3">
            <ImageIcon className="w-12 h-12 text-gray-300" />
            <span>Tidak ada berkas CDN terdaftar di database</span>
          </div>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
            {files.map((file) => (
              <div
                key={file.id}
                onClick={() => setSelectedFile(file)}
                className="nb-border rounded-[var(--radius)] bg-white overflow-hidden shadow-[3px_3px_0_0_#000] hover:shadow-[5px_5px_0_0_#000] transition-all cursor-pointer flex flex-col group relative w-full"
              >
                <div className="aspect-square bg-gray-100 relative overflow-hidden flex items-center justify-center border-b-2 border-black">
                  <img
                    src={file.url}
                    alt={file.file_name || file.id}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-200"
                    loading="lazy"
                  />
                  <span className="absolute top-1.5 left-1.5 bg-black/85 text-white text-[9px] font-mono uppercase px-2 py-0.5 rounded border border-black">
                    {file.provider}
                  </span>
                </div>

                <div className="p-2.5 flex flex-col justify-between flex-1">
                  <p className="text-xs font-bold truncate text-gray-900" title={file.file_name}>
                    {file.file_name || file.id}
                  </p>

                  <div className="flex items-center justify-between text-[10px] font-mono text-gray-500 mt-1">
                    <span>{file.width && file.height ? `${file.width}x${file.height}` : "IMG"}</span>
                    <span>{file.file_size ? `${(file.file_size / 1024).toFixed(0)} KB` : ""}</span>
                  </div>

                  <div className="flex items-center justify-between mt-3 pt-2 border-t border-gray-200">
                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        copyToClipboard(file.url, file.id);
                      }}
                      className="nb-border bg-gray-50 hover:bg-yellow-200 p-1.5 rounded-[var(--radius)] text-xs transition-colors flex items-center gap-1"
                      title="Salin URL CDN"
                    >
                      {copiedId === file.id ? (
                        <Check className="w-3.5 h-3.5 text-green-600" />
                      ) : (
                        <Copy className="w-3.5 h-3.5" />
                      )}
                    </button>

                    <button
                      onClick={(e) => {
                        e.stopPropagation();
                        window.open(file.url, "_blank");
                      }}
                      className="nb-border bg-gray-50 hover:bg-blue-100 p-1.5 rounded-[var(--radius)] text-xs transition-colors"
                      title="Buka Direct URL"
                    >
                      <ExternalLink className="w-3.5 h-3.5" />
                    </button>

                    <button
                      onClick={(e) => handleDeleteFile(file.id, e)}
                      className="nb-border bg-red-100 hover:bg-red-200 text-red-700 p-1.5 rounded-[var(--radius)] text-xs transition-colors"
                      title="Hapus Berkas CDN"
                    >
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Pagination Footer */}
        {totalPages > 1 && (
          <div className="flex items-center justify-center gap-2 mt-6">
            <button
              disabled={page <= 1}
              onClick={() => fetchFiles(page - 1)}
              className="nb-border nb-shadow bg-white hover:bg-gray-100 disabled:opacity-50 px-3 py-1.5 text-xs font-bold uppercase rounded-[var(--radius)]"
            >
              Sebelumnya
            </button>
            <span className="font-mono text-xs font-bold px-3 py-1 bg-white nb-border rounded-[var(--radius)]">
              {page} / {totalPages}
            </span>
            <button
              disabled={page >= totalPages}
              onClick={() => fetchFiles(page + 1)}
              className="nb-border nb-shadow bg-white hover:bg-gray-100 disabled:opacity-50 px-3 py-1.5 text-xs font-bold uppercase rounded-[var(--radius)]"
            >
              Selanjutnya
            </button>
          </div>
        )}
      </div>

      {/* COMPACT & RESPONSIVE DETAIL POPUP MODAL */}
      <Dialog open={!!selectedFile} onOpenChange={(open) => !open && setSelectedFile(null)}>
        <DialogContent className="max-w-md w-[92vw] p-0 nb-border shadow-[6px_6px_0_0_#000] bg-white rounded-[var(--radius)] overflow-hidden">
          <DialogHeader className="p-3.5 bg-[var(--nb-yellow)] border-b-[3px] border-black flex flex-row items-center justify-between">
            <div className="flex items-center gap-2">
              <Info className="w-4 h-4 text-black" />
              <DialogTitle className="font-bold text-xs md:text-sm uppercase tracking-wider">
                Detail Berkas CDN
              </DialogTitle>
            </div>
          </DialogHeader>

          {selectedFile && (
            <div className="p-4 space-y-4 max-h-[80vh] overflow-y-auto">
              {/* Image Preview Box */}
              <div className="aspect-video bg-gray-100 nb-border rounded-[var(--radius)] overflow-hidden flex items-center justify-center relative">
                <img src={selectedFile.url} alt="" className="w-full h-full object-contain" />
                <span className="absolute top-2 left-2 bg-black/85 text-white text-[9px] font-mono uppercase px-2 py-0.5 rounded border border-black">
                  {selectedFile.provider}
                </span>
              </div>

              {/* Metadata Information List */}
              <div className="space-y-2 text-xs font-mono bg-gray-50 p-3 rounded-[var(--radius)] nb-border">
                <div>
                  <span className="text-gray-500 text-[10px] block uppercase font-bold">Nama Berkas:</span>
                  <span className="font-bold text-black break-all">{selectedFile.file_name || selectedFile.id}</span>
                </div>

                <div>
                  <span className="text-gray-500 text-[10px] block uppercase font-bold">Record ID (Database):</span>
                  <span className="font-mono text-black break-all text-[10px] bg-white p-1 rounded border border-gray-300 block mt-0.5">
                    {selectedFile.id}
                  </span>
                </div>

                <div className="grid grid-cols-2 gap-2 pt-1 border-t border-gray-200">
                  <div>
                    <span className="text-gray-500 text-[10px] block uppercase font-bold">Dimensi:</span>
                    <span className="font-bold text-gray-900">{selectedFile.width} x {selectedFile.height} px</span>
                  </div>
                  <div>
                    <span className="text-gray-500 text-[10px] block uppercase font-bold">Ukuran Berkas:</span>
                    <span className="font-bold text-gray-900">{selectedFile.file_size ? `${(selectedFile.file_size / 1024).toFixed(1)} KB` : "-"}</span>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-2 pt-1 border-t border-gray-200">
                  <div>
                    <span className="text-gray-500 text-[10px] block uppercase font-bold">Provider:</span>
                    <span className="font-bold uppercase text-indigo-600">{selectedFile.provider}</span>
                  </div>
                  <div>
                    <span className="text-gray-500 text-[10px] block uppercase font-bold">Mime Type:</span>
                    <span className="font-bold text-gray-900">{selectedFile.mime_type || "image/png"}</span>
                  </div>
                </div>

                {selectedFile.created_at && (
                  <div className="pt-1 border-t border-gray-200">
                    <span className="text-gray-500 text-[10px] block uppercase font-bold">Tanggal Unggah:</span>
                    <span className="font-bold text-gray-900">{new Date(selectedFile.created_at).toLocaleString("id-ID")}</span>
                  </div>
                )}
              </div>

              {/* Action Buttons */}
              <div className="space-y-2 pt-1">
                <button
                  onClick={() => copyToClipboard(selectedFile.url, selectedFile.id)}
                  className="w-full nb-border nb-shadow bg-[var(--nb-yellow)] hover:bg-yellow-400 text-black py-2 text-xs font-bold uppercase rounded-[var(--radius)] flex items-center justify-center gap-2 nb-press"
                >
                  <Copy className="w-4 h-4" /> Salin Direct URL
                </button>

                <button
                  onClick={() => handleDeleteFile(selectedFile.id)}
                  className="w-full nb-border nb-shadow bg-red-500 hover:bg-red-600 text-white py-2 text-xs font-bold uppercase rounded-[var(--radius)] flex items-center justify-center gap-2 nb-press"
                >
                  <Trash2 className="w-4 h-4" /> Hapus Berkas CDN
                </button>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
