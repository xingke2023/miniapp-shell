import { useState, useRef, useEffect } from "react";
import { useLocation, useNavigate } from "react-router";
import {
  Camera,
  Mic,
  Send,
  Image as ImageIcon,
  ChevronLeft,
  History,
  Lightbulb,
  Tag,
  ChevronDown,
  ChevronUp,
  FileText,
  CreditCard,
  Edit3,
  Save,
  X as CloseIcon,
  Check,
} from "lucide-react";

interface Message {
  id: number;
  type: "user" | "ai" | "system";
  content: string;
  timestamp: Date;
  image?: string;
  card?: {
    title: string;
    items: Array<{ label: string; value: string }>;
    clickable?: boolean; // 标识卡片是否可点击
    clickTarget?: string; // 点击后跳转的路由
    readOnly?: boolean; // 标识卡片是否只读（不显示编辑和确认按钮）
  };
  isEditing?: boolean;
  editedData?: Array<{ label: string; value: string }>;
  isConfirmed?: boolean;
  fromSuggestion?: boolean; // 标识是否来自AI智能建议
  isIgnored?: boolean; // 标识是否已忽略
}

type TagMode = "competitor" | "delivery" | "payment" | null;

export function AIChat() {
  const location = useLocation();
  const navigate = useNavigate();
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [isRecording, setIsRecording] = useState(false);
  const [showTemplates, setShowTemplates] = useState(false);
  const [selectedTag, setSelectedTag] = useState<TagMode>(null);
  const [showHistory, setShowHistory] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const historyRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const state = location.state as any;
    if (state?.mode) {
      handleModeInit(state.mode);
    }
    if (state?.alert) {
      handleAlertDetails(state.alert);
    }
  }, [location.state]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({
      behavior: "smooth",
    });
  }, [messages]);

  // 点击历史列表外部关闭
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        showHistory &&
        historyRef.current &&
        !historyRef.current.contains(event.target as Node)
      ) {
        const target = event.target as HTMLElement;
        // 检查是否点击了"查看历史"按钮
        if (!target.closest("[data-history-button]")) {
          setShowHistory(false);
        }
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener(
        "mousedown",
        handleClickOutside,
      );
    };
  }, [showHistory]);

  const handleModeInit = (mode: string) => {
    switch (mode) {
      case "upload-delivery":
        setSelectedTag("delivery");
        addMessage("system", "请将到货单发给我，我来帮你记录");
        break;
      case "payment":
        setSelectedTag("payment");
        addMessage(
          "system",
          "请将支付凭证发给我，我来帮你记录",
        );
        break;
      case "competitor-info":
        // 竞品情报汇总
        addMessage("ai", "今日竞品情报汇总", {
          title: "今日竞品信息统计",
          items: [
            { label: "收集人数", value: "5人" },
            { label: "竞品门店数", value: "8家" },
            { label: "商品条目数", value: "23条" },
            { label: "最新更新", value: "10分钟前" },
          ],
          clickable: true,
          clickTarget: "/competitor-list",
          readOnly: true, // 只读模式，不显示编辑和确认按钮
        });
        setTimeout(() => {
          addMessage(
            "ai",
            "点击卡片查看详细的竞品信息列表",
          );
        }, 500);
        break;
      case "daily-summary":
        addMessage("system", "请对今日经营做个总结");
        setTimeout(() => {
          addMessage(
            "ai",
            "未上传「商品销售统计」表格，请提醒财务人员于闭店后上传，上传后我将为您生成详细的经营分析报告。",
          );
        }, 500);
        break;
      case "inventory":
        addMessage("system", "请告诉我今日盘存情况");
        setTimeout(() => {
          addMessage(
            "ai",
            "请告诉我各商品的库存数量，我来帮您记录",
          );
        }, 500);
        break;
    }
  };

  const handleAlertDetails = (alert: any) => {
    addMessage("ai", alert.details, {
      title: alert.title,
      items: [
        { label: "当前库存", value: "15kg" },
        { label: "建议促销折扣", value: "8折" },
        { label: "预计销售周期", value: "2天" },
      ],
    }, undefined, true); // 标记为来自智能建议
    setTimeout(() => {
      addMessage(
        "ai",
        "如需修改促销内容，请告诉我要修改的地方",
      );
    }, 500);
  };

  const addMessage = (
    type: "user" | "ai" | "system",
    content: string,
    card?: any,
    image?: string,
    fromSuggestion?: boolean,
  ) => {
    const newMessage: Message = {
      id: Date.now(),
      type,
      content,
      timestamp: new Date(),
      card,
      image,
      fromSuggestion,
    };
    setMessages((prev) => [...prev, newMessage]);
  };

  const handleSend = () => {
    if (!input.trim()) return;

    addMessage("user", input);
    const userInput = input;
    setInput("");

    // 模拟AI响应
    setTimeout(() => {
      if (selectedTag === "competitor") {
        handleCompetitorResponse(userInput);
      } else if (selectedTag === "delivery") {
        handleDeliveryResponse(userInput);
      } else if (selectedTag === "payment") {
        handlePaymentResponse(userInput);
      } else {
        handleGeneralResponse(userInput);
      }
    }, 800);
  };

  const handleCompetitorResponse = (input: string) => {
    addMessage("ai", "已收到竞品情报，正在解析...");
    setTimeout(() => {
      addMessage("ai", "竞品情报已记录", {
        title: "竞品信息",
        items: [
          { label: "竞品门店", value: "百佳超市" },
          { label: "商品名称", value: "草莓" },
          { label: "商品规格", value: "250g/盒" },
          { label: "价格", value: "HK$28" },
          { label: "备注", value: "特价促销中" },
        ],
      });
    }, 1500);
  };

  const handleDeliveryResponse = (input: string) => {
    addMessage("ai", "正在解析到货单信息...");
    setTimeout(() => {
      addMessage("ai", "到货单已记录", {
        title: "今日到货",
        items: [
          { label: "草莓", value: "20kg" },
          { label: "香蕉", value: "15kg" },
          { label: "苹果", value: "25kg" },
          { label: "橙子", value: "18kg" },
        ],
      });
    }, 1500);
  };

  const handlePaymentResponse = (input: string) => {
    addMessage("ai", "正在识别支付凭证...");
    setTimeout(() => {
      addMessage("ai", "支付凭证已记录", {
        title: "支付信息",
        items: [
          { label: "支付方式", value: "银行转账" },
          { label: "金额", value: "HK$1,280" },
          { label: "供应商", value: "XX水果批发" },
          { label: "时间", value: "2026-04-01 10:30" },
        ],
      });
    }, 1500);
  };

  const handleGeneralResponse = (input: string) => {
    if (input.includes("促销") || input.includes("清货")) {
      addMessage(
        "ai",
        "根据当前库存情况，我为您生成了促销方案：",
        {
          title: "促销建议",
          items: [
            { label: "商品", value: "草莓" },
            { label: "促销折扣", value: "8折" },
            { label: "促销时段", value: "今日15:00-20:00" },
            { label: "预计清货量", value: "10kg" },
          ],
        },
      );
      setTimeout(() => {
        addMessage(
          "ai",
          "如需修改促销内容，请告诉我要修改的地方",
        );
      }, 500);
    } else if (
      input.includes("卖得好") ||
      input.includes("卖得不好")
    ) {
      addMessage(
        "ai",
        "收到您的反馈，我会根据销售情况调整建议",
      );
      setTimeout(() => {
        if (input.includes("卖得好")) {
          addMessage(
            "ai",
            "建议增加该商品的备货量，并可考虑适当提价或推出组合优惠",
          );
        } else {
          addMessage(
            "ai",
            "建议：1. 降价促销清货 2. 调整陈列位置 3. 减少下次进货量",
          );
        }
      }, 800);
    } else {
      addMessage("ai", "我理解了您的需求，正在为您分析...");
    }
  };

  const handleImageUpload = () => {
    // 模拟图片上传
    addMessage("user", "已上传图片", undefined, "placeholder");
    setTimeout(() => {
      if (selectedTag === "delivery") {
        addMessage("ai", "图片已识别，正在解析到货单信息...");
        setTimeout(() => {
          addMessage("ai", "单解析成功", {
            title: "今日到货",
            items: [
              { label: "草莓", value: "20kg" },
              { label: "香蕉", value: "15kg" },
              { label: "苹果", value: "25kg" },
              { label: "橙子", value: "18kg" },
            ],
          });
        }, 1500);
      } else if (selectedTag === "payment") {
        addMessage("ai", "图片已识别，正在解析支付凭证...");
        setTimeout(() => {
          addMessage("ai", "支付凭证解析成功", {
            title: "支付信息",
            items: [
              { label: "支付方式", value: "银行转账" },
              { label: "金额", value: "HK$1,280" },
              { label: "供应商", value: "XX水果批发" },
            ],
          });
        }, 1500);
      } else {
        addMessage("ai", "图片已识别，正在分析...");
      }
    }, 800);
  };

  const handleTagChange = (tag: TagMode) => {
    setSelectedTag(tag);
    if (tag === "competitor") {
      addMessage("system", "请将竞品情报发给我，我来帮你记录");
    } else if (tag === "delivery") {
      addMessage("system", "请将到货单发给我，我来帮你记录");
    } else if (tag === "payment") {
      addMessage("system", "请将支付凭证发给我，我来帮你记录");
    }
  };

  const templates = [
    {
      category: "到货单录入",
      items: [
        "今天到了XX kg的XX（商品名）",
        "刚收到供应商送来的XX，大约XX斤",
      ],
    },
    {
      category: "库存反馈",
      items: ["XX商品还剩XX kg", "XX快卖完了", "XX库存充足"],
    },
    {
      category: "促销建议",
      items: ["XX商品需要促销", "XX商品打几折合适"],
    },
    {
      category: "销售反馈",
      items: ["XX商品卖得很好", "XX商品卖得不好"],
    },
  ];

  const historyDates = [
    { date: "2026年3月31日", count: 12 },
    { date: "2026年3月30日", count: 8 },
    { date: "2026年3月29日", count: 15 },
    { date: "2026年3月28日", count: 10 },
    { date: "2026年3月27日", count: 18 },
  ];

  // 编辑表格功能
  const handleEditTable = (messageId: number) => {
    setMessages((prev) =>
      prev.map((msg) => {
        if (msg.id === messageId && msg.card) {
          return {
            ...msg,
            isEditing: true,
            editedData:
              msg.editedData ||
              JSON.parse(JSON.stringify(msg.card.items)),
          };
        }
        return msg;
      }),
    );
  };

  const handleSaveTable = (messageId: number) => {
    setMessages((prev) =>
      prev.map((msg) => {
        if (msg.id === messageId) {
          return {
            ...msg,
            isEditing: false,
          };
        }
        return msg;
      }),
    );
  };

  const handleCancelEdit = (messageId: number) => {
    setMessages((prev) =>
      prev.map((msg) => {
        if (msg.id === messageId && msg.card) {
          return {
            ...msg,
            isEditing: false,
            editedData: JSON.parse(
              JSON.stringify(msg.card.items),
            ),
          };
        }
        return msg;
      }),
    );
  };

  const handleConfirm = (messageId: number) => {
    setMessages((prev) =>
      prev.map((msg) => {
        if (msg.id === messageId) {
          return {
            ...msg,
            isConfirmed: true,
          };
        }
        return msg;
      }),
    );
    
    // 模拟提交到后台
    addMessage("ai", "数据已确认并提交，感谢您的反馈！");
  };

  const handleIgnore = (messageId: number) => {
    setMessages((prev) =>
      prev.map((msg) => {
        if (msg.id === messageId) {
          return {
            ...msg,
            isIgnored: true,
          };
        }
        return msg;
      }),
    );
    
    // 智能建议忽略后的反馈
    addMessage("ai", "感谢反馈，我们将持续优化模型");
  };

  const handleValueChange = (
    messageId: number,
    itemIndex: number,
    newValue: string,
  ) => {
    setMessages((prev) =>
      prev.map((msg) => {
        if (msg.id === messageId && msg.editedData) {
          const updatedData = [...msg.editedData];
          updatedData[itemIndex] = {
            ...updatedData[itemIndex],
            value: newValue,
          };
          return {
            ...msg,
            editedData: updatedData,
          };
        }
        return msg;
      }),
    );
  };

  return (
    <div className="flex flex-col h-screen bg-gray-50">
      {/* 顶部栏 */}
      <div className="bg-white border-b border-border px-4 py-3 flex items-center justify-between">
        <button
          onClick={() => {
            // 从哪里来回到哪里
            if (
              window.history.state &&
              window.history.state.idx > 0
            ) {
              navigate(-1);
            } else {
              navigate("/");
            }
          }}
          className="text-muted-foreground hover:text-foreground transition-colors"
        >
          <ChevronLeft className="w-6 h-6" />
        </button>
        <div className="text-center flex-1">
          <div className="flex items-center justify-center gap-2">
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center text-white text-sm">
              AI
            </div>
            <div>
              <p className="text-sm">AI店长助手</p>
              <p className="text-xs text-muted-foreground">
                在线
              </p>
            </div>
          </div>
        </div>
        <button
          onClick={() => setShowHistory(!showHistory)}
          className="text-muted-foreground hover:text-foreground transition-colors"
          data-history-button
        >
          <History className="w-6 h-6" />
        </button>
      </div>

      {/* 历史对话列表 */}
      {showHistory && (
        <div
          ref={historyRef}
          className="absolute top-14 left-0 right-0 bg-white border-b border-border shadow-lg z-50 max-h-80 overflow-y-auto"
        >
          <div className="p-4">
            <h3 className="text-sm mb-3 text-muted-foreground">
              历史对话
            </h3>
            {historyDates.map((item, index) => (
              <button
                key={index}
                onClick={() => {
                  setShowHistory(false);
                  // 这里可以加载对应日期的历史对话
                }}
                className="w-full text-left px-4 py-3 rounded-lg hover:bg-muted/50 transition-colors mb-2"
              >
                <div className="flex items-center justify-between">
                  <span>{item.date}</span>
                  <span className="text-sm text-muted-foreground">
                    {item.count}条消息
                  </span>
                </div>
              </button>
            ))}
          </div>
        </div>
      )}

      {/* 消息列表 */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-4">
        {messages.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <div className="w-16 h-16 rounded-full bg-gradient-to-br from-primary to-accent flex items-center justify-center text-white text-2xl mb-4">
              🤖
            </div>
            <p className="text-muted-foreground mb-2">
              我是AI店长助手
            </p>
            <p className="text-sm text-muted-foreground">
              可以帮您管理库存、分析经营、提供建议
            </p>
          </div>
        ) : (
          messages.map((message) => (
            <div
              key={message.id}
              className={`flex ${
                message.type === "user"
                  ? "justify-end"
                  : "justify-start"
              }`}
            >
              {message.type === "system" ? (
                <div className="bg-secondary/30 text-secondary-foreground px-4 py-2 rounded-lg text-sm max-w-[80%]">
                  {message.content}
                </div>
              ) : (
                <div
                  className={`${
                    message.card ? "w-full" : "max-w-[80%]"
                  } ${
                    message.type === "user"
                      ? "bg-primary text-primary-foreground"
                      : "bg-white border border-border"
                  } px-4 py-3 rounded-2xl`}
                >
                  {message.image && (
                    <div className="w-40 h-40 bg-muted rounded-lg mb-2 flex items-center justify-center">
                      <ImageIcon className="w-8 h-8 text-muted-foreground" />
                    </div>
                  )}
                  <p className="text-[15px]">{message.content}</p>
                  {message.card && (
                    <div 
                      className={`bg-muted/30 rounded-lg p-3 mt-3 space-y-2 ${
                        message.card.clickable 
                          ? 'cursor-pointer hover:bg-muted/50 active:scale-[0.98] transition-all' 
                          : ''
                      }`}
                      onClick={() => {
                        if (message.card?.clickable && message.card.clickTarget) {
                          navigate(message.card.clickTarget);
                        }
                      }}
                    >
                      <div className="flex items-center justify-between">
                        <p className="text-[15px]">{message.card.title}</p>
                        {!message.card.readOnly && ( // 只读卡片不显示状态标签
                          message.fromSuggestion ? (
                            // 来自智能建议的卡片显示"提醒"标签
                            !message.isIgnored ? (
                              <span className="flex items-center gap-1 text-[13px] text-blue-600 bg-blue-50 px-2 py-0.5 rounded-full flex-shrink-0">
                                提醒
                              </span>
                            ) : (
                              <span className="flex items-center gap-1 text-[13px] text-gray-500 bg-gray-100 px-2 py-0.5 rounded-full flex-shrink-0">
                                <CloseIcon className="w-3 h-3" />
                                已忽略
                              </span>
                            )
                          ) : (
                            // 普通卡片显示"待确认"/"已确认"标签
                            !message.isConfirmed ? (
                              <span className="flex items-center gap-1 text-[13px] text-amber-600 bg-amber-50 px-2 py-0.5 rounded-full flex-shrink-0">
                                待确认
                              </span>
                            ) : (
                              <span className="flex items-center gap-1 text-[13px] text-green-600 bg-green-50 px-2 py-0.5 rounded-full flex-shrink-0">
                                <Check className="w-3 h-3" />
                                已确认
                              </span>
                            )
                          )
                        )}
                      </div>

                      {/* 显示数据 */}
                      <div className="space-y-1.5">
                        {(message.isEditing
                          ? message.editedData!
                          : message.editedData ||
                            message.card.items
                        ).map((item, index) => (
                          <div
                            key={index}
                            className="flex justify-between items-center text-[15px] gap-2"
                          >
                            <span className="text-muted-foreground min-w-[80px] flex-shrink-0">
                              {item.label}
                            </span>
                            {message.isEditing ? (
                              <input
                                type="text"
                                value={item.value}
                                onChange={(e) =>
                                  handleValueChange(
                                    message.id,
                                    index,
                                    e.target.value,
                                  )
                                }
                                className="flex-1 min-w-0 px-2 py-1 border border-border rounded bg-white text-right outline-none focus:border-primary text-[15px]"
                              />
                            ) : (
                              <span
                                className={
                                  message.editedData
                                    ? "text-primary"
                                    : ""
                                }
                              >
                                {item.value}
                              </span>
                            )}
                          </div>
                        ))}
                      </div>

                      {/* 编辑模式的操作按钮 */}
                      {message.isEditing && (
                        <div className="flex flex-col pt-2 border-t border-border/50 gap-2">
                          <div className="flex gap-2 justify-end">
                            <button
                              onClick={() =>
                                handleCancelEdit(message.id)
                              }
                              className="flex items-center gap-1 px-3 py-1.5 text-[15px] text-muted-foreground hover:text-foreground transition-colors border border-border rounded"
                            >
                              <CloseIcon className="w-3 h-3" />
                              取消
                            </button>
                            <button
                              onClick={() =>
                                handleSaveTable(message.id)
                              }
                              className="flex items-center gap-1 px-3 py-1.5 text-[15px] bg-primary text-primary-foreground rounded hover:bg-primary/90 transition-colors"
                            >
                              <Save className="w-3 h-3" />
                              保存
                            </button>
                          </div>
                        </div>
                      )}

                      {/* 非编辑模式的提示和按钮 */}
                      {!message.isEditing && message.type === "ai" && !message.isConfirmed && !message.isIgnored && !message.card?.readOnly && (
                        <div className="flex flex-col pt-2 border-t border-border/50 gap-2">
                          {message.fromSuggestion ? (
                            // 来自智能建议的卡片：只显示"忽略"按钮
                            <>
                              <p className="text-[15px] text-muted-foreground">
                                这是系统自动检测到的建议，您可以选择忽略
                              </p>
                              <div className="flex gap-2 justify-end">
                                <button
                                  onClick={() => handleIgnore(message.id)}
                                  className="flex items-center gap-1 px-3 py-1.5 text-[15px] text-gray-600 hover:text-gray-800 transition-colors border border-gray-300 rounded hover:bg-gray-50"
                                >
                                  <CloseIcon className="w-3 h-3" />
                                  忽略
                                </button>
                              </div>
                            </>
                          ) : (
                            // 普通卡片：显示"编辑"和"确认"按钮
                            <>
                              <p className="text-[15px] text-muted-foreground">
                                点击"编辑"，可根据实际情况手动调整
                                <br />
                                点击"确认"提交
                              </p>
                              <div className="flex gap-2 justify-end">
                                <button
                                  onClick={() => handleEditTable(message.id)}
                                  className="flex items-center gap-1 px-3 py-1.5 text-[15px] text-muted-foreground hover:text-foreground transition-colors border border-border rounded"
                                >
                                  <Edit3 className="w-3 h-3" />
                                  编辑
                                </button>
                                <button
                                  onClick={() => handleConfirm(message.id)}
                                  className="flex items-center gap-1 px-3 py-1.5 text-[15px] bg-green-600 text-white rounded hover:bg-green-700 transition-colors"
                                >
                                  <Check className="w-3 h-3" />
                                  确认
                                </button>
                              </div>
                            </>
                          )}
                        </div>
                      )}
                      
                      {/* 已确认状态的提示 */}
                      {message.isConfirmed && (
                        <p className="text-[15px] text-green-600 pt-2 border-t border-border/50">
                          ✓ 数据已确认并提交
                        </p>
                      )}
                      
                      {/* 忽略状态的提示 */}
                      {message.isIgnored && (
                        <p className="text-[15px] text-gray-500 pt-2 border-t border-border/50">
                          ✖ 已忽略
                        </p>
                      )}
                    </div>
                  )}
                </div>
              )}
            </div>
          ))
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* 提示语模板和标签 */}
      <div className="bg-white border-t border-border px-4 py-2">
        <div className="flex items-center gap-2 mb-2 overflow-x-auto pb-1">
          <button
            onClick={() => setShowTemplates(!showTemplates)}
            className={`flex items-center gap-1 px-3 py-1.5 rounded-full text-sm whitespace-nowrap transition-colors ${
              showTemplates 
                ? "bg-primary text-primary-foreground" 
                : "bg-muted text-foreground"
            }`}
          >
            <Lightbulb className="w-4 h-4" />
            提示语
            {showTemplates ? (
              <ChevronUp className="w-4 h-4" />
            ) : (
              <ChevronDown className="w-4 h-4" />
            )}
          </button>
          <button
            onClick={() =>
              handleTagChange(
                selectedTag === "competitor"
                  ? null
                  : "competitor",
              )
            }
            className={`flex items-center gap-1 px-3 py-1.5 rounded-full text-sm whitespace-nowrap ${
              selectedTag === "competitor"
                ? "bg-accent text-accent-foreground"
                : "bg-muted text-foreground"
            }`}
          >
            <Tag className="w-4 h-4" />
            竞品情报
          </button>
          <button
            onClick={() =>
              handleTagChange(
                selectedTag === "delivery" ? null : "delivery",
              )
            }
            className={`flex items-center gap-1 px-3 py-1.5 rounded-full text-sm whitespace-nowrap ${
              selectedTag === "delivery"
                ? "bg-primary text-primary-foreground"
                : "bg-muted text-foreground"
            }`}
          >
            <FileText className="w-4 h-4" />
            上传到货单
          </button>
          <button
            onClick={() =>
              handleTagChange(
                selectedTag === "payment" ? null : "payment",
              )
            }
            className={`flex items-center gap-1 px-3 py-1.5 rounded-full text-sm whitespace-nowrap ${
              selectedTag === "payment"
                ? "bg-primary text-primary-foreground"
                : "bg-muted text-foreground"
            }`}
          >
            <CreditCard className="w-4 h-4" />
            上传支付凭证
          </button>
        </div>

        {showTemplates && (
          <div className="bg-muted/50 rounded-lg p-3 mb-2 max-h-48 overflow-y-auto">
            {templates.map((template, index) => (
              <div key={index} className="mb-3 last:mb-0">
                <p className="text-xs text-muted-foreground mb-1.5">
                  {template.category}
                </p>
                <div className="space-y-1">
                  {template.items.map((item, i) => (
                    <button
                      key={i}
                      onClick={() => {
                        setInput(item);
                        setShowTemplates(false);
                      }}
                      className="block w-full text-left text-sm px-2 py-1 rounded hover:bg-white transition-colors"
                    >
                      {item}
                    </button>
                  ))}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* 输入区域 */}
      <div className="bg-white border-t border-border px-4 py-3 pb-safe">
        <div className="flex items-center gap-2">
          <button
            onClick={handleImageUpload}
            className="w-10 h-10 flex items-center justify-center text-muted-foreground hover:text-foreground transition-colors"
          >
            <Camera className="w-6 h-6" />
          </button>

          <div className="flex-1 flex items-center gap-2 bg-input-background rounded-full px-4 py-2">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyPress={(e) =>
                e.key === "Enter" && handleSend()
              }
              placeholder={
                selectedTag === "competitor"
                  ? "请描述竞品信息..."
                  : selectedTag === "delivery"
                    ? "请描述到货单信息..."
                    : selectedTag === "payment"
                      ? "请描述支付凭证信息..."
                      : "输入消息..."
              }
              className="flex-1 bg-transparent outline-none text-sm"
            />
            <button
              onClick={() => setIsRecording(!isRecording)}
              className={`transition-colors ${
                isRecording
                  ? "text-primary"
                  : "text-muted-foreground"
              }`}
            >
              <Mic className="w-5 h-5" />
            </button>
          </div>

          <button
            onClick={handleSend}
            disabled={!input.trim()}
            className="w-10 h-10 flex items-center justify-center bg-primary text-primary-foreground rounded-full disabled:opacity-50 transition-opacity"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>
  );
}