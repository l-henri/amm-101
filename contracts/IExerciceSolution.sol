pragma solidity ^0.6.0;

interface IExerciceSolution 
{
	function addLiquidity() external;

	function withdrawLiquidity() external;

	function swapYourTokenForDummyToken() external;

	function swapYourTokenForEth() external;
}
