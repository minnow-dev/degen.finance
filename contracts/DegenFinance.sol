// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./library/Ownable.sol";
import "./library/SafeERC20.sol";
import "./library/SushiLibrary.sol";
import "./library/CloneFactoryCreate2.sol";
contract DegenFinance is Ownable, CloneFactoryCreate2 {
    using SafeERC20 for IERC20;

    address immutable weth;
    address immutable uniFactory;
    address immutable sushiFactory;

    uint256 public constant BASIS_POINT = 100000;
    uint256 public feeRatio;

    receive() external payable {
    }

    constructor(
        address _weth,
        address _uniFactory,
        address _sushiFactory
    ) Ownable(msg.sender) {
        weth = _weth;
        uniFactory = _uniFactory;
        sushiFactory = _sushiFactory;
    }

    function deployWallet(address _beneficiary) public returns(address){
    }

    function getWallet(address _beneficiary) public view returns(address){
    }

    // operational functions
    function setFeeRatio(uint256 _ratio) external onlyOwner{
        require(_ratio <= BASIS_POINT/100, "ratio cannot be bigger than 1%");
        feeRatio = _ratio;
    }

    // fee and token withdrawal
    function withdrawFee() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }

    function rescueToken(address token) external onlyOwner{
        IERC20 erc20 = IERC20(token);
        erc20.safeTransfer(msg.sender, erc20.balanceOf(address(this)));
    }
}
