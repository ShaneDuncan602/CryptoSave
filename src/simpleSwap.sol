// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.0;

// // import "v3-periphery/interfaces/ISwapRouter.sol";
// // import "v3-periphery/libraries/TransferHelper.sol";

// import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
// import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

// contract SimpleSwap {
//     ISwapRouter public immutable swapRouter;
//     // address swapRouter = 0xE592427A0AEce92De3Edee1F18E0157C05861564
//     // address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
//     // address public constant WETH9 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
//     // address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
//     // address public constant BUSD = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;

//     // Addresses for Goerli testnet
//     address public constant LINK = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
//     address public constant USDC = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;

//     uint24 public constant feeTier = 3000;

//     function getBalance() public view returns (uint256) {
//         return msg.sender.balance;
//     }

//     mapping(address => uint256) public balances;

//     address public constant routerAddress =
//         0xE592427A0AEce92De3Edee1F18E0157C05861564;
//     ISwapRouter public immutable swapRouter = ISwapRouter(routerAddress);

//     // constructor(ISwapRouter _swapRouter) {
//     //     swapRouter = _swapRouter;
//     // }

//     function swap(uint256 amountIn) external returns (uint256 amountOut) {
//         // Transfer the specified amount of USDC to this contract.
//         TransferHelper.safeTransferFrom(
//             USDC,
//             msg.sender,
//             address(this),
//             amountIn
//         );
//         // Approve the router to spend tokenIn.
//         TransferHelper.safeApprove(USDC, address(swapRouter), amountIn);
//         // Create the params that will be used to execute the swap
//         ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
//             .ExactInputSingleParams({
//                 tokenIn: USDC,
//                 tokenOut: LINK,
//                 fee: feeTier,
//                 recipient: msg.sender,
//                 deadline: block.timestamp,
//                 amountIn: amountIn,
//                 amountOutMinimum: 0,
//                 sqrtPriceLimitX96: 0
//             });
//         // The call to `exactInputSingle` executes the swap.
//         amountOut = swapRouter.exactInputSingle(params);
//         return amountOut;
//     }
// }
