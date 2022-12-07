// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "./swap/UniswapV3Condensed.sol";

/**
 * @title Insurance for ETH hodlers
 * @author @ShaneDuncan602
 * @notice This is only the POC in its most basic form
 * @dev Don't judge me...this was a rush job
 */
contract CryptoSave is Ownable {
    uint256 public lastStablePurchasePrice; // last purchase price
    uint256 public lastCryptoPurchasePrice; // last purchase price
    uint256 cryptoAmount;
    uint256 stableAmount;
    uint256 public totalGasUsed;

    UniswapV3SwapExamples uni = new UniswapV3SwapExamples();
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    IWETH private weth = IWETH(WETH);
    IERC20 private dai = IERC20(DAI);

    event Transfer(string fromCurrency, string toCurrency, uint256 amount);

    constructor() {
        mintNFT();
    }

    /**
     * @dev This function is called from the external timer and is the entry point
     */
    function poke(uint8 action, uint256 ethPrice, uint256 daiPrice) external returns (bool success) {
        lastStablePurchasePrice = daiPrice;
        lastCryptoPurchasePrice = ethPrice;
        if (action == 0) {
            return tradeToStable();
        } else {
            return tradeToCrypto();
        }
    }

    /**
     * @dev Trade contract assets to stable coin
     */
    function tradeToStable() private returns (bool success) {
        weth.approve(address(uni), cryptoAmount);
        uint256 holdAmount = cryptoAmount;
        stableAmount = uni.swapExactInputSingleHop(
            WETH,
            DAI,
            3000,
            cryptoAmount
        );
        cryptoAmount = 0;
        emit Transfer("WETH", "DAI", holdAmount);
        totalGasUsed += tx.gasprice;
        return (stableAmount != 0);
    }

    /**
     * @dev Trade contract assets to crypto coin
     */
    function tradeToCrypto() private returns (bool success) {
        dai.approve(address(uni), stableAmount);
        uint256 holdAmount = stableAmount;
        cryptoAmount += uni.swapExactInputSingleHop(
            DAI,
            WETH,
            3000,
            stableAmount
        );
        stableAmount = 0;
        emit Transfer("DAI", "WETH", holdAmount);
        totalGasUsed += tx.gasprice;
        return (cryptoAmount != 0);
    }

    /**
     * @dev Wrap the eth for easy trading
     */
    function convertToWeth() private {
        IWETH(weth).deposit{value: address(this).balance}();
    }

    /**
     * @dev add to the contract's ether amount
     */
    receive() external payable {
        // address payable _address = address(owner());
        // owner().send(msg.value);
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}

    function fundContract() public payable {
        cryptoAmount += address(this).balance;
        convertToWeth();
    }

    /**
     * @dev Mint the progress NFT
     */
    function mintNFT() public onlyOwner {}

    /**
     * @dev Update the progress NFT
     */
    function updateNFT() public onlyOwner {}

    /**
     * @dev transfer all the tokens from the address of this contract
     * to address of the owner
     */
    function cashOut() external onlyOwner {
        /// transfer stable coin to the owner
        withdrawToken(DAI, stableAmount);
        /// transfer crypto to the owner 
        withdrawToken(WETH, cryptoAmount);
        //weth.withdraw(cryptoAmount);
    }

    /**
     * @dev transfer the token from the address of this contract
     * to address of the owner
     */
    function withdrawToken(address _tokenContract, uint256 _amount) private {
        IERC20 tokenContract = IERC20(_tokenContract);

        // needs to execute `approve()` on the token contract to allow itself the transfer
        tokenContract.approve(address(this), _amount);

        tokenContract.transferFrom(address(this), owner(), _amount);
    }

    function getStableAmount() public view returns(uint256){
        return stableAmount;
    }

    function getCryptoAmount() public view returns(uint256){
        return cryptoAmount;
    }
}
