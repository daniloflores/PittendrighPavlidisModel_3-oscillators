PittendrighPavlidisModel_3-oscillators
This repository contains an implemention of the Pittendrigh-Pavlidis model of 3 coupled oscillators.

## Introduction
The Pittendrigh-Pavlidis equations have been originally used to model two limit-cycle oscillators, in a master-slave configuration, to study biological rhythms in the fruit-fly Drosophila (Pittendrigh, 1981; Pittendrigh et al., 1991).
They were later adpated to model two oscillators with mutual coupling, to understand the evening-morning oscillators in rodents (Oda et al., 2000; Flôres and Oda, 2020). This implementation was made in Java, within the CircadianDynamix extension of the Neurodynamix II software (Friensen and Friense, 2010).
The present code adapts the Java implementation into the programming language R and adds a third oscillator, to simulate the interaction between evening-morning oscillators and the Food-Entrainable Oscillator (FEO) in rodents.

## Model equations
Equações do oscilador evening (e)
dRe/dt = Re – ceSe – beSe2 + (de – Le) + K (1)
dSe/dt = Re – aeSe + CmeSm + CFEOeSFEO (2)
Equações do oscilador morning (m)
dRm/dt = Rm – cmSm – bmSm2 + (dm – Lm) + K (3)
dSm/dt = Rm – amSm + CemSe + CFEOmSFEO (4)
Equações do Food-entrainable oscillator (FEO)
dRFEO/dt = RFEO – cFEOSFEO – bFEOSFEO2 + (dFEO – Food) + K (5)
dSFEO/dt = RFEO – aFEOSFEO + CeFEOSe + CmFEOSm (6)

Test
h<sub>&theta;</sub>(x) = &theta;<sub>o</sub> x + &theta;<sub>1</sub>x

## References
Friesen WO, and Friesen JA (2010) Neurodynamix II: Concepts of neurophysiology illustrated by computer simulations, Oxford University Press, New York"
