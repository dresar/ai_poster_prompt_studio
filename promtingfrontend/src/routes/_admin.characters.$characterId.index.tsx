import { createFileRoute, Link, useNavigate } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { api } from "@/lib/api";
import { nb } from "@/lib/nb";
import { ArrowLeft, Pencil, User, Copy } from "lucide-react";
import { toast } from "sonner";

export const Route = createFileRoute("/_admin/characters/$characterId/")({
  component: CharactersDetailPage,
});

function CharactersDetailPage() {
  const { characterId } = Route.useParams();
  const navigate = useNavigate();

  const { data: characters = [], isLoading } = useQuery<any[]>({
    queryKey: ["admin", "characters"],
    queryFn: async () => {
      const r = await api<any>(`/admin/characters`);
      return r.data || r;
    },
  });

  const character = characters.find((c) => c.id === characterId);

  const copyToClipboard = (text: string, label: string) => {
    if (!text) {
      toast.error(`${label} kosong`);
      return;
    }
    navigator.clipboard.writeText(text);
    toast.success(`${label} berhasil disalin!`);
  };

  if (isLoading) {
    return <div className="text-center p-10">Memuat...</div>;
  }

  if (!character) {
    return <div className="text-center p-10">Karakter tidak ditemukan.</div>;
  }

  return (
    <div className="max-w-4xl mx-auto space-y-5">
      <div className="flex items-center gap-4">
        <button onClick={() => navigate({ to: "/characters" })} className={`${nb.btn} bg-white`}>
          <ArrowLeft className="w-4 h-4" />
        </button>
        <div className="flex-1">
          <h2 className="text-2xl">Detail Karakter</h2>
          <p className="text-sm text-muted-foreground font-mono">
            Informasi lengkap tentang karakter
          </p>
        </div>
        <Link
          to="/characters/$characterId/edit"
          params={{ characterId }}
          className={`${nb.btn} ${nb.btnYellow}`}
        >
          <Pencil className="w-4 h-4" /> Edit Karakter
        </Link>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="md:col-span-1">
          <div className={`${nb.card} overflow-hidden`}>
            <div className="aspect-video bg-muted">
              {character.imageUrl ? (
                <img
                  src={character.imageUrl}
                  alt={character.name}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full flex items-center justify-center text-muted-foreground">
                  <User className="w-24 h-24 opacity-20" />
                </div>
              )}
            </div>
          </div>
        </div>

        <div className="md:col-span-2 space-y-4">
          <div className={`${nb.card} p-6 space-y-4`}>
            <div>
              <h3 className="text-3xl font-bold">{character.name}</h3>
              <div className="mt-2 inline-block bg-black text-white font-mono uppercase px-3 py-1 rounded text-xs">
                {character.category}
              </div>
            </div>

            <div>
              <div className="flex justify-between items-center mb-1">
                <h4 className="text-sm font-bold uppercase">Deskripsi Singkat</h4>
                <button onClick={() => copyToClipboard(character.description, "Deskripsi")} className="text-xs flex items-center gap-1 hover:text-blue-600">
                  <Copy className="w-3 h-3" /> Salin
                </button>
              </div>
              <p className="text-sm text-muted-foreground bg-muted p-3 rounded nb-border">
                {character.description || "-"}
              </p>
            </div>

            <div>
              <div className="flex justify-between items-center mb-1">
                <h4 className="text-sm font-bold uppercase">Prompt Konsistensi (Legacy)</h4>
                <button onClick={() => copyToClipboard(character.promptConsistency, "Prompt Konsistensi")} className="text-xs flex items-center gap-1 hover:text-blue-600">
                  <Copy className="w-3 h-3" /> Salin
                </button>
              </div>
              <p className="text-xs font-mono text-muted-foreground bg-muted p-3 rounded nb-border whitespace-pre-wrap">
                {character.promptConsistency || "-"}
              </p>
            </div>

            <div>
              <div className="flex justify-between items-center mb-1">
                <h4 className="text-sm font-bold uppercase text-purple-600">Master Prompt (Blueprint Mutlak)</h4>
                <button onClick={() => copyToClipboard(character.masterPrompt, "Master Prompt")} className="text-xs flex items-center gap-1 hover:text-purple-600">
                  <Copy className="w-3 h-3" /> Salin
                </button>
              </div>
              <p className="text-xs font-mono text-muted-foreground bg-purple-50 p-3 rounded nb-border border-purple-200 whitespace-pre-wrap">
                {character.masterPrompt || "-"}
              </p>
            </div>

            <div>
              <div className="flex justify-between items-center mb-1">
                <h4 className="text-sm font-bold uppercase text-green-600">Positive Prompt (Tags Wajib)</h4>
                <button onClick={() => copyToClipboard(character.positivePrompt, "Positive Prompt")} className="text-xs flex items-center gap-1 hover:text-green-600">
                  <Copy className="w-3 h-3" /> Salin
                </button>
              </div>
              <p className="text-xs font-mono text-muted-foreground bg-green-50 p-3 rounded nb-border border-green-200 whitespace-pre-wrap">
                {character.positivePrompt || "-"}
              </p>
            </div>

            <div>
              <div className="flex justify-between items-center mb-1">
                <h4 className="text-sm font-bold uppercase text-red-600">Negative Prompt (Larangan)</h4>
                <button onClick={() => copyToClipboard(character.negativePrompt, "Negative Prompt")} className="text-xs flex items-center gap-1 hover:text-red-600">
                  <Copy className="w-3 h-3" /> Salin
                </button>
              </div>
              <p className="text-xs font-mono text-muted-foreground bg-red-50 p-3 rounded nb-border border-red-200 whitespace-pre-wrap">
                {character.negativePrompt || "-"}
              </p>
            </div>

            <div>
              <div className="flex justify-between items-center mb-1">
                <h4 className="text-sm font-bold uppercase">Character Bible (JSON)</h4>
                <button onClick={() => copyToClipboard(character.characterBible ? JSON.stringify(character.characterBible, null, 2) : "", "Character Bible")} className="text-xs flex items-center gap-1 hover:text-blue-600">
                  <Copy className="w-3 h-3" /> Salin JSON
                </button>
              </div>
              <pre className="text-[10px] font-mono text-muted-foreground bg-muted p-3 rounded nb-border overflow-auto max-h-40">
                {character.characterBible ? JSON.stringify(character.characterBible, null, 2) : "-"}
              </pre>
            </div>

            <div className="pt-4 border-t-2 border-black/10">
              <p className="text-xs font-mono text-muted-foreground">
                ID: {character.id}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
