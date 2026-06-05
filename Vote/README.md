# Vote — ZK 匿名投票

合格选民集合用与 Whitelist 相同的 Merkle 叶子；链上只记录 **nullifier** 防双投，**voteCommitment** 用于链下计票而不暴露身份。

## 电路

| 信号 | 可见性 | 含义 |
|------|--------|------|
| `root`, `pollId` | public | 选举 ID + 选民 Merkle 根 |
| `nullifier` | public | `Poseidon(secret, pollId)`，链上唯一 |
| `voteCommitment` | public | `Poseidon(vote, secret, pollId)` |
| `secret`, `vote`, path | private | 身份、选票 `0/1`、Merkle 路径 |

约束：`vote ∈ {0,1}`，Merkle 成员，nullifier / commitment 与私密输入一致。

## 本地测试

```bash
yarn test ./test/Vote.js
```

## 链上

1. `createPoll(pollId, root)`
2. 选民提交 `castVote(proof, pubSignals)`，`pubSignals = [root, pollId, nullifier, voteCommitment]`
3. 合约检查 `nullifierUsed`，防止同一选民对同一 poll 投两次

## 生产注意

- 本地 `script.sh` 的 PTAU 仅用于学习；主网使用公开 ceremony 的 `.ptau` / `.zkey`。
- 计票需链下聚合 `voteCommitment` 或扩展电路（本例为最小可部署模型）。
