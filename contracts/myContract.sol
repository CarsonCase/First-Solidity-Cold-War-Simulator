pragma solidity ^0.5.16;

contract myContract{
    event test(uint message);
    event win(string team);
    event transfer(address to, uint ammount);
    uint constant startingHP = 1 ether;

    uint redHP = startingHP;
    uint blueHP = startingHP;
    
    uint redArmy = 0;
    uint blueArmy = 0;

    //Generals
    mapping(address => uint) red_generals;
    mapping(address => uint) blue_generals;
    address payable[] red_general_accs;
    address payable[] blue_general_accs;

    function reset() private{
        redHP = startingHP;
        blueHP = startingHP;
        redArmy = 0;
        blueArmy = 0;

    }
    function gameEnd(bool red) private{
        uint booty = address(this).balance;
        emit test(booty);
        if(red){
            for(uint i=0; i<red_general_accs.length; i++){
                uint spoils = (red_generals[red_general_accs[0]]/redArmy) * booty;
                red_general_accs[0].transfer(spoils);
                emit transfer(red_general_accs[0],spoils);
            }
            emit win("red");
        }else{
            for(uint i=0; i<blue_general_accs.length; i++){
                uint spoils = (blue_generals[blue_general_accs[0]]/blueArmy) * booty;
                blue_general_accs[0].transfer(spoils);
                emit transfer(blue_general_accs[0],spoils);

            }
            emit win("blue");
        }
        reset();
    }

    function tick()public{
        redHP -= blueArmy;
        blueHP -= redArmy;

        //Check if any winners
        if((redHP>startingHP || redHP == 0) && (blueHP > startingHP || blueHP == 0)){
            emit win("Tie");
            //No winner. Reset. Keep the money
            reset();
        }else if (redHP>startingHP || redHP == 0){
            gameEnd(false);
        }else if (blueHP>startingHP || blueHP == 0){
            gameEnd(true);
        }
    }

    function hireSoldiers(bool red)public payable{
        if(red){
            redArmy+=msg.value;
            red_generals[msg.sender] += msg.value;
            red_general_accs.push(msg.sender);
        }else{
            blueArmy+=msg.value;
            blue_generals[msg.sender] += msg.value;
            blue_general_accs.push(msg.sender);
        }
    }


    function getHp(bool red) view public returns(uint){
        if(red){
            return redHP;
        }else{
            return blueHP;
        }
    }

    function getArmy(bool red) view public returns(uint){
        if(red){
            return redArmy;
        }else{
            return blueArmy;
        }
    }

 }