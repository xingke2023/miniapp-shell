import { Outlet, useLocation, useNavigate } from "react-router";
import { Home, MessageCircle, User } from "lucide-react";
import { useEffect } from "react";

export function Root() {
  const location = useLocation();
  const navigate = useNavigate();

  const navigation = [
    { name: "首页", path: "/", icon: Home },
    { name: "AI交互", path: "/ai-chat", icon: MessageCircle, primary: true },
    { name: "我的", path: "/profile", icon: User },
  ];

  // 检查认证状态
  useEffect(() => {
    const isAuthenticated = localStorage.getItem("authenticated");
    if (!isAuthenticated && location.pathname !== "/register") {
      navigate("/register");
    }
  }, [location.pathname, navigate]);

  // 在AI对话页隐藏底部导航栏
  const hideNavbar = location.pathname === "/ai-chat";

  return (
    <div className="flex flex-col h-screen bg-background">
      <main className={`flex-1 overflow-y-auto ${hideNavbar ? "" : "pb-20"}`}>
        <Outlet />
      </main>

      {/* 底部导航栏 */}
      {!hideNavbar && (
        <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-border z-50">
          <div className="flex items-center justify-around h-16 max-w-screen-sm mx-auto">
            {navigation.map((item) => {
              const isActive = location.pathname === item.path;
              const Icon = item.icon;

              if (item.primary) {
                return (
                  <button
                    key={item.path}
                    onClick={() => navigate(item.path)}
                    className="flex flex-col items-center justify-center -mt-8"
                  >
                    <div className="w-14 h-14 rounded-full bg-gradient-to-br from-primary to-accent shadow-lg flex items-center justify-center">
                      <Icon className="w-7 h-7 text-white" />
                    </div>
                  </button>
                );
              }

              return (
                <button
                  key={item.path}
                  onClick={() => navigate(item.path)}
                  className={`flex flex-col items-center justify-center gap-1 px-4 py-2 transition-colors ${
                    isActive ? "text-primary" : "text-muted-foreground"
                  }`}
                >
                  <Icon className="w-6 h-6" />
                  <span className="text-xs">{item.name}</span>
                </button>
              );
            })}
          </div>
        </nav>
      )}
    </div>
  );
}