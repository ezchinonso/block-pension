import React, { useState, useEffect, useCallback } from 'react';
import { useWallet } from 'use-wallet';
import { MetaMaskButton, Checkbox } from 'rimble-ui';
import { ethers } from 'ethers';
import PensionScheme from './contracts/PensionScheme.json';
//import cToken from './contracts/cToken.json';
import * as S from './style';
import GlobalStyle from './GlobalStyle';
import {
  BrowserRouter as Router,
  Switch,
  Route,
  Link
} from 'react-router-dom';
import {
    Box,
    Input,
    Field,
    Button,
    Text,
    Card,
    Flex
  } from "rimble-ui";

const App =()=>{
  const { account, connect, ethereum, balance} = useWallet();

  const [contract, setContract] = useState();
  //const [cEthContract, setcEthContract] = useState();
  const [inputValueId, setInputValueId] = useState('');
  const [inputValueAddr, setInputValueAddr] = useState('');
  const [inputValueAmount, setInputValueAmount] = useState('');
  const [inputValueDate, setInputValueDate] = useState('');
  const [inputValueTime, setInputValueTime] = useState('');
  const [formValidated, setFormValidated] = useState(false);
  

  const handleInputId = useCallback(async (e) => {
    setInputValueId(e.target.value);
    validateInput(e);
  });
  const handleInputAddr = useCallback(async (e) => {
    setInputValueAddr(e.target.value);
    validateInput(e);
  });
  const handleInputAmount = useCallback(async (e) => {
    setInputValueAmount(e.target.value);
    validateInput(e);
  });
  const handleInputDate = useCallback(async (e) => {
    setInputValueDate(e.target.value);
    validateInput(e);
  });

  const handleInputTime = useCallback(async (e) => {
    setInputValueTime(e.target.value);
    validateInput(e);
  });

  const handleFormValidation = useCallback(async (e) => {
    setFormValidated(!formValidated)
    validateInput(e)
  });

  const validateInput = useCallback(async (e) => {
    e.target.parentNode.classList.add("was-validated");
  });

  const handleDeposit = useCallback(async (id, amount) =>{
    try {
      let overrides = {
        // To convert Ether to Wei:
        value: ethers.utils.parseEther(amount.toString())     // ether in this case MUST be a string
    
        // Or you can use Wei directly if you have that:
        // value: someBigNumber
        // value: 1234   // Note that using JavaScript numbers requires they are less than Number.MAX_SAFE_INTEGER
        // value: "1234567890"
        // value: "0x1234"
    
        // Or, promises are also supported:
        // value: provider.getBalance(addr)
    };

      const tx = await contract.deposit(id,overrides);
      await tx.wait();
      contract.on("Deposit", (id, sender, amount1 ,contribution, event) => {
        const amt = ethers.utils.formatEther(amount1.toString())
        const cont = ethers.utils.formatEther(contribution.toString())
        alert(`${sender} contributed ${amt}ETH towards your retirement. Pension ${id} - total contribution is ${cont} ETH `)
        console.log(`${sender} contributed ${amt}ETH towards your retirement. Pension ${id} - total contribution is ${cont} ETH`)
      });
      
    } catch(err) {
      console.log(err);
    } 
  }, [contract]);

  const handleWithdraw = useCallback(async (id) => {
    try {

      const tx = await contract.withdrawPension(id);
      await tx.wait();
      
      //const pfa = await contract.getPFA(id);
      
      //const balance = await cEthContract.balanceOfUnderlying(pfa);
      //alert(`Your remaining balance is ${balance}`)

    } catch(err) {
      console.log(err);
    } 
  }, [contract]);

  const handleRegister = useCallback(async (addr, date, time) => {
    try {
      const t=time.split('-');
      const d=date.split(':')
      console.log(t[0],t[1],t[2], d[0],d[1])
      console.log(Date.now()/1000)
      const datum = new Date(t[0],t[1]-1,t[2],d[0],d[1],0);
      console.log(datum)
      const rTime = datum.getTime()/1000;

      console.log(rTime)
      const tx = await contract.register(addr, rTime);
      await tx.wait();
      contract.on("Register", (id, beneficiary, sponsor, event) => {
        alert(`Successfully registered. ${beneficiary}'s Pension ID is ${id}`)
        console.log(`Successfully registered. ${beneficiary}'s Pension ID is ${id}`)
    });


    } catch(err) {
      console.log(err);
    } 
  }, [contract]);

  const handleChangeWithdrawalType = useCallback(async(id, type) =>{
    try{
      if(type === false){
        const tx = await contract.changeWithdrawalType(id) 
        await tx.wait()
        alert('Withdrawal type changed to LumpSumWithdrawal')
      }
    }catch(err){
      console.log(err)
    }
  },[contract])

  useEffect(() => {
    const loadEthereum = async () => {
      try {
        const web3Provider = new ethers.providers.Web3Provider(ethereum);
        const signer = web3Provider.getSigner(account);
        const pensionContract = new ethers.Contract(
          '0x219F1BB95037F16141D33e16d567b88aE669F59d',
          PensionScheme.abi,
          signer
          );      
        
        //const cEth = new ethers.Contract(
        // '0xBe839b6D93E3eA47eFFcCA1F27841C917a8794f3',
        //  cToken.abi,
        //  signer    
        //  );

        
        setContract(pensionContract);
        //setcEthContract(cEth)
      } catch (err) {
        console.log(err);
      }
    };
    if (ethereum) {
      loadEthereum();
    }
  }, [account, ethereum]);

    return(
      <>
      
      <S.Container>
      <Router>
        <S.Heading>
          <ul>
            <Link to="/" >return </Link>
            <Link to="/register">register </Link>
         </ul>
         <S.MetaMaskArea>
         {!account ? (
            <MetaMaskButton.Outline onClick={() => connect('injected')} size='small'>
              Connect with Metamask
            </MetaMaskButton.Outline>
          ) : (<S.Address>Connected: {account.slice(0, 5)}...{account.slice(-3)} | Balance: {`${ethers.utils.formatEther(balance).slice(0, 5)} ETH`}</S.Address>)}
          
         </S.MetaMaskArea>
        </S.Heading>
        <Switch>
        <Route path="/register">
          <Card bg={'background'}>
              <Flex mx={-3} flexWrap={"wrap"}>
                  <Box width={[1, 1, 1/2]} px={3}>
                      <Field label="Beneficiary Address" width={1}>
                          <Input
                          type="text"
                          required // set required attribute to use brower's HTML5 input validation
                          onChange={handleInputAddr}
                          value={inputValueAddr}
                          width={1}
                          />
                      </Field>
                  </Box>
                  <Box width={[1, 1, 1/2]} px={3}>
                      <Field label="Time of Retirement" width={1}>
                          <Input
                          type="date"
                          required // set required attribute to use brower's HTML5 input validation
                          onChange={handleInputDate}
                          value={inputValueDate}
                          width={1}
                          />
                           <Input
                          type="time"
                          required // set required attribute to use brower's HTML5 input validation
                          onChange={handleInputTime}
                          value={inputValueTime}
                          width={1}
                          />
                      </Field>
                  </Box>
                  <Button onClick={()=>handleRegister(inputValueAddr, inputValueTime, inputValueDate )}>register</Button>
              </Flex>
          </Card>
        </Route>
        <Route path="/">
          <Box marginBottom={4}> 
            <Text fontFamily="sansSerif" italic> "Chase your passion and your pension" </Text>
          </Box>
          
          
          <Field label="Enter Beneficiary ID"  marginleft={40}>
              <Input
              type="text"
              placeholder="Beneficiary ID"
              required // set required attribute to use brower's HTML5 input validation
              onChange={handleInputId}
              value={inputValueId}
              width={1}
              />
          </Field>
          <Flex>
          <Card bg={'background'} marginRight={1}>
          
                  <Box width={[1, 1, 1/2]} px={3} >
                      <Field label="Enter Amount" width={1}>
                          <Input
                          type="number"
                          placeholder="Amount"
                          required // set required attribute to use brower's HTML5 input validation
                          onChange={handleInputAmount}
                          value={inputValueAmount}
                          />
                      </Field>
                      <S.Section>          
                        <Button marginRight={5} marginLeft={5} borderRadius={22} onClick={() => handleDeposit(inputValueId, inputValueAmount)}>Deposit</Button>           
                      </S.Section>
                  </Box>
      
          </Card>
          <Card bg={'background'} marginLeft={1}>
        
                  
                      <Checkbox label="Change withdraw Type" 
                        value={formValidated}
                        onChange={handleFormValidation}
                        onClick={() => handleChangeWithdrawalType(inputValueId, formValidated)}
                      />
                      <Box width={[1, 1, 1/2]} px={3}>
                      <S.Section>          
                        <Button marginRight={5} marginLeft={5} marginTop={5}  borderRadius={22} onClick={() => handleWithdraw(inputValueId)}>Withdraw</Button>             
                      </S.Section>
                  </Box>
          </Card>
          </Flex>
        </Route>
        </Switch>
        <S.Section>

        </S.Section>
        </Router>
      </S.Container>
      <GlobalStyle />
      </>
    )
}

export default App