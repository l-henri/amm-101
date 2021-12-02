pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRichERC20 is IERC20 
{

  function symbol() external view returns (string memory);
}
