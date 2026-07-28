import { useState } from "react";
import { useNavigate } from "react-router";
import { ArrowRight } from "lucide-react";

export function Login() {
  const navigate = useNavigate();
  const [phone, setPhone] = useState("");
  const [code, setCode] = useState("");
  const [countdown, setCountdown] = useState(0);

  const handleSendCode = () => {
    // 模拟发送验证码
    setCountdown(180); // 3分钟倒计时
    const timer = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          clearInterval(timer);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  };

  const handleLogin = () => {
    // 模拟登录，直接跳转到注册页面进行身份认证
    navigate("/register");
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white flex flex-col">
      <div className="flex-1 flex flex-col justify-center px-6 py-12">
        <div className="text-center mb-12">
          <div className="w-20 h-20 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-primary to-accent flex items-center justify-center">
            <span className="text-3xl text-white">🍊</span>
          </div>
          <h1 className="text-3xl mb-2 text-primary">AI店长助手</h1>
          <p className="text-muted-foreground">智能经营，轻松管理</p>
        </div>

        <div className="space-y-4">
          <div>
            <label className="block text-sm mb-2">手机号</label>
            <input
              type="tel"
              value={phone}
              onChange={(e) => setPhone(e.target.value)}
              placeholder="请输入手机号"
              className="w-full px-4 py-3 rounded-lg bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-primary/20"
            />
          </div>

          <div>
            <label className="block text-sm mb-2">验证码</label>
            <div className="flex gap-2">
              <input
                type="text"
                value={code}
                onChange={(e) => setCode(e.target.value)}
                placeholder="请输入验证码"
                className="flex-1 px-4 py-3 rounded-lg bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-primary/20"
              />
              <button
                onClick={handleSendCode}
                disabled={countdown > 0 || !phone}
                className="px-5 py-3 rounded-lg bg-secondary text-secondary-foreground disabled:opacity-50 whitespace-nowrap"
              >
                {countdown > 0 ? `${countdown}s` : "获取验证码"}
              </button>
            </div>
            <p className="text-xs text-muted-foreground mt-1">验证码有效期3分钟</p>
          </div>

          <button
            onClick={handleLogin}
            disabled={!phone || !code}
            className="w-full py-3 rounded-lg bg-primary text-primary-foreground disabled:opacity-50 flex items-center justify-center gap-2 mt-8"
          >
            登录/注册
            <ArrowRight className="w-5 h-5" />
          </button>
        </div>
      </div>

      <div className="text-center text-xs text-muted-foreground pb-8 px-6">
        登录即表示同意《用户协议》和《隐私政策》
      </div>
    </div>
  );
}
