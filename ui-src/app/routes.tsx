import { createBrowserRouter } from "react-router";
import { Root } from "./components/root";
import { Home } from "./pages/home";
import { AIChat } from "./pages/ai-chat";
import { Profile } from "./pages/profile";
import { Login } from "./pages/login";
import { Register } from "./pages/register";
import { NotFound } from "./pages/not-found";
import { Feedback } from "./pages/feedback";
import { Settings } from "./pages/settings";
import { PaymentRecords } from "./pages/payment-records";
import { PaymentStats } from "./pages/payment-stats";
import { ResumeLibrary } from "./pages/resume-library";
import { CompetitorList } from "./pages/competitor-list";

export const router = createBrowserRouter([
  {
    path: "/login",
    Component: Login,
  },
  {
    path: "/register",
    Component: Register,
  },
  {
    path: "/",
    Component: Root,
    children: [
      { index: true, Component: Home },
      { path: "ai-chat", Component: AIChat },
      { path: "profile", Component: Profile },
      { path: "feedback", Component: Feedback },
      { path: "settings", Component: Settings },
      { path: "payment-records", Component: PaymentRecords },
      { path: "payment-stats", Component: PaymentStats },
      { path: "resume-library", Component: ResumeLibrary },
      { path: "competitor-list", Component: CompetitorList },
      { path: "*", Component: NotFound },
    ],
  },
  {
    path: "*",
    Component: Register, // 默认跳转到注册页面
  },
]);