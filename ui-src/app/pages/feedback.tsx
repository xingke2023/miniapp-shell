import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronLeft, CheckCircle2 } from "lucide-react";

export function Feedback() {
  const navigate = useNavigate();
  const [feedback, setFeedback] = useState("");
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = () => {
    if (!feedback.trim()) return;
    setSubmitted(true);
    setTimeout(() => {
      navigate("/profile");
    }, 5000);
  };

  if (submitted) {
    return (
      <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white flex items-center justify-center px-6">
        <div className="text-center">
          <div className="w-24 h-24 mx-auto mb-6 rounded-full bg-secondary flex items-center justify-center">
            <CheckCircle2 className="w-12 h-12 text-accent" />
          </div>
          <h2 className="text-2xl mb-2">提交成功</h2>
          <p className="text-muted-foreground mb-8">感谢您的反馈</p>
          <div className="inline-flex items-center gap-2 text-sm text-primary">
            <div className="w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin"></div>
            5秒后返回...
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white">
      <div className="bg-white border-b border-border px-4 py-3 flex items-center gap-3">
        <button onClick={() => navigate("/profile")} className="text-primary">
          <ChevronLeft className="w-6 h-6" />
        </button>
        <h1 className="text-lg">用户反馈</h1>
      </div>

      <div className="px-6 py-6">
        <div className="bg-secondary/20 border border-secondary rounded-lg p-4 mb-6">
          <p className="text-sm text-secondary-foreground">
            💡 您的每一条反馈都很重要，帮助我们不断改进产品
          </p>
        </div>

        <div>
          <label className="block text-sm mb-2">反馈内容</label>
          <textarea
            value={feedback}
            onChange={(e) => setFeedback(e.target.value.slice(0, 200))}
            placeholder="我觉得XX功能使用有问题。我希望增加XX功能。"
            className="w-full h-40 px-4 py-3 rounded-lg bg-input-background border border-border focus:outline-none focus:ring-2 focus:ring-primary/20 resize-none"
          />
          <div className="flex justify-between items-center mt-2">
            <p className="text-xs text-muted-foreground">
              请输入您的建议或问题反馈
            </p>
            <p className="text-xs text-muted-foreground">
              {feedback.length}/200
            </p>
          </div>
        </div>

        <button
          onClick={handleSubmit}
          disabled={!feedback.trim()}
          className="w-full py-3 rounded-lg bg-primary text-primary-foreground disabled:opacity-50 mt-8"
        >
          提交反馈
        </button>
      </div>
    </div>
  );
}
