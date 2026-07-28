import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronLeft, Camera, Check } from "lucide-react";

export function Settings() {
  const navigate = useNavigate();
  const [phone, setPhone] = useState("138****8888");
  const [isEditing, setIsEditing] = useState(false);
  const [newPhone, setNewPhone] = useState("");
  const [code, setCode] = useState("");
  const [countdown, setCountdown] = useState(0);

  const handleSendCode = () => {
    setCountdown(180);
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

  const handleSavePhone = () => {
    if (newPhone && code) {
      setPhone(newPhone);
      setIsEditing(false);
      setNewPhone("");
      setCode("");
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white pb-20">
      <div className="bg-white border-b border-border px-4 py-3 flex items-center gap-3">
        <button onClick={() => navigate("/profile")} className="text-primary">
          <ChevronLeft className="w-6 h-6" />
        </button>
        <h1 className="text-lg">设置</h1>
      </div>

      <div className="px-6 py-6 space-y-6">
        {/* 头像 */}
        <div>
          <label className="block text-sm mb-3">头像</label>
          <div className="flex items-center gap-4">
            <div className="relative">
              <div className="w-20 h-20 rounded-full bg-gradient-to-br from-primary/20 to-accent/20 flex items-center justify-center text-3xl">
                👤
              </div>
              <button className="absolute bottom-0 right-0 w-6 h-6 bg-primary rounded-full flex items-center justify-center text-white">
                <Camera className="w-3.5 h-3.5" />
              </button>
            </div>
            <button className="px-4 py-2 rounded-lg border border-border text-sm hover:bg-muted/50 transition-colors">
              更换头像
            </button>
          </div>
        </div>

        {/* 用户名 */}
        <div>
          <label className="block text-sm mb-2">用户名</label>
          <div className="px-4 py-3 rounded-lg bg-muted/30 border border-border">
            <p className="text-muted-foreground">张店长</p>
          </div>
          <p className="text-xs text-muted-foreground mt-1">
            ⚠️ 用户名为认证姓名，不可修改
          </p>
        </div>

        {/* 手机号 */}
        <div>
          <label className="block text-sm mb-2">手机号</label>
          {!isEditing ? (
            <div className="flex items-center gap-3">
              <div className="flex-1 px-4 py-3 rounded-lg bg-muted/30 border border-border">
                <p className="text-muted-foreground">{phone}</p>
              </div>
              <button
                onClick={() => setIsEditing(true)}
                className="px-4 py-3 rounded-lg bg-primary text-primary-foreground text-sm"
              >
                修改
              </button>
            </div>
          ) : (
            <div className="space-y-3">
              <input
                type="tel"
                value={newPhone}
                onChange={(e) => setNewPhone(e.target.value)}
                placeholder="请输入新手机号"
                className="w-full px-4 py-3 rounded-lg bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-primary/20"
              />
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
                  disabled={countdown > 0 || !newPhone}
                  className="px-5 py-3 rounded-lg bg-secondary text-secondary-foreground disabled:opacity-50 whitespace-nowrap"
                >
                  {countdown > 0 ? `${countdown}s` : "获取验证码"}
                </button>
              </div>
              <div className="flex gap-2">
                <button
                  onClick={() => {
                    setIsEditing(false);
                    setNewPhone("");
                    setCode("");
                  }}
                  className="flex-1 py-3 rounded-lg border border-border text-sm"
                >
                  取消
                </button>
                <button
                  onClick={handleSavePhone}
                  disabled={!newPhone || !code}
                  className="flex-1 py-3 rounded-lg bg-primary text-primary-foreground disabled:opacity-50 text-sm"
                >
                  保存
                </button>
              </div>
            </div>
          )}
        </div>

        {/* 店铺信息 */}
        <div>
          <label className="block text-sm mb-2">店铺信息</label>
          <div className="px-4 py-3 rounded-lg bg-muted/30 border border-border space-y-2">
            <div className="flex justify-between">
              <span className="text-muted-foreground text-sm">所属店铺</span>
              <span className="text-sm">香港湾仔店</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground text-sm">职位</span>
              <span className="text-sm">店长</span>
            </div>
          </div>
          <p className="text-xs text-muted-foreground mt-1">
            如需修改店铺信息，请联系管理员
          </p>
        </div>
      </div>
    </div>
  );
}
