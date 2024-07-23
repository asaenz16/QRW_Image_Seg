---
title: Quantum Random Walks and Image Segmentation
comments: true
---

<link rel="alternate" type="application/rss+xml" href="{{ site.url }}/feed.xml">

## Introduction

We present two image segmentation algorithms: (1) a low Qbit, high error circuit, and (2) a high Qbit, low error circuit. Both algorithms are based on the same Hamiltonian, but the representation of the Hamiltonian uses a different number of Qbits. For circuit (1), we encode information from an image with a (relatively) low number of Qbits and processing the information from the image requires a (relatively) high number of 2-control gates, leading to a high error when implemented on a *real* NISQ quantum computer. In particular, circuit (1) requires $$\log_2(N) + \log_2(M)$$ Qbits for an $$N\times M$$-pixel image. For circuit (2), we encode the information from an image with a (relatively) high number of Qbits and processing the information from the information from the image requires a (relatively) low number of 2-control gate, leading to a low error when implemented on a *real* NISQ quantum computer. In particular, circuit (2) requires $$N\times M$$ Qbits for an $$N\times M$$-pixel image. The number of 2-control gates in this case is $$2(2N M - N -M)$$. We don't have an exact formula for the number of 2-control gates in the case of circuit (1). For a $$4\times4$$-pixel image, circuit (1) requires 162 2-control gates, after optimizing the circuit using the BQSKit software, and circuit (2) requires 48 2-control gates.

The Qbits represent the location of pixels of the image. The image (i.e.~the color of the pixels) is represented by the circuit.  

## Objective: Image Segmentation

In the image segmentation algorithm, our initial data is an image with some labelled pixel and the goal is to label the rest of the pixels with a labels from the originally labeled pixels. After labeling, pixels with the same label are said to belong to the same *segment*. The pixels not initially labeled are labelled based on a wave function, $$|\Psi_{}(t) \rangle$$ that evolves under a quantum spin Hamiltonian determined by the image with the initial condition of the wave function determined by the initially labelled pixels.

Below, you may find blog posts detailng some of out progress as we prepare our results for publication. Feel free to leave comments on the posts.

## Background: Quantum Spin Chains

The image segmentation algorithm is inspired by inhomogeneous quantum spin chains, which are very well studied in solid state physics. A good and comprehensive introduction to quantum spin chains may be found in teh following textbook: [An Introduction to Quantum Spin Systems by Parkinson and Farnell](https://link.springer.com/book/10.1007/978-3-642-13290-2){:target="_blank"} . Briefly, a *quantum spin chain* is given as follows:

1. the *state space* is given by the tensor product over a lattice $$\Lambda$$,
$$
\mathbb{H}_{\Lambda} = \bigotimes_{\Lambda} \mathbb{C}^{2S+1},
$$
where $$S \in \tfrac{1}{2}\mathbb{Z}_{\geq 1}$$ is the \emph{spin parameter} for the quantum spin chain. (Typically, one considers the lattices $$\Lambda = \mathbb{Z}^{d}, \left(\mathbb{Z}/ L\mathbb{Z} \right)^{d}$$ for some dimension $$d >0$$ and some period $$L>0$$. We focus on the lattice $$\Lambda = \mathbb{Z}/L\mathbb{Z}, \{(i,j)| 1 \leq i \leq N, 1\leq j \leq M\}$$.)
2. there is class of *spin operators*:
$$
S^{x}_{i} \cdot S^{x}_{j}, \quad S^{y}_{i} \cdot S^{x}_{j}, \quad S^{z}_{i} \cdot S^{z}_{j},
$$
so that the operators $$S_k^{x},S_k^{y}, S_k^{z}$$ are given by (constant multiples) of the Pauli operators, acting on the $$k \in \Lambda$$ copy of $$\mathbb{C}^{2S+1}$$ in $$\mathbb{H}_{\Lambda}$$.
3. the *Hamiltonian* is given by a sum of local operators,
$$
H = \sum_{i, j \in \Lambda} h_{i,j}
$$
with the local operators given by
$$
h_{i,j} = J^x_{i,j}\, S^{x}_{i} \cdot S^{x}_{j} + J^y_{i, j}\, S^{y}_{i} \cdot S^{x}_{j} + J^z_{i,j}\, \left( S^{z}_{i} \cdot S^{z}_{j} - 1/2\right)
$$
where the parameters $$J^x_{i,j}, J^y_{i,j}, J^z_{i,j} \in \mathbb{R}$$ are referred as the *strength* or *weight* parameters of the corresponding local operator, with bounded support (i.e. $$J^x_{i,j}, J^y_{i,j}, J^z_{i,j} = 0$$ if $$\vert i-j \vert >R$$ for some $$R>0$$).

There is an exact and analytical treatment for one-dimension spin chain and, for higher dimensions, spin chains are very well-understood through observations from experiments and simulations. We consider inhomogeneous quantum spin chains so that the strength parameters $$J^x_{i,j}, J^y_{i,j}, J^z_{i,j}$$ are inhomogeneous. Typically, quantum spin chains in simulations are not inhomogeneous since the strength parameters have some type of symmetry, such as translation invariance. We interpret the spin of a particle as a *color* from the set $$\{1, 2, \cdots, dim(S)\}$$. For $$S = 1/2$$, the colors are $$\{1,2\}$$ with multiple common identifications, e.g. spin-up and spin-down particles, occupied or vacant position, heads or tail.

## Strategy: Quantum Algorithm

Let us denote an *image*, $$\mathcal{I} = (\Lambda, c)$$, as a lattice with a *color map*,

$$
c: \Lambda \rightarrow [0,1]^3.
$$

The three coordinates of the color map represent the *Red-Green-Blue(RGB)* composition of the color. Also, we introduce the a (partial/intial) *labelling* of some subset of seed pixels, meaning a (partial/initial) label function

$$
\ell: \Lambda_0 \rightarrow [L] , \quad L \geq 1
$$

where $$\Lambda_0 \subset \Lambda$$ is the set of *seed* pixels and $$[L] := \{1, 2, \dots, L\}$$ is the set of *labels*. We denote the pre-image of each label by

$$
p(l) := \{i_1, i_2, \dots, i_{s(l)}\} \subseteq \Lambda_0
$$

for each $l \in [L]$.

We use the color map to define a collection of strength parameters:

$$
J_{i,j}(\mathcal{I}) :=  \Vert c(i) - c(j)\Vert
$$

for $$i, j \in \Lambda$ with $\vert i - j \vert =1$$. This leads to the Hamiltonian $$H_{\mathcal{I}}$$, given as in the previous section with

$$
J_{i,j}^{z} = \Delta, \quad J_{i,j}^{x}= J_{i,j}^{y} = \begin{cases}J_{i,j}(\mathcal{I}), &\quad \vert i-j\vert = 1 \\ 0, &\quad \vert i-j\vert \neq 1\end{cases}
$$

where $$\Delta \in \mathbb{R}$$ is an anisotropy parameter. For a $$S = \tfrac{1}{2}$$-spin chain, a particular orthonormal basis is given by the location of the up-spin particles,

$$
| i_1, i_2, \dots, i_m \rangle, \quad m=1, 2, \dots
$$

and the vacuum state $$| \emptyset \rangle$$. We consider the following collection of Schrodinger equations

$$
\begin{cases}
  \iota \hbar \frac{d }{dt}|\Psi_i(t) \rangle = H_{\mathcal{I}} |\Psi_i(t) \rangle,\\
  |\Psi_i(0)\rangle = |i \rangle
\end{cases}
$$

for all $$i \in \Lambda_0$$.

The goal of the image segmentation algorithm is to extend the label function, from the seed pixels $$\ell : \Lambda_0 \rightarrow [L]$$, to the entire lattice 

$$
\ell: \Lambda  \rightarrow [L].
$$

We propose to label a pixel based on the occupation probabilities from the collection of Schrodinger equations above. The probability of finding an up-spin particle at site $$i \in \Lambda$$ at time $$t \geq 0$$ is given by

$$
P_{t}(i,j)=\mathbb{P}\big(|\Psi_i(t) \rangle = | j \rangle\big) = \left| \langle j| \Psi_i(t)\rangle \right|^2, \quad i \in \Lambda_0, \, j \in \Lambda
$$

where $$\langle j| \Psi_i(t)\rangle$$ is the dot product -- the dot product is completely determinde by the orthonormal basis given above, which is a standard fact from linear algebra -- of the states $$| \Psi_i(t)\rangle,| j\rangle \in \mathbb{H}_{\Lambda}$$. Then, we propose to label a pixel $$j \in \Lambda$$ with the label $$l \in [L]$$ if $$P_{t}(i_0, j)$$ is maximal (over a time average) for all seed pixels $$i \in \Lambda_0$$ and $$c(i_0) = l$$. More precisely, we extend the label map as follows:

$$
\ell(j) = \ell \left( \arg\, \max_{ i \in \Lambda_0} \left(\lim_{T \rightarrow \infty}\frac{1}{T} \sum_{t=1}^T P_t(i, j) \right)  \right).
$$

## Remark: Classical vs Quantum

The classical version of the this image segmentation algorithm replace the probabilities $$P_t(i,j)$$, given above, by the transition probabilities of a random walk where the one-step transition probabilities are given by a Markov matrix determined, similarly, by the local difference of the colors in the image. We thus refer to our algorithm as a *quantum random walk* algorithm where the position of the up-spin particle is the location of the quantum random walker. The quantum advantage lies in the speed of the random walker. In the classical case, the distance travel by a random walker in $$t$$ steps is proportional to $$\sqrt{t}$$, due to the central limit theorem in probability. In the quantum case, the distance travel by a random walker in $$t$$ steps is proportional to $$t$$, which we may show. Thus, we expect the limit in the previous equation to stabilize faster in quantum case than in the classical case, leading to a (potentially) faster implementation. In short, quantum random walkers explore space faster than their classical counterparts, leading to quadratic speedup.

<!---
# See

Further discussion on the following topics:

- [The one-point function](/URSA23/pages/OPF.html)

--->


# Team
- [Axel Saenz Rodiguez](https://sites.google.com/view/axelsaenz){:target="_blank"}, Assitant Professor, Math, Oregon State University
- [Ngoc Ha](https://scholar.google.com/citations?user=IxMZCA4AAAAJ&hl=en){:target="_blank"}, PhD Student, Statistics, Oregon State University
- [Fernando Angulo Barba](https://sites.google.com/view/nandomath/home){:target="_blank"}, Undergraduate Student, Oregon State University
- [Talita Periciano](https://tperciano.wixsite.com/home){:target="_blank"}, Research Scientist, Lawrence Berkeley National Laboratory
- [Roel Van Beeumen](http://www.roelvanbeeumen.be/drupal8/){:target="_blank"}, Research Scientist, Lawrence Berkeley National Laboratory
- [Daan Camps](https://campsd.github.io/){:target="_blank"}, Researcher/Staff, Lawrence Berkeley National Laboratory

<!---
# Funding 

This project is funded by Oregon State University

A. Saezn Rodriguez and N. Elsasser were funded through the [Research and Innovation Seed Program (SciRIS)](https://science.oregonstate.edu/research/research-and-innovation-seed-program) under the project titled *Polariton-controlled spin waves in quantum magnets for next-generation spintronics*

C. Lee, M. Spears, and C. Chaing were funded through the [URSA Engage Program 2023-2024](https://academicaffairs.oregonstate.edu/research/ursa-engage)

M. Faks and A. Zaidan were funded through the [URSA Engage Program 2022-2023](https://academicaffairs.oregonstate.edu/research/ursa-engage)
--->



<script type="text/javascript" async
  src="https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-MML-AM_CHTML" async>
</script>

<!---
{% if page.comments %}

<div id="disqus_thread"></div>
<script>
    /**
    *  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
    *  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables    */
    /*
    var disqus_config = function () {
    this.page.url = PAGE_URL;  // Replace PAGE_URL with your page's canonical URL variable
    this.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
    };
    */
    (function() { // DON'T EDIT BELOW THIS LINE
    var d = document, s = d.createElement('script');
    s.src = 'https://https-asaenz16-github-io-ursa23.disqus.com/embed.js';
    s.setAttribute('data-timestamp', +new Date());
    (d.head || d.body).appendChild(s);
    })();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>

{% endif %}
--->




{% include utterances.html %}
