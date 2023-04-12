const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Event management", () => {
    let eventAddress;

    async function deployOneYearLockFixture() {
        const ONE_DAY_IN_SECS = 24 * 60 * 60;
        const ONE_GWEI = 1_000_000_000;
        const type1 = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('type1'))
        const type2 = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('type2'))
        const type3 = ethers.utils.keccak256(ethers.utils.toUtf8Bytes('type3'))


        const lockedAmount = ONE_GWEI;
        const startDate = (await time.latest());
        const endDate = (await time.latest()) + ONE_DAY_IN_SECS;


        // Contracts are deployed using the first signer/account by default
        const [owner, otherAccount] = await ethers.getSigners();

        const EventCreator = await ethers.getContractFactory("EventCreator");
        const eventCreator = await EventCreator.deploy();
        const Event = await ethers.getContractFactory("Event");
        const newEvent = await eventCreator.CreateEvent(
            startDate,
            endDate,
            10,
            [type1, type2],
            [ethers.utils.parseUnits('0.1', 'ether'), ethers.utils.parseUnits('0.5', 'ether')],
            [{ start: 1, end: 5 },{ start: 6, end: 10 }],
            "event1",
            "E1",
            { value: ethers.utils.parseUnits('0.5', 'ether') }
        )

        let recipt = await newEvent.wait()
        eventAddress = recipt.events[0].args.eventAddress;
        console.log(eventAddress)

        const event = Event.attach(eventAddress)


        return { eventCreator, event, startDate, endDate, owner, otherAccount, type1, type2, type3 };
    }
    describe("create new event", function () {
       
        it("should check event details", async () => {
        const { event } = await loadFixture(deployOneYearLockFixture);
        console.log(await event.eventDetials())

        })

        it("should check event price with types ", async () => {

        const { event, type1, type2 } = await loadFixture(deployOneYearLockFixture);
        console.log(await event.tickets(type1))
        console.log(await event.getTicketPriceByType(type1))
        console.log(await event.getTicketPriceByType(type2))
        })

        it("should check event range with types ", async () => {

            const { event, type1, type2 } = await loadFixture(deployOneYearLockFixture);
            console.log(await event.tickets(type1))
            
            })

        it("should buy type1 tickets", async () => {

            
            const { event, type1, type2,otherAccount } = await loadFixture(deployOneYearLockFixture);
            await event.connect(otherAccount).BuyTicket([{_type: type2,ticketNumber:6},{_type: type2,ticketNumber:7}],{value: ethers.utils.parseEther('1')})
            // console.log(await event.calculateTicketsPrice([{_type: type1,ticketNumber:2},{_type: type1,ticketNumber:1},
            //     {_type: type1,ticketNumber:1},
            //     {_type: type2,ticketNumber:6}]));
            // console.log(await event.calculateTicketsPrice([{_type: type2,ticketNumber:6}]));

            // expect(await event.ownerOf(2)).to.equal(otherAccount.address)
            // expect(await event.ownerOf(101)).to.equal(otherAccount.address)
            // await event.connect(otherAccount).BuyTicket([4,5])
            // await event.connect(otherAccount).BuyTicket([6])



            

        })
    


    });
})