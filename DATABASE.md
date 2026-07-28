# 舌尖香港 · 数据库结构说明

> 生成日期：2026-03-31

---

## 数据库结构总览

### 1. 组织架构

| 表 | 说明 |
|---|---|
| `organizations` | 租户/总公司，含全局配置（JSON settings） |
| `regions` | 大区，支持父子层级，关联大区经理 |
| `stores` | 门店，含地理坐标、营业时间、状态 |

---

### 2. 权限与用户

| 表 | 说明 |
|---|---|
| `users` | 基础用户，含 `is_admin` 字段控制 Filament 访问 |
| `roles` | 角色（总部/大区/门店三个 scope），如 STORE_MANAGER |
| `permissions` | 权限点，格式如 `inventory.product.create` |
| `role_permissions` | 角色-权限多对多 |
| `user_store_roles` | 用户在具体门店/大区的角色绑定，支持过期时间 |

---

### 3. 商品管理

| 表 | 说明 |
|---|---|
| `product_categories` | 商品分类，支持父子层级 |
| `products` | 商品档案，含条码、规格、储存条件、保质期、是否生鲜 |
| `store_products` | 门店-商品关联，含售价、库存上下限、货架位置 |

---

### 4. 供应商采购

| 表 | 说明 |
|---|---|
| `suppliers` | 供应商，含账期、评级、结算方式 |
| `supplier_products` | 供应商-商品报价，含首选标记、价格有效期 |
| `supplier_price_history` | 供货价格变更历史 |
| `purchase_orders` | 采购单（AI建议/手动/紧急补货），含审批流 |
| `purchase_order_items` | 采购单明细，**supplier_id 在明细层**（支持同一单多供应商） |
| `supplier_settlements` | 供应商对账结算 |
| `supplier_settlement_orders` | 结算单-采购单多对多关联 |

---

### 5. 库存管理

| 表 | 说明 |
|---|---|
| `inventory` | 实时库存（当前量、可用量、锁定量、均摊成本） |
| `inventory_transactions` | 库存流水，8种类型（入库/出库/损耗/盘点/促销/调拨/退货） |
| `inventory_count_sheets` | 盘点单，含状态流转和审批 |
| `inventory_count_items` | 盘点单明细，含差异原因 |

**inventory_transactions.transaction_type 枚举：**

| 值 | 类型 |
|---|---|
| 1 | 采购入库 |
| 2 | 销售出库 |
| 3 | 损耗报废 |
| 4 | 盘点调整 |
| 5 | 促销出库 |
| 6 | 调拨入库 |
| 7 | 调拨出库 |
| 8 | 退货 |

---

### 6. AI 助手

| 表 | 说明 |
|---|---|
| `ai_sessions` | 对话会话，支持多渠道（App/微信/Web） |
| `ai_messages` | 消息记录，含意图识别结果、实体抽取、分发模块 |
| `ai_command_templates` | 意图模板配置，定义触发词和参数 |

**ai_sessions.channel 枚举：**

| 值 | 渠道 |
|---|---|
| 1 | App 语音 |
| 2 | App 文字 |
| 3 | 企业微信 |
| 4 | Web |

---

### 7. AI 预测与订货

| 表 | 说明 |
|---|---|
| `sales_daily_summary` | 每日销售汇总，含天气、节假日标记 |
| `ai_forecast_models` | 预测模型（SARIMA/LSTM/XGBoost），含精度指标（MAPE/RMSE） |
| `ai_forecast_results` | 预测结果，含80%置信区间上下限 |
| `ai_order_reviews` | 订货复盘报告，含滞销/缺货商品清单 |

---

### 8. 财务管理

| 表 | 说明 |
|---|---|
| `expense_categories` | 支出科目树，标记是否销售成本（is_cogs） |
| `expenses` | 支出记录，支持 AI 录入、收据图片附件 |
| `financial_monthly_summary` | 月度财务汇总（营收/毛利/净利/库存周转率） |

**expenses.payment_method 枚举：**

| 值 | 支付方式 |
|---|---|
| 1 | 现金 |
| 2 | 转账 |
| 3 | 微信支付 |
| 4 | 支付宝 |
| 5 | 企业银行 |

---

### 9. 促销管理

| 表 | 说明 |
|---|---|
| `promotion_rules` | 促销规则（库存阈值/临期/滞销/节假日触发） |
| `promotions` | 促销活动，AI 自动或人工创建，含审批流 |
| `promotion_items` | 活动商品，含 AI 建议价和成本底价 |
| `promotion_reviews` | 活动效果复盘（GMV/毛利率/清货率/防损金额） |

---

### 10. 竞品情报

| 表 | 说明 |
|---|---|
| `competitors` | 竞争对手档案，含距离最近门店 |
| `competitor_products` | 竞品与自有商品匹配，含置信度 |
| `competitor_price_records` | 竞品价格采集记录（人工/扫码/爬虫/三方API） |
| `competitor_hot_products` | 竞品热销商品，含引入建议 |
| `intelligence_reports` | AI 生成竞品分析报告（周报/月报/专项分析） |

---

### 11. 人力资源

| 表 | 说明 |
|---|---|
| `employees` | 员工档案，含合同、薪资、技能标签 |
| `employee_store_history` | 员工调店记录 |
| `schedules` | 排班计划（早/中/晚/全天） |
| `attendance_records` | 考勤打卡记录，含异常状态 |
| `leave_requests` | 请假申请及审批流 |
| `salary_records` | 工资单，含基本工资、绩效、各项扣除、实发金额 |

**employees.status 枚举：**

| 值 | 状态 |
|---|---|
| 1 | 试用期 |
| 2 | 正式 |
| 3 | 已离职 |
| 4 | 停薪留职 |

---

### 12. 人才简历库

| 表 | 说明 |
|---|---|
| `resumes` | 求职简历，含意向地区、工作类型、薪资期望，支持 AI 解析录入 |

**resumes 关键 JSON 字段：**

| 字段 | 说明 | 示例 |
|---|---|---|
| `districts` | 意向工作地区 | `["筲箕湾", "西湾河"]` |
| `work_types` | 工作类型 | `["全职", "小时工"]` |
| `positions` | 意向岗位 | `["收银员", "理货员"]` |
| `languages` | 语言能力 | `["粤语", "普通话"]` |
| `skills` | 技能标签 | `["生鲜处理", "收银系统"]` |

---

### 13. 报表与看板

| 表 | 说明 |
|---|---|
| `dashboard_configs` | 可配置看板，支持个人/门店/大区/总部四个视角 |
| `reports` | 日/周/月报，含 AI 分析内容和图表配置 |
| `custom_report_templates` | 自定义报表模板，支持 cron 定时生成 |

---

### 14. SaaS 集成

| 表 | 说明 |
|---|---|
| `saas_integrations` | 第三方平台集成（企业微信、钉钉、POS、ERP），Token 加密存储 |
| `wework_users` | 企业微信用户绑定 |

---

## 整体设计特点

| 特点 | 说明 |
|---|---|
| **多租户隔离** | 所有主数据均以 `organization_id` 隔离，cascade delete |
| **层级结构** | 大区、商品分类、支出科目均支持 `parent_id` 自关联 |
| **软删除** | 主数据表均支持软删除，保留历史数据完整性 |
| **审批流** | 采购单、促销、请假等均有 `created_by` / `approved_by` 字段 |
| **AI 可追溯** | 所有 AI 操作均关联到 `ai_sessions` / `ai_messages` 记录 |
| **JSON 灵活字段** | 配置、技能标签、地区偏好、功能开关等用 JSON 列存储 |
| **时序数据** | 流水、会话、预测结果均含时间戳，支持时序分析 |
| **操作审计** | 价格变更、库存流水、考勤等均记录操作人和时间 |

---

## 关键外键关系图

```
organizations
  ├── regions (organization_id)
  │     └── stores (region_id)
  ├── stores (organization_id)
  │     ├── inventory (store_id)
  │     ├── inventory_transactions (store_id)
  │     ├── purchase_orders (store_id)
  │     ├── expenses (store_id)
  │     ├── promotions (store_id)
  │     └── ai_sessions (store_id)
  ├── products (organization_id)
  │     ├── store_products (product_id)
  │     ├── inventory (product_id)
  │     └── supplier_products (product_id)
  ├── suppliers (organization_id)
  │     ├── supplier_products (supplier_id)
  │     └── purchase_order_items (supplier_id)
  ├── roles (organization_id)
  │     ├── role_permissions (role_id)
  │     └── user_store_roles (role_id)
  └── users
        └── user_store_roles (user_id)
```

---

## MVP 当前状态

- `organization_id = 1`、`region_id = 1`、`store_id = 1` 硬编码在 Controllers 中
- 权限系统表结构已建立（roles/permissions/user_store_roles），**尚未接入 API 鉴权**
- Filament 后台通过 `users.is_admin = true` 简单控制访问
