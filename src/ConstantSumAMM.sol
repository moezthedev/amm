// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ConstantSumAMM {
    address public token0;
    address public token1;
    uint256 public reserve0;
    uint256 public reserve1;
    uint256 public constant FEE_RATE = 5; 

    event Swap(address indexed user, address indexed tokenIn, uint256 amountIn, address indexed tokenOut, uint256 amountOut);
    event AddLiquidity(address indexed provider, uint256 amount0, uint256 amount1);
    event RemoveLiquidity(address indexed provider, uint256 amount0, uint256 amount1);

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function addLiquidity(uint256 amount0, uint256 amount1) external {
        ERC20(token0).transferFrom(msg.sender, address(this), amount0);
        ERC20(token1).transferFrom(msg.sender, address(this), amount1);
        reserve0 += amount0;
        reserve1 += amount1;
        emit AddLiquidity(msg.sender, amount0, amount1);
    }

    function removeLiquidity(uint256 amount0, uint256 amount1) external {
        require(reserve0 >= amount0 && reserve1 >= amount1, "Insufficient liquidity");
        reserve0 -= amount0;
        reserve1 -= amount1;
        require(ERC20(token0).transfer(msg.sender, amount0), "Transfer failed");
        require(ERC20(token1).transfer(msg.sender, amount1), "Transfer failed");
        emit RemoveLiquidity(msg.sender, amount0, amount1);
    }

    function swap(address tokenIn, uint256 amountIn) external {
        require(amountIn > 0, "Amount must be greater than 0");
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");

        bool isToken0In = tokenIn == token0;
        address inputToken = isToken0In ? token0 : token1;
        address outputToken = isToken0In ? token1 : token0;
       
        uint256 reserveOut = isToken0In ? reserve1 : reserve0;

       
        uint256 fee = (amountIn * FEE_RATE) / 100;
        uint256 amountInAfterFee = amountIn - fee;

        require(ERC20(inputToken).transferFrom(msg.sender, address(this), amountIn), "Transfer failed");
        uint256 amountOut = amountInAfterFee;  

        require(reserveOut >= amountOut, "Insufficient liquidity");
        require(ERC20(outputToken).transfer(msg.sender, amountOut), "Transfer failed");

        if (isToken0In) {
            reserve0 += amountIn;
            reserve1 -= amountOut;
        } else {
            reserve0 -= amountOut;
            reserve1 += amountIn;
        }

        emit Swap(msg.sender, tokenIn, amountIn, outputToken, amountOut);
    }
     function approve(address _spender, uint256 _value) external returns (bool success) {
        require(_spender != address(0), "Invalid spender address");
        require(_value == 0 || ERC20(token0).allowance(msg.sender, _spender) == 0, "Allowance already set");

        ERC20(token0).approve(_spender, _value);
        ERC20(token1).approve(_spender, _value);

        return true;
    }

    function transferToken0(address recipient, uint256 amount) external {
        require(reserve0 >= amount, "Insufficient reserve for token0");
        reserve0 -= amount;
        require(ERC20(token0).transfer(recipient, amount), "Transfer failed");
        
    }

    function transferToken1(address recipient, uint256 amount) external {
        require(reserve1 >= amount, "Insufficient reserve for token1");
        reserve1 -= amount;
        require(ERC20(token1).transfer(recipient, amount), "Transfer failed");
        
    }
}

interface ERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
     function approve(address spender, uint256 amount) external returns (bool);
      function allowance(address owner, address spender) external view returns (uint256);
}
