// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// interface IWETH {
//     function deposit() external payable;
//     function withdraw(uint256 wad) external;
//     function transfer(address to, uint256 value) external returns (bool);
// }

interface IWETH is IERC20 {
  receive() external payable;

  function deposit() external payable;

  function withdraw(uint256 wad) external;
}
