# 舌尖香港 · API 接口文档

> 版本：v1.4 · 更新日期：2026-03-31
> 面向：门店收银终端、移动 App、远程上传工具
> Base URL：`http://<服务器IP>:8080/api`

---

## 通用说明

### 认证方式

除登录/注册外，所有接口均需在 Header 中携带 Bearer Token：

```
Authorization: Bearer <token>
```

Token 通过登录接口获取，长期有效直到主动登出。

### 请求格式

- 所有请求 Body 使用 `Content-Type: application/json`
- 文件上传使用 `Content-Type: multipart/form-data`

### 统一响应格式

**成功（200 / 201）：**
```json
{ "data": { ... } }
// 或列表：
{ "data": [...], "current_page": 1, "total": 50, "per_page": 20 }
```

**创建成功（201）：**
```json
{ "message": "...", "id": 1 }
```

**参数错误（422）：**
```json
{
  "message": "The given data was invalid.",
  "errors": {
    "field": ["错误说明"]
  }
}
```

**未认证（401）：**
```json
{ "message": "Unauthenticated." }
```

### 流水号规则

| 前缀 | 来源 | 示例 |
|------|------|------|
| `SO-` | 正常收银上报 | `SO-20260331-A3K9PL` |
| `ADJ-` | 远程补录 / 手动调整 | `ADJ-20260331-X7BM2Q` |

---

## 一、认证 Auth

### 1.1 登录

**门店员工登录，获取 Token，所有后续请求均需此 Token。**

```
POST /api/login
```

**请求参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `email` | string | ✅ | 账号邮箱 |
| `password` | string | ✅ | 密码 |

**请求示例：**
```json
{
  "email": "cashier@sjtxg.com",
  "password": "password123"
}
```

**返回示例：**
```json
{
  "message": "Login successful",
  "token": "1|abcdefg1234567890...",
  "user": {
    "id": 3,
    "name": "小李",
    "email": "cashier@sjtxg.com"
  }
}
```

> ⚠️ 保存 `token`，后续所有请求 Header 中必须携带。

---

### 1.2 登出

```
POST /api/logout
Authorization: Bearer <token>
```

**返回：**
```json
{ "message": "Logged out successfully" }
```

---

### 1.3 获取当前用户信息

```
GET /api/me
Authorization: Bearer <token>
```

**返回：**
```json
{
  "user": {
    "id": 3,
    "name": "小李",
    "email": "cashier@sjtxg.com",
    "is_admin": false
  }
}
```

---

### 1.4 注册（限内部使用）

```
POST /api/register
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `name` | string | ✅ | 用户名 |
| `email` | string | ✅ | 邮箱，全局唯一 |
| `password` | string | ✅ | 密码，最少8位 |
| `password_confirmation` | string | ✅ | 确认密码 |

---

## 二、零售流水 Sales

### 2.1 新建销售单（核心接口）

**门店每完成一笔收银，调用此接口上报。系统自动：扣减库存 → 写库存流水 → 更新当日快照和销售汇总 → 更新商品最后销售时间。**

```
POST /api/sales
Authorization: Bearer <token>
```

**请求参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `items` | array | ✅ | 商品明细，至少1条 |
| `items[].product_id` | integer | ✅ | 商品ID |
| `items[].qty` | number | ✅ | 数量，最小 0.001 |
| `items[].unit_price` | number | ✅ | 单价（售价，单位：元） |
| `items[].discount_amount` | number | ❌ | 该商品行级折扣金额，默认 0 |
| `paid_amount` | number | ✅ | 实收金额（元） |
| `payment_method` | integer | ✅ | 支付方式（见枚举） |
| `cashier_id` | integer | ❌ | 收银员用户ID，不填则为匿名 |
| `discount_amount` | number | ❌ | 整单折扣金额，默认 0 |
| `notes` | string | ❌ | 备注，最多500字 |

**payment_method 枚举：**

| 值 | 说明 |
|----|------|
| 1 | 现金 |
| 2 | 微信支付 |
| 3 | 支付宝 |
| 4 | 银行卡 |
| 5 | 混合支付 |

**请求示例：**
```json
{
  "items": [
    { "product_id": 12, "qty": 2.5, "unit_price": 18.00, "discount_amount": 0 },
    { "product_id": 7,  "qty": 1,   "unit_price": 25.00, "discount_amount": 5.00 }
  ],
  "paid_amount": 60.00,
  "payment_method": 2,
  "cashier_id": 3,
  "discount_amount": 0
}
```

**返回示例（201）：**
```json
{
  "message": "销售单创建成功",
  "id": 88,
  "order_no": "SO-20260331-A3K9PL"
}
```

**副作用（自动执行，每个商品）：**
- `sales_orders` + `sales_order_items` — 写入完整流水记录
- `inventory.current_qty` — 扣减对应数量
- `inventory.last_sold_at` — 更新为当前时间
- `inventory_transactions` — 写入 type=2 销售出库
- `inventory_daily_snapshots` — `sold_qty +=`、`closing_qty` 更新；首次降为 0 时记录 `sold_out_at`
- `sales_daily_summaries` — 当日各商品销售量/金额实时累加

---

### 2.2 查询流水列表

**查询历史销售记录，包含正常收银（SO-）和远程补录（ADJ-）。**

```
GET /api/sales
Authorization: Bearer <token>
```

**Query 参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `date` | string | 按日期筛选，格式 `2026-03-31` |
| `cashier_id` | integer | 按收银员筛选 |
| `status` | integer | 1=已完成 2=已退款 3=部分退款 |
| `page` | integer | 页码，默认 1，每页 20 条 |

**返回示例：**
```json
{
  "data": [
    {
      "id": 88,
      "order_no": "SO-20260331-A3K9PL",
      "cashier": { "id": 3, "name": "小李" },
      "sold_at": "2026-03-31T10:30:00",
      "total_amount": "65.00",
      "paid_amount": "60.00",
      "payment_method": 2,
      "status": 1,
      "notes": null,
      "items": [
        {
          "product": { "id": 12, "name": "苹果", "unit": "斤" },
          "qty": "2.500",
          "unit_price": "18.00",
          "subtotal": "45.00"
        }
      ]
    },
    {
      "id": 102,
      "order_no": "ADJ-20260331-X7BM2Q",
      "cashier": null,
      "sold_at": "2026-03-31T14:30:00",
      "total_amount": "240.00",
      "paid_amount": "240.00",
      "status": 1,
      "notes": "[远程补录] 西红柿售罄"
    }
  ],
  "current_page": 1,
  "total": 50,
  "per_page": 20
}
```

---

### 2.3 销售单详情

```
GET /api/sales/{id}
Authorization: Bearer <token>
```

返回单笔销售单完整信息，含门店、收银员、所有商品明细。

---

### 2.4 今日营业汇总

**获取当日门店总单数、总金额、各支付方式占比。**

```
GET /api/sales/today
Authorization: Bearer <token>
```

**返回示例：**
```json
{
  "data": {
    "date": "2026-03-31",
    "order_count": 47,
    "total_amount": 3856.50,
    "by_payment": [
      { "method": "微信支付", "count": 30, "total_amount": 2600.00 },
      { "method": "现金",    "count": 12, "total_amount": 980.50 },
      { "method": "支付宝",  "count": 5,  "total_amount": 276.00 }
    ]
  }
}
```

---

## 三、库存管理 Inventory

### 3.1 当前库存列表

**查询门店所有商品的实时库存数量。**

```
GET /api/inventory
Authorization: Bearer <token>
```

**返回示例：**
```json
{
  "data": [
    {
      "id": 1,
      "product_id": 12,
      "product_name": "苹果",
      "unit": "斤",
      "is_fresh": true,
      "current_qty": 45.5,
      "available_qty": 45.5,
      "last_in_at": "03-30 09:15",
      "last_out_at": "03-31 14:22",
      "last_sold_at": "03-31 14:22",
      "updated_at": "03-31 14:22"
    }
  ]
}
```

**字段说明：**

| 字段 | 说明 |
|------|------|
| `current_qty` | 当前实际库存数量 |
| `available_qty` | 可用库存（= current_qty，锁定量暂不使用） |
| `last_in_at` | 最后一次入库时间 |
| `last_out_at` | 最后一次出库时间（含补录） |
| `last_sold_at` | 最后一次销售时间，用于判断商品销售速度 |

---

### 3.2 库存流水

**查询最近100条库存变动记录，包含正常销售和远程补录的流水。**

```
GET /api/inventory/transactions
Authorization: Bearer <token>
```

**返回示例：**
```json
{
  "data": [
    {
      "id": 205,
      "product_name": "苹果",
      "unit": "斤",
      "transaction_type": 2,
      "type_label": "销售出库",
      "qty_change": -2.5,
      "qty_before": 48.0,
      "qty_after": 45.5,
      "notes": "零售 SO-20260331-A3K9PL",
      "created_at": "03-31 10:30"
    }
  ]
}
```

**transaction_type 枚举：**

| 值 | 标签 | 触发场景 |
|----|------|---------|
| 1 | 进货入库 | 进货单收货 / AI 助手录入 |
| 2 | 销售出库 | 收银上报 / 远程标记售罄 |
| 3 | 损耗报废 | 远程登记损耗 / AI 助手录入 |
| 4 | 盘点调整 | 远程盘点修正 / AI 助手盘点 |
| 8 | 退货入库 | 销售退款（Filament后台） |

---

### 3.3 手动调整库存（含补录销售）

**远程修正库存数量，支持三种模式。有销售数据时同步写入销售流水和当日汇总。**

```
POST /api/inventory/adjust
Authorization: Bearer <token>
```

**请求参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `product_id` | integer | ✅ | 商品ID |
| `type` | string | ✅ | 调整类型（见枚举） |
| `qty` | number | ⚠️ | `type=adjust` 时必填，库存目标绝对值 |
| `qty_change` | number | ⚠️ | `type=damage` 时必填，损耗数量（正数） |
| `sold_qty` | number | ❌ | 本次对应的销售数量，填了则同步写销售流水 |
| `sold_amount` | number | ❌ | 本次对应的销售金额（元） |
| `occurred_at` | datetime | ❌ | 实际发生时间，格式 `2026-03-31 14:30`，不填默认当前时间 |
| `notes` | string | ❌ | 备注，最多500字 |

**type 枚举：**

| 值 | 说明 | 写库存流水类型 |
|----|------|--------------|
| `sold_out` | 标记售罄，库存直接归零 | type=2 销售出库 |
| `adjust` | 盘点修正，直接设定库存绝对值 | type=4 盘点调整 |
| `damage` | 损耗报废，减少指定数量 | type=3 损耗报废 |

**请求示例 1 — 标记西红柿售罄，补录销售数据：**
```json
{
  "product_id": 5,
  "type": "sold_out",
  "sold_qty": 20,
  "sold_amount": 240.00,
  "occurred_at": "2026-03-31 14:30",
  "notes": "西红柿售罄"
}
```

**请求示例 2 — 盘点修正，苹果实际还有8斤：**
```json
{
  "product_id": 12,
  "type": "adjust",
  "qty": 8,
  "notes": "盘点后修正"
}
```

**请求示例 3 — 损耗，猪肉腐烂扔掉2斤：**
```json
{
  "product_id": 3,
  "type": "damage",
  "qty_change": 2,
  "notes": "猪肉变质报废"
}
```

**返回示例：**
```json
{
  "message": "库存已更新",
  "data": {
    "product_id": 5,
    "qty_before": 20.0,
    "qty_after": 0,
    "qty_change": -20.0,
    "occurred_at": "2026-03-31 14:30"
  }
}
```

**副作用（填了 `sold_qty` 时额外执行）：**
- `sales_orders` — 写入一条备注为 `[远程补录]` 的流水，流水号前缀 `ADJ-`
- `sales_order_items` — 写入商品明细
- `sales_daily_summaries` — 累加当日该商品销售量/金额

---

### 3.4 补录销售数据

**补录未走收银台的销售数据（不更改实物库存）。每次调用累加到指定日期，不覆盖已有数据。同步写入销售流水和当日快照 sold_qty。**

```
POST /api/inventory/sales-summary
Authorization: Bearer <token>
```

**请求参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `product_id` | integer | ✅ | 商品ID |
| `date` | string | ✅ | 销售日期，格式 `2026-03-31` |
| `sales_qty` | number | ✅ | 补录销售数量，最小 0.001 |
| `sales_amount` | number | ✅ | 补录销售金额（元） |
| `transaction_count` | integer | ❌ | 笔数，不填默认按1笔计 |
| `occurred_at` | datetime | ❌ | 实际发生时间，不填默认当前时间 |
| `notes` | string | ❌ | 备注 |

**请求示例：**
```json
{
  "product_id": 8,
  "date": "2026-03-31",
  "sales_qty": 15.5,
  "sales_amount": 186.00,
  "transaction_count": 6,
  "notes": "下午散称未录入系统的销售"
}
```

**返回示例：**
```json
{
  "message": "销售数据已补录",
  "data": {
    "order_no": "ADJ-20260331-X7BM2Q",
    "sales_order_id": 115,
    "product_id": 8,
    "date": "2026-03-31",
    "sales_qty": 35.5,
    "sales_amount": 426.00,
    "transaction_count": 13
  }
}
```

> 返回的 `sales_qty` / `sales_amount` 为累加后的当日总量，非本次补录量。

---

### 3.5 每日库存运营概览（核心日报接口）

**按日期查询每个商品的完整运营数据：往日库存、今日进货、今日库存、已售量/金额、结算库存、售罄时间。**

```
GET /api/inventory/daily-overview?date=2026-03-31
Authorization: Bearer <token>
```

**Query 参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `date` | string | 查询日期，格式 `2026-03-31`，不传默认今天 |

**返回示例：**
```json
{
  "data": {
    "date": "2026-03-31",
    "total_received_skus": 8,
    "total_sold_skus": 10,
    "total_sold_amount": 3856.50,
    "total_sold_out": 3,
    "products": [
      {
        "product_id": 12,
        "product_name": "苹果",
        "unit": "斤",
        "is_fresh": true,
        "opening_qty": 10.0,
        "received_qty": 50.0,
        "available_qty": 60.0,
        "sold_qty": 60.0,
        "sold_amount": 1080.00,
        "transaction_count": 24,
        "damage_qty": 0,
        "adjustment_qty": 0,
        "closing_qty": 0,
        "is_sold_out": true,
        "sold_out_at": "14:22",
        "last_sold_at": "14:22"
      },
      {
        "product_id": 8,
        "product_name": "香蕉",
        "unit": "斤",
        "is_fresh": true,
        "opening_qty": 5.0,
        "received_qty": 30.0,
        "available_qty": 35.0,
        "sold_qty": 20.0,
        "sold_amount": 160.00,
        "transaction_count": 7,
        "damage_qty": 0,
        "adjustment_qty": 0,
        "closing_qty": 15.0,
        "is_sold_out": false,
        "sold_out_at": null,
        "last_sold_at": "16:45"
      }
    ]
  }
}
```

**字段说明：**

| 字段 | 数据来源 | 说明 |
|------|---------|------|
| `opening_qty` | `inventory_daily_snapshots` | 往日库存 = 当天第一笔交易前的库存量，一旦写入不再变动 |
| `received_qty` | `inventory_daily_snapshots` | 今日进货合计（已确认收货的进货单） |
| `available_qty` | 计算值 | 今日库存 = `opening_qty + received_qty` |
| `sold_qty` | `sales_daily_summaries` | 今日销售出库合计（含补录，以销售汇总为准） |
| `sold_amount` | `sales_daily_summaries` | 今日销售金额合计 |
| `damage_qty` | `inventory_daily_snapshots` | 今日损耗合计 |
| `adjustment_qty` | `inventory_daily_snapshots` | 今日盘点调整合计 |
| `closing_qty` | `inventory_daily_snapshots` | 结算库存（实时，每笔交易后更新） |
| `is_sold_out` | 计算值 | `closing_qty <= 0` 即为售罄 |
| `sold_out_at` | `inventory_daily_snapshots` | 当日首次售罄时间（closing_qty 首次降为 0 的交易时间，补货后自动清除） |
| `last_sold_at` | `inventory` | 最后一次销售时间 |

---

### 3.6 今日操作日志

**查询当日所有远程操作指令记录。无论是否影响库存，均留有记录（`is_operational` 区分）。**

```
GET /api/daily-logs?date=2026-03-31
Authorization: Bearer <token>
```

**Query 参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| `date` | string | 查询日期，格式 `2026-03-31`，不传默认今天 |

**返回示例：**
```json
{
  "data": {
    "date": "2026-03-31",
    "total": 6,
    "operational_count": 4,
    "logs": [
      {
        "id": 1,
        "occurred_at": "09:10",
        "source": "AI助手",
        "content": "AI语音: 今天苹果到货五十斤",
        "intent": "stock_in",
        "is_operational": true,
        "product_name": "苹果",
        "qty_change": 50.0,
        "reference_type": "ai_message",
        "reference_id": 12
      },
      {
        "id": 2,
        "occurred_at": "14:30",
        "source": "手动API",
        "content": "手动调整: 标记售罄",
        "intent": "sold_out",
        "is_operational": true,
        "product_name": "西红柿",
        "qty_change": -12.0,
        "reference_type": "inventory",
        "reference_id": 5
      },
      {
        "id": 3,
        "occurred_at": "16:00",
        "source": "AI助手",
        "content": "AI助手: 今天新来了不少顾客",
        "intent": "other",
        "is_operational": false,
        "product_name": null,
        "qty_change": null,
        "reference_type": "ai_message",
        "reference_id": 18
      }
    ]
  }
}
```

**字段说明：**

| 字段 | 说明 |
|------|------|
| `source` | AI助手 / 手动API / Filament后台 |
| `intent` | stock_in / stock_out / sold_out / damage / adjust / supplement / note / other |
| `is_operational` | true=已影响库存/销售数据；false=仅记录（如"今天来了不少顾客"） |
| `qty_change` | 库存变动量（正入负出），仅 is_operational=true 时有值 |

---

## 四、AI 助手 AI Assistant

### 4.1 文字 / 图片输入

**用自然语言描述库存操作，AI 自动解析并更新库存。**

```
POST /api/ai/message
Authorization: Bearer <token>
```

**请求参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `text` | string | ⚠️ | 自然语言文本，最多2000字。`text` 和 `image_base64` 至少填一个 |
| `image_base64` | string | ⚠️ | 图片 Base64（如送货单、白板盘点表） |
| `session_id` | integer | ❌ | 上一条消息的 session_id，用于多轮对话 |

**自然语言示例：**
```
"今天苹果到货50斤，香蕉20斤"   → 入库
"卖掉了3斤苹果，2斤葡萄"       → 出库
"盘点：苹果现在还有45斤"       → 库存调整
"猪肉腐烂了，扔掉了2斤"       → 损耗
"今天来了不少顾客"             → 仅记录（is_operational=false）
```

**返回示例：**
```json
{
  "reply": "已记录：苹果入库50斤，香蕉入库20斤，库存已更新。",
  "intent": "stock_in",
  "session_id": 15,
  "operations": [
    {
      "product_id": 12,
      "product_name": "苹果",
      "action": "in",
      "qty": 50,
      "unit": "斤",
      "qty_before": 5.5,
      "qty_after": 55.5
    }
  ]
}
```

**intent 枚举：**

| 值 | 说明 |
|----|------|
| `stock_in` | 入库（进货、到货） |
| `stock_out` | 出库（损耗、报废） |
| `inventory_adjust` | 盘点调整 |
| `other` | 无法识别 / 纯信息（不触发库存操作） |

---

### 4.2 语音输入

```
POST /api/ai/voice
Authorization: Bearer <token>
Content-Type: multipart/form-data
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `audio` | file | ✅ | 录音文件，格式：mp3/wav/m4a/webm/ogg，最大 25MB |
| `session_id` | integer | ❌ | 关联会话ID |

**返回示例：**
```json
{
  "transcribed_text": "今天苹果到货五十斤",
  "reply": "已记录：苹果入库50斤，库存已更新。",
  "intent": "stock_in",
  "session_id": 16,
  "operations": [...]
}
```

---

### 4.3 查询会话列表

```
GET /api/ai/sessions
Authorization: Bearer <token>
```

返回分页列表，含 session_id、渠道、创建时间。

---

### 4.4 查询会话消息记录

```
GET /api/ai/sessions/{session_id}/messages
Authorization: Bearer <token>
```

**返回示例：**
```json
[
  {
    "id": 101,
    "role": 1,
    "raw_content": "今天苹果到货50斤",
    "intent": "stock_in",
    "entities": [{ "product_name": "苹果", "qty": 50, "unit": "斤", "action": "in" }],
    "created_at": "2026-03-31T09:15:00"
  },
  {
    "id": 102,
    "role": 2,
    "ai_response": "已记录：苹果入库50斤，库存已更新。",
    "processing_time_ms": 842,
    "created_at": "2026-03-31T09:15:01"
  }
]
```

**role：** 1=用户 2=AI助手

---

## 五、人才简历 Resumes

### 5.1 解析简历（预览，不保存）

```
POST /api/resumes/parse
Authorization: Bearer <token>
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `text` | string | ✅ | 简历原文，最多5000字 |
| `image_base64` | string | ❌ | 简历图片 |

---

### 5.2 保存简历

```
POST /api/resumes
Authorization: Bearer <token>
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `name` | string | 姓名 |
| `phone` | string | 电话 |
| `gender` | integer | 0=未知 1=男 2=女 |
| `age` | integer | 年龄，15-99 |
| `districts` | array | 意向工作地区，如 `["筲箕湾","柴湾"]` |
| `work_types` | array | 工作类型，如 `["全职","小时工"]` |
| `positions` | array | 意向职位，如 `["收银员"]` |
| `experience_years` | number | 工作年限 |
| `salary_min` | integer | 最低薪资期望 |
| `salary_max` | integer | 最高薪资期望 |
| `salary_unit` | integer | 1=月薪 2=日薪 3=时薪 |
| `education` | integer | 1=初中 2=高中/中专 3=大专 4=本科 |
| `availability_date` | date | 最早到岗日期 |
| `languages` | array | 语言能力 |
| `skills` | array | 技能标签 |
| `source` | integer | 1=手动 2=AI解析 3=文件上传 |
| `status` | integer | 0=无效 1=求职中 2=已入职 3=暂不求职 |
| `notes` | string | 备注 |

---

### 5.3 批量解析并保存

```
POST /api/resumes/batch
Authorization: Bearer <token>
```

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `items` | array | ✅ | 简历列表，最多50条 |
| `items[].text` | string | ✅ | 每份简历原文 |
| `items[].image_base64` | string | ❌ | 对应图片 |

**返回示例：**
```json
{
  "total": 5,
  "success": 4,
  "failed": 1,
  "results": [
    { "status": "ok", "id": 201, "name": "陈小明" },
    { "status": "failed", "reason": "AI解析失败" }
  ]
}
```

---

### 5.4 简历列表

```
GET /api/resumes?status=1&work_type=全职&district=筲箕湾
Authorization: Bearer <token>
```

| 参数 | 说明 |
|------|------|
| `status` | 1=求职中 2=已入职 |
| `work_type` | 全职 / 兼职 / 小时工 |
| `district` | 地区名 |
| `position` | 职位名 |
| `page` | 页码 |

---

### 5.5 自然语言搜索简历

```
GET /api/resumes/search?q=筲箕湾附近能做小时工的收银员
Authorization: Bearer <token>
```

**返回示例：**
```json
{
  "data": [...],
  "criteria": {
    "districts": ["筲箕湾", "西湾河"],
    "work_types": ["小时工"],
    "positions": ["收银员"]
  },
  "total": 8
}
```

---

### 5.6 更新简历

```
PUT /api/resumes/{id}
Authorization: Bearer <token>
```

Body 字段同 5.2，仅传需要修改的字段。

---

### 5.7 删除简历

```
DELETE /api/resumes/{id}
Authorization: Bearer <token>
```

---

## 六、错误码速查

| HTTP 状态码 | 含义 | 常见原因 |
|------------|------|---------|
| 200 | 成功 | — |
| 201 | 创建成功 | — |
| 401 | 未认证 | Token 未携带或已失效，需重新登录 |
| 422 | 参数错误 | 必填字段缺失、格式不对、值不在枚举范围内 |
| 404 | 资源不存在 | ID 不存在或已被删除 |
| 500 | 服务器错误 | 联系技术支持 |

---

## 七、数据写入链路总览

```
收银上报 POST /api/sales
  ├─ sales_orders              流水号 SO-YYYYMMDD-XXXXXX
  ├─ sales_order_items         商品明细
  ├─ inventory                 current_qty -= / last_sold_at 更新
  ├─ inventory_transactions    type=2 销售出库
  ├─ inventory_daily_snapshots sold_qty += / closing_qty 更新
  │                            closing_qty 首次降为 0 → sold_out_at 写入
  └─ sales_daily_summaries     当日汇总实时累加

进货单确认收货（Filament后台）
  ├─ inventory                 current_qty += / last_in_at 更新
  ├─ inventory_transactions    type=1 进货入库
  ├─ inventory_daily_snapshots received_qty += / closing_qty 更新
  │                            重新有货（closing_qty>0）→ sold_out_at 清除
  └─ daily_operation_logs      source=3 后台，intent=stock_in

远程标记售罄 POST /api/inventory/adjust (type=sold_out, 含 sold_qty)
  ├─ sales_orders              流水号 ADJ-，备注 [远程补录]
  ├─ sales_order_items         商品明细
  ├─ inventory                 current_qty=0 / last_sold_at 更新
  ├─ inventory_transactions    type=2 销售出库
  ├─ inventory_daily_snapshots sold_qty += / closing_qty=0 / sold_out_at 写入
  ├─ sales_daily_summaries     当日汇总实时累加
  └─ daily_operation_logs      source=2 手动API，intent=sold_out

补录销售 POST /api/inventory/sales-summary（不改实物库存）
  ├─ sales_orders              流水号 ADJ-，备注 [远程补录]
  ├─ sales_order_items         商品明细
  ├─ sales_daily_summaries     指定日期汇总累加
  ├─ inventory_daily_snapshots sold_qty += （若当日有快照则同步，无快照跳过）
  └─ daily_operation_logs      source=2 手动API，intent=supplement

盘点修正 POST /api/inventory/adjust (type=adjust)
  ├─ inventory                 current_qty 设为目标值
  ├─ inventory_transactions    type=4 盘点调整
  ├─ inventory_daily_snapshots adjustment_qty += / closing_qty 更新
  └─ daily_operation_logs      source=2 手动API，intent=adjust

损耗报废 POST /api/inventory/adjust (type=damage)
  ├─ inventory                 current_qty -= qty_change
  ├─ inventory_transactions    type=3 损耗报废
  ├─ inventory_daily_snapshots damage_qty += / closing_qty 更新
  └─ daily_operation_logs      source=2 手动API，intent=damage

AI助手操作（影响库存类）POST /api/ai/message 或 voice
  ├─ ai_sessions + ai_messages  对话记录
  ├─ inventory                  按 intent 更新
  ├─ inventory_transactions     对应类型
  ├─ inventory_daily_snapshots  对应字段更新 + sold_out_at 逻辑
  ├─ daily_operation_logs       source=1 AI，intent=对应intent，is_operational=true
  └─ （退出 dispatchToInventory 后，message/voice 方法写 log）

AI助手操作（仅信息类，如"今天来了不少顾客"）
  ├─ ai_sessions + ai_messages  对话记录
  └─ daily_operation_logs       source=1 AI，intent=other，is_operational=false
```

---

## 八、门店使用流程

### 日常收银上报

```
1. 员工上班    → POST /api/login                  获取 token
2. 每笔收银    → POST /api/sales                  上报流水，自动扣库存 + 更新快照
3. 查当日营业  → GET  /api/sales/today            总额 + 支付方式占比
4. 查每日运营  → GET  /api/inventory/daily-overview 往日库存/进货/销售/售罄全览
5. 下班查库存  → GET  /api/inventory              当前各商品库存
```

### 远程补录 / 调整

```
某商品卖完未录入 → POST /api/inventory/adjust        type=sold_out + sold_qty
散称销售补录     → POST /api/inventory/sales-summary
盘点后修正库存   → POST /api/inventory/adjust        type=adjust
损耗报废登记     → POST /api/inventory/adjust        type=damage
查所有变动流水   → GET  /api/inventory/transactions
查今日指令记录   → GET  /api/daily-logs
```

### AI 语音入库（进货/盘点/损耗）

```
录音上传 → POST /api/ai/voice   → 自动识别 + 更新库存 + 写操作日志
文字描述 → POST /api/ai/message → 同上
核对结果 → GET  /api/inventory/transactions
当日日报 → GET  /api/inventory/daily-overview
```
