import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import { useState } from "react";
import { toast } from "sonner";
import { api } from "@/lib/api";
import { nb } from "@/lib/nb";
import { Upload, ArrowLeft } from "lucide-react";

export const Route = createFileRoute("/_admin/characters/new")({
  component: CharactersNewPage,
});

function CharactersNewPage() {
  const qc = useQueryClient();
  const navigate = useNavigate();
  const [uploading, setUploading] = useState(false);
  const [form, setForm] = useState({
    name: "",
    description: "",
    imageUrl: "",
    promptConsistency: "",
    masterPrompt: "",
    positivePrompt: "",
    negativePrompt: "",
    characterBible: "",
    category: "general",
    isActive: true,
  });

  const categories = ["general", "human", "animal", "fantasy", "mascot", "robot"];

  const saveMut = useMutation({
    mutationFn: () => {
      const body = {
        name: form.name,
        description: form.description,
        imageUrl: form.imageUrl,
        promptConsistency: form.promptConsistency,
        masterPrompt: form.masterPrompt,
        positivePrompt: form.positivePrompt,
        negativePrompt: form.negativePrompt,
        characterBible: form.characterBible ? JSON.parse(form.characterBible) : null,
        category: form.category,
      };
      return api(`/admin/characters`, { method: "POST", body });
    },
    onSuccess: () => {
      toast.success("Karakter ditambahkan");
      qc.invalidateQueries({ queryKey: ["admin", "characters"] });
      navigate({ to: "/characters" });
    },
    onError: (e: any) => toast.error(e.message),
  });

  async function handleFile(file: File) {
    setUploading(true);
    try {
      const base64: string = await new Promise((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(reader.result as string);
        reader.onerror = reject;
        reader.readAsDataURL(file);
      });
      const res = await api<any>("/poster/upload", {
        method: "POST",
        body: { image: base64, fileName: file.name },
      });
      const url = res.url || res.data?.url;
      if (!url) throw new Error("Upload gagal: URL kosong");
      setForm((f) => ({ ...f, imageUrl: url }));
      toast.success("Gambar terupload");
    } catch (e: any) {
      toast.error(e.message);
    } finally {
      setUploading(false);
    }
  }

  return (
    <div className="max-w-2xl mx-auto space-y-5">
      <div className="flex items-center gap-4">
        <button onClick={() => navigate({ to: "/characters" })} className={`${nb.btn} bg-white`}>
          <ArrowLeft className="w-4 h-4" />
        </button>
        <div>
          <h2 className="text-2xl">Tambah Karakter Baru</h2>
          <p className="text-sm text-muted-foreground font-mono">
            Isi detail karakter untuk ditambahkan ke pustaka
          </p>
        </div>
      </div>

      <div className={`${nb.card} p-6`}>
        <form
          onSubmit={(e) => {
            e.preventDefault();
            saveMut.mutate();
          }}
          className="space-y-4"
        >
          <div>
            <label className={nb.label}>Nama Karakter</label>
            <input
              required
              value={form.name}
              onChange={(e) => setForm({ ...form, name: e.target.value })}
              className={nb.input}
              placeholder="mis: Gadis Hijab Ceria, Robot AI Helper"
            />
          </div>
          <div>
            <label className={nb.label}>Kategori</label>
            <select
              value={form.category}
              onChange={(e) => setForm({ ...form, category: e.target.value })}
              className={nb.input}
            >
              {categories.map((cat) => (
                <option key={cat} value={cat}>
                  {cat.charAt(0).toUpperCase() + cat.slice(1)}
                </option>
              ))}
            </select>
          </div>
          <div>
            <label className={nb.label}>Deskripsi</label>
            <textarea
              required
              rows={3}
              value={form.description}
              onChange={(e) => setForm({ ...form, description: e.target.value })}
              className={`${nb.input} text-sm`}
              placeholder="Deskripsi singkat karakter — siapa dia, tampilan fisik, kepribadian"
            />
          </div>
          <div>
            <label className={nb.label}>Prompt Konsistensi (Singkat)</label>
            <textarea
              required
              rows={3}
              value={form.promptConsistency}
              onChange={(e) => setForm({ ...form, promptConsistency: e.target.value })}
              className={`${nb.input} font-mono text-xs`}
              placeholder="Prompt singkat konsistensi (legacy)"
            />
          </div>
          <div>
            <label className={nb.label}>Master Prompt</label>
            <textarea
              rows={6}
              value={form.masterPrompt}
              onChange={(e) => setForm({ ...form, masterPrompt: e.target.value })}
              className={`${nb.input} font-mono text-xs`}
              placeholder="Aturan ketat / blueprint mutlak karakter (menimpa Prompt Konsistensi)"
            />
          </div>
          <div>
            <label className={nb.label}>Positive Prompt (Tags)</label>
            <textarea
              rows={3}
              value={form.positivePrompt}
              onChange={(e) => setForm({ ...form, positivePrompt: e.target.value })}
              className={`${nb.input} font-mono text-xs`}
              placeholder="Tags wajib yang harus selalu ada di gambar"
            />
          </div>
          <div>
            <label className={nb.label}>Negative Prompt</label>
            <textarea
              rows={3}
              value={form.negativePrompt}
              onChange={(e) => setForm({ ...form, negativePrompt: e.target.value })}
              className={`${nb.input} font-mono text-xs`}
              placeholder="Hal yang dilarang (mis: manusia, rambut, pakaian)"
            />
          </div>
          <div>
            <label className={nb.label}>Character Bible (JSON)</label>
            <textarea
              rows={4}
              value={form.characterBible}
              onChange={(e) => setForm({ ...form, characterBible: e.target.value })}
              className={`${nb.input} font-mono text-[10px]`}
              placeholder="{... JSON ...}"
            />
          </div>
          <div>
            <label className={nb.label}>Gambar Karakter (URL atau Upload)</label>
            <div className="flex gap-2 mb-2">
              <input
                type="text"
                value={form.imageUrl}
                onChange={(e) => setForm({ ...form, imageUrl: e.target.value })}
                className={`${nb.input} flex-1 text-sm`}
                placeholder="https://contoh.com/gambar.png"
              />
            </div>
            <div className="nb-border rounded-[var(--radius)] bg-muted p-3 space-y-2">
              {form.imageUrl && (
                <img
                  src={form.imageUrl}
                  alt="preview"
                  className="w-full aspect-video object-cover nb-border rounded-md"
                />
              )}
              <label className={`${nb.btn} ${nb.btnBlack} w-full cursor-pointer`}>
                <Upload className="w-4 h-4" />
                {uploading ? "MENGUPLOAD…" : "PILIH GAMBAR KARAKTER"}
                <input
                  type="file"
                  accept="image/*"
                  hidden
                  onChange={(e) => e.target.files?.[0] && handleFile(e.target.files[0])}
                />
              </label>
            </div>
          </div>
          <button
            type="submit"
            disabled={saveMut.isPending}
            className={`${nb.btn} ${nb.btnGreen} w-full mt-4`}
          >
            {saveMut.isPending ? "MENYIMPAN…" : "SIMPAN KARAKTER"}
          </button>
        </form>
      </div>
    </div>
  );
}
