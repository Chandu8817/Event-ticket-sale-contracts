// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Event is ERC721Enumerable {
    mapping(bytes32 => uint256) public ticketPrice;

    uint256 public ticketSolded;

    struct EventDetials {
        uint256 startDate;
        uint256 endDate;
        uint256 NumberOfTickets;
        bytes32[] ticketTypes;
    }

    struct TicketRange {
        uint start;
        uint end;
    }
    struct BuyTicketArgs{
        bytes32 _type;
        uint56 ticketNumber;
    }
    mapping(bytes32 => TicketRange) public tickets;

    EventDetials public eventDetials;

    constructor(
        uint256 startDate,
        uint256 endDate,
        uint256 _numberOfTickets,
        bytes32[] memory _ticketTypes,
        uint256[] memory _ticketPrice,
        TicketRange[] memory _ticketRange,
        string memory name,
        string memory symbol
    ) ERC721(name, symbol) {
        _createEvent(
            startDate,
            endDate,
            _numberOfTickets,
            _ticketTypes,
            _ticketPrice,
            _ticketRange
        );
    }

    function _createEvent(
        uint256 startDate,
        uint256 endDate,
        uint256 _numberOfTickets,
        bytes32[] memory _ticketTypes,
        uint256[] memory _ticketPrice,
        TicketRange[] memory _ticketRange
    ) internal {
        eventDetials.startDate = startDate;
        eventDetials.endDate = endDate;
        eventDetials.NumberOfTickets = _numberOfTickets;
        eventDetials.ticketTypes = _ticketTypes;
        require(
            (_ticketPrice.length == _ticketTypes.length) &&
                (_ticketRange.length == _ticketTypes.length),
            "ticket type,tickets and price length missmatch"
        );
        require(startDate < endDate, "SD lt ED");
        require(
            _ticketRange[0].start == 1,
            "Start number of ticket should be 1"
        );
        require(
            _ticketRange[_ticketRange.length - 1].end == _numberOfTickets,
            "end number of ticket should be number of tickets"
        );

        uint256 rangeTotal;
        for (uint256 index = 0; index < _ticketRange.length; ) {
            rangeTotal += (_ticketRange[index].end -
                (_ticketRange[index].start - 1));
            require(
                _ticketRange[index].start < _ticketRange[index].end,
                "len missmatch1"
            );
            if (index < _ticketRange.length - 1) {
                require(
                    _ticketRange[index].end < _ticketRange[index + 1].start,
                    "length missmatch"
                );
            }
            unchecked {
                index++;
            }
        }
        require(
            _numberOfTickets == rangeTotal,
            "range out of total number of tickets"
        );

        for (uint256 i = 0; i < _ticketTypes.length; i++) {
            ticketPrice[_ticketTypes[i]] = _ticketPrice[i];
            tickets[_ticketTypes[i]] = _ticketRange[i]; //[pavliaon]=10,
        }
    }

    function BuyTicket(BuyTicketArgs[] calldata _tickets) public payable {
        _buyTickets(_tickets);
    }

    function _buyTickets(BuyTicketArgs[] calldata _tickets) internal {
        uint256 remaingTickets = eventDetials.NumberOfTickets - ticketSolded;
        require(
            _tickets.length <= remaingTickets,
            "Invaild number of ticket1"
        );

        require(msg.value==calculateTicketsPrice(_tickets),"insufficent funds for tickets");

        for (uint256 i = 0; i < _tickets.length; ) {
            
             require(
            _tickets[i].ticketNumber <= eventDetials.NumberOfTickets,
            "Invaild number of ticket2"
        );
            _mint(msg.sender, _tickets[i].ticketNumber);
            unchecked {
                i++;
                ticketSolded++;
            }
        }
        
    }

    function getTicketPriceByType(bytes32 _type) public view returns (uint256) {
      
        return ticketPrice[_type];
    }

    function checkTicketInRange(
        uint256 _ticketNumber,
        bytes32 _type
    ) public view returns (bool) {
        if (
            _ticketNumber >= tickets[_type].start &&
            _ticketNumber <= tickets[_type].end
        ) {
            return true;
        }
        return false;
    }

    function calculateTicketsPrice(
        BuyTicketArgs[] calldata _tickets
    ) public view returns (uint256) {
        uint256 _price;
        // require(
        //     _ticketNumbers.length == _ticketTypes.length,
        //     "calculateTickets length mismatch"
        // );
        for (uint256 index = 0; index < _tickets.length; ) {
            if (
                checkTicketInRange(_tickets[index].ticketNumber, _tickets[index]._type)
            ) {
 
                _price = _price + getTicketPriceByType(_tickets[index]._type);
            }else{
                revert("ticket number not found in type " );
            }

            unchecked {
                index++;
            }
        }
        return _price;
    }
}
