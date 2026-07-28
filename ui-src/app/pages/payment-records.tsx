import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronLeft, Calendar, Receipt, X, FileText } from "lucide-react";

interface PaymentRecord {
  id: number;
  date: string;
  project: string;
  amount: number;
  method: string;
  image?: string;
  supplier?: string;
  category?: string;
  note?: string;
  status?: string;
}

export function PaymentRecords() {
  const navigate = useNavigate();
  const [startDate, setStartDate] = useState("2026-03-01");
  const [endDate, setEndDate] = useState("2026-03-31");
  const [selectedRecord, setSelectedRecord] = useState<PaymentRecord | null>(null);
  const [showDetail, setShowDetail] = useState(false);
  const [showImagePreview, setShowImagePreview] = useState(false);

  const records: PaymentRecord[] = [
    {
      id: 1,
      date: "2026-03-31 10:30",
      project: "水果采购",
      amount: 3500,
      method: "现金",
      supplier: "XX水果批发市场",
      category: "采购支出",
      note: "草莓、香蕉、苹果等时令水果",
      status: "已审核",
      image: "https://images.unsplash.com/photo-1554224311-beee4f8a024d?w=800",
    },
    {
      id: 2,
      date: "2026-03-30 15:20",
      project: "蔬菜采购",
      amount: 2800,
      method: "转账",
      supplier: "绿色蔬菜供应商",
      category: "采购支出",
      note: "白菜、菠菜、西红柿等新鲜蔬菜",
      status: "已审核",
      image: "https://images.unsplash.com/photo-1542838132-92c53300491e?w=800",
    },
    {
      id: 3,
      date: "2026-03-29 09:15",
      project: "店铺维修",
      amount: 1200,
      method: "微信",
      supplier: "XX维修公司",
      category: "运营支出",
      note: "冷柜维修保养",
      status: "待审核",
      image: "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=800",
    },
    {
      id: 4,
      date: "2026-03-28 14:45",
      project: "水果采购",
      amount: 4200,
      method: "现金",
      supplier: "XX水果批发市场",
      category: "采购支出",
      note: "橙子、柚子、葡萄等进口水果",
      status: "已审核",
      image: "https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=800",
    },
  ];

  const totalAmount = records.reduce((sum, record) => sum + record.amount, 0);

  const handleRecordClick = (record: PaymentRecord) => {
    setSelectedRecord(record);
    setShowDetail(true);
  };

  const handleCloseDetail = () => {
    setShowDetail(false);
    setTimeout(() => setSelectedRecord(null), 300);
  };

  const handleImagePreview = (show: boolean) => {
    setShowImagePreview(show);
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-primary/5 to-white pb-20">
      <div className="bg-white border-b border-border px-4 py-3 flex items-center gap-3">
        <button onClick={() => navigate("/profile")} className="text-primary">
          <ChevronLeft className="w-6 h-6" />
        </button>
        <h1 className="text-lg">我的支付凭证</h1>
      </div>

      {/* 日期筛选 */}
      <div className="bg-white border-b border-border px-6 py-4">
        <div className="flex items-center gap-3">
          <div className="flex-1">
            <label className="block text-xs text-muted-foreground mb-1">
              开始日期
            </label>
            <div className="relative">
              <input
                type="date"
                value={startDate}
                onChange={(e) => setStartDate(e.target.value)}
                className="w-full px-3 py-2 rounded-lg bg-input-background border border-border text-sm"
              />
              <Calendar className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground pointer-events-none" />
            </div>
          </div>
          <div className="text-muted-foreground mt-5">-</div>
          <div className="flex-1">
            <label className="block text-xs text-muted-foreground mb-1">
              结束日期
            </label>
            <div className="relative">
              <input
                type="date"
                value={endDate}
                onChange={(e) => setEndDate(e.target.value)}
                className="w-full px-3 py-2 rounded-lg bg-input-background border border-border text-sm"
              />
              <Calendar className="absolute right-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground pointer-events-none" />
            </div>
          </div>
        </div>
      </div>

      {/* 统计信息 */}
      <div className="px-6 py-4">
        <div className="bg-gradient-to-br from-primary to-accent text-white rounded-2xl p-6">
          <p className="text-sm opacity-90 mb-1">所选时间段总支付</p>
          <h2 className="text-3xl">HK$ {totalAmount.toLocaleString()}</h2>
          <p className="text-xs opacity-75 mt-2">共 {records.length} 条记录</p>
        </div>
      </div>

      {/* 支付记录列表 */}
      <div className="px-6 pb-6">
        <div className="space-y-3">
          {records.map((record) => (
            <div
              key={record.id}
              className="bg-white rounded-xl p-4 border border-border cursor-pointer hover:shadow-md active:scale-[0.98] transition-all"
              onClick={() => handleRecordClick(record)}
            >
              <div className="flex items-start justify-between">
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center">
                    <Receipt className="w-5 h-5 text-primary" />
                  </div>
                  <div>
                    <h3 className="text-sm mb-0.5">{record.project}</h3>
                    <p className="text-xs text-muted-foreground">
                      {record.date}
                    </p>
                  </div>
                </div>
                <div className="text-right">
                  <p className="text-lg text-primary">
                    -HK$ {record.amount.toLocaleString()}
                  </p>
                  <p className="text-xs text-muted-foreground">{record.method}</p>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* 详细信息弹窗 */}
      {showDetail && selectedRecord && (
        <>
          {/* 遮罩层 */}
          <div
            className="fixed inset-0 bg-black/50 z-40 transition-opacity"
            onClick={handleCloseDetail}
          />

          {/* 详情面板 - 从底部滑出 */}
          <div className="fixed inset-x-0 bottom-0 z-50 bg-white rounded-t-3xl max-h-[90vh] overflow-y-auto animate-slide-up">
            {/* 头部 */}
            <div className="sticky top-0 bg-white border-b border-border px-6 py-4 flex items-center justify-between rounded-t-3xl">
              <h2 className="text-lg">支付详情</h2>
              <button
                onClick={handleCloseDetail}
                className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-muted transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* 支付凭证图片 */}
            {selectedRecord.image && (
              <div className="px-6 pt-4">
                <p className="text-sm text-muted-foreground mb-2">支付凭证</p>
                <div
                  className="w-full rounded-xl overflow-hidden bg-muted cursor-pointer hover:opacity-90 transition-opacity"
                  onClick={(e) => {
                    e.stopPropagation();
                    handleImagePreview(true);
                  }}
                >
                  <img
                    src={selectedRecord.image}
                    alt="支付凭证"
                    className="w-full object-contain"
                  />
                </div>
                <p className="text-xs text-muted-foreground mt-2 text-center">
                  点击图片查看大图
                </p>
              </div>
            )}

            {/* 详细信息 */}
            <div className="px-6 py-4 space-y-4">
              <div className="bg-gradient-to-br from-primary to-accent text-white rounded-2xl p-6">
                <p className="text-sm opacity-90 mb-1">支付金额</p>
                <h2 className="text-3xl">
                  HK$ {selectedRecord.amount.toLocaleString()}
                </h2>
              </div>

              <div className="bg-muted/30 rounded-xl p-4 space-y-3">
                <div className="flex items-start justify-between py-2 border-b border-border/50">
                  <span className="text-sm text-muted-foreground">项目名称</span>
                  <span className="text-sm text-right">{selectedRecord.project}</span>
                </div>
                <div className="flex items-start justify-between py-2 border-b border-border/50">
                  <span className="text-sm text-muted-foreground">支付时间</span>
                  <span className="text-sm text-right">{selectedRecord.date}</span>
                </div>
                <div className="flex items-start justify-between py-2 border-b border-border/50">
                  <span className="text-sm text-muted-foreground">支付方式</span>
                  <span className="text-sm text-right">{selectedRecord.method}</span>
                </div>
                <div className="flex items-start justify-between py-2 border-b border-border/50">
                  <span className="text-sm text-muted-foreground">供应商</span>
                  <span className="text-sm text-right">{selectedRecord.supplier}</span>
                </div>
                <div className="flex items-start justify-between py-2 border-b border-border/50">
                  <span className="text-sm text-muted-foreground">支出类别</span>
                  <span className="text-sm text-right">{selectedRecord.category}</span>
                </div>
                <div className="flex items-start justify-between py-2 border-b border-border/50">
                  <span className="text-sm text-muted-foreground">审核状态</span>
                  <span
                    className={`text-sm text-right ${
                      selectedRecord.status === "已审核"
                        ? "text-green-600"
                        : "text-orange-600"
                    }`}
                  >
                    {selectedRecord.status}
                  </span>
                </div>
                <div className="flex items-start justify-between py-2">
                  <span className="text-sm text-muted-foreground">备注</span>
                  <span className="text-sm text-right max-w-[60%]">{selectedRecord.note}</span>
                </div>
              </div>
            </div>

            {/* 底部安全区 */}
            <div className="h-8" />
          </div>
        </>
      )}

      {/* 图片大图预览 */}
      {showImagePreview && selectedRecord?.image && (
        <div
          className="fixed inset-0 bg-black z-[60] flex items-center justify-center p-4"
          onClick={() => handleImagePreview(false)}
        >
          <button
            className="absolute top-4 right-4 w-10 h-10 flex items-center justify-center rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors"
            onClick={() => handleImagePreview(false)}
          >
            <X className="w-6 h-6" />
          </button>
          <img
            src={selectedRecord.image}
            alt="支付凭证大图"
            className="max-w-full max-h-full object-contain"
            onClick={(e) => e.stopPropagation()}
          />
        </div>
      )}
    </div>
  );
}