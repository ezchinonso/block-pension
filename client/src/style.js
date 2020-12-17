import styled from 'styled-components'


export const Container = styled.main`
  background: white;
  height: 100%;
  width: 100%;
  display: flex;
  flex-direction: column;
  align-items: center; 
  justify-content: center; 
`;

export const MetaMaskArea = styled.div`
    align-self: top;
    margin-left: 0px;
    position: fixed;
    top: 10px;
    right: 10px;

    display: flex;
    flex-direction: column;
    align-items: top;
    position: top;
    `;


export const Heading = styled.div`
  align-self: top;
  margin-left: 0px;
  position: fixed;
  top: 0;
  left: 0;

  display: flex;
  flex-direction: column;
  align-items: top;
  position: top;
`;

export const Address = styled.span`
  color: black;
  font-size: 16px;
`;

export const Section = styled.div`
  align-items: center;
`;
