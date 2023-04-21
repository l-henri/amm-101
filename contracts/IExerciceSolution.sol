// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

interface IExerciceSolution 
{
	function addLiquidity() external;

	function withdrawLiquidity() external;

	function swapYourTokenForDummyToken() external;

	function swapYourTokenForEth() external;
}
