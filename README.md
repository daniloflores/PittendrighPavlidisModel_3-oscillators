# PittendrighPavlidisModel_3-oscillators

This repository contains an implemention of the Pittendrigh-Pavlidis model of 3 coupled oscillators.

## Introduction
The Pittendrigh-Pavlidis equations have been originally used to model biological rhythms in the fruit fly *Drosophila* (Pittendrigh, 1981; Pittendrigh et al., 1991), with two limit-cycle oscillators in a master-slave configuration.
The equations were later adpated to model the evening-morning oscillators that control biological rhythms in rodents (Oda et al., 2000; Flôres and Oda, 2020). In this case, the two limit-cycle oscillators were mutually coupled. This implementation was made in Java, within the CircadianDynamix extension of the Neurodynamix II software (Friensen and Friense, 2010).
In the present code, the Java implementation is adapted to the programming language R. And a third oscillator is added to the model, to simulate the interaction between evening-morning oscillators and the Food-Entrainable Oscillator (FEO) in rodents.

## Model equations
Evening oscilador (e)

d*R*<sub>e</sub>/dt = *R*<sub>e</sub> – *c*<sub>e</sub>*S*<sub>e</sub> – *b*<sub>e</sub>*S*<sub>e</sub><sup>2</sup> + (*d*<sub>e</sub> – *L*<sub>e</sub>) + *K*<sub>e</sub>

d*S*<sub>e</sub>/dt = *R*<sub>e</sub> – *a*<sub>e</sub>*S*<sub>e</sub> + *C*<sub>me</sub>*S*<sub>m</sub> + *C*<sub>FEOe</sub>*S*<sub>FEO</sub>

Morning oscilador (m)

d*R*<sub>m</sub>/dt = *R*<sub>m</sub> – *c*<sub>m</sub>*S*<sub>m</sub> – *b*<sub>m</sub>*S*<sub>m</sub><sup>2</sup> + (*d*<sub>m</sub> – *L*<sub>m</sub>) + *K*<sub>m</sub>

d*S*<sub>m</sub>/dt = *R*<sub>m</sub> – *a*<sub>m</sub>*S*<sub>m</sub> + *C*<sub>em</sub>*S*<sub>e</sub> + *C*<sub>FEOm</sub>*S*<sub>FEO</sub>

Food-entrainable oscillator (FEO)

d*R*<sub>FEO</sub>/dt = *R*<sub>FEO</sub> – *c*<sub>FEO</sub>*S*<sub>FEO</sub> – *b*<sub>FEO</sub>*S*<sub>FEO</sub><sup>2</sup> + (*d*<sub>FEO</sub> – *Food*) + *K*<sub>FEO</sub>

d*S*<sub>FEO</sub>/dt = *R*<sub>FEO</sub> – *a*<sub>FEO</sub>*S*<sub>FEO</sub> + *C*<sub>eFEO</sub>*S*<sub>e</sub> + *C*<sub>mFEO</sub>*S*<sub>m</sub>


State variables ***R*** and ***S*** together describe the phase of each oscillator at a given time point. The *R* variable is prevented from reaching negative values. Parameters ***a***, ***b***, ***c***, and ***d*** are set to fixed values and collectively define an oscillator configuration, with intrinsic period and amplitude. ***K*** (Kyner) is a small nonlinear term that guarantees numerical smoothness (*K* = *k*<sub>1</sub>/(1 + *k*<sub>2</sub>*R*<sup>2</sup>), *k*<sub>1</sub> = 1, *k*<sub>2</sub> = 100; Oda et al., 2000). The ***L*** and ***Food*** terms simulate the light and food inputs (forcing variables). Their values are maintained at zero to simulate no stimulus: dark in case of *L* and constant food availability for *Food*. When lights are turned on, *L* is changed to a positive amplitude value in arbitrary units (a.u.), which simulates the light intensity. The coupling term ***C*** controls the strength with which one oscillator acts on the other. In each *C* term, the subscribed letters indicate the direction of the coupling, for instance, *C*<sub>eFEO</sub> is the coupling from the evening oscillator (e) to FEO.


## References
- Flôres DEFL, and Oda GA (2020) Quantitative Study of Dual Circadian Oscillator Models under Different Skeleton Photoperiods. J. Biol. Rhythms 35:302–316.
- Friesen WO, and Friesen JA (2010) Neurodynamix II: Concepts of neurophysiology illustrated by computer simulations, Oxford University Press, New York".
- Oda GA, Menaker M, and Friesen WO (2000) Modeling the dual pacemaker system of the tau mutant hamster. J Biol Rhythms 15:246-264.
- Pittendrigh CS (1981) Circadian organization and the photoperiodic phenomena. In: Follett BK, editor. Biological clocks in seasonal reproductive cycles. Bristol (UK): John Wright. p. 1-35.
- Pittendrigh CS, Kyner WT, and Takamura T (1991) The amplitude of circadian oscillations: temperature dependence, latitudinal clines, and the photoperiodic time measurement. J Biol Rhythms 6:299-313.
