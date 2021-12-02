pragma solidity ^0.6.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IExerciceSolution 
{
	function addLiquidity() external;

	function withdrawLiquidity() external;
}
