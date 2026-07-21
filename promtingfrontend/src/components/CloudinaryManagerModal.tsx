import React, { useState, useEffect } from "react";
import {
  Upload,
  Copy,
  Check,
  Trash2,
  Image as ImageIcon,
  ExternalLink,
  RefreshCw,
  Search,
  HardDrive,
  Loader2
} from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { toast } from "sonner";

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

export function CloudinaryManagerModal({ triggerBtn }: { triggerBtn?: React.ReactNode }) {
  const [open, setOpen] = useState(false);
  const [files, setFiles] = useState<StorageCdnFile[]>([]);
  const [loading, setLoading] = useState(false);
  const [isUploading, setIsUploading] = useState(false);
  const [uploadStatus, setUploadStatus] = useState<string>("");
  const [copiedId, setCopiedId] = useState<string | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedFile, setSelectedFile] = useState<StorageCdnFile | null>(null);

  const fetchFiles = async () => {
    setLoading(true);
    try {
      const searchParam = encodeURIComponent(searchQuery.trim());
      const res = await fetch(
        `${BASE_URL}/storage/list?page=1&limit=50&provider=cloudinary&search=${searchParam}`,
        {
          headers: { Authorization: `Bearer ${GATEWAY_KEY}` },
        }
      );
      const data = await res.json();
      if (res.ok && data.items) {
        setFiles(data.items);
      }
    } catch (err: any) {
      console.error("Failed to fetch CDN files", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (open) {
      fetchFiles();
    }
  }, [open]);

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const inputFiles = e.target.files;
    if (!inputFiles || inputFiles.length === 0) return;

    setIsUploading(true);
    setUploadStatus(`Mengunggah 0/${inputFiles.length} berkas ke Storage CDN Gateway...`);

    let successCount = 0;

    for (let i = 0; i < inputFiles.length; i++) {
      const file = inputFiles[i];
      setUploadStatus(`Mengunggah (${i + 1}/${inputFiles.length}): ${file.name}`);

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
          toast.error(`Gagal upload ${file.name}: ${data.message || "Upload error"}`);
        }
      } catch (err: any) {
        toast.error(`Gagal upload ${file.name}: ${err.message}`);
      }
    }

    setIsUploading(false);
    setUploadStatus("");
    e.target.value = "";

    if (successCount > 0) {
      toast.success(`Berhasil mengunggah ${successCount} gambar ke Storage Gateway!`);
      fetchFiles();
    }
  };

  const copyToClipboard = (url: string, id: string) => {
    navigator.clipboard.writeText(url);
    setCopiedId(id);
    toast.success("URL CDN berhasil disalin!");
    setTimeout(() => setCopiedId(null), 2000);
  };

  const handleDeleteFile = async (id: string, e?: React.MouseEvent) => {
    if (e) e.stopPropagation();
    if (!confirm("Hapus berkas CDN ini dari database persisten?")) return;

    try {
      const res = await fetch(`${BASE_URL}/storage/files/${id}`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${GATEWAY_KEY}` },
      });
      const data = await res.json();
      if (res.ok && data.success) {
        toast.success("Berkas terhapus dari CDN Gateway");
        setFiles((prev) => prev.filter((f) => f.id !== id));
        if (selectedFile?.id === id) setSelectedFile(null);
      } else {
        toast.error(data.message || "Gagal menghapus berkas");
      }
    } catch (err: any) {
      toast.error(`Error hapus: ${err.message}`);
    }
  };

  return (
    <Dialog open={open} onOpenChange={setOpen}>
      <DialogTrigger asChild>
        {triggerBtn || (
          <button className="nb-border nb-shadow-sm rounded-[var(--radius)] bg-[var(--nb-yellow)] hover:bg-yellow-400 text-black px-2.5 py-1.5 md:px-3 md:py-2 font-bold uppercase text-xs flex items-center gap-2 nb-press transition-all">
            <HardDrive className="w-4 h-4 text-black" />
            <span className="hidden sm:inline">Storage CDN Gateway</span>
          </button>
        )}
      </DialogTrigger>

      <DialogContent className="max-w-4xl w-[95vw] max-h-[90vh] flex flex-col p-0 nb-border shadow-[6px_6px_0_0_#000] bg-white rounded-[var(--radius)] overflow-hidden">
        {/* Header */}
        <DialogHeader className="p-4 bg-[var(--nb-yellow)] border-b-[3px] border-black flex flex-row items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className="nb-border bg-white p-1.5 rounded-[var(--radius)] shadow-[2px_2px_0_0_#000]">
              <HardDrive className="w-5 h-5 text-black" />
            </div>
            <div>
              <DialogTitle className="font-bold text-sm md:text-base uppercase tracking-wider">
                Storage CDN Gateway Manager
              </DialogTitle>
              <p className="text-[10px] md:text-xs font-mono text-black/70">
                Penyimpanan Media Terpusat (Multi-CDN Persistent Database)
              </p>
            </div>
          </div>
        </DialogHeader>

        {/* Toolbar: Search & Mass Upload */}
        <div className="p-3 bg-gray-100 border-b-2 border-black flex flex-wrap gap-2 items-center justify-between">
          <div className="relative flex-1 min-w-[200px]">
            <Search className="w-4 h-4 absolute left-2.5 top-2.5 text-gray-500" />
            <input
              type="text"
              placeholder="Cari nama berkas CDN..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && fetchFiles()}
              className="w-full pl-8 pr-3 py-1.5 text-xs font-mono bg-white nb-border rounded-[var(--radius)] focus:outline-none"
            />
          </div>

          <div className="flex gap-2 items-center">
            <button
              onClick={fetchFiles}
              disabled={loading}
              className="nb-border nb-shadow-sm bg-white hover:bg-gray-50 text-black px-3 py-1.5 text-xs font-bold uppercase rounded-[var(--radius)] flex items-center gap-1.5"
            >
              <RefreshCw className={`w-3.5 h-3.5 ${loading ? "animate-spin" : ""}`} />
              Refresh
            </button>

            <label className="nb-border nb-shadow-sm bg-[var(--nb-green)] hover:bg-green-400 text-black px-3 py-1.5 text-xs font-bold uppercase rounded-[var(--radius)] cursor-pointer flex items-center gap-1.5 whitespace-nowrap nb-press">
              <Upload className="w-3.5 h-3.5" />
              {isUploading ? "Uploading..." : "Upload Berkas (Massal)"}
              <input
                type="file"
                multiple
                accept="image/*"
                onChange={handleFileUpload}
                disabled={isUploading}
                className="hidden"
              />
            </label>
          </div>
        </div>

        {isUploading && (
          <div className="bg-blue-100 text-blue-900 border-b-2 border-black p-2 text-xs font-mono flex items-center gap-2">
            <Loader2 className="w-4 h-4 animate-spin" />
            <span>{uploadStatus}</span>
          </div>
        )}

        {/* Main Content Body */}
        <div className="flex-1 overflow-y-auto p-4 bg-gray-50 min-h-[350px]">
          {loading ? (
            <div className="py-16 text-center font-mono text-xs text-gray-500 flex flex-col items-center gap-2">
              <Loader2 className="w-6 h-6 animate-spin text-black" />
              <span>Memuat daftar berkas CDN dari Gateway...</span>
            </div>
          ) : files.length === 0 ? (
            <div className="py-16 text-center font-mono text-xs text-gray-500 flex flex-col items-center gap-2">
              <ImageIcon className="w-10 h-10 text-gray-300" />
              <span>Belum ada gambar terunggah di Storage CDN Gateway</span>
            </div>
          ) : (
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-3">
              {files.map((file) => (
                <div
                  key={file.id}
                  onClick={() => setSelectedFile(file)}
                  className={`nb-border rounded-[var(--radius)] bg-white overflow-hidden shadow-[2px_2px_0_0_#000] hover:shadow-[4px_4px_0_0_#000] transition-all cursor-pointer flex flex-col group relative w-full ${
                    selectedFile?.id === file.id ? "ring-2 ring-black bg-yellow-50" : ""
                  }`}
                >
                  <div className="aspect-square bg-gray-100 relative overflow-hidden flex items-center justify-center border-b border-black">
                    <img
                      src={file.url}
                      alt={file.file_name || file.id}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-200"
                      loading="lazy"
                    />
                    <span className="absolute top-1 left-1 bg-black/80 text-white text-[8px] font-mono uppercase px-1.5 py-0.5 rounded">
                      {file.provider}
                    </span>
                  </div>

                  <div className="p-2 flex flex-col justify-between flex-1">
                    <p className="text-[11px] font-bold truncate text-gray-800" title={file.file_name}>
                      {file.file_name || file.id}
                    </p>
                    <div className="flex items-center justify-between text-[9px] font-mono text-gray-500 mt-1">
                      <span>{file.width && file.height ? `${file.width}x${file.height}` : "IMG"}</span>
                      <span>{file.file_size ? `${(file.file_size / 1024).toFixed(0)} KB` : ""}</span>
                    </div>

                    <div className="flex items-center justify-between mt-2 pt-1.5 border-t border-gray-200">
                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          copyToClipboard(file.url, file.id);
                        }}
                        className="p-1 hover:bg-gray-100 rounded text-gray-700 hover:text-black transition-colors"
                        title="Salin URL"
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
                        className="p-1 hover:bg-gray-100 rounded text-gray-700 hover:text-black transition-colors"
                        title="Buka Direct URL"
                      >
                        <ExternalLink className="w-3.5 h-3.5" />
                      </button>

                      <button
                        onClick={(e) => handleDeleteFile(file.id, e)}
                        className="p-1 hover:bg-red-100 rounded text-red-600 transition-colors"
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
        </div>

        {/* Selected File Footer Info */}
        {selectedFile && (
          <div className="p-3 bg-yellow-100 border-t-2 border-black flex flex-wrap gap-3 items-center justify-between text-xs font-mono">
            <div className="flex items-center gap-3 overflow-hidden">
              <img src={selectedFile.url} alt="" className="w-10 h-10 object-cover rounded border border-black" />
              <div className="truncate">
                <p className="font-bold text-black truncate">{selectedFile.file_name || selectedFile.id}</p>
                <p className="text-[10px] text-gray-600">
                  ID: {selectedFile.id} | {selectedFile.width}x{selectedFile.height} px | {selectedFile.provider}
                </p>
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={() => copyToClipboard(selectedFile.url, selectedFile.id)}
                className="nb-border bg-white hover:bg-gray-50 px-2.5 py-1 text-xs font-bold uppercase rounded-[var(--radius)] flex items-center gap-1"
              >
                <Copy className="w-3 h-3" /> Salin URL
              </button>
              <button
                onClick={() => handleDeleteFile(selectedFile.id)}
                className="nb-border bg-red-500 hover:bg-red-600 text-white px-2.5 py-1 text-xs font-bold uppercase rounded-[var(--radius)] flex items-center gap-1"
              >
                <Trash2 className="w-3 h-3" /> Hapus
              </button>
            </div>
          </div>
        )}
      </DialogContent>
    </Dialog>
  );
}
