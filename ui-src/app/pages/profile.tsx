import { useNavigate } from "react-router";
import {
  Camera,
  ChevronRight,
  CreditCard,
  FileText,
  TrendingUp,
  Users,
  MessageSquare,
  Settings,
  LogOut,
  Receipt,
  BarChart3,
} from "lucide-react";

export function Profile() {
  const navigate = useNavigate();

  const user = {
    name: "张店长",
    role: "店长",
    store: "香港湾仔店",
    phone: "138****8888",
    avatar: "",
  };

  // 支付凭证组
  const paymentMenuItems = [
    {
      label: "提交支付凭证",
      icon: Receipt,
      action: () => navigate("/ai-chat", { state: { mode: "payment" } }),
    },
    {
      label: "我的支付凭证",
      icon: FileText,
      action: () => navigate("/payment-records"),
    },
    {
      label: "支付统计",
      icon: BarChart3,
      action: () => navigate("/payment-stats"),
      badge: "财务可见",
    },
  ];

  // 简历库组
  const resumeMenuItems = [
    {
      label: "我要提交简历",
      icon: FileText,
      action: () => navigate("/ai-chat", { state: { mode: "resume" } }),
    },
    {
      label: "查看简历库",
      icon: Users,
      action: () => navigate("/resume-library"),
    },
  ];

  // 数据分析组
  const dataMenuItems = [
    {
      label: "竞品情报",
      icon: Users,
      action: () =>
        navigate("/ai-chat", { state: { mode: "competitor-info" } }),
    },
    {
      label: "今日盘点",
      icon: TrendingUp,
      action: () => navigate("/ai-chat", { state: { mode: "daily-summary" } }),
    },
  ];

  // 设置组
  const settingsMenuItems = [
    {
      label: "用户反馈",
      icon: MessageSquare,
      action: () => navigate("/feedback"),
    },
    {
      label: "设置",
      icon: Settings,
      action: () => navigate("/settings"),
    },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white pb-20">
      {/* 个人信息卡片 */}
      <div className="bg-gradient-to-br from-primary to-accent text-white px-6 pt-8 pb-12 rounded-b-3xl">
        <div className="flex items-center gap-4 mb-6">
          <div className="relative">
            <div className="w-20 h-20 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-3xl">
              👤
            </div>
            <button className="absolute bottom-0 right-0 w-6 h-6 bg-white rounded-full flex items-center justify-center text-primary">
              <Camera className="w-4 h-4" />
            </button>
          </div>
          <div>
            <h2 className="text-2xl mb-1">{user.name}</h2>
            <p className="text-sm opacity-90">{user.role}</p>
            <p className="text-sm opacity-75">{user.store}</p>
          </div>
        </div>
      </div>

      {/* 功能菜单 */}
      <div className="px-6 -mt-8 space-y-4">
        {/* 支付凭证组 */}
        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          <div className="px-5 py-3 bg-muted/30 border-b border-border">
            <div className="flex items-center gap-2">
              <CreditCard className="w-5 h-5 text-primary" />
              <h3 className="text-base font-semibold text-foreground">支付凭证</h3>
            </div>
          </div>
          {paymentMenuItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={index}
                onClick={item.action}
                className="w-full flex items-center justify-between px-5 py-4 hover:bg-muted/30 transition-colors border-b border-border last:border-b-0"
              >
                <div className="flex items-center gap-3">
                  <Icon className="w-5 h-5 text-muted-foreground" />
                  <span className="text-[15px] text-foreground">{item.label}</span>
                </div>
                {item.badge ? (
                  <span className="text-xs bg-secondary text-secondary-foreground px-2 py-0.5 rounded">
                    {item.badge}
                  </span>
                ) : (
                  <ChevronRight className="w-5 h-5 text-muted-foreground" />
                )}
              </button>
            );
          })}
        </div>

        {/* 简历库组 */}
        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          <div className="px-5 py-3 bg-muted/30 border-b border-border">
            <div className="flex items-center gap-2">
              <Users className="w-5 h-5 text-primary" />
              <h3 className="text-base font-semibold text-foreground">简历库</h3>
            </div>
          </div>
          {resumeMenuItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={index}
                onClick={item.action}
                className="w-full flex items-center justify-between px-5 py-4 hover:bg-muted/30 transition-colors border-b border-border last:border-b-0"
              >
                <div className="flex items-center gap-3">
                  <Icon className="w-5 h-5 text-muted-foreground" />
                  <span className="text-[15px] text-foreground">{item.label}</span>
                </div>
                <ChevronRight className="w-5 h-5 text-muted-foreground" />
              </button>
            );
          })}
        </div>

        {/* 数据分析组 */}
        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          <div className="px-5 py-3 bg-muted/30 border-b border-border">
            <div className="flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-primary" />
              <h3 className="text-base font-semibold text-foreground">数据分析</h3>
            </div>
          </div>
          {dataMenuItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={index}
                onClick={item.action}
                className="w-full flex items-center justify-between px-5 py-4 hover:bg-muted/30 transition-colors border-b border-border last:border-b-0"
              >
                <div className="flex items-center gap-3">
                  <Icon className="w-5 h-5 text-muted-foreground" />
                  <span className="text-[15px] text-foreground">{item.label}</span>
                </div>
                <ChevronRight className="w-5 h-5 text-muted-foreground" />
              </button>
            );
          })}
        </div>

        {/* 设置组 */}
        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          {settingsMenuItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={index}
                onClick={item.action}
                className="w-full flex items-center justify-between px-5 py-4 hover:bg-muted/30 transition-colors border-b border-border last:border-b-0"
              >
                <div className="flex items-center gap-3">
                  <Icon className="w-5 h-5 text-primary" />
                  <span>{item.label}</span>
                </div>
                <ChevronRight className="w-5 h-5 text-muted-foreground" />
              </button>
            );
          })}
        </div>

        {/* 退出登录 */}
        <button
          onClick={() => {
            localStorage.removeItem("authenticated");
            navigate("/login");
          }}
          className="w-full py-4 rounded-2xl bg-white shadow-lg flex items-center justify-center gap-2 text-destructive hover:bg-destructive/5 transition-colors"
        >
          <LogOut className="w-5 h-5" />
          <span>退出登录</span>
        </button>
      </div>

      {/* 版本信息 */}
      <div className="text-center mt-8 text-xs text-muted-foreground">
        <p>AI店长助手 v1.0.0</p>
      </div>
    </div>
  );
}