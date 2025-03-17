// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FitnessToken is ERC20 {
    address public gameContract;
    address public fitcoinAddress;
    mapping(address => uint256) public points;

    struct Character {
        uint256 id;
        string name;
        uint256 height;
        uint256 weight;
        uint256 stamina;
        uint256 points;
        uint256 lastActiveTime;
        bool isDead;
    }

    mapping (address => Character[3]) public characters;

    struct Food {
        uint256 id;
        string name;
        uint256 price; // 积分价格
        uint256 calories;
    }

    Food[] public foods;

    constructor(address _gameContract, address _fitcoinAddress) ERC20("FitCoin", "FIT") {
        gameContract = _gameContract;
        fitcoinAddress = _fitcoinAddress;
        // 初始化食品数据
        foods.push(Food(1, "Apple", 50, 100));
        foods.push(Food(2, "Hamburger", 200, 500));
    }

    function mint(address to, uint256 amount) external {
        require(msg.sender == gameContract, "Unauthorized");
        _mint(to, amount);
    }

    function exchangePoints(uint256 amount) external {
        require(points[msg.sender] >= amount, "Insufficient points");
        points[msg.sender] -= amount;
        FitnessToken(fitcoinAddress).mint(msg.sender, amount * 1e18); // 1:1兑换
    }

    function buyFood(uint256 characterId, uint256 foodId) external {
        Character storage c = getCharacter(characterId);
        Food memory f = foods[foodId];

        require(c.points >= f.price, "Insufficient points");

        c.points -= f.price;
        c.stamina += f.calories;
    }

    function getCharacter(uint256 _characterId) internal view returns (Character storage) {
        require(_characterId < 3, "Invalid character ID");
        return characters[msg.sender][_characterId];
    }
}