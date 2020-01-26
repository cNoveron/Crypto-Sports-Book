pragma solidity ^0.5.0;

import "./Escrow.sol";
import "./WhitelistAdminRole.sol";

/**
 * @title ConditionalEscrow
 * @dev Base abstract escrow to only allow withdrawal if a condition is met.
 * @dev Intended usage: See Escrow.sol. Same usage guidelines apply here.
 */
contract ConditionalEscrow is Escrow, WhitelistAdminRole {

    uint256 minFee = 10 finney;
    uint256 minBet = 30 finney;
    bool gameEnded;

    Team public winningTeam;

    enum Team{
        SAN_FRANCISCO_49ERS,
        KANSAS_CITY_CHIEFS
    }

    uint8 SAN_FRANCISCO_49ERS_score = 0;
    uint8 KANSAS_CITY_CHIEFS_score = 0;
    mapping(address => Team) public myTeam;

    function reportScoreForSanFrancisco(uint8 score) public onlyWhitelistAdmin {
        SAN_FRANCISCO_49ERS_score += score;
    }

    function reportScoreForKansasCity(uint8 score) public onlyWhitelistAdmin {
        KANSAS_CITY_CHIEFS_score += score;
    }
    
    function setWinningTeam() public onlyWhitelistAdmin {
        SAN_FRANCISCO_49ERS_score > KANSAS_CITY_CHIEFS_score
            ? winningTeam = Team.SAN_FRANCISCO_49ERS
            : winningTeam = Team.KANSAS_CITY_CHIEFS;
        gameEnded = true;
    }

    function myBetWasPlaced() public view returns (bool) {
        return depositsOf(msg.sender) > 0;
    }

    function myTeamWon() public view returns (bool) {
        require(gameEnded,"The game hasn't ended yet!");
        require(myBetWasPlaced(),"You didn't place a bet.");
        return myTeam[msg.sender] == winningTeam;
    }

    function withdraw() public {
        require(myTeamWon(),"Sorry, you didn't win :'(");
        super.withdraw(msg.sender);
    }

    function bet(Team chosenTeam) public payable returns (bool) {
        require(msg.value > minBet,"Please send at least 0.03 ETH.");
        myTeam[msg.sender] = chosenTeam;
        uint256 fee = msg.value.div(20);
        uint256 betAmount = minFee < fee
            ? msg.value.sub(fee)
            : msg.value.sub(minFee);
        deposit(msg.sender,betAmount);
    }
}
