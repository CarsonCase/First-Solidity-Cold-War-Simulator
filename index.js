const Web3 = require("web3");
const MyContract = require("./build/contracts/myContract.json");
const express = require("express");
const bodyParser = require("body-parser");
const path = require("path");

const app = express();

app.use(express.static(path.join(__dirname,"public")));

app.use(bodyParser.urlencoded({     // to support URL-encoded bodies
    extended: true
  })); 


web3 = new Web3("http://127.0.0.1:7545");

const init = async()=>{
    const id = await web3.eth.net.getId();
    const deployedNetwork = MyContract.networks[id];
    const contract = new web3.eth.Contract(
        MyContract.abi,
        deployedNetwork.address
    );
    return contract;
}


const hireSoldiers = async(red,address,val)=>{
    const c = await init();
    const receipt = await c.methods.hireSoldiers(red).send({
        from: address,
        gas: 2100000,
        value: web3.utils.toWei(val, "ether")
    }).catch( err => console.log(err));
}

const tick = async(address)=>{
    const c = await init();
    const receipt = await c.methods.tick().send({
        from: address
    })
    .catch(err=>console.log(err));
}

app.get("/",async(req,res)=>{
    let info ={}
    //contract instance
    const c = await init();

    //get red HP
    info.redHP = await c.methods.getHp(true).call();

    //get blue HP
    info.blueHP = await c.methods.getHp(false).call();

    //get red Army
    info.redArmy = await c.methods.getArmy(true).call();

    //get blue Army
    info.blueArmy = await c.methods.getArmy(false).call();
    
    console.log(info);
    res.render("index.ejs",info);
    
});


app.post("/hire",(req,res)=>{
    let red = true;
    if(req.body.team_select == "blue"){
        red = false;
    }
    hireSoldiers(red,req.body.address,req.body.value).then(receipt=>{
        console.log(receipt);
        res.redirect("/");
    });
});

app.post("/tick",(req,res)=>{
    tick(req.body.address);
    console.log("tick complete");
    res.redirect("/"); 
})


app.listen(8080,()=>{
    console.log("Server started on port 8080");
});

