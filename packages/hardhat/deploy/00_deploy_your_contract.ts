import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

const deployYourContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("SafeWallet", {
    from: deployer,
    // Constructor args.
    // Use your frontend address
    args: [],
    log: true,
    // Speed up deployment on local network, no effect on live networks
    autoMine: true,
  });

  // Get the deployed contract.
  // const safeWallet = await hre.ethers.getContract("SafeWallet", deployer);
};

export default deployYourContract;

// Tags are useful if you have multiple deploy files and only want to run one of them
// e.g. yarn deploy --tags YourContract
deployYourContract.tags = ["SafeWallet"];
