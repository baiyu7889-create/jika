# 非成人产品竞品调研与 MVP 设计转译

更新时间：2026-08-07

## 一句话判断

一期不应照搬任何单一竞品，而应组合五类已验证机制：TikTok 的单任务短视频消费、Netflix/YouTube 的续看与收藏、Runway 的额度和失败返还、Reddit/YouTube 的内容治理、支付平台的异步订单状态机。

## 调研边界

- 仅调研非成人产品和公开官方资料。
- 只吸收交互机制，不复制品牌视觉、文案或内部算法。
- “官方事实”与“对本产品的推导”分开表达。
- 定价、转化率和内部排序权重不从竞品臆测。

## 证据与设计转译

| 产品 | 官方可确认机制 | 对 MVP 1.0 的转译 | 不在一期照搬 |
|---|---|---|---|
| TikTok | For You 是默认个性化信息流；用户可通过“不感兴趣”、关键词和主题偏好影响推荐；推荐会做内容与创作者多样性控制。 | 短视频默认“推荐”；右侧保留互动，更多菜单必须提供不感兴趣、举报、拉黑；记录观看时长、完播、关注、付费和负反馈。 | 兴趣冷启动问卷、复杂实时推荐、完整创作者中心。 |
| Netflix | My List 集中管理收藏内容；Continue Watching 允许用户移除条目；推荐使用观看、完成、评分、内容信息、设备与时间等信号。 | 长视频首页首屏展示继续观看；“我的”统一承载收藏、观看记录、已购；记录可删除，下架内容显示不可用。 | 多画像、多终端电视体验、复杂个性化行排序。 |
| YouTube Premium | 会员权益集中说明；跨设备保存播放位置；会员能力按设备/内容类型明确限制。 | 会员中心必须展示适用范围、排除项、有效期、是否自动续费；支付成功后原位续播；H5/App 共用服务端进度。 | 下载、后台播放、画中画、投屏，均属于文档明确暂缓项。 |
| Runway | AI 工具按 credits 计费；生成错误后额度自动返回；消耗记录可查询；输入违规与系统失败使用不同错误说明。 | 提交前展示预计消耗和耗时；提交后先冻结；任务显示排队、生成、审核、成功、失败、已退回；失败/超时/拒绝自动退回并展示资产流水。 | 高级模型参数、无限计划、多人工作区。 |
| Google Flow | iOS 客户端的后台生成会在成功、失败或部分完成时发送应用内通知；App 关闭时可用系统推送；点击通知查看结果或错误。失败不收取 credits，待处理/错误可重试或删除。 | 生成允许后台执行；成功通知直达结果；失败通知直达原因和重试；H5 使用站内通知，App 可叠加系统推送。 | 竞品的创意工作台、场景搭建和多轮编辑。 |
| Adobe Firefly | 可上传参考图后生成多个变体；历史中可回看结果；“Generate more”使用当前提示词和设置再生成。 | 结果页保留“重新生成”，默认复用原素材/配置，但每次创建新任务 ID、重新计费且保留原结果。 | 多变体编辑、创意套件联动和高级风格控制。 |
| Reddit / YouTube | 举报具体内容优于泛化投诉；帖子、评论和用户可分别举报/限制；评论可进入待审核队列。 | 帖子、评论、媒体、AI结果均有举报入口；举报和拉黑分开；新账号与媒体帖子显示“审核中”；结果通过消息中心反馈。 | 私信、复杂版主工具、社区自治规则系统。 |
| Stripe 状态机 | 支付从创建、确认、附加动作、处理中到成功/失败；异步 webhook 会重试。 | 客户端不得点击即发权益；原型显示“订单创建-支付处理中-查单成功-权益到账”；重复点击复用业务单号，避免重复扣费。 | 具体支付 SDK 和渠道实现由技术方案确定。 |

## 关键发现

### 1. 内容消费要把“发现”与“回访”分开

- 短视频负责发现：首屏只保留播放、试看状态、唯一权益和核心互动。
- 长视频负责深度消费：分类、筛选、详情、线路、清晰度、合集和续看必须可见。
- “我的”负责回访：继续观看、收藏、已购、更新提醒和消息不能散落在多个入口。

### 2. 付费墙必须是内容权益的解释页

- 标准内容只显示会员方案，不出现金币价。
- 精品内容只显示金币价、可用精品券和会员折扣，不同时承诺会员免费观看。
- 支付前固定展示适用范围、排除项、退款规则和自动续费状态。
- 支付后以服务端查单结果发放权益，完成后返回原播放位置。

### 3. AI 任务不是一次按钮点击，而是一条资产状态机

推荐前端状态：配置 -> 授权确认 -> 资产冻结 -> 排队 -> 生成 -> 审核 -> 成功扣除 / 失败退回。

前端必须始终显示：任务 ID、当前状态、预计耗时、资产来源、冻结或退回金额、失败原因、可用操作。

竞品交互结论已收敛为：上传与预检 -> 资产冻结 -> 后台生成 -> 成功/失败通知 -> 通知直达结果/错误 -> 可修改后重试或使用原配置重新生成。重试不覆盖原记录，任务、计费和退回都必须独立可追溯。

### 4. UGC 的“可发布”不等于“立即公开”

- 新账号、含媒体和命中敏感规则的内容先进入审核。
- 发布成功反馈应区分“已提交审核”与“已公开”。
- 举报与拉黑分别可达，不能用一个含糊按钮代替。
- 审核、驳回、限流、下线和申诉都要进入消息中心。

### 5. H5 与 App 应共用业务状态，不共用系统壳

- 共用：内容、权益、订单、资产、AI任务、社区、搜索和埋点。
- App：原生状态栏、安全区、支付 SDK、推送、设备管理。
- H5：浏览器视口、返回栈、外部支付回跳、安装引导。
- 任何权益都不能仅保存在本地缓存中。

## 设计原则

1. 单屏单任务：浏览、详情、购买、提交任务分别成页或成层。
2. 一个内容一个主权益：会员或金币二选一。
3. 所有资产结果可追溯：业务单号、前后余额、时间、状态、原因。
4. 所有异步行为有状态：支付、AI、审核、退款、补单均不可只用 Toast 表达。
5. 风险操作先说明后确认：发布、AI上传、购买、注销都显示规则与结果。

## 会员页补充：Tinder 分层会员（2026-08-08）

- Tinder 官方将 Plus、Gold、Platinum 作为递进层级展示：先说明当前层的核心价值，再说明“包含上一层全部权益”，降低多方案理解成本。
- 对搜同的转译不是复制功能或品牌，而是复用信息层级：顶部选择视频 VIP、AI 创作卡、全站畅享卡并阅读权益；底部再选择月、季、年并进入付款。
- 搜同继续执行自己的业务边界：三卡可并存、AI 卡不解锁视频、金币精品不承诺会员免费看、所有方案默认不自动续费。
- 价格卡必须同时展示周期、总价、相对月卡节省金额和最终 CTA；登录回跳不得丢失已选卡种与周期。

## 官方资料

- [TikTok：For You 与用户反馈](https://support.tiktok.com/en/getting-started/for-you/test-for-you)
- [TikTok：推荐系统与多样性](https://support.tiktok.com/en/using-tiktok/exploring-videos/how-tiktok-recommends-content)
- [Netflix：My List](https://help.netflix.com/en/node/10523)
- [Netflix：推荐系统](https://help.netflix.com/en/node/100639)
- [Netflix：管理 Continue Watching](https://help.netflix.com/en/node/115312)
- [YouTube Premium：续看与权益](https://support.google.com/youtube/answer/6308116?hl=en)
- [Runway：生成失败与额度返还](https://help.runwayml.com/hc/en-us/articles/32880432736659-Why-am-I-receiving-errors-when-trying-to-generate)
- [Runway：Credits 规则](https://help.runwayml.com/hc/en-us/articles/15124877443219-How-do-credits-work)
- [Google Flow：生成错误与通知](https://support.google.com/flow/answer/16353335?co=GENIE.Platform%3DiOS&hl=en)
- [Google Flow：开始使用与失败 credits 处理](https://support.google.com/flow/answer/16353333?hl=en&rd=1)
- [Adobe Firefly：参考图、生成历史与 Generate more](https://helpx.adobe.com/firefly/web/work-with-images/generate-images/generate-images-from-text-descriptions.html)
- [Reddit：举报帖子与评论](https://support.reddithelp.com/hc/en-us/articles/360058309512-How-do-I-report-a-post-or-comment)
- [YouTube：评论审核设置](https://support.google.com/youtube/answer/9483359?hl=en)
- [Stripe：PaymentIntent 生命周期](https://docs.stripe.com/payments/paymentintents/lifecycle)
- [Stripe：Webhook 重试与签名](https://docs.stripe.com/webhooks)
- [Apple：App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Google Play：UGC 审核与举报要求](https://support.google.com/googleplay/android-developer/answer/9876937)
- [Google Play：AI 生成内容政策](https://support.google.com/googleplay/android-developer/answer/13985936)
- [Tinder：Subscription tiers](https://tinder.com/en-GB/feature/subscription-tiers)
- [Tinder Help：Tinder subscriptions](https://www.help.tinder.com/hc/en-us/articles/115004487406-Tinder-subscriptions)
