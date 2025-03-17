// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.4;

contract CharacterActions {

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

    function startWorkout(uint256 characterId, uint256 planDays) external {
        Character storage c = getCharacter(characterId);
        require(c.stamina > 0, "Low stamina");
    
        uint256 caloriesBurned = planDays * 500; // 示例计算
        c.points += caloriesBurned * 10; // 积分规则
        c.stamina -= planDays * 10;
        c.lastActiveTime = block.timestamp;
    }

    function checkStamina(uint256 characterId) public view returns (bool) {
        Character storage c = getCharacter(characterId);
        if (c.stamina == 0 && block.timestamp > c.lastActiveTime + 5 minutes) {
            return true; // 死亡状态
        }
        return false;
    }

    // 定义 getCharacter 函数，返回 Character 的存储引用
    function getCharacter(uint256 _characterId) internal view returns (Character storage) {
        require(_characterId < 3, "Invalid character ID");
        return characters[msg.sender][_characterId];
    }

}