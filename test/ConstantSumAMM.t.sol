// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ConstantSumAMM.sol";

contract ERC20Token is ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint256 _totalSupply) {
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply;
    }

    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(balanceOf[sender] >= amount, "Insufficient balance");
        require(allowance[sender][msg.sender] >= amount, "Allowance exceeded");
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;
        allowance[sender][msg.sender] -= amount;
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
}

contract ConstantSumAMMTest is Test {
    ERC20Token token0;
    ERC20Token token1;
    ConstantSumAMM amm;

    address user = address(0x123);

    function setUp() public {
        token0 = new ERC20Token("Token0", "TK0", 1000000 * 10**18);
        token1 = new ERC20Token("Token1", "TK1", 1000000 * 10**18);

        amm = new ConstantSumAMM(address(token0), address(token1));

        token0.transfer(user, 1000 * 10**18);
        token1.transfer(user, 1000 * 10**18);
    }

    function testAddLiquidity() public {
        vm.startPrank(user);
        token0.approve(address(amm), 1000 * 10**18);
        token1.approve(address(amm), 1000 * 10**18);

        uint256 amount0 = 500 * 10**18;
        uint256 amount1 = 500 * 10**18;

        amm.addLiquidity(amount0, amount1);

        assertEq(amm.reserve0(), amount0);
        assertEq(amm.reserve1(), amount1);
        vm.stopPrank();
    }

    function testRemoveLiquidity() public {
        vm.startPrank(user);
        token0.approve(address(amm), 1000 * 10**18);
        token1.approve(address(amm), 1000 * 10**18);

        uint256 amount0 = 500 * 10**18;
        uint256 amount1 = 500 * 10**18;

        amm.addLiquidity(amount0, amount1);

        amm.removeLiquidity(amount0, amount1);

        assertEq(amm.reserve0(), 0);
        assertEq(amm.reserve1(), 0);
        vm.stopPrank();
    }

    function testSwapWithToken0() public {
        vm.startPrank(user);
        token0.approve(address(amm), 1000 * 10**18);
        token1.approve(address(amm), 1000 * 10**18);

        uint256 initialAmount0 = 500 * 10**18;
        uint256 initialAmount1 = 500 * 10**18;

        amm.addLiquidity(initialAmount0, initialAmount1);

        uint256 amountIn = 100 * 10**18;
        uint256 fee = (amountIn * 5) / 100;
        uint256 amountInAfterFee = amountIn - fee;
        uint256 expectedAmountOut = amountInAfterFee;

        token0.approve(address(amm), amountIn);
        amm.swap(address(token0), amountIn);

        assertEq(amm.reserve0(), initialAmount0 + amountIn);
        assertEq(amm.reserve1(), initialAmount1 - expectedAmountOut);
        vm.stopPrank();
    }

    function testSwapWithToken1() public {
        vm.startPrank(user);
        token0.approve(address(amm), 1000 * 10**18);
        token1.approve(address(amm), 1000 * 10**18);

        uint256 initialAmount0 = 500 * 10**18;
        uint256 initialAmount1 = 500 * 10**18;

        amm.addLiquidity(initialAmount0, initialAmount1);

        uint256 amountIn = 100 * 10**18;
        uint256 fee = (amountIn * 5) / 100;
        uint256 amountInAfterFee = amountIn - fee;
        uint256 expectedAmountOut = amountInAfterFee;

        token1.approve(address(amm), amountIn);
        amm.swap(address(token1), amountIn);

        assertEq(amm.reserve0(), initialAmount0 - expectedAmountOut);
        assertEq(amm.reserve1(), initialAmount1 + amountIn);
        vm.stopPrank();
    }

    function testSwapWithInsufficientLiquidity() public {
        vm.startPrank(user);
        token0.approve(address(amm), 100 * 10**18);
        token1.approve(address(amm), 100 * 10**18);

        uint256 initialAmount0 = 500 * 10**18;
        uint256 initialAmount1 = 500 * 10**18;

        amm.addLiquidity(initialAmount0, initialAmount1);

        uint256 amountIn = 2000 * 10**18;  // Exceed available liquidity

        try amm.swap(address(token0), amountIn) {
            fail();  // It should fail
        } catch Error(string memory reason) {
            assertEq(reason, "Insufficient liquidity");
        }

        vm.stopPrank();
    }
}
