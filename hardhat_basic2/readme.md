follow this:
https://rahulsethuram.medium.com/the-new-solidity-dev-stack-buidler-ethers-waffle-typescript-tutorial-f07917de48a


steps to install
1. npm install --save-dev hardhat
2. npx hardhat
3. mkdir contracts test scripts
4. npm install --save-dev ts-node typescript @types/node @types/mocha
5. create a config file
```
{
  "compilerOptions": {
    "target": "es5",
    "module": "commonjs",
    "strict": true,
    "esModuleInterop": true,
    "outDir": "dist"
  },
  "include": ["./scripts", "./test"],
  "files": [
    "./hardhat.config.ts"
  ]
}
```
6. mv hardhat.config.js hardhat.config.ts
7. npm install --save-dev ethers @nomiclabs/hardhat-waffle ethereum-waffle
8. npx hardhat compile -> compile the file , make sure the folder is contracts not contract

best and official guide
https://hardhat.org/guides/typescript.html
