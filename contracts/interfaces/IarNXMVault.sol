// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

interface IarNXMVault {
    function arNxmValue(uint256 amount) external view returns(uint256);
    //for v2
    function nxmValue(uint256 amount) external view returns(uint256);

    // for depositing wnxm in v2
    function deposit(uint256 amount, address referrer, bool isNXM) external;

    // for withdrawing wnxm in v2
    function withdraw(uint256 amount, bool isNXM) external;
}
