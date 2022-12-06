// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
import "openzeppelin-contracts/access/Ownable.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";

contract CryptoSave is Ownable {
    uint8 public percentRise = 10;
    uint8 public percentFall = 10;
    uint256 public lastStablePrice;
    uint256 public lastCryptoPrice;
    uint256 cryptoAmount;
    uint256 stableAmount;
    enum ActionType {
        GO_STABLE,
        GO_CRYPTO
    }

    constructor() {
        mintNFT();
    }

    /**
     * @dev This function is called from the external timer and is the entry point
     */
    function poke(ActionType action) external returns (bool success) {
        if (action == ActionType.GO_CRYPTO) {
            return tradeToStable();
        } else {
            return tradeToCrypto();
        }
    }

    /**
     * @dev Trade contract assets to stable coin
     */
    function tradeToStable() private returns (bool success) {}

    /**
     * @dev Trade contract assets to crypto coin
     */
    function tradeToCrypto() private returns (bool success) {}

    /**
     * @dev Setter for the percent in rise that will trigger the trade from stable to crypto
     */
    function setPercentRise(uint8 _percentRise) public onlyOwner {
        percentRise = _percentRise;
    }

    /**
     * @dev Setter for the percent in fall that will trigger the trade from crypto to stable
     */
    function setPercentFall(uint8 _percentFall) public onlyOwner {
        percentFall = _percentFall;
    }

    /**
     * @dev add to the contract's ether amount
     */
    receive() external payable {
        // React to receiving ether
    }

    /**
     * @dev add to the contract's stable coin amount
     */
    function addStableCoin(uint256 _stableAmount) external {
        // React to receiving stable coin
        stableAmount += _stableAmount;
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
        /// transfer stable coin to the owner (TODO: add dai address)
        withdrawToken(address(0), stableAmount);
        /// transfer crypto to the owner (TODO: add eth address)
        withdrawToken(address(0), cryptoAmount);
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
}
