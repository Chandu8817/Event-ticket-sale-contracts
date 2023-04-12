// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./Event.sol";

contract EventCreator {
    uint eventcreatationFee = 0.5 ether;
    address[] eventList;
    

    event NewEvent(
        address eventAddress,
        uint256 numberOfTickets,
        bytes32[] ticketTypes,
        uint256[] ticketPrices,
        Event.TicketRange[]  ticketRange,
        uint256 starteDate,
        uint256 endeDate
    );

    function CreateEvent(
        uint256 startDate,
        uint256 endDate,
        uint256 _numberOfTickets,
        bytes32[] memory _ticketTypes,
        uint256[] memory _ticketPrices,
        Event.TicketRange[] memory _ticketRange,

        string memory name,
        string memory symbol
    ) public payable returns(address) {
        require(msg.value>= eventcreatationFee,"not enough funds to create event");
        Event newEvent = new Event(startDate,endDate,_numberOfTickets,_ticketTypes,_ticketPrices,_ticketRange,name,symbol
        );

        emit NewEvent(
            address(newEvent),
            _numberOfTickets,
            _ticketTypes,
            _ticketPrices,
            _ticketRange,
            startDate,
            endDate
        );
        return address(newEvent);
    }
}
