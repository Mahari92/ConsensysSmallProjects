pragma solidity ^0.4.0;

//consensus - developer program
//jeyakumar.sathish@emirates.com

//A shopfront
//The project will start as a database whereby:

//as an administrator, you can add products, which consist of an id, a price and a stock.
//as a regular user you can buy 1 of the products.
//as the owner you can make payments or withdraw value from the contract.
//Eventually, you will refactor it to include:

//ability to remove products.
//co-purchase by different people.
//add merchants akin to what Amazon has become.
//add the ability to pay with a third-party token.

//three actors #buyer #admin #seller or #owner
//actions #add/delete/reorder #list/buy #withdrawsales


contract Owned {
	address public owner;

	function Owned() {
		owner = msg.sender;	
	}

	modifier fromOwner {
		require(msg.sender == owner) ;
		_;
	}
}

contract Administration is Owned{
    mapping(address=>bool) public administrators;

    function Administration(){

    }

    function addAdministrator(address admin) 
        public 
        fromOwner 
        returns (bool){
        administrators[admin]=true;
        return true;
    }

    function deleteAdministrator(address admin) 
        public 
        fromOwner 
        returns (bool){
        administrators[admin]=false;
        return true;
    }
}


contract ShopFront is Administration {

    struct Product{
        uint id;
        uint price;
        uint token;
        uint tokenValue;
        uint stock;
        bool isAvailable;
        address owner;
        }
     
    mapping(address=>uint) private salesRecords;
    mapping (uint=>Product) productRecords;
    
    function ShopFront(){
    }
    
    function addProduct(uint productID,uint productPrice,uint tokenName,uint tokenValue,uint productQuantity) returns(bool){
        require(productRecords[productID].isAvailable==false);
        productRecords[productID].id = productID;
        productRecords[productID].price = productPrice;
        productRecords[productID].token = tokenName;
        productRecords[productID].tokenValue = tokenValue;
        productRecords[productID].stock = productQuantity;
        productRecords[productID].isAvailable = true;
        productRecords[productID].owner = msg.sender;
        return true;
    }

   function deleteProduct(uint productID) returns(bool){
        Product memory product = productRecords[productID];
        require(product.isAvailable == true);
        require(owner==msg.sender || administrators[msg.sender]==true || product.owner==msg.sender);
        productRecords[productID].isAvailable=false;
        return true;
    }

 function reorderProduct(uint productID,uint stock) returns(bool){
        Product memory product = productRecords[productID];
        product.stock = stock;
        productRecords[productID] = product;
       return true;
    }

  function listProducts(uint productID) constant public returns(uint productsID,uint productPrice,uint tokenName,uint tokenValue,uint productQuantity){
        Product memory product = productRecords[productID];
        require(product.isAvailable);
        return (product.id, product.price, product.token, product.tokenValue, product.stock);
    }
  
   function buyProduct(uint productID, uint productQuantity) payable returns(bool){
        Product memory product = productRecords[productID];
        require(product.isAvailable==true);
        require(msg.value >= product.price);
        require(product.stock != 0 || product.stock >= productQuantity);

        uint productOwnerBalance = product.owner.balance;
        if(productOwnerBalance + (product.price * productQuantity) < productOwnerBalance){
            revert();
        }
        productRecords[productID].stock -= productQuantity;
        salesRecords[product.owner] += (product.price * productQuantity);
        return true;
    }

    function withdrawSales() returns(bool){
        if(salesRecords[msg.sender]==0){
            revert();
        }

        if(msg.sender.balance + salesRecords[msg.sender] < msg.sender.balance){
            revert();
        }
        else{
            uint amountToSend = salesRecords[msg.sender];
            if(amountToSend==0) revert();
            salesRecords[msg.sender]=0;
            if(msg.sender.send(amountToSend)){

                return true;
            }
            else{
                salesRecords[msg.sender]=amountToSend;
                revert();
            }
        }
    }
}
