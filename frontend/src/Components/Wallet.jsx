import React from 'react'
import { useState } from 'react';
// Import everything
import { ethers } from "ethers";

// Import just a few select items
import { BrowserProvider, parseUnits } from "ethers";

// Import from a specific export
import { HDNodeWallet } from "ethers/wallet";
const Wallet = async () => {
    let signer = null;
    let provider;
    
    async function requestAccount() {
        console.log('first')
        if(window.ethereum==null){
            console.log("MetaMask not installed; using read-only defaults")
        } else {
            const provider = new ethers.BrowserProvider(window.ethereum);
            console.log(provider);
            const balance = await provider.getBalance("ethers.eth")
            console.log(formatEther(balance));
            signer = await provider.getSigner();
        }
    }
   
  return (
    <div>
        <button className='text-[16px] p-4 rounded-2xl bg-red-600 text-white'
         onClick={requestAccount}>
            Connect Wallet 
        </button>
        <h3>Wallet Address: oddd</h3>
    </div>
  )
}

export default Wallet