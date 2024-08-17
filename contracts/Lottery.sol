//Lottery.sol
//https://github.com/chitraliwadikar/Lottery-System-Smart-Contract/blob/main/Lottery.sol
//https://github.com/ishankjena/smart-contract-lottery/blob/master/src/Raffle.sol
//https://github.com/urdestiny2/lotterycontract/blob/main/smartcontract-lottery/contracts/Lottery.sol

// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract MyContract is Initializable, PausableUpgradeable, OwnableUpgradeable {
    bool public lotteryEnded; //是否已经结束
    uint256 private ticketPrice = 0.1 ether;
    uint256 private fee = 5;
    uint256 private endTime;
    uint256 private winnerRate = 20; //获奖人占中人数的比例
    uint256 private winnerBoundRate = 80; //获奖人分享总奖金的比例
    uint256 private lotteryTicketSalesDays = 7 days;//彩票售卖时长
    address[] public players; //购买人列表
    mapping(address => bool) public hasBoughtTicket; //每一期,每个人只能购买一张
    mapping(address => uint256) public boughtTimestamp; //购买时间

    event TicketPurchased(address indexed player);
    event LotteryEnded(address[] winners, uint256 prize);
    event NewLotteryStarted(uint256 ticketPrice, uint256 duration, uint256 fee);
    event sendBonusToWinner(
        address indexed player,
        uint256 indexed ticketPrice
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address initialOwner,
        uint256 _fee
    ) public initializer {
        __Pausable_init();
        __Ownable_init(initialOwner);
        fee = _fee;
        endTime = block.timestamp + lotteryTicketSalesDays;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    modifier onlyHuman() {
        require(isEOA(msg.sender), "Contracts are not allowed");
        _;
    }

    modifier lotteryActive() {
        require(block.timestamp < endTime, "Lottery has ended");
        _;
    }

    modifier lotteryEndedOnly() {
        require(block.timestamp >= endTime, "Lottery is still active");
        _;
    }

    // 检查一个地址是否为外部拥有账户（EOA）
    function isEOA(address account) public view returns (bool) {
        uint256 size;
        assembly {
            // 获取给定地址的合约代码大小
            size := extcodesize(account)
        }
        // 如果代码大小为0，则为EOA
        return size == 0;
    }

    //购买彩票
    function buyTicket() external payable onlyHuman lotteryActive {
        require(msg.value == ticketPrice, "Incorrect ticket price");
        require(!hasBoughtTicket[msg.sender], "Ticket already purchased");

        players.push(msg.sender);
        hasBoughtTicket[msg.sender] = true;
        boughtTimestamp[msg.sender] = block.timestamp;

        emit TicketPurchased(msg.sender);
    }

    //计算中奖人列表(按照二八定律,20%的人分享80%的总金额)
    function drawWinners() public onlyOwner lotteryEndedOnly {
        require(!lotteryEnded, "Lottery already ended");

        uint256 ownerFee = (address(this).balance * fee) / 100;
        uint256 totalPrize = ((address(this).balance - ownerFee) * 80) / 100;

        //payable(owner).transfer(ownerFee);

        uint256 numberOfWinners = (players.length * 20) / 100;
        address[] memory winners = _pickWinners(numberOfWinners);

        numberOfWinners = winners.length;
        for (uint256 i = 0; i < numberOfWinners; i++) {
            payable(winners[i]).transfer(totalPrize / numberOfWinners);
            emit sendBonusToWinner(winners[i], totalPrize / numberOfWinners);
        }

        lotteryEnded = true;
        emit LotteryEnded(winners, totalPrize);
    }

    //计算获奖者名单
    function _pickWinners(uint256 numWinners)
        internal
        view
        onlyOwner
        lotteryEndedOnly
        returns (address[] memory)
    {
        require(numWinners <= players.length, "Not enough participants");

        address[] memory winners = new address[](numWinners);
        uint256[] memory indices = new uint256[](numWinners);
        uint256 selectedIndices = 0;

        uint256 numOfPlayers = players.length;
        for (uint256 i = 0; i < numOfPlayers; i++) {
            if (selectedIndices >= numWinners) {
                break;
            }

            uint256 randomIndex = random(i) % players.length;
            bool alreadyPicked = false;

            // Ensure the same index is not picked again
            for (uint256 j = 0; j < selectedIndices; j++) {
                if (indices[j] == randomIndex) {
                    alreadyPicked = true;
                    break;
                }
            }

            if (!alreadyPicked) {
                indices[selectedIndices] = randomIndex;
                winners[selectedIndices] = players[randomIndex];
                selectedIndices++;
            }
        }
        return winners;
    }

    function random(uint256 _nonce) private view returns (uint256) {
        return
            uint256(
                keccak256(abi.encodePacked(block.timestamp, _nonce, players))
            );
    }

    function startNewLottery(
        uint256 _ticketPrice,
        uint256 _durationDays,
        uint256 _fee
    ) public onlyOwner lotteryEndedOnly{
        require(lotteryEnded, "Previous lottery has not ended");

        // 重置状态变量以开始新一期彩票
        ticketPrice = _ticketPrice;
        endTime = block.timestamp + _durationDays * 86400;
        fee = _fee;

        for (uint256 i = 0; i < players.length; i++) {
            address tmpPlayer = players[i];
            hasBoughtTicket[tmpPlayer] = false;
            boughtTimestamp[tmpPlayer] = 0;
        }
        delete players;

        lotteryEnded = false;
        emit NewLotteryStarted(_ticketPrice, _durationDays, _fee);
    }

    //设置管理费率
    function setManagementFeeRate(uint256 _rate)
        public
        onlyOwner
        lotteryEndedOnly
    {
        fee = _rate;
    }

    //设置奖金分配策略(例如1:9 or 2:8)
    function setBonusDistributionDtrategy(
        uint256 _winnerRate,
        uint256 _winnerBoundRate
    ) public onlyOwner lotteryActive {
        winnerRate = _winnerRate;
        winnerBoundRate = _winnerBoundRate;
    }

    //设置最小彩票价格
    function setMinPrice(uint256 _rate) public onlyOwner lotteryEndedOnly {
        ticketPrice = _rate;
    }

    //用户查询自己拥有token总数

    //用户查询彩票的开奖日期

    //提款
}
