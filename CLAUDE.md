# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**舌尖香港 · AI店长助手** — 生鲜门店 AI 管理系统，前后端分离的 monorepo。

- **Backend**: Laravel 12 API (PHP 8.4) — `backend/`
- **Frontend**: Next.js 16 (React 19.2, TypeScript) — `frontend/`
- **Admin Panel**: Filament v3 (Livewire v3) — `http://0.0.0.0:8303/admin`
- **WeChat Mini Program**: 原生小程序（ES5 风格）— `miniprogram/`，复用同一套后端 API

---

## 核心业务逻辑（单店视角）

每天的数据库记录由 6 个维度组成，全部按天存档：

| # | 数据 | 存储表 |
|---|------|--------|
| 1 | 往日库存（每品种开盘数量） | `inventory_daily_snapshots.opening_qty`（当天第一笔事务时冻结） |
| 2 | 今日进货明细 | `purchase_orders` + `purchase_order_items` |
| 3 | 今日库存 = 往日 + 进货 | `inventory_daily_snapshots.closing_qty`（实时滚动更新） |
| 4 | 今日销售情况（每笔+补录） | `sales_orders` + `sales_order_items` |
| 5 | 今日所有远程指令留档 | `daily_operation_logs`（AI/手动/后台，含非库存类指令） |
| 6 | 今日销售汇总 | `sales_daily_summaries`（per-product 汇总量/金额/售罄时间） |

**完整写链（以进货为例）：**
```
Filament 进货单"确认收货"
  → inventory.current_qty += ordered_qty
  → inventory_transactions  type=1
  → inventory_daily_snapshots.received_qty +=  /  closing_qty = qtyAfter
  → daily_operation_logs  source=3, intent=stock_in
```

**完整写链（以销售为例）：**
```
POST /api/sales
  → sales_orders + sales_order_items
  → inventory.current_qty -= qty,  last_sold_at = now()
  → inventory_transactions  type=2
  → inventory_daily_snapshots.sold_qty +=  /  closing_qty = qtyAfter
      └─ 若 closing_qty 首次归零 → sold_out_at = now()（当天唯一）
  → sales_daily_summaries  sales_qty / sales_amount / transaction_count +=
```

**核心表职责：**

| 表 | 职责 |
|---|------|
| `inventory` | 实时库存（current_qty / last_sold_at），滚动更新 |
| `inventory_transactions` | 所有变动审计流水，永不删除 |
| `inventory_daily_snapshots` | per-product 每日快照：opening / received / sold / damage / closing / sold_out_at |
| `purchase_orders` + `purchase_order_items` | 每日进货计划与实收明细 |
| `sales_orders` + `sales_order_items` | 每笔零售流水 |
| `sales_daily_summaries` | per-product 每日销售汇总（量/金额/均价/笔数）；含三来源分列：`pos_qty/amount`、`supplement_qty/amount`、`ai_qty/amount` |
| `daily_operation_logs` | 所有远程指令留档（AI + 手动 API + Filament 后台） |

**今日库存公式：** `closing_qty = opening_qty + received_qty - sold_qty - damage_qty ± adjustment_qty`

⚠️ `InventoryDailySnapshot::record()` 中 type=1（进货）只更新 `received_qty`，**不修改** `opening_qty`。

---

## Current Ports

> ⚠️ 同机双栈部署：本项目（company-ai / PostgreSQL）跑在 `:8303` + `:3117`。下表是**本项目**的端口。

| Service | Port | URL |
|---------|------|-----|
| Laravel API + Filament Admin | 8303 | `http://0.0.0.0:8303` |
| Next.js Frontend | 3117 | `http://0.0.0.0:3117` |


## 项目路径 & 进程管理

- **项目根目录**: `/home/mi/app61.xingke888.com`
- **运行用户**: `mi`（PM2 由 `pm2-mi.service` 管理）

### PM2 管理（必须加 sudo -u mi）
```bash
sudo -u mi pm2 list
sudo -u mi pm2 restart app61-backend
sudo -u mi pm2 restart app61-frontend
sudo -u mi pm2 logs app61-backend --lines 50
sudo -u mi pm2 save
```

## Development Commands

### Backend (run from `backend/`)
```bash
php artisan serve --host=0.0.0.0 --port=8303

php artisan migrate
php artisan migrate:fresh --seed
php artisan config:clear          # Required after .env changes
php artisan route:list --path=api # Inspect API routes

php artisan make:model Foo -mf            # Model + migration + factory
php artisan make:controller Api/FooController
php artisan make:filament-resource Foo    # Filament admin resource

php artisan test
php artisan test --filter=testName
php artisan test tests/Feature/FooTest.php
```

### Frontend (run from `frontend/`)
```bash
npm run dev       # Dev server on :3117
npm run build     # Production build (use to verify TypeScript errors)
npm run lint
npx shadcn@latest add [component-name]
```

---

## Architecture

### Authentication — Three separate systems

**External API (JWT token-based, recommended for remote/machine callers):**
1. POST `/api/login` → returns `jwt_token` (JWT) + `token` (Sanctum opaque)
2. `login` field accepts **username** OR email — system auto-detects by presence of `@`
3. JWT encodes `store_id` as a claim; middleware extracts it via `User::resolveStoreId()`
4. Signed with `JWT_SECRET` (HS256). Configured in `backend/config/jwt.php`

**Frontend app (Sanctum opaque token):**
1. Same POST `/api/login` → use the `token` field
2. Token stored in `localStorage`, sent as `Authorization: Bearer {token}`
3. `AuthProvider` (`frontend/lib/auth-context.tsx`) manages global state

**Admin panel (Filament session-based):**
- URL: `/admin`, login at `/admin/login`
- Only users with `is_admin = true` can access (enforced via `User::canAccessPanel()`)
- Admin account: `admin@sjtxg.com` / `Admin@2026`
- Demo account: `demo@example.com` / `username: demo` / `password` (no admin access)

**API route middleware:** All protected routes use `auth.hybrid` (`app/Http/Middleware/JwtOrSanctumAuth.php`, registered in `bootstrap/app.php`). It routes by token shape: a **JWT (token with 2 dots)** → `authenticateViaJwt` (sets `JwtAbilityToken` with an `abilities` array, store_id from JWT claims); **anything else** → `authenticateViaSanctum` → `Auth::guard('sanctum')->user()`. `store_id` is always resolved from the token via `User::resolveStoreId()` — never trusted from the request body.

#### ⚠️ 重要：同源 / web-view 调用方必须用 JWT，不能用 Sanctum opaque token

`paper.xingke888.com` **同时托管前端和后端**，所以小程序 web-view 里加载的 H5 页面对 `/api/*` 的 fetch 是**同源请求，会自动带上 cookie**。此时 Sanctum 路径 `Auth::guard('sanctum')->user()` 先查会话 guard：若存在任何 `laravel_session` 会话 → 返回 `Laravel\Sanctum\TransientToken`（**没有 `abilities` 属性**）→ `resolveStoreId()` 访问 `$token->abilities` 抛 **500**，Bearer token 被无视。

**解决方案：machine/web-view 调用方一律用 `jwt_token`**。JWT 走 `authenticateViaJwt` 独立路径，完全不碰会话 guard。

- 小程序 `utils/request.js` 登录后存的就是 `res.data.jwt_token`（不是 `token`）；web-view URL 携带的也是 JWT。
- 防御性兜底：`User::resolveStoreId()` 用 `isset($token->abilities)` 安全判断，TransientToken 直接回退 `primaryStoreId()`。

### API Layer Pattern (Frontend)

All API calls go through `frontend/lib/api/client.ts` (custom fetch wrapper). Token is passed **explicitly** as the last parameter — it is NOT auto-injected:

```ts
export const fooApi = {
  list:   (token: string) => apiClient.get<FooResponse>('/foo', token),
  create: (data: FooData, token: string) => apiClient.post<Foo>('/foo', data, token),
}
// Voice/file uploads use native fetch directly (apiClient doesn't support FormData)
```

API files: `lib/api/assistant.ts`, `lib/api/inventory.ts`, `lib/api/sales.ts`, `lib/api/purchase-orders.ts`, `lib/api/damage.ts`, `lib/api/suggestions.ts`, `lib/api/operations.ts`, `lib/api/resumes.ts`, `lib/api/auth.ts`

### AI Assistant Flow

```
User input (text / image base64 / voice file)
  → POST /api/ai/message  or  POST /api/ai/voice
  → AiService::parseInventoryIntent()   (OpenAI-compatible API)
  → AiAssistantController: intent is query? → fetchQueryData() → card_type + card_data
                            intent is write? → dispatchToInventory()
                                ├─ Product::findOrCreateByName()
                                ├─ Inventory::firstOrCreate([store_id, product_id])
                                ├─ InventoryTransaction::create()
                                ├─ InventoryDailySnapshot::record()
                                ├─ action=in  → PurchaseOrder + PurchaseOrderItem
                                ├─ action=sell/sold_out → SalesOrder + SalesDailySummary
                                └─ action=out → DamageRecord (自动关联最近进货单/供应商)
  → Returns { reply, intent, operations[], card_type?, card_data?, session_id }
```

**AI 模型分工（三路独立配置）：**

| 用途 | 环境变量 | 当前值 |
|------|---------|-------|
| 文字意图解析 | `AI_BASE_URL` / `AI_MODEL` | DeepSeek `deepseek-v4-pro` |
| 图片识别 | `AI_VISION_BASE_URL` / `AI_VISION_MODEL` | fidelityai `gemini-3-flash-preview` |
| 语音转文字 | `AI_WHISPER_BASE_URL` / `AI_WHISPER_MODEL` | fidelityai `whisper-1` |

**⚠️ 意图匹配逻辑：「匹配」不是后端关键词规则，而是 LLM 归类 + 后端按字符串路由两段式。**

1. **LLM 归类**（`AiService::parseInventoryIntent()`）：system prompt 强制模型只返回 JSON `{intent, date, items:[{product_name,qty,unit,action,reason}], customer:{}, reply}`。Claude 等不支持 `response_format=json_object` → 靠 `extractJson()` 从代码块/夹带文字里抠 JSON，解析失败兜底 `intent=other`。

2. **后端按 `intent` 字符串三岔路由**（`AiAssistantController::message()`，纯字符串判断不再调 LLM）：

   | 类别 | 判断 | 处理 | 返回字段 |
   |------|------|------|---------|
   | **查询类** | `in_array($intent, $queryIntents)`（`*_query` + `weather_query`） | `fetchQueryData()` 直接查 DB，不写库 | `card_type` + `card_data` |
   | **库存写入类** | 非 query/other 且 `items` 非空 | `dispatchToInventory()` 写库存/流水/快照/单据 | `operations[]` |
   | **CRM 写入类** | `intent ∈ {customer_add, follow_up_add}` | `dispatchCrm()`（走 `customer` 字段） | `operations[]` |
   | **other** | 都不匹配 | 仅写 `daily_operation_logs` | 仅 `reply` |

3. **小程序消费**：写入类显示 `reply`+`operations`；查询类真实数据在 `card_data` → `chat.js cardToMarkdown()` 渲染成 markdown（**无 SSE 流式**）。

**AI 识别的 intent / action 枚举：**

| intent | action | 语义 | 后端写入 |
|--------|--------|------|---------|
| `purchase_receipt` | `in` | 进货到货 | InventoryTransaction + PurchaseOrder/Item |
| `sale_report` | `sell` | 有具体售出量 | InventoryTransaction + SalesOrder + SalesDailySummary |
| `sold_out` | `sold_out` | 商品完全售罄 | 同上，qty=0 |
| `remaining` | `remaining` | 报告剩余量（倒推售出量） | 同上 |
| `stocktake` | `adjust` | 盘点上报绝对值 | InventoryTransaction(type=4) |
| `waste_report` | `out` | 损耗/报废（items 含 `reason` 字段） | InventoryTransaction(type=3) + DamageRecord |
| `inventory_query` | — | 查当前库存 | card_type=inventory |
| `sales_today_query` | — | 查今日/历史销售 | card_type=sales_today |
| `daily_overview_query` | — | 查每日运营概览 | card_type=daily_overview |
| `purchase_orders_query` | — | 查进货单 | card_type=purchase_orders |
| `daily_logs_query` | — | 查操作日志 | card_type=daily_logs |
| `weather_query` | — | 查天气（LLM生成+DB缓存） | card_type=weather |
| `refund_claims_query` | — | 查供应商退款申请 | card_type=refund_claims |
| `suggestions_query` | — | 查进货/促销建议（调 SuggestionService） | card_type=suggestions |
| `product_query` | — | 查商品档案 | card_type=product |
| `customer_add` / `follow_up_add` | — | CRM 新增顾客/跟进 | `dispatchCrm()` |
| `customer_query` / `customer_orders_query` | — | 查顾客/订单 | card_type=customer/customer_orders |
| `other` | — | 非库存类 | 仅写 DailyOperationLog |

### Services Layer

| Service | 职责 |
|---------|------|
| `AiService` | LLM 调用封装（文字/图片/语音三路） |
| `SuggestionService` | 进货/促销建议算法（近7天快照→补货优先级），被 `SuggestionController` 和 `AiAssistantController` 调用 |
| `ResumeParserService` | 简历 AI 解析 + 自然语言搜索条件提取 |
| `JwtService` | JWT 签发与验证（HS256，secret 来自 `config/jwt.php`） |
| `SalesUploadService` | 销售数据批量上传处理 |
| `PurchaseUploadService` | 进货单批量上传处理 |

### Database

PostgreSQL 14. Connection: `laravel` / `laravel_password` / `laravel_app`（`127.0.0.1:5432`）。

MVP seed data: organization_id=1, region_id=1, store_id=1 (硬编码在 controllers，待权限系统接入后动态化).

Key table groups:
- **AI**: `ai_sessions`, `ai_messages`
- **Inventory**: `inventory`, `inventory_transactions`, `inventory_daily_snapshots`
- **Daily ops**: `daily_operation_logs`, `sales_daily_summaries`
- **Products**: `products`, `product_categories`
- **Sales**: `sales_orders`, `sales_order_items`
- **Suppliers**: `suppliers`, `supplier_products`, `purchase_orders`, `purchase_order_items`
- **Org**: `organizations`, `regions`, `stores`, `users`, `roles`, `permissions`, `user_store_roles`
- **Finance**: `expenses`, `expense_categories`
- **HR**: `employees`, `schedules`, `attendance_records`, `salary_records`
- **Talent**: `resumes`
- **Mini-program**: `industries`, `menu_templates`, `quick_actions`（行业选择 + 菜单模版体系）

### Filament Admin (v3)

- Panel provider: `backend/app/Providers/Filament/AdminPanelProvider.php`
- Resources auto-discovered from `backend/app/Filament/Resources/`
- Current resources by nav group:
  - **销售管理**: `SalesOrderResource`
  - **商品管理**: `ProductResource`
  - **库存管理**: `DailyOperations` (每日营运概览, sort=0), `InventoryResource`, `PurchaseOrderResource`
  - **供应商**: `SupplierResource` (含 SupplierProductsRelationManager)
  - **财务管理**: `ExpenseResource`, `ExpenseCategoryResource`
  - **人才库**: `ResumeResource`
  - **系统**: `UserResource`, `RoleResource`, `IndustryResource`（行业模版）, `MenuTemplateResource`（菜单模版）, `QuickActionResource`（快捷按钮）

Add new resource:
```bash
php artisan make:filament-resource Product --generate
```

**Filament v3 命名空间规则：**
- Table 行级 actions 用 `Filament\Actions\EditAction` 等，**不是** `Filament\Tables\Actions\EditAction`
  - 在 Resource 文件里加 `use Filament\Actions;`，写 `Actions\EditAction::make()`
- List page 的 `getTabs()` 返回 `Filament\Schemas\Components\Tabs\Tab`
- Form/Table schema 方法签名：`Schema $schema` (不是 `Form $form` / `Table $table`)

**自定义 Blade 视图的 Tailwind CSS：**
Filament 发布的 `app.css` 只含 Filament 自身组件用的类。自定义视图（如 `DailyOperations`）用到的 Tailwind 工具类需通过 Vite 主题编译：
- 主题文件：`backend/resources/css/filament/admin/theme.css`
- **修改自定义视图 Tailwind 类后需重新 `npm run build`**（在 `backend/`）

---

## 前端注意事项

### 生产模式运行
前端以 `npm run start`（生产模式）运行在 `:3117`，**修改前端代码后必须重新 build 才能生效**：
```bash
cd frontend && npm run build
# 重启：pkill 只杀父 shell，子 next-server 会被 init 收养继续占端口
pgrep -f next-server   # 找真正 PID
kill <PID> && nohup npm run start > /tmp/nextjs.log 2>&1 &
ss -ltn | grep :3117   # 确认端口释放后再启动
```

### 日期处理陷阱
前端所有 `todayStr()` 函数**必须使用本地时间**，不能用 `new Date().toISOString().slice(0, 10)`（返回 UTC，香港时间凌晨 0-8 点会早一天）：
```ts
// ✅ 正确
function todayStr() {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}
```
后端时区为 `Asia/Shanghai`，PostgreSQL 使用本地时区（CST），日期存储和查询均基于本地时间。

---

## 微信小程序（`miniprogram/`）

原生小程序，**复用 Next.js 前端用的同一套后端**。所有源码**强制 ES5 风格**（`var`/`function`，无 `let/const`/箭头函数/模板字符串/解构）——避免微信开发者工具 ES6→ES5 转译触发 `@babel/runtime` require 报错。无构建步骤；改完代码在**微信开发者工具里"清缓存→重新编译"**才生效。

**后端地址**：`miniprogram/app.js` 的 `apiBaseUrl = https://paper.xingke888.com/api`。

**登录（账号密码，非微信一键登录）**：
- `utils/request.js` `login()` → `POST /login`，**存 `jwt_token`（JWT）**到 `globalData.token` + storage（**不是 Sanctum `token`**——避免 web-view 同源 cookie 触发 TransientToken 500）。
- **多门店账号**不带 `store_id` 会 422 + `stores:[]` → `chat.js _doLogin` 用 `wx.showActionSheet` 弹门店选择后带 `store_id` 重登。
- `app.js onLaunch`：**没 token 不恢复 user**（否则"假登录"）。`chat.js onLoad` 调 `/me` 校验缓存 token，失效则回登录表单。
- ⚠️ Laravel 对**缺 `Accept: application/json`** 头的请求返回 302 重定向而非 422 JSON——`request.js` 固定带该头。

**行业选择（启动落地页）**：`pages/industry/industry` 是**启动第一页**（`app.json` pages 首位）。选中后存 `globalData.industry = {slug, title, apiBase, apiToken, aiPath}`（**仅内存，不写 storage — 每次进入都要重选**）→ `wx.redirectTo` 到 `chat`。

**外部行业链路（apiBase 非空，如进销存及CRM）**：

外部行业是**完全独立的 app / 项目 / URL**，paper 小程序仅作启动入口，所有意图识别、业务逻辑、数据库操作均由外部 app 自己处理。

| 字段 | 来源 | 作用 |
|------|------|------|
| `apiBase` | `industries.api_base` | 外部后端 base URL（如 `https://app2.xingke888.com/api`） |
| `apiToken` | `industries.api_token` | 服务账号 JWT，后台配置，小程序无感直接使用 |
| `aiPath` | `industries.ai_path` | AI 聊天接口路径，留空默认 `/ai/message` |

**完整链路：**
```
用户选外部行业
  → GET /api/industries 返回 { apiBase, apiToken, aiPath }
  → 存入 globalData.industry（仅内存）
  → chat.js 检测 ind.apiBase 非空 → externalMode=true
  → ind.apiToken 非空 → 直接进入，无需登录表单
  → ind.apiToken 为空 → 提示「请联系管理员配置服务账号」

用户发消息（文字 / 图片）
  → api.aiMessage(text, { baseOverride, tokenOverride, pathOverride })
  → 请求直接发到外部 app：POST {apiBase}{aiPath}
  → Header: Authorization: Bearer {apiToken}
  → Body: { text, image_base64?, session_id? }
  → 外部 app 处理意图、写自己的数据库，返回 { reply, session_id? }
  → 小程序显示 reply

外部 app 返回 401
  → 不清除 paper 登录态
  → 提示「Token 已失效，请联系管理员更新」（后台更新 api_token 字段）
```

**后台配置入口**：Filament「系统 → 行业模版」→ 编辑对应行业，填写「外部后端 base」/ 「外部服务账号 Token」/「AI 聊天接口路径」。

`utils/request.js` 的 `callBackend()` 支持 `baseOverride` / `tokenOverride` 参数；`utils/api.js` 的 `aiMessage()` 额外支持 `pathOverride` 参数。

**菜单模版体系（行业 → 多套模版 → 按钮）**：在「行业 → 按钮」之间有一层 `menu_templates`。
- 一个行业可建多套模版，`is_active=true` 的为当前生效
- 后台「菜单模版」资源：**「设为当前」**（同行业互斥）、**「复制模版」**（克隆模版+全部按钮）
- 切换生效模版是纯服务端行为，小程序 `GET /quick-actions?industry=slug` 返回内容随之变，**小程序零改动**
- **生鲜（`fresh`）是唯一有真实后端链路的行业**；其余行业是 prompt 菜单外壳，点按钮→发文字给 AI

**按钮点击路由**（`onQuickAction` 按 `type` 字段分流）：
- `items` → 弹子菜单；`home` → reLaunch 落地页；`route` → navigateTo 原生页；`open` → navigateTo web-view
- `web` → 发 prompt + 追加链接；`prompt`（兜底）→ 文字塞输入框 → `onSend()`
- 确定的填表/上传/列表动作 → 专用 REST；自然语言/碎片输入 → 统一 `/ai/message`

**web-view 报表页**：`pages/report/report` 是通用容器，URL 形如 `paper.xingke888.com{path}?token=<JWT>&from=miniapp`。⚠️ **业务域名白名单需在微信公众平台填 `paper.xingke888.com`**，且需企业认证。

**前端配合 web-view**：
- `lib/auth-context.tsx`：URL 带 `?token=` 时自动登录，`history.replaceState` 抹掉 token
- 页面在 `from=miniapp` 时**未登录不跳 `/login`**（那会落到 Laravel 404），改为 `backToChat()`
- ⚠️ **Tailwind v4 的 `@layer` 在微信 web-view 老内核不被应用 → 整页无样式**。已在 `frontend/postcss.config.mjs` 加 `@csstools/postcss-cascade-layers` 把 `@layer` 拍平。改 postcss 后必须 `npm run build` + 重启 `:3117`。

---

## 部署架构（生产）

nginx 反向代理（`/etc/nginx/sites-enabled/` 下每域名一份）：

| 域名 | 代理到 | 内容 |
|------|--------|------|
| `company.xingke888.com` | `:8303` + `:3117` | 本项目主域名：`/api`,`/admin`,`/livewire` 等 → `:8303`；其余 catch-all → `:3117` |
| `paper.xingke888.com` | `:8303` + `:3117` | 与 `company.*` 同规则，专供小程序 web-view（前后端同源） |
| `s.xingke888.com` | `:8303` | 全部路径 → 本项目后端（旧域名） |

SSL 证书由 Let's Encrypt 签发（`/etc/letsencrypt/live/`）。

**⚠️ nginx 配置修改后需以 root 执行 `nginx -t && nginx -s reload`**，非 root 执行 `nginx -t` 会因证书权限报错（误报）。

**⚠️ Filament 静态资源缓存：** 各域名的 `/css/filament/`、`/js/filament/`、`/fonts/filament/` 指向 `:8303`。升级 Filament 后如样式异常，先确认该 location 规则仍有效。

---

## Laravel 12 Conventions

- No `app/Http/Kernel.php` — middleware registered in `bootstrap/app.php`
- Use `casts()` method (not `$casts` property) on models
- Use Form Request classes for validation (not inline in controllers)
- Never call `env()` outside config files — always use `config('key')`
- `store_id = 1` is hardcoded in MVP controllers until the role/permission system is integrated

## Key Config Files

- `backend/.env` — DB, AI keys, APP_URL, SANCTUM_STATEFUL_DOMAINS, `JWT_SECRET`
- `backend/config/ai.php` — AI service config (reads from .env)
- `backend/config/jwt.php` — JWT secret + algo (HS256)
- `frontend/.env.local` — `NEXT_PUBLIC_API_URL`
- `frontend/package.json` — port configured in `dev`/`start` scripts

---

## Key API Endpoints

### 认证
| Method | Endpoint | Notes |
|--------|----------|-------|
| POST | `/api/login` | `{login, password}` → `{token, jwt_token, store_id, user}` |
| GET | `/api/me` | 当前用户（含 `store_id`, `roles`） |

### 库存
| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/api/inventory` | 当前库存列表 |
| GET | `/api/inventory/daily-overview` | 每日运营概览（含 `sales_breakdown`） |
| POST | `/api/inventory/adjust` | 手动调整（`sold_out` / `adjust` / `damage` 三种模式） |
| GET | `/api/purchase-orders` | 进货单列表（`?date=&status=`） |
| POST | `/api/purchase-orders` | 创建并确认收货（items 用商品名，自动匹配/创建商品） |

### 销售
| Method | Endpoint | Notes |
|--------|----------|-------|
| POST | `/api/sales` | 新建销售单（自动扣减库存） |
| GET | `/api/sales/today` | 今日汇总（含 `sales_breakdown`） |
| POST | `/api/sales/supplement` | 补录（`sold_out` / `remaining` / `qty` 三种模式） |

### 损耗
| Method | Endpoint | Notes |
|--------|----------|-------|
| POST | `/api/damage` | 录入损耗（扣库存 + DamageRecord + 自动关联供应商） |
| GET | `/api/damage/stats` | 按商品/供应商汇总（`?from=&to=`） |

### AI 助手
| Method | Endpoint | Notes |
|--------|----------|-------|
| POST | `/api/ai/message` | `{text, image_base64?, session_id?}` → `{reply, intent, operations[], card_type?, card_data?}` |
| POST | `/api/ai/voice` | multipart `audio` → 同 message 流程 |

### 行业 / 小程序
| Method | Endpoint | Notes |
|--------|----------|-------|
| GET | `/api/industries` | 公开接口，返回 `{slug, name, title, api_base, api_token}` |
| GET | `/api/quick-actions` | `?industry=slug` 返回当前生效模版按钮 + 通用按钮 |

**库存流水 transaction_type 枚举：** 1=采购入库 2=销售出库 3=损耗报废 4=盘点调整 5=促销出库 6=调拨入库 7=调拨出库 8=退货入库

**DamageRecord 关键字段：** `purchase_order_item_id`（自动关联最近进货单，用于追溯供应商）、`status`（1=待处理 2=已提交 3=已退款）
