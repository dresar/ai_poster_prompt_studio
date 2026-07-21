import { createFileRoute } from "@tanstack/react-router";
import { useQuery } from "@tanstack/react-query";
import { api, tokenStore } from "@/lib/api";
import { nb } from "@/lib/nb";
import { RefreshCw, Users, Ticket, Sparkles, KeyRound } from "lucide-react";
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
} from "recharts";

export const Route = createFileRoute("/_admin/dashboard")({
  component: DashboardPage,
});

type Stats = {
  totalUsers?: number;
  promptsToday?: number;
  avgViralScore?: number;
  healthyGeminiKeys?: number;
  usage7d?: { date: string; count: number }[];
};

function DashboardPage() {
  const { data, isFetching, refetch } = useQuery<Stats>({
    queryKey: ["admin", "stats"],
    queryFn: async () => {
      const r = await api<any>("/admin/stats");
      const d = r.data || r;
      return {
        totalUsers: d.totalUsers,
        promptsToday: d.totalPromptsToday,
        avgViralScore: d.averageViralScore,
        healthyGeminiKeys: d.geminiKeys?.healthy,
        usage7d: d.chartData || [],
      };
    },
    enabled: tokenStore.user?.role === "ADMIN",
  });

  const s = data || {};
  const chart = s.usage7d || [];

  const cards = [
    {
      label: "Total Pengguna",
      value: s.totalUsers ?? 0,
      icon: Users,
      bgColor: "var(--nb-yellow)",
      textColor: "black",
    },
    {
      label: "Prompt Hari Ini",
      value: s.promptsToday ?? 0,
      icon: Sparkles,
      bgColor: "var(--nb-green)",
      textColor: "white",
    },
    {
      label: "Skor Viral Rata-rata",
      value: s.avgViralScore ?? 0,
      icon: Ticket,
      bgColor: "var(--nb-pink)",
      textColor: "white",
    },
    {
      label: "Kunci Provider Sehat",
      value: s.healthyGeminiKeys ?? 0,
      icon: KeyRound,
      bgColor: "var(--nb-blue)",
      textColor: "white",
    },
  ];

  return (
    <div className="space-y-4 md:space-y-6">
      <div className="flex items-end justify-between flex-wrap gap-2 md:gap-3">
        <div>
          <h2 className="text-xl md:text-2xl font-bold uppercase">📊 Ringkasan</h2>
          <p className="text-[10px] md:text-sm text-muted-foreground font-mono">
            Statistik real-time platform.
          </p>
        </div>
        <button
          onClick={() => refetch()}
          className={`${nb.btn} ${nb.btnBlack} text-[10px] md:text-sm px-2.5 py-1.5 md:px-4 md:py-2 flex items-center gap-1.5 md:gap-2`}
          disabled={isFetching}
        >
          <RefreshCw className={`w-3.5 h-3.5 md:w-4 md:h-4 ${isFetching ? "animate-spin" : ""}`} />
          Refresh
        </button>
      </div>

      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4">
        {cards.map((c) => {
          const Icon = c.icon;
          return (
            <div 
              key={c.label} 
              className={`${nb.card} p-3 md:p-5 shadow-[3px_3px_0_0_rgba(0,0,0,1)] md:shadow-[4px_4px_0_0_rgba(0,0,0,1)] border-2 border-black`}
              style={{ backgroundColor: c.bgColor, color: c.textColor }}
            >
              <Icon className="w-4 h-4 md:w-6 md:h-6 mb-2 md:mb-3" strokeWidth={2.5} />
              <p className="text-[9px] md:text-xs uppercase font-bold opacity-80 leading-tight">{c.label}</p>
              <p className="text-xl md:text-4xl font-mono font-bold mt-1">{String(c.value)}</p>
            </div>
          );
        })}
      </div>

      <div className={`${nb.card} p-3 md:p-5`}>
        <h3 className="text-base md:text-lg mb-3 md:mb-4 font-bold">Prompt Terbuat (7 Hari)</h3>
        <div className="h-48 md:h-72 w-full">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={chart}>
              <CartesianGrid stroke="#000" strokeDasharray="4 4" strokeOpacity={0.15} />
              <XAxis
                dataKey="date"
                stroke="#000"
                tick={{ fontFamily: "Fira Code", fontSize: 9 }}
              />
              <YAxis width={30} stroke="#000" tick={{ fontFamily: "Fira Code", fontSize: 9 }} />
              <Tooltip
                contentStyle={{
                  border: "2px solid #000",
                  borderRadius: 8,
                  boxShadow: "3px 3px 0 #000",
                  background: "#fff",
                  fontFamily: "Fira Code",
                  fontSize: "10px"
                }}
              />
              <Bar dataKey="count" fill="#ec4899" stroke="#000" strokeWidth={2} />
            </BarChart>
          </ResponsiveContainer>
        </div>
        {chart.length === 0 && (
          <p className="text-center text-[10px] md:text-sm text-muted-foreground font-mono mt-3 md:mt-4">
            Belum ada data usage.
          </p>
        )}
      </div>
    </div>
  );
}
