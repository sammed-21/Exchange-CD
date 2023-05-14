// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public cryptoDevTokenAddress;

    constructor(address _CryptoDevtoken) ERC20("CryptoDev LP token", "CDLP") {
        require(
            _CryptoDevtoken != address(0),
            "Token address passed is null address"
        );
        cryptoDevTokenAddress = _CryptoDevtoken;
    }

    //get the current amount of token form the contract
    function getReserve() public view returns (uint256) {
        return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
    }

    function addLiquidity(uint _amount) public payable returns (uint) {
        uint liquidity;
        uint ethBalance = address(this).balance;
        uint cryptoDevTokenReserve = getReserve();
        ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);
        //if reserve is empty than we can dirctly take eth and token reserce
        if (cryptoDevTokenReserve == 0) {
            cryptoDevToken.transferFrom(msg.sender, address(this), _amount);
            //has there is no current reserve in the contract we can mint the LP token the amount of liquidit he addes to the contract
            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            // if the reserce is not empty intake the user supply value of eth and determine ratio for how many crypto dev tokens
            //needed to be supply to prevent   any large price impacts
            uint ethReserve = ethBalance - msg.value;
            uint cryptoDevTokenAmount = (msg.value * cryptoDevTokenReserve) /
                (ethReserve);
            require(
                _amount >= cryptoDevTokenAmount,
                "Amount of token sent is less than minium tokens required"
            );

            cryptoDevToken.transferFrom(
                msg.sender,
                address(this),
                cryptoDevTokenAmount
            );
            liquidity = (totalSupply() * msg.value) / ethReserve;
            _mint(msg.sender, liquidity);
        }
        return liquidity;
    }

    function removeLiquidity(uint _amount) public returns (uint, uint) {
        require(_amount > 0, "amount should be greater than zero");
        uint ethReserve = address(this).balance;
        uint _totalSupply = totalSupply();

        //amount of eth that would sent back is based on ration

        // eth sendt back /current eth reserve = amount lp token user want to withdraw /total amount of lp tokens supply
        uint ethAmount = (ethReserve * _amount) / _totalSupply;

        //it is same with crypto dev tokens
        //amunt of dev tokens would sent back user/current crypto dev token reserve = amount lp tokens that user wants to withdraw/total supply of lp tokens

        uint cryptoDevTokenAmount = (getReserve() * _amount) / _totalSupply;

        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(ethAmount);
        ERC20(cryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);
        return (ethAmount, cryptoDevTokenAmount);
    }

    function getAmountOfTokens(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        uint256 inputAmountWithFee = inputAmount * 99;

        // concept of xy =k
        //we need to make sure (x+ del x) *(y-del y) = x*y
        //del y = (y * del x ) / (x + del x)
        // del y is our case is toknes to be received
        // del y = (y*del x)/(x+del x)
        // del x = inputamount with fee , x = intputReserve , y= outputreserve
        uint256 numerator = inputAmountWithFee * outputReserve;
        uint256 denominator = (inputReserve * 100) / inputAmountWithFee;
        return numerator / denominator;
    }

    //swap eth for crypto dev tokens
    function ethToCryptoDevToken(uint _minTokens) public payable {
        uint256 tokenReserve = getReserve();
        // call the getAmountOfTokens to get the amount of crypto dev tokens
        uint256 tokensBought = getAmountOfTokens(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );
        require(tokensBought >= _minTokens, "insufficient output amount");
        ERC20(cryptoDevTokenAddress).transfer(msg.sender, tokensBought);
    }

    // swaps cryptodev tokens for eth

    function cryptoDevTokenToEth(uint _tokensSold, uint _minEth) public {
        uint256 tokenReserve = getReserve();
        //call getAmountoftoken to get the amount of eth that would be return to user ofter the swap
        uint256 ethBought = getAmountOfTokens(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );
        require(ethBought >= _minEth, "insufficient output amount");
        //transfer the crypto dev tokens from the user address to the contract
        ERC20(cryptoDevTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _tokensSold
        );
        // send the ethBought to user from the contract
        payable(msg.sender).transfer(ethBought);
    }
}
