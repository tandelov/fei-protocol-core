pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./BondingCurve.sol";
import "../pcv/IPCVDeposit.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";


/// @title a square root growth bonding curve for purchasing FEI with ETH
/// @author Fei Protocol
contract EthBondingCurve is BondingCurve {
    // solhint-disable-next-line var-name-mixedcase
    uint256 internal immutable SHIFT; // k shift
    using SafeERC20 for IERC20;

    constructor(
        uint256 scale,
        address core,
        address[] memory pcvDeposits,
        uint256[] memory ratios,
        address oracle,
        uint256 duration,
        uint256 incentive,
        address _deployer,
        address _token,
        uint256 _coeff
    )
        public
        BondingCurve(
            scale,
            core,
            pcvDeposits,
            ratios,
            oracle,
            duration,
            incentive,
            _deployer,
            _token,
            _coeff
        )
    {
        SHIFT = scale / 3; // Enforces a .50c starting price per bonding curve formula
        curvetoken = IERC20(_token);
    }

    /// @notice purchase FEI for underlying tokens
    /// @param to address to receive FEI
    /// @param amountIn amount of underlying tokens input
    /// @return amountOut amount of FEI received
    function purchase(address to, uint256 amountIn)
        external
        payable
        override
        postGenesis
        whenNotPaused
        returns (uint256 amountOut)
    {
        require(
            msg.value == amountIn,
            "Bonding Curve: Sent value does not equal input"
        );
        return _purchase(amountIn, to);
    }

    function getTotalPCVHeld() public view override returns (uint256) {
        return address(this).balance;
    }

    // Represents the integral solved for upper bound of P(x) = ((k+X)/(k+S))^1/2 * O. Subtracting starting point C
    function _getBondingCurveAmountOut(uint256 adjustedAmountIn)
        internal
        view
        override
        returns (uint256 amountOut)
    {
        uint256 shiftTotal = _shift(totalPurchased); // k + C
        uint256 shiftTotalCubed = shiftTotal.mul(shiftTotal.mul(shiftTotal));
        uint256 radicand =
            (adjustedAmountIn.mul(3).mul(_shift(scale).sqrt()) / 2).add(
                shiftTotalCubed.sqrt()
            );
        return (radicand.cubeRoot() ** 2).sub(shiftTotal); // result - (k + C)
    }

    // Bonding curve formula is sqrt(k+x)/sqrt(k+S)
    function _getBondingCurvePriceMultiplier()
        internal
        view
        override
        returns (Decimal.D256 memory)
    {
        return
            Decimal.ratio(_shift(totalPurchased).sqrt(), _shift(scale).sqrt());
    }

    function _allocateSingle(uint256 amount, address pcvDeposit)
        internal
        override
    {
        IPCVDeposit(pcvDeposit).deposit{value: amount}(amount);
    }

    function _shift(uint256 x) internal view returns (uint256) {
        return SHIFT.add(x);
    }
}
