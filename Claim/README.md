# Claim — ZK 一次性领取（空投）

叶子绑定 **secret + amount**，nullifier 绑定 **secret + distributionId**，防止改金额或重复领取。

## 电路

| 信号 | 可见性 | 含义 |
|------|--------|------|
| `root`, `distributionId`, `nullifier`, `amount` | public | 分配批次、防重放、领取数量 |
| `secret`, path | private | 领取密钥与 Merkle 路径 |

叶子：`leaf = Poseidon(secret, amount)`。

## 本地测试

```bash
yarn test ./test/Claim.js
```

## 链上

1. `createDistribution(distributionId, root, beneficiary, cap)` 并向合约地址转入 ETH（`receive()`）
2. 用户 `claim(proof, pubSignals)`，`pubSignals = [root, distributionId, nullifier, amount]`
3. 合约向 `beneficiary` 转账 `amount` wei（演示用；生产可改为 ERC20）

## 生产注意

- `amount` 在电路里公开；若需隐藏金额需另做 commitment 方案。
- 与 Vote 相同：勿将本地生成的 zkey 用于主网。
