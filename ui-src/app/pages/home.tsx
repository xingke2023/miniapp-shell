import { useNavigate } from "react-router";
import {
  FileText,
  TrendingUp,
  Users,
  Lock,
  AlertTriangle,
  Sparkles,
  Package,
  Sun,
  CloudRain,
  X,
  Cloud,
  ChevronRight,
  CreditCard,
  BarChart3,
} from "lucide-react";
import { useState } from "react";
import { toast } from "sonner";
import { ImageWithFallback } from "../components/figma/ImageWithFallback";

export function Home() {
  const navigate = useNavigate();
  const [alerts, setAlerts] = useState([
    {
      id: 1,
      type: "warning",
      title: "清货建议",
      content: "草莓库存较多，建议今日促销清货",
      details:
        "当前草莓库存15kg，预计2天内品质下降，建议8折促销",
    },
    {
      id: 2,
      type: "info",
      title: "补货建议",
      content: "香蕉库存不足，建议明日补货",
      details: "预计今日售完，明日需补货约20kg",
    },
    {
      id: 3,
      type: "weather",
      title: "天气预警",
      content: "预计6小时后有雨，注意调整户外商品",
      details: "今日18:00后有中雨，建议提前将户外商品移入室内",
    },
  ]);

  const weekWeather = [
    {
      day: "周二",
      icon: Sun,
      temp: "22°",
      high: "24°",
      low: "18°",
    },
    {
      day: "周三",
      icon: Cloud,
      temp: "20°",
      high: "22°",
      low: "17°",
    },
    {
      day: "周四",
      icon: CloudRain,
      temp: "18°",
      high: "20°",
      low: "15°",
    },
    {
      day: "周五",
      icon: Cloud,
      temp: "21°",
      high: "23°",
      low: "16°",
    },
    {
      day: "周六",
      icon: Sun,
      temp: "23°",
      high: "25°",
      low: "19°",
    },
    {
      day: "周日",
      icon: Sun,
      temp: "24°",
      high: "26°",
      low: "20°",
    },
    {
      day: "周一",
      icon: CloudRain,
      temp: "19°",
      high: "21°",
      low: "16°",
    },
  ];

  const mainActions = [
    {
      title: "上传到货单",
      icon: FileText,
      bgColor: "bg-[#941100]",
      action: () =>
        navigate("/ai-chat", {
          state: { mode: "upload-delivery" },
        }),
    },
    {
      title: "上传竞品情报",
      icon: Users,
      bgColor: "bg-[#FF9300]",
      action: () =>
        navigate("/ai-chat", {
          state: { mode: "competitor-info" },
        }),
    },
    {
      title: "上传支付凭证",
      icon: CreditCard,
      bgColor: "bg-[#941100]",
      action: () =>
        navigate("/ai-chat", { state: { mode: "payment" } }),
    },
    {
      title: "今日盘存",
      icon: Package,
      bgColor: "bg-[#FF9300]",
      action: () =>
        navigate("/ai-chat", { state: { mode: "inventory" } }),
    },
    {
      title: "今日数据",
      icon: BarChart3,
      bgColor: "bg-[#941100]",
      action: () =>
        navigate("/ai-chat", {
          state: { mode: "daily-summary" },
        }),
    },
    {
      title: "敬请期待",
      icon: Lock,
      bgColor: "bg-gray-400",
      action: () => {},
      disabled: true,
    },
  ];

  const handleClose = (id: number) => {
    setAlerts(alerts.filter((alert) => alert.id !== id));
    toast.success("感谢反馈，我们将持续优化模型");
  };

  const handleViewDetails = (alert: any) => {
    navigate("/ai-chat", { state: { alert } });
  };

  const getAlertIcon = (type: string) => {
    switch (type) {
      case "warning":
        return (
          <AlertTriangle className="w-5 h-5 text-accent" />
        );
      case "weather":
        return <CloudRain className="w-5 h-5 text-blue-500" />;
      default:
        return <Sparkles className="w-5 h-5 text-primary" />;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white">
      {/* 头部信息 - 带背景图片 */}
      <div className="relative overflow-visible pb-2.5">
        <div className="relative h-48 rounded-b-3xl overflow-hidden">
          {/* 背景图片 */}
          <ImageWithFallback
            src="https://images.unsplash.com/photo-1549248581-cf105cd081f8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmcmVzaCUyMHByb2R1Y2UlMjBtYXJrZXQlMjB2ZWdldGFibGVzfGVufDF8fHx8MTc3NTAyNzg0NHww&ixlib=rb-4.1.0&q=80&w=1080"
            alt="生鲜背景"
            className="absolute inset-0 w-full h-full object-cover"
          />
          {/* 主题色蒙版 */}
          <div className="absolute inset-0 bg-gradient-to-br from-primary to-accent opacity-50"></div>

          {/* 内容 */}
          <div className="relative text-white p-6 h-full flex flex-col justify-between">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm opacity-90">今天是</p>
                <h2 className="text-xl">2026年4月1日 星期三</h2>
              </div>
              <div className="flex items-center gap-2">
                <Sun className="w-6 h-6" />
                <span className="text-lg">22°C</span>
              </div>
            </div>
          </div>
        </div>

        {/* 一周天气预报 - 溢出在背景框下方 */}
        <div className="px-6 -mt-12 relative z-10">
          <div className="bg-white/95 backdrop-blur-sm rounded-xl p-3 shadow-lg overflow-x-auto border border-primary/10">
            <div className="flex gap-3 min-w-max">
              {weekWeather.map((weather, index) => {
                const WeatherIcon = weather.icon;
                return (
                  <div
                    key={index}
                    className="flex flex-col items-center gap-1 min-w-[50px]"
                  >
                    <p className="text-xs text-muted-foreground">
                      {weather.day}
                    </p>
                    <WeatherIcon className="w-5 h-5 text-primary" />
                    <p className="text-sm">{weather.temp}</p>
                    <div className="flex gap-1 text-xs text-muted-foreground">
                      <span>{weather.high}</span>
                      <span>/</span>
                      <span>{weather.low}</span>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      {/* 主要功能区 - 在背景框下方 */}
      <div className="px-6 mt-2.5 mb-6">
        <div className="grid grid-cols-3 gap-3">
          {mainActions.map((action, index) => {
            const Icon = action.icon;
            return (
              <button
                key={index}
                onClick={action.action}
                disabled={action.disabled}
                className={`${action.bgColor} text-white p-4 rounded-xl shadow-md flex flex-col items-center gap-2 transition-all active:scale-95 disabled:opacity-60 disabled:cursor-not-allowed hover:shadow-lg`}
              >
                <Icon className="w-7 h-7" strokeWidth={2} />
                <span className="text-xs text-center leading-tight font-medium">
                  {action.title}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* AI建议和预警 */}
      <div className="px-6 pb-6">
        <div className="flex items-center gap-2 mb-4">
          <Sparkles className="w-5 h-5 text-primary" />
          <h3 className="text-lg">AI智能建议</h3>
        </div>

        <div className="space-y-3">
          {alerts.length === 0 ? (
            <div className="bg-white rounded-xl p-6 text-center">
              <Package className="w-12 h-12 text-muted-foreground mx-auto mb-2" />
              <p className="text-muted-foreground">
                暂无新的建议
              </p>
            </div>
          ) : (
            alerts.map((alert) => (
              <div
                key={alert.id}
                className="bg-white rounded-xl p-4 shadow-sm border border-border"
              >
                <div className="flex items-start gap-3">
                  <div className="mt-0.5">
                    {getAlertIcon(alert.type)}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="text-sm mb-1">
                      {alert.title}
                    </h4>
                    <p className="text-sm text-muted-foreground">
                      {alert.content}
                    </p>
                  </div>
                  <button
                    onClick={() => handleClose(alert.id)}
                    className="text-muted-foreground hover:text-foreground transition-colors"
                  >
                    <X className="w-4 h-4" />
                  </button>
                </div>
                <div className="flex items-center justify-end mt-3">
                  <button
                    onClick={() => handleViewDetails(alert)}
                    className="flex items-center gap-1 text-sm text-primary hover:text-primary/80 transition-colors"
                  >
                    查看详情
                    <ChevronRight className="w-4 h-4" />
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}