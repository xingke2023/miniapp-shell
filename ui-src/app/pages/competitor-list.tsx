import { useState } from "react";
import { useNavigate } from "react-router";
import {
  ChevronLeft,
  Store,
  Calendar,
  ChevronDown,
  X,
  ChevronRight,
} from "lucide-react";

interface CompetitorInfo {
  id: number;
  store: string;
  product: string;
  spec: string;
  price: number;
  note: string;
  submitter: string;
  date: string;
  time: string;
  images: string[];
}

export function CompetitorList() {
  const navigate = useNavigate();
  const [startDate, setStartDate] = useState("2026-04-01");
  const [endDate, setEndDate] = useState("2026-04-02");
  const [selectedInfo, setSelectedInfo] = useState<CompetitorInfo | null>(null);
  const [showDetail, setShowDetail] = useState(false);
  const [showImagePreview, setShowImagePreview] = useState(false);
  const [previewImageIndex, setPreviewImageIndex] = useState(0);

  // 模拟竞品信息数据
  const competitorInfos: CompetitorInfo[] = [
    {
      id: 1,
      store: "百佳超市(铜锣湾店)",
      product: "进口草莓",
      spec: "250g/盒",
      price: 28,
      note: "特价促销中，买2送1",
      submitter: "张小明",
      date: "2026-04-02",
      time: "10:30",
      images: ["https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=800"],
    },
    {
      id: 2,
      store: "惠康超市(中环店)",
      product: "泰国榴莲",
      spec: "约2kg/个",
      price: 180,
      note: "金枕头品种，促销价",
      submitter: "李小红",
      date: "2026-04-02",
      time: "09:15",
      images: ["https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800"],
    },
    {
      id: 3,
      store: "百佳超市(铜锣湾店)",
      product: "日本富士苹果",
      spec: "4个/盒",
      price: 48,
      note: "限时优惠",
      submitter: "王大伟",
      date: "2026-04-02",
      time: "08:45",
      images: ["https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=800"],
    },
    {
      id: 4,
      store: "759阿信屋(旺角店)",
      product: "澳洲车厘子",
      spec: "500g/盒",
      price: 98,
      note: "J级大果，甜度高",
      submitter: "张小明",
      date: "2026-04-01",
      time: "16:20",
      images: ["https://images.unsplash.com/photo-1528821128474-27f963b062bf?w=800"],
    },
    {
      id: 5,
      store: "百佳超市(中环店)",
      product: "新西兰奇异果",
      spec: "6个/盒",
      price: 32,
      note: "金果品种",
      submitter: "李小红",
      date: "2026-04-01",
      time: "15:00",
      images: ["https://images.unsplash.com/photo-1585059895524-72359e06133a?w=800"],
    },
    {
      id: 6,
      store: "惠康超市(尖沙咀店)",
      product: "墨西哥牛油果",
      spec: "2个/包",
      price: 22,
      note: "成熟度适中",
      submitter: "王大伟",
      date: "2026-04-01",
      time: "14:30",
      images: ["https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=800"],
    },
    {
      id: 7,
      store: "百佳超市(铜锣湾店)",
      product: "台湾释迦",
      spec: "约600g/个",
      price: 58,
      note: "凤梨释迦",
      submitter: "张小明",
      date: "2026-04-01",
      time: "11:00",
      images: ["https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=800"],
    },
    {
      id: 8,
      store: "759阿信屋(铜锣湾店)",
      product: "韩国香梨",
      spec: "3个/盒",
      price: 38,
      note: "爽脆多汁",
      submitter: "李小红",
      date: "2026-03-31",
      time: "17:00",
      images: ["https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?w=800"],
    },
  ];

  // 筛选今日数据
  const getTodayInfos = () => {
    const today = "2026-04-02";
    return competitorInfos.filter((info) => info.date === today);
  };

  // 根据日期筛选
  const getFilteredInfos = () => {
    return competitorInfos.filter(
      (info) => info.date >= startDate && info.date <= endDate
    );
  };

  const handleInfoClick = (info: CompetitorInfo) => {
    setSelectedInfo(info);
    setShowDetail(true);
  };

  const handleCloseDetail = () => {
    setShowDetail(false);
    setPreviewImageIndex(0);
  };

  const handleImageClick = (index: number) => {
    setPreviewImageIndex(index);
    setShowImagePreview(true);
  };

  const handleCloseImagePreview = () => {
    setShowImagePreview(false);
  };

  const handleShowToday = () => {
    const today = "2026-04-02";
    setStartDate(today);
    setEndDate(today);
  };

  const filteredInfos = getFilteredInfos();
  const todayCount = getTodayInfos().length;

  return (
    <div className="flex flex-col h-screen bg-gray-50">
      {/* 顶部栏 */}
      <div className="bg-white border-b border-border">
        <div className="flex items-center justify-between px-4 py-3">
          <button
            onClick={() => navigate(-1)}
            className="text-muted-foreground hover:text-foreground transition-colors"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <h1 className="text-lg">竞品情报</h1>
          <div className="w-6" />
        </div>

        {/* 日期筛选和今天/全部按钮 */}
        <div className="px-4 pb-3 space-y-2">
          <div className="flex items-center gap-2 bg-muted/50 rounded-lg px-3 py-2">
            <Calendar className="w-4 h-4 text-muted-foreground flex-shrink-0" />
            <input
              type="date"
              value={startDate}
              onChange={(e) => setStartDate(e.target.value)}
              className="flex-1 bg-transparent outline-none text-sm"
            />
            <span className="text-muted-foreground">-</span>
            <input
              type="date"
              value={endDate}
              onChange={(e) => setEndDate(e.target.value)}
              className="flex-1 bg-transparent outline-none text-sm"
            />
          </div>
          
          <div className="flex items-center gap-2 justify-end">
            <button
              onClick={handleShowToday}
              className="flex items-center gap-1 px-3 py-1.5 bg-primary text-primary-foreground rounded-lg hover:bg-primary/90 transition-colors text-sm"
            >
              今天
              <span className="text-xs">({todayCount})</span>
            </button>
            <button
              onClick={() => {
                setStartDate("2026-03-01");
                setEndDate("2026-04-02");
              }}
              className="flex items-center gap-1 px-3 py-1.5 bg-muted text-foreground rounded-lg hover:bg-muted/80 transition-colors text-sm"
            >
              全部
            </button>
          </div>
        </div>
      </div>

      {/* 统计信息 */}
      <div className="bg-white border-b border-border px-4 py-3">
        <div className="flex items-center justify-between text-sm">
          <span className="text-muted-foreground">共找到</span>
          <span className="text-primary">{filteredInfos.length} 条竞品信息</span>
        </div>
      </div>

      {/* 竞品信息列表 */}
      <div className="flex-1 overflow-y-auto px-4 py-4 space-y-3">
        {filteredInfos.map((info) => (
          <div
            key={info.id}
            className="bg-white rounded-xl p-4 border border-border cursor-pointer hover:shadow-md active:scale-[0.98] transition-all"
            onClick={() => handleInfoClick(info)}
          >
            <div className="flex items-start justify-between mb-2">
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-1">
                  <Store className="w-4 h-4 text-accent flex-shrink-0" />
                  <h3 className="text-sm">{info.store}</h3>
                </div>
                <p className="text-xs text-muted-foreground mb-1">
                  {info.date} {info.time} · {info.submitter}
                </p>
              </div>
              <ChevronRight className="w-5 h-5 text-muted-foreground flex-shrink-0" />
            </div>

            <div className="space-y-1">
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">商品</span>
                <span className="text-sm">{info.product}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">规格</span>
                <span className="text-sm">{info.spec}</span>
              </div>
              <div className="flex items-center justify-between">
                <span className="text-sm text-muted-foreground">价格</span>
                <span className="text-lg text-primary">HK$ {info.price}</span>
              </div>
              {info.note && (
                <div className="pt-1 mt-1 border-t border-border/50">
                  <p className="text-xs text-muted-foreground">{info.note}</p>
                </div>
              )}
            </div>
          </div>
        ))}

        {filteredInfos.length === 0 && (
          <div className="flex flex-col items-center justify-center py-20">
            <Store className="w-16 h-16 text-muted-foreground/30 mb-4" />
            <p className="text-muted-foreground">暂无竞品信息</p>
          </div>
        )}
      </div>

      {/* 详情面板 */}
      {showDetail && selectedInfo && (
        <>
          <div
            className="fixed inset-0 bg-black/50 z-40"
            onClick={handleCloseDetail}
          />
          <div className="fixed inset-x-0 bottom-0 bg-white rounded-t-3xl z-50 max-h-[90vh] overflow-y-auto">
            {/* 详情顶部 */}
            <div className="sticky top-0 bg-white border-b border-border px-6 py-4 flex items-center justify-between rounded-t-3xl">
              <h2 className="text-lg">竞品详情</h2>
              <button
                onClick={handleCloseDetail}
                className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-muted transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* 详情内容 */}
            <div className="px-6 py-4 space-y-4">
              {/* 门店信息 */}
              <div>
                <div className="flex items-center gap-2 mb-2">
                  <Store className="w-5 h-5 text-accent" />
                  <h3 className="text-base">{selectedInfo.store}</h3>
                </div>
                <p className="text-sm text-muted-foreground pl-7">
                  {selectedInfo.date} {selectedInfo.time} · 提交人：{selectedInfo.submitter}
                </p>
              </div>

              {/* 商品信息 */}
              <div className="bg-muted/30 rounded-lg p-4 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">商品名称</span>
                  <span className="text-sm">{selectedInfo.product}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">商品规格</span>
                  <span className="text-sm">{selectedInfo.spec}</span>
                </div>
                <div className="flex items-center justify-between">
                  <span className="text-sm text-muted-foreground">价格</span>
                  <span className="text-lg text-primary">HK$ {selectedInfo.price}</span>
                </div>
                {selectedInfo.note && (
                  <div className="pt-2 mt-2 border-t border-border/50">
                    <p className="text-sm text-muted-foreground mb-1">备注</p>
                    <p className="text-sm">{selectedInfo.note}</p>
                  </div>
                )}
              </div>

              {/* 商品图片 */}
              {selectedInfo.images && selectedInfo.images.length > 0 && (
                <div>
                  <p className="text-sm text-muted-foreground mb-2">现场图片</p>
                  <div className="grid grid-cols-3 gap-2">
                    {selectedInfo.images.map((image, index) => (
                      <div
                        key={index}
                        className="aspect-square rounded-lg overflow-hidden bg-muted cursor-pointer hover:opacity-90 transition-opacity"
                        onClick={() => handleImageClick(index)}
                      >
                        <img
                          src={image}
                          alt={`竞品图片${index + 1}`}
                          className="w-full h-full object-cover"
                        />
                      </div>
                    ))}
                  </div>
                  <p className="text-xs text-muted-foreground mt-2 text-center">
                    点击图片查看大图
                  </p>
                </div>
              )}
            </div>

            {/* 底部安全区 */}
            <div className="h-8" />
          </div>
        </>
      )}

      {/* 图片大图预览 */}
      {showImagePreview && selectedInfo?.images && (
        <div
          className="fixed inset-0 bg-black z-[60] flex items-center justify-center p-4"
          onClick={handleCloseImagePreview}
        >
          <button
            className="absolute top-4 right-4 w-10 h-10 flex items-center justify-center rounded-full bg-white/10 hover:bg-white/20 text-white transition-colors"
            onClick={handleCloseImagePreview}
          >
            <X className="w-6 h-6" />
          </button>
          <img
            src={selectedInfo.images[previewImageIndex]}
            alt="竞品图片大图"
            className="max-w-full max-h-full object-contain"
            onClick={(e) => e.stopPropagation()}
          />
        </div>
      )}
    </div>
  );
}