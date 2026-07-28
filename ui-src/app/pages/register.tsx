import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronDown, CheckCircle2 } from "lucide-react";

export function Register() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    name: "",
    store: "",
    position: "",
  });
  const [submitted, setSubmitted] = useState(false);

  const stores = ["香港湾仔店", "香港中环店", "香港铜锣湾店", "香港尖沙咀店"];
  const positions = ["店长", "店员", "财务", "采购", "总部负责人"];

  const handleSubmit = () => {
    setSubmitted(true);
    // 模拟提交后等待审核，3秒后跳转到首页
    setTimeout(() => {
      localStorage.setItem("authenticated", "true");
      navigate("/");
    }, 3000);
  };

  if (submitted) {
    return (
      <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white flex items-center justify-center px-6">
        <div className="text-center">
          <div className="w-24 h-24 mx-auto mb-6 rounded-full bg-secondary flex items-center justify-center">
            <CheckCircle2 className="w-12 h-12 text-accent" />
          </div>
          <h2 className="text-2xl mb-2">提交成功</h2>
          <p className="text-muted-foreground mb-1">您的身份信息已提交</p>
          <p className="text-muted-foreground mb-8">请等待管理员审核</p>
          <div className="inline-flex items-center gap-2 text-sm text-primary">
            <div className="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
            即将跳转至首页...
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white">
      <div className="px-6 py-12">
        <div className="mb-8">
          <h1 className="text-2xl mb-2">身份认证</h1>
          <p className="text-muted-foreground">请填写您的真实信息以完成认证</p>
        </div>

        <div className="space-y-5">
          <div>
            <label className="block text-sm mb-2">姓名</label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              placeholder="请输入真实姓名"
              className="w-full px-4 py-3 rounded-lg bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-primary/20"
            />
          </div>

          <div>
            <label className="block text-sm mb-2">所属店铺</label>
            <div className="relative">
              <select
                value={formData.store}
                onChange={(e) => setFormData({ ...formData, store: e.target.value })}
                className="w-full px-4 py-3 rounded-lg bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-primary/20 appearance-none"
              >
                <option value="">请选择店铺</option>
                {stores.map((store) => (
                  <option key={store} value={store}>
                    {store}
                  </option>
                ))}
              </select>
              <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground pointer-events-none" />
            </div>
          </div>

          <div>
            <label className="block text-sm mb-2">职位</label>
            <div className="grid grid-cols-2 gap-3">
              {positions.map((position) => (
                <button
                  key={position}
                  onClick={() => setFormData({ ...formData, position })}
                  className={`py-3 rounded-lg border-2 transition-all ${
                    formData.position === position
                      ? "border-primary bg-primary/5 text-primary"
                      : "border-border bg-input-background text-foreground"
                  }`}
                >
                  {position}
                </button>
              ))}
            </div>
          </div>

          <div className="bg-secondary/30 border border-secondary rounded-lg p-4 mt-6">
            <p className="text-sm text-secondary-foreground">
              ⚠️ 提示：提交后需等待管理员审核，审核通过前无法使用小程序功能
            </p>
          </div>

          <button
            onClick={handleSubmit}
            disabled={!formData.name || !formData.store || !formData.position}
            className="w-full py-3 rounded-lg bg-primary text-primary-foreground disabled:opacity-50 mt-8"
          >
            提交审核
          </button>
        </div>
      </div>
    </div>
  );
}