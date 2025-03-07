项目概述
本项目是一款基于 BNB 链的 GameFi 健身养成类游戏。玩家通过创建角色、制定健身计划、执行计划并获取积分，最终可以将积分兑换为代币或转账给其他用户。游戏结合 AI 技术，根据玩家的身高体重生成个性化的健身计划，并通过链上数据存储确保透明性和安全性。

核心功能
1. 用户系统
注册/登录：玩家通过邮箱或钱包地址注册和登录。

钱包连接：支持多种区块链钱包（如 MetaMask、Trust Wallet、Coinbase Wallet 等）。

角色创建：

玩家可创建最多 3 个角色。

每个角色需要输入身高、体重，AI 根据 BMI 判断健康状况。

角色信息（身高、体重、积分、体力等）存储在链上。

2. 健身计划
AI 生成计划：

根据玩家的身高体重计算 BMI，生成增肌、减脂或保持体型的健身计划。

每种计划包含每日消耗的脂肪量（示例：减脂计划每天消耗 0.5kg）。

执行计划：

玩家选择计划并执行，执行后消耗体力并获得积分。

积分根据计划类型和执行天数计算。

3. 经济系统
积分获取：

执行健身计划后获得积分。

积分可用于兑换代币或转账给其他用户（需支付 Gas 费用）。

食物系统：

玩家可用积分购买食物补充体力。

食物价格和热量参照现实世界（如苹果：50 积分/100 卡路里）。

体力不足时，玩家需及时补充食物，否则角色会在 5 分钟后死亡。

4. 角色管理
体力与健康：

体力为正值，消耗完且 5 分钟内未补充食物则角色死亡。

角色死亡后，玩家可创建新角色（最多 3 个），死亡角色的积分可继承。

增肥计划：

玩家可选择增肥计划，需用积分购买高热量食物。

5. 链上数据
角色信息：身高、体重、积分、体力、最后活动时间等存储在链上。

积分与代币：

积分可兑换为代币（1:1 比例），代币符合 BEP20 标准。

转账积分需支付 Gas 费用。

技术栈
前端
框架：React + TypeScript

钱包连接：Web3.js 或 Wagmi（支持多钱包）

UI 库：Ant Design 或 TailwindCSS

AI 逻辑：本地计算 BMI + 规则引擎生成计划

智能合约
语言：Solidity

链：BNB Chain（兼容 EVM）

工具：Hardhat（开发、测试、部署）

其他工具
IPFS：存储角色形象等非关键数据

测试网：BNB Testnet（测试代币获取：BNB Testnet Faucet）

功能模块详细设计
1. 用户系统模块
前端
登录/注册页面：支持邮箱或钱包地址登录。

钱包连接组件：集成 Web3Modal 或 Wagmi。

角色创建页面：输入身高、体重，调用 AI 生成健康状态。

合约
UserContract.sol：

solidity
复制
struct Character {
    uint256 id;
    string name;
    uint256 height;
    uint256 weight;
    uint256 stamina;
    uint256 points;
    uint256 lastActiveTime;
    bool isDead;
}

mapping(address => Character[3]) public userCharacters; // 每个地址最多 3 个角色
2. 健身计划模块
前端
计划生成页面：根据 BMI 显示增肌、减脂或保持计划。

计划执行页面：选择计划并执行，显示预计消耗脂肪量和积分奖励。

合约
GameContract.sol：

solidity
复制
function startWorkout(uint256 characterId, uint256 planDays) external {
    Character storage c = getCharacter(characterId);
    require(c.stamina > 0, "Low stamina");
    
    uint256 caloriesBurned = planDays * 500; // 示例计算
    c.points += caloriesBurned * 10; // 积分规则
    c.stamina -= planDays * 10;
    c.lastActiveTime = block.timestamp;
}
3. 经济系统模块
前端
积分兑换页面：显示积分余额，支持兑换代币或转账。

食物购买页面：显示食物列表（价格、热量），支持用积分购买。

合约
FitnessToken.sol（BEP20 代币）：

solidity
复制
contract FitnessToken is BEP20 {
    address public gameContract;
    
    constructor() BEP20("FitCoin", "FIT") {}
    
    function mint(address to, uint256 amount) external {
        require(msg.sender == gameContract, "Unauthorized");
        _mint(to, amount);
    }
}
积分兑换方法：

solidity
复制
function exchangePoints(uint256 amount) external {
    require(points[msg.sender] >= amount, "Insufficient points");
    points[msg.sender] -= amount;
    FitnessToken(fitcoinAddress).mint(msg.sender, amount * 1e18); // 1:1 兑换
}
4. 食物与体力模块
前端
体力显示：实时显示角色体力值。

食物购买：支持用积分购买食物补充体力。

合约
食物数据结构：

solidity
复制
struct Food {
    uint256 id;
    string name;
    uint256 price; // 积分价格
    uint256 calories;
}

Food[] public foods; // 预置数据：苹果（50 积分/100 卡）、汉堡（200 积分/500 卡）等
购买食物方法：

solidity
复制
function buyFood(uint256 characterId, uint256 foodId) external {
    Character storage c = getCharacter(characterId);
    Food memory f = foods[foodId];
    
    require(c.points >= f.price, "Insufficient points");
    
    c.points -= f.price;
    c.stamina += f.calories;
}
开发计划
阶段 1：基础功能
完成钱包连接和用户系统。

实现角色创建和链上数据存储。

阶段 2：核心玩法
开发健身计划生成与执行功能。

实现积分系统和代币兑换。

阶段 3：扩展功能
添加食物与体力系统。

实现角色死亡与继承逻辑。

阶段 4：测试与优化
在 BNB Testnet 上测试所有功能。

优化合约 Gas 费用和前端用户体验。

风险与解决方案
链上存储成本高：

解决方案：仅存储关键数据，非关键数据（如角色形象）存 IPFS。

AI 计算复杂度：

解决方案：简化 AI 逻辑，使用本地规则引擎生成计划。

防作弊机制：

解决方案：关键操作需签名验证，限制高频交易。

交付物
智能合约代码（Hardhat 项目）。

前端 DApp（React 项目）。

测试报告和部署文档。

