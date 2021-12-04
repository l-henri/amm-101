pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./ERC20TD.sol";
import "./IExerciceSolution.sol";
import "./IRichERC20.sol";
import "./utils/IUniswapV2Factory.sol";
import "./utils/IUniswapV2Pair.sol";

contract Evaluator 
{

	mapping(address => bool) public teachers;
	ERC20TD public TDAMM;

	ERC20 public dummyToken;
	IUniswapV2Factory public uniswapV2Factory;
	address public WETH;

	uint256[20] private randomSupplies;
	string[20] private randomTickers;
 	uint public nextValueStoreRank;

 	mapping(address => string) public assignedTicker;
 	mapping(address => uint256) public assignedSupply;
 	mapping(address => mapping(uint256 => bool)) public exerciceProgression;
 	mapping(address => IRichERC20) public studentErc20;
 	mapping(address => IExerciceSolution) public studentExercice;
 	mapping(address => bool) public hasBeenPaired;

 	event newRandomTickerAndSupply(string ticker, uint256 supply);
 	event constructedCorrectly(address erc20Address, address dummyTokenAddress, address uniFactoryAddress, address wethAddress);
	constructor(ERC20TD _TDAMM, ERC20 _dummyToken, IUniswapV2Factory _uniswapV2Factory, address _WETH) 
	public 
	{
		TDAMM = _TDAMM;
		dummyToken = _dummyToken;
		uniswapV2Factory = _uniswapV2Factory;
		WETH = _WETH;
		emit constructedCorrectly(address(TDAMM), address(_dummyToken), address(_uniswapV2Factory), _WETH);

	}

	fallback () external payable 
	{}

	receive () external payable 
	{}

	function ex1_showIHaveTokens()
	public
	{
		require(dummyToken.balanceOf(msg.sender) > 0, "You do not hold dummyTokens. Buy them on Uniswap");

		if (!exerciceProgression[msg.sender][1])
		{
			exerciceProgression[msg.sender][1] = true;
			TDAMM.distributeTokens(msg.sender, 2);
		}

	}

	function ex2_showIProvidedLiquidity()
	public
	{
		// Getting address from factory for pair dummyToken / WETH
		(address token0, address token1) = address(dummyToken) < WETH ? (address(dummyToken), WETH) : (WETH, address(dummyToken));
		address dummyTokenAndWethPair = uniswapV2Factory.getPair(token0, token1);

		// Checking if caller holds LP token
		ERC20 dummyTokenAndWethPairAsERC20 = ERC20(dummyTokenAndWethPair);
		require(dummyTokenAndWethPairAsERC20.balanceOf(msg.sender) > 0, "You do not hold liquidity in the required pool");
		if (!exerciceProgression[msg.sender][2])
		{
			exerciceProgression[msg.sender][2] = true;
			TDAMM.distributeTokens(msg.sender, 2);
		}
	}

	function ex6a_getTickerAndSupply()
	public
	{
		assignedSupply[msg.sender] = randomSupplies[nextValueStoreRank]*1000000000000000000;
		// assignedTicker[msg.sender] = bytes32ToString(randomTickers[nextValueStoreRank]);
		assignedTicker[msg.sender] = randomTickers[nextValueStoreRank];

		nextValueStoreRank += 1;
		if (nextValueStoreRank >= 20)
		{
			nextValueStoreRank = 0;
		}

		// Crediting points
		if (!exerciceProgression[msg.sender][5])
		{
			exerciceProgression[msg.sender][5] = true;
			TDAMM.distributeTokens(msg.sender, 2);
		}
	}

	function ex6b_testErc20TickerAndSupply()
	public
	{
		// Checking ticker and supply were received
		require(exerciceProgression[msg.sender][5]);

		// Checking ticker was set properly
		require(_compareStrings(assignedTicker[msg.sender], studentErc20[msg.sender].symbol()), "Incorrect ticker");
		// Checking supply was set properly
		require(assignedSupply[msg.sender] == studentErc20[msg.sender].totalSupply(), "Incorrect supply");
		// Checking some ERC20 functions were created
		require(studentErc20[msg.sender].allowance(address(this), msg.sender) == 0, "Allowance not implemented or incorrectly set");
		require(studentErc20[msg.sender].balanceOf(address(this)) == 0, "BalanceOf not implemented or incorrectly set");
		require(studentErc20[msg.sender].approve(msg.sender, 10), "Approve not implemented");

		// Crediting points
		if (!exerciceProgression[msg.sender][6])
		{
			exerciceProgression[msg.sender][6] = true;
			// Creating ERC20
			TDAMM.distributeTokens(msg.sender, 2);
		}

	}

	function ex7_tokenIsTradableOnUniswap()
	public
	{
		// Retrieving address of pair from library
		(address token0, address token1) = address(studentErc20[msg.sender]) < WETH ? (address(studentErc20[msg.sender]), WETH) : (WETH, address(studentErc20[msg.sender]));
		address studentTokenAndWethPair = uniswapV2Factory.getPair(token0, token1);

		require(studentTokenAndWethPair != address(0));

		// Crediting points
		if (!exerciceProgression[msg.sender][7])
		{
			exerciceProgression[msg.sender][7] = true;
			// Creating ERC20
			TDAMM.distributeTokens(msg.sender, 5);
		}

	}

	function ex8_contractCanSwapVsEth()
	public
	{
		// Retrieving address of pair from library
		(address token0, address token1) = address(studentErc20[msg.sender]) < WETH ? (address(studentErc20[msg.sender]), WETH) : (WETH, address(studentErc20[msg.sender]));
		address studentTokenAndWethPair = uniswapV2Factory.getPair(token0, token1);

		// Checking pair balance before calling exercice contract
		IUniswapV2Pair studentTokenAndWethPairInstance = IUniswapV2Pair(studentTokenAndWethPair);
		(uint112 reserve0, uint112 reserve1, ) = studentTokenAndWethPairInstance.getReserves();

		// Checking caller balance before executing contract
		uint initBalance = studentErc20[msg.sender].balanceOf(address(studentExercice[msg.sender]));

		// Calling student contract to tell him to provide liquidity
		studentExercice[msg.sender].swapYourTokenForEth();

		// Checking pair balance after calling exercice contract
		(uint112 reserve3, uint112 reserve4,) = studentTokenAndWethPairInstance.getReserves();
		require((reserve0 != reserve3) && (reserve1 != reserve4), "No liquidity change in your token's pool");

		// Checking your token balance after calling the exercice
		uint endBalance = studentErc20[msg.sender].balanceOf(address(studentExercice[msg.sender]));
		require(initBalance != endBalance, "You still have the same amount of tokens");

		// Crediting points
		if (!exerciceProgression[msg.sender][8])
		{
			exerciceProgression[msg.sender][8] = true;
			// Creating ERC20
			TDAMM.distributeTokens(msg.sender, 1);
		}

	}

	function ex9_contractCanSwapVsDummyToken()
	public
	{
		// Retrieving address of pair from library
		(address token0, address token1) = address(studentErc20[msg.sender]) < address(dummyToken) ? (address(studentErc20[msg.sender]), address(dummyToken)) : (address(dummyToken), address(studentErc20[msg.sender]));
		address studentTokenAndWethPair = uniswapV2Factory.getPair(token0, token1);

		// Checking pair balance before calling exercice contract
		IUniswapV2Pair studentTokenAndWethPairInstance = IUniswapV2Pair(studentTokenAndWethPair);
		(uint112 reserve0, uint112 reserve1, ) = studentTokenAndWethPairInstance.getReserves();
		
		// Checking caller balance before executing contract
		uint initTokenBalance = studentErc20[msg.sender].balanceOf(address(studentExercice[msg.sender]));
		uint initDummyBalance = dummyToken.balanceOf(address(studentExercice[msg.sender]));

		// Calling student contract to tell him to provide liquidity
		studentExercice[msg.sender].swapYourTokenForDummyToken();

		// Checking pair balance after calling exercice contract
		(uint112 reserve3, uint112 reserve4,) = studentTokenAndWethPairInstance.getReserves();
		require((reserve0 < reserve3) && (reserve1 < reserve4), "No liquidity change in your token's pool");

		// Checking your token balance after calling the exercice
		uint endTokenBalance = studentErc20[msg.sender].balanceOf(address(studentExercice[msg.sender]));
		require(initTokenBalance != endTokenBalance, "You still have the same amount of your tokens");
		uint endDummyBalance = dummyToken.balanceOf(address(studentExercice[msg.sender]));
		require(initDummyBalance != endDummyBalance, "You still have the same amount of dummy tokens");

		// Crediting points
		if (!exerciceProgression[msg.sender][9])
		{
			exerciceProgression[msg.sender][9] = true;
			// Creating ERC20
			TDAMM.distributeTokens(msg.sender, 2);
		}

	}
	function ex10_contractCanProvideLiquidity()
	public
	{
		// Retrieving address of pair from library
		(address token0, address token1) = address(studentErc20[msg.sender]) < WETH ? (address(studentErc20[msg.sender]), WETH) : (WETH, address(studentErc20[msg.sender]));
		address studentTokenAndWethPair = uniswapV2Factory.getPair(token0, token1);

		// Checking pair balance before calling exercice contract
		IUniswapV2Pair studentTokenAndWethPairInstance = IUniswapV2Pair(studentTokenAndWethPair);
		(uint112 reserve0, uint112 reserve1, ) = studentTokenAndWethPairInstance.getReserves();

		// Calling student contract to tell him to provide liquidity
		studentExercice[msg.sender].addLiquidity();

		// Checking pair balance after calling exercice contract
		(uint112 reserve3, uint112 reserve4,) = studentTokenAndWethPairInstance.getReserves();

		require((reserve0 < reserve3) && (reserve1 < reserve4), "No liquidity change in your token's pool");

		// Crediting points
		if (!exerciceProgression[msg.sender][10])
		{
			exerciceProgression[msg.sender][10] = true;
			// Creating ERC20
			TDAMM.distributeTokens(msg.sender, 2);
		}

	}

	function ex11_contractCanWithdrawLiquidity()
	public
	{
		// Retrieving address of pair from library
		(address token0, address token1) = address(studentErc20[msg.sender]) < WETH ? (address(studentErc20[msg.sender]), WETH) : (WETH, address(studentErc20[msg.sender]));
		address studentTokenAndWethPair = uniswapV2Factory.getPair(token0, token1);

		// Checking pair balance before calling exercice contract
		IUniswapV2Pair studentTokenAndWethPairInstance = IUniswapV2Pair(studentTokenAndWethPair);
		(uint112 reserve0, uint112 reserve1, ) = studentTokenAndWethPairInstance.getReserves();

		// Calling student contract to tell him to provide liquidity
		studentExercice[msg.sender].withdrawLiquidity();

		// Checking pair balance after calling exercice contract
		(uint112 reserve3, uint112 reserve4,) = studentTokenAndWethPairInstance.getReserves();

		require((reserve0 > reserve3) && (reserve1 > reserve4), "No liquidity change in your token's pool");

		// Crediting points
		if (!exerciceProgression[msg.sender][11])
		{
			exerciceProgression[msg.sender][11] = true;
			// Creating ERC20
			TDAMM.distributeTokens(msg.sender, 2);
		}

	}


	modifier onlyTeachers() 
	{

	    require(TDAMM.teachers(msg.sender));
	    _;
	}

	function submitExercice(IExerciceSolution studentExercice_)
	public
	{
		// Checking this contract was not used by another group before
		require(!hasBeenPaired[address(studentExercice_)]);

		// Assigning passed ERC20 as student ERC20
		studentExercice[msg.sender] = studentExercice_;
		hasBeenPaired[address(studentExercice_)] = true;
			
	}

	function submitErc20(IRichERC20 studentErc20_)
	public
	{
		// Checking this contract was not used by another group before
		require(!hasBeenPaired[address(studentErc20_)]);
		// Assigning passed ERC20 as student ERC20
		studentErc20[msg.sender] = studentErc20_;
		hasBeenPaired[address(studentErc20_)] = true;
			
	}

	function _compareStrings(string memory a, string memory b) 
	internal 
	pure 
	returns (bool) 
	{
    	return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
	}

	function bytes32ToString(bytes32 _bytes32) 
	public 
	pure returns (string memory) 
	{
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

	function readTicker(address studentAddres)
	public
	view
	returns(string memory)
	{
		return assignedTicker[studentAddres];
	}

	function readSupply(address studentAddres)
	public
	view
	returns(uint256)
	{
		return assignedSupply[studentAddres];
	}

	function setRandomTickersAndSupply(uint256[20] memory _randomSupplies, string[20] memory _randomTickers) 
	public 
	onlyTeachers
	{
		randomSupplies = _randomSupplies;
		randomTickers = _randomTickers;
		nextValueStoreRank = 0;
		for (uint i = 0; i < 20; i++)
		{
			emit newRandomTickerAndSupply(randomTickers[i], randomSupplies[i]);
		}
	}




}
