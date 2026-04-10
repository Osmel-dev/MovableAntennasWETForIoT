Movable Antennas-aided Wireless Energy Transfer for the Internet of Things
==================

This code package is related to the following scientific article:

O. Martínez Rosabal, O. L. Alcaraz López, M. Di Renzo, R. D. Souza, and H. Alves, "Movable Antennas-aided Wireless Energy Transfer for the Internet of Things," accepted for publication in IEEE Wireless Communications Letters.

Available at: [https://arxiv.org/pdf/2507.06805](https://arxiv.org/pdf/2506.21966)

## Abstract of Article

Recent advancements in movable antennas (MAs) technology create new opportunities for 6G and beyond wireless systems. MAs are promising for radio frequency wireless energy transfer because they can dynamically adjust antenna positions, improving energy efficiency and scalability. This work aims to minimize the transmit power by an analog beamforming power beacon equipped with independently-controlled MAs (IMAs) for charging multiple single-antenna devices. To this end, we enforce a minimum separation among antennas and a minimum received power at the devices. The resulting optimization problem is nonlinear and nonconvex due to interdependencies among the variables. To tackle this, we propose a semidefinite program guided particle swarm optimization (SgPSO) algorithm where each particle represents an antenna configuration, and the fitness function optimizes the corresponding power allocation. SgPSO is utilized for configuring the MAs, which largely outperformed fixed array implementations, particularly with more antennas or devices. We also present an alternative implementation using uniformly-spaced MAs, whose performance closely approaches that of the IMAs, with the gap widening only as the number of devices grows. We also examine how increasing the number of antennas promotes near-field conditions, which decrease as devices become more widely distributed.

## Content of Code Package

The repository contains Matlab scripts and user-defined functions required to reproduce the numerical results in the article. To run the code, you need to install the latest version of the modeling framework CVX available at https://cvxr.com/cvx/download/. Also we encourage the use of Mosek as it provides the most reliable results.

To obtain results faster, we recommend the use of high-performance computing services as these may take hours if not days to complete on a normal computer. 

See each file for further documentation.

## Acknowledgements

This work is partially supported by Research Council of Finland (Grants 348515 and  369116 (6GFlagship)), by RNP/MCTI Brasil 6G project (01245.020548/2021-07), and by the Nokia Foundation, the French Institute of Finland, and the French Embassy in Finland under the France-Nokia Chair of Excellence in IC. The authors also wish to acknowledge CSC - IT Center for Science, Finland, for computational resources.
