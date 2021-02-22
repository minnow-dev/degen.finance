// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "./interfaces/IERC20.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/IUniswapV2Pair.sol";
import "./interfaces/IUniswapV2Factory.sol";
import "./library/SafeERC20.sol";
import "./library/SushiLibrary.sol";
import "./library/CloneFactoryCreate2.sol";

contract DegenWallet {
    using SafeERC20 for IERC20;

    address immutable factory;

    IWETH immutable weth;

    IUniswapV2Factory immutable uniFactory;
    IUniswapV2Factory immutable sushiFactory;

    address public beneficiary;

    modifier onlyBeneficiary() {
        require(msg.sender == beneficiary, "!beneficiary");
        _;
    }

    constructor(address _weth, address _uniFactory, address _sushiFactory) {
        factory = msg.sender;
        weth = IWETH(_weth);
        uniFactory = IUniswapV2Factory(_uniFactory);
        sushiFactory = IUniswapV2Factory(_sushiFactory);
    }

    // this will enable eth deposit
    receive() external payable {}

    function initialize(address _beneficiary) external {
        require(beneficiary == address(0) && _beneficiary != address(0), "already initialized");
        beneficiary = _beneficiary;
    }

    function swap(address _in, address _out, uint256 _amountIn, address _to, uint256 _validUntil) public onlyBeneficiary returns(uint256){
        require(block.timestamp <= _validUntil, "expired");
        (,address pair, uint256 amountOut) = _profitablePair(_in, _out, _amountIn);
        IERC20(_in).safeTransfer(pair, _amountIn);
        _swap(pair, _in, _amountIn, amountOut, _to);
        return amountOut;
    }

    function degenWithEth(address[] calldata _tokens, uint256[] calldata _ethAmounts, uint256 _validUntil) external payable onlyBeneficiary {
        require(_tokens.length == _ethAmounts.length, "array length diff");
        _wrapeth();
        for(uint256 i = 0; i<_tokens.length; i++){
            swap(address(weth), _tokens[i], _ethAmounts[i], address(this), _validUntil);
        }
    }

    function liquidate(address[] calldata _tokens, address _out, uint256 _validUntil) external onlyBeneficiary{
        address uniTo = _out == address(weth)? address(this):uniFactory.getPair(address(weth), _out);
        if(uniTo == address(0)) {
            uniTo = address(this);
        }
        address sushiTo = _out == address(weth)? address(this):uniFactory.getPair(address(weth), _out);
        if(sushiTo == address(0)){
            sushiTo = address(this);
        }
        // change all tokens to weth
        for(uint256 i = 0; i<_tokens.length; i++){
            uint256 balance = IERC20(_tokens[i]).balanceOf(address(this));
            (IUniswapV2Factory amm, address pair, uint256 amountOut)=_profitablePair(_tokens[i], address(weth), balance);
        }
        // swap weth -> out. skip if weth == out
        if(uniTo != address(this)){
        }
        if(sushiTo != address(this)){
        }
    }
    
    function _wrapeth() internal {
        weth.deposit{value:address(this).balance}();
    }

    function _unwrapeth() internal {
        weth.withdraw(weth.balanceOf(address(this)));
    }

    function _swap(address _pair, address _in, uint256 _amountIn, uint256 _amountOut, address _to) internal {
        IUniswapV2Pair pair = IUniswapV2Pair(_pair);
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        if (_in == pair.token0()) {
            pair.swap(0, _amountOut, _to, new bytes(0));
        } else {
            pair.swap(_amountOut, 0, _to, new bytes(0));
        }
    }

    function _return(address _pair ,address _in, uint256 _amountIn) internal view returns(uint256 amountOut) {
        IUniswapV2Pair pair = IUniswapV2Pair(_pair);
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        uint256 amountInWithFee = _amountIn * 997;
        if (_in == pair.token0()) {
            amountOut =
                (_amountIn *997 *reserve1) /
                ((reserve0 * 1000) + amountInWithFee);
        } else {
            amountOut =
                (_amountIn * 997 * reserve0) /
                ((reserve1 * 1000) + amountInWithFee);
        }
    }

    function _profitablePair(address _in, address _out, uint256 _amountIn) internal view returns(IUniswapV2Factory swapfactory, address pair, uint256 amountOut) {
        address uniPair = uniFactory.getPair(_in, _out);
        uint256 uniReturn = _return(uniPair, _in, _amountIn);
        address sushiPair = sushiFactory.getPair(_in, _out);
        uint256 sushiReturn = _return(sushiPair, _in, _amountIn);
        require(uniReturn != 0 || sushiReturn != 0, "not supported swap");
        return uniReturn > sushiReturn ? (uniFactory, uniPair, uniReturn) : (sushiFactory, sushiPair, sushiReturn);
    }
}
