// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRichERC20 is IERC20 
{

  function symbol() external view returns (string memory);
}
