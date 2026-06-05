#!/usr/bin/env bash
# Usage: ./scripts/compile-scenario.sh <ScenarioDir> <CircuitName>
# Example: ./scripts/compile-scenario.sh Whitelist Whitelist
set -euo pipefail

DIR="${1:?Scenario directory required}"
NAME="${2:?Circuit name required}"

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/$DIR"

echo "Compiling ${NAME}.circom in ${DIR}/..."

circom "${NAME}.circom" --r1cs --wasm --sym -o .

PTAU=12
mkdir -p ptau
if [ ! -f "./ptau/powersOfTau28_hez_final_${PTAU}.ptau" ]; then
    echo "Downloading powersOfTau28_hez_final_${PTAU}.ptau ..."
    wget -q -P ./ptau "https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_${PTAU}.ptau"
fi

if [ ! -f "input.json" ]; then
    echo "Missing input.json in ${DIR}/ — copy from input.example.json and fill witness."
    exit 1
fi

cp input.json "${NAME}_js/input.json"
cd "${NAME}_js"
node generate_witness.js "${NAME}.wasm" input.json witness.wtns
cp witness.wtns ../witness.wtns
cd ..

# Local dev ceremony (NOT for production — use public PTAU + phase-2 contributions).
snarkjs powersoftau new bn128 14 "pot14_0000.ptau" -v
snarkjs powersoftau contribute "pot14_0000.ptau" "pot14_0001.ptau" --name="local" -v -e="local dev"
snarkjs powersoftau prepare phase2 "pot14_0001.ptau" "pot14_final.ptau" -v

snarkjs groth16 setup "${NAME}.r1cs" "./ptau/powersOfTau28_hez_final_${PTAU}.ptau" "${NAME}_0000.zkey"
snarkjs zkey contribute "${NAME}_0000.zkey" "${NAME}_0001.zkey" --name="local" -v -e="local dev"
snarkjs zkey export verificationkey "${NAME}_0001.zkey" verification_key.json

snarkjs groth16 prove "${NAME}_0001.zkey" witness.wtns proof.json public.json
snarkjs groth16 verify verification_key.json public.json proof.json

mkdir -p contracts
snarkjs zkey export solidityverifier "${NAME}_0001.zkey" "./contracts/verifier.sol"

echo "Done. Verifier: ${DIR}/contracts/verifier.sol"
echo "Copy to repo root: cp contracts/verifier.sol ../../contracts/${NAME}Verifier.sol"
