# Whitelist — ZK Merkle 白名单

证明「我的私密身份在允许列表的 Merkle 根下」，不暴露是哪一个叶子。

## 电路

| 信号 | 可见性 | 含义 |
|------|--------|------|
| `root` | public | 链上登记的允许列表 Merkle 根 |
| `secret` | private | 用户私密身份（域元素） |
| `pathElements`, `pathIndices` | private | Merkle 路径 |
| `out` | output | 恒为 `1` |

叶子：`leaf = Poseidon(secret)`。树深 8（最多 256 个叶子，不足用零填充）。

## 本地测试

```bash
yarn test ./test/Whitelist.js
```

## 生成证明 + Solidity verifier

1. 用 `lib/proofInputs.js` 生成 `input.json`（或参考 `input.example.json`）。
2. `chmod +x script.sh && ./script.sh`
3. 将 `contracts/verifier.sol` 部署为 `IZKVerifier`，再部署 `contracts/ZKWhitelist.sol`。

## 链上调用

`ZKWhitelist.proveAccess(proofA, proofB, proofC, pubSignals)`，其中 `pubSignals = [root]`。

管理员需先 `registerRoot(root)`。
