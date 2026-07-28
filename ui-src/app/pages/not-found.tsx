import { useNavigate } from "react-router";
import { Home } from "lucide-react";

export function NotFound() {
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white flex items-center justify-center px-6">
      <div className="text-center">
        <div className="text-8xl mb-4">🤔</div>
        <h1 className="text-4xl mb-2 text-primary">404</h1>
        <p className="text-muted-foreground mb-8">页面未找到</p>
        <button
          onClick={() => navigate("/")}
          className="inline-flex items-center gap-2 px-6 py-3 rounded-lg bg-primary text-primary-foreground"
        >
          <Home className="w-5 h-5" />
          返回首页
        </button>
      </div>
    </div>
  );
}
