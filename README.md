PittendrighPavlidisModel_3-oscillators
This repository contains an implemention of the Pittendrigh-Pavlidis model of 3 coupled oscillators.

## Introduction
The Pittendrigh-Pavlidis equations have been originally used to model two limit-cycle oscillators, in a master-slave configuration, to study biological rhythms in the fruit-fly Drosophila (Pittendrigh, 1981; Pittendrigh et al., 1991).
They were later adpated to model two oscillators with mutual coupling, to understand the evening-morning oscillators in rodents (Oda et al., 2000; Flôres and Oda, 2020). This implementation was made in Java, within the CircadianDynamix extension of the Neurodynamix II software (Friensen and Friense, 2010).
The present code adapts the Java implementation into the programming language R and adds a third oscillator, to simulate the interaction between evening-morning oscillators and the Food-Entrainable Oscillator (FEO) in rodents.

## Model equations
Equações do oscilador evening (e)

dR<sub>e</sub>/dt = R<sub>e</sub> – c<sub>e</sub>S<sub>e</sub> – b<sub>e</sub>S<sub>e</sub>2 + (d<sub>e</sub> – L<sub>e</sub>) + K<sub>e</sub>
dS<sub>e</sub>/dt = R<sub>e</sub> – a<sub>e</sub>S<sub>e</sub> + C<sub>me</sub>S<sub>m</sub> + C<sub>FEOe</sub>S<sub>FEO</sub>

Equações do oscilador morning (m)

dRm/dt = Rm – cmSm – bmSm2 + (dm – Lm) + Km
dSm/dt = Rm – amSm + CemSe + CFEOmSFEO

Equações do Food-entrainable oscillator (FEO)

dRFEO/dt = RFEO – cFEOSFEO – bFEOSFEO2 + (dFEO – Food) + KFEO
dSFEO/dt = RFEO – aFEOSFEO + CeFEOSe + CmFEOSm (6)

Test
h<sub>&theta;</sub>(x) = &theta;<sub>o</sub> x + &theta;<sub>1</sub>x

State variables R and S together describe the state of one oscillator at a given time point. The R variable is prevented from reaching negative values. Parameters a, b, c, and d are set to fixed values and collectively define an oscillator configuration, with intrinsic period and amplitude. K (Kyner) is a small nonlinear term that guarantees numerical smoothness (K = k1/(1 + k2R2), k1 = 1, k2 = 100; Oda et al., 2000). The L term simulates the light input (forcing variable). Its value is maintained at zero to simulate the dark hours. When lights are turned on, it is changed to a positive amplitude value in arbitrary units (a.u.), which simulates the light intensity. In one particular case indicated below, we used pulses of negative amplitude. The coupling term C controls the strength with which the E oscillator influences the morning oscillator (CEM) and vice versa (CME). When coupling is symmetric, CEM = CME.


## References
- Flôres DEFL, and Oda GA (2020) Quantitative Study of Dual Circadian Oscillator Models under Different Skeleton Photoperiods. J. Biol. Rhythms 35:302–316.
- Friesen WO, and Friesen JA (2010) Neurodynamix II: Concepts of neurophysiology illustrated by computer simulations, Oxford University Press, New York".
- Oda GA, Menaker M, and Friesen WO (2000) Modeling the dual pacemaker system of the tau mutant hamster. J Biol Rhythms 15:246-264.
- Pittendrigh CS (1981) Circadian organization and the photoperiodic phenomena. In: Follett BK, editor. Biological clocks in seasonal reproductive cycles. Bristol (UK): John Wright. p. 1-35.
- Pittendrigh CS, Kyner WT, and Takamura T (1991) The amplitude of circadian oscillations: temperature dependence, latitudinal clines, and the photoperiodic time measurement. J Biol Rhythms 6:299-313.
