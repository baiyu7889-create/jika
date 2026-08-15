# 基咔 MVP 1.0 用户端—后台契约（rc31）

更新日期：2026-08-14  
边界：本文是接口族与状态约束草案，不是已联调的 OpenAPI。原型中的“模拟回调/审核/推进”不代表客户端拥有生产权限；真实字段、鉴权、错误码和幂等约束需由研发契约冻结。

## 1. 统一对象

| 对象 | 必填字段 | 约束 |
|---|---|---|
| `RouteSnapshot` | `page/sourceTab/filter/query/scrollTop/objectId/playerSnapshot` | 仅客户端导航状态，不作为交易事实源 |
| `ResumeIntent` | `intentId/action/objectId/sourceRoute/requiredEntitlement/status/createdAt/expiresAt/latestPrice` | 充值回跳后必须重新查询价格、权益和对象状态；价格变化二次确认；完成、取消或过期后幂等关闭 |
| `Order` | `bizNo/userId/productSnapshot/status/timeline/grants/refundResult/firstRechargeQualification` | 业务单号唯一；重复创建、回调和查单不得重复发放；首充资格在发放事务内校验并占用 |
| `LedgerEntry` | `entryId/bizNo/assetType/before/delta/after/action/reason/status/serverTime` | 只追加不可覆盖；余额必须由账本聚合并防负数 |
| `MembershipEntitlement` | `family/startAt/endAt/sourceOrders/currentCycleGrant/nextGrantAt/status` | 同卡顺延，不同卡并存取并集；周期额度不提前发完 |
| `Collection` | `id/title/totalCount/updatedCount/entitlement/status` | 下架不删除历史购买和审计记录 |
| `Episode` | `id/collectionId/number/name/duration/entitlement/purchaseState/progress` | 集号唯一；播放进度按用户、内容幂等更新 |
| `AITask` | `taskId/parentTaskId/attempt/status/assetStatus/baseCost/finalCost/frozenAllocation/review/result/resultDeletedAt/timeline` | 任务状态与资产状态分离；用户删除结果不修改任务成功状态；重新生成创建新ID并按当前资格计价；失败/超时/拒绝只能退回一次 |
| `Message` | `id/type/targetType/targetId/readAt/serverTime` | 对象已失效时展示状态变化，不跳转错误对象 |
| `SupportTicket` | `ticketId/bizNo/type/status/timeline` | 客服可查询和流转，不可直接改资产或审批内容 |
| `CommunityPost` | `id/authorId/topic/title/body/media/status/sensitiveRuleVersion/publishedAt/version` | 提交命中敏感词时返回失败且不创建公开对象；已发布对象可因治理下架 |
| `CommunityComment` | `id/postId/parentCommentId/authorId/body/status/sensitiveRuleVersion/publishedAt/version` | `parentCommentId` 为空表示一级评论，非空必须归入对应父楼层；敏感词失败不创建公开对象 |

## 2. 状态机

- 订单：`待支付 → 处理中 → 成功`；异常为 `失败/关闭/拒付`；售后为 `退款中 → 已退款/退款拒绝`。
- AI任务：业务状态为 `排队中 → 生成中 → 审核中 → 成功`，异常终态为 `生成失败/超时/审核拒绝`；资产状态独立为 `冻结中 → 已转实扣/已退回`；用户侧结果可写 `resultDeletedAt`，不得把任务状态改为已删除。
- 帖子：`草稿 → 已发布/发布失败`；已发布后可因治理进入 `已下架`，申诉通过后可恢复 `已发布`。`发布失败` 仅返回敏感词命中或字段错误，不生成审核中对象。
- 评论/回复：`草稿 → 已发布/发布失败`；回复必须携带 `parentCommentId` 并在父楼层返回。已发布对象可因治理进入 `已下架`。
- 注销：`资格校验 → 冷静期 → 再次验证 → 已注销`；冷静期内支持撤销。

## 3. P0 接口族

| 域 | 用户端能力 | 后台/服务端职责 |
|---|---|---|
| 内容/合集 | 分类、标签、详情、逐集、播放地址、进度、线路错误上报 | 发布状态、权益、推荐、线路、下架与版权控制 |
| 搜索 | 视频/合集/帖子/用户/标签聚合与排序 | 热词、索引、审核可见性和分页游标 |
| 订单 | 创建、支付回跳查单、订单详情、退款申请、补单核查 | 幂等单号、回调验签、发放、退款/拒付、冲正；补单仅由受权服务根据支付事实执行 |
| 钱包 | 付费金币、活动币、AI额度、精品券、冻结资产、充值、首充奖励与不可覆盖流水 | 账本、分账余额、首充资格原子占用、AI额度周期发放/到期、冻结/实扣/原路退回、负余额拦截和告警 |
| 会员 | 四张P0商品、资格、购买、续期、当前权益 | 狂欢卡三重限购、同卡顺延、30日周期发放、权益并集与到期任务 |
| AI | 预检、提交、任务、结果、重试、删除用户侧结果 | 编排、审核、资产冻结/结算、通知和审计留存 |
| 社区 | 帖子、评论、楼中楼回复、点赞、举报、下架申诉、我的帖子 | 敏感词同步校验、直接发布、父子评论关系、发布后治理和对象可见性 |
| 消息/客服 | 分类、已读、对象直达、工单创建/查询 | 可靠投递、关联对象、工单权限与时间线 |
| 账号 | 设备、退出、消息开关、协议、注销 | 身份验证、设备会话、冷静期、未结业务拦截 |
| 用户关系 | 公开个人页、粉丝列表、关注列表、关注/取消关注 | 游标分页、关系状态、黑名单过滤、隐私可见性与幂等关注 |
| 广告/公告配置 | 启动广告、长视频首次进入广告队列、平台公告 | 返回投放模块、会话频控、顺序、有效期、落地页和公告开关；短视频不得接收营销弹窗位，客户端按会话幂等展示 |
| 推广配置 | 短视频分享直达推广落地页 | 返回启用状态、受信落地页、活动参数与失效兜底；客户端不得拼接任意非受信域名 |
| App 图标 | 查看预置图标、选择并调用原生切换 | 图标资源必须预置在安装包；服务端仅下发可用 ID/排序，不远程注入图标文件；H5 返回不支持 |

## 4. 幂等与权限

1. 客户端不得直接设置订单成功、发会员/金币/额度/券、审批内容、结束退款或修改流水。
2. `order_create` 使用客户端请求ID与服务端业务单号双重幂等；重复点击返回原业务单号。
3. 支付回调只触发服务端查单；发放表以 `bizNo + grantType` 唯一约束。
4. AI退回以 `taskId + returnVersion` 唯一约束；部分资产需按冻结来源逐项退回。
5. 充值恢复先查询 `ResumeIntent`，再查询对象、权益和当前价格；价格或状态变化必须二次确认。
6. 所有状态响应包含 `version/serverTime`；客户端提交旧版本时返回 `409 STATE_CHANGED` 并刷新对象。
7. 推广落地页使用运营配置白名单并附 `source/contentId/campaignId`；配置缺失或校验失败时不得离开当前视频。
8. App 图标选择是设备级本地偏好，不改变账号权益；原生返回失败、取消或不支持时不得把新图标写为当前状态。
9. 首充额外奖励必须在支付成功发放事务中以 `userId + activityId` 唯一占用；多个待支付订单同时存在时，仅第一个成功且符合资格的订单可获得奖励。
10. 补单申请只创建 `SupportTicket(type=supplement)`；客户端和客服不能把订单改为成功，也不能直接写权益或账本，补单执行仍复用原业务单号及发放唯一约束。

## 5. 统一错误与恢复

| 错误 | 用户端结果 |
|---|---|
| `UNAUTHENTICATED` | 登录后恢复原意图和草稿 |
| `FORBIDDEN` | 独立无权限状态，不隐藏原因 |
| `STATE_CHANGED` | 拉取最新对象，禁止覆盖 |
| `INSUFFICIENT_ASSET` | 创建 ResumeIntent；客户端在原业务页打开快捷充值底部抽屉 |
| `CONTENT_UNAVAILABLE` | 保留购买/观看记录，显示下架或不可用 |
| `PAYMENT_PENDING` | 显示处理中，支持主动查单 |
| `AI_RETURNED` | 展示原因、退回流水和重新生成入口 |
| `RATE_LIMITED` | 保留草稿和上下文，展示重试时间 |
| `SENSITIVE_CONTENT` | 发布失败，不创建公开帖子/评论/回复；返回命中提示与规则版本，客户端保留草稿 |

## 6. 监控与告警

- 支付成功未发权益、重复发放、负余额、冻结超时未释放、周期额度漏发必须实时告警。
- 审核积压、消息投递失败、工单超时、注销冷静期任务失败需进入运营监控。
- 演示活动值必须配置化并标注环境；正式价格、奖励、资格规则经产品/财务/法务冻结后再发布。

## 7. 最小接口草案（待研发冻结）

| 方法 | 路径 | 关键请求/响应 | 幂等/版本要求 |
|---|---|---|---|
| `GET` | `/v1/search` | `q/type/cursor` → 聚合结果与 `nextCursor` | 返回对象 `version/serverTime` |
| `GET` | `/v1/collections/{id}` | 合集、逐集、购买状态和进度 | 下架对象仍返回历史状态 |
| `POST` | `/v1/orders` | `requestId/productId/productVersion` → `bizNo/status` | `requestId` 唯一，重复返回原单 |
| `GET` | `/v1/orders/{bizNo}` | 商品快照、时间线、发放、退款 | 支付回跳只能查单，不由客户端改状态 |
| `POST` | `/v1/orders/{bizNo}/refunds` | 原因、版本 → 退款单 | 同订单进行中退款唯一 |
| `GET` | `/v1/wallet` | 五类余额、冻结额 | 余额由账本聚合 |
| `GET` | `/v1/recharge-products` | 六档金币商品、金额、普通赠送、首充资格与额外奖励、版本 | “我的”独立充值页和业务内快捷抽屉必须使用同一商品快照；最终资格在发放时复核 |
| `GET` | `/v1/ledger` | `assetType/cursor` → 只追加流水 | 不提供覆盖/删除接口 |
| `POST` | `/v1/resume-intents` | 恢复动作、对象和来源路由 | 过期、取消、完成均幂等 |
| `POST` | `/v1/ai/tasks` | `requestId/tool/baseCost/configVersion` | 返回服务端 `finalCost`；重复请求同任务 |
| `GET` | `/v1/ai/tasks/{taskId}` | 业务状态、资产状态、审核与结果 | 返回 `version`；结果删除不删任务 |
| `DELETE` | `/v1/ai/results/{resultId}` | 删除用户侧可见结果 | 保留任务、审核和资产审计 |
| `POST` | `/v1/comments` | 对象、正文、回复对象、草稿版本 | 旧版本返回 `409 STATE_CHANGED` |
| `POST` | `/v1/support/tickets` | 类型、业务单号、描述；补单类型必须有关联订单 | `requestId` 防重复工单；创建工单不改变订单与资产 |
| `POST` | `/v1/devices/{id}/logout` | 二次验证凭证 | 当前设备限制由账号服务返回 |
| `POST` | `/v1/account/cancellation` | 二次验证凭证、资格版本 | 返回阻断项、冷静期和撤销截止时间 |
