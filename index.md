---
title: Quantum Random Walks and Image Segmentation
comments: true
---

<link rel="alternate" type="application/rss+xml" href="{{ site.url }}/feed.xml">

# Introduction

We present two image segmentation algorithms: (1) a low Qbit, high error circuit, and (2) a high Qbit, low error circuit. Both algorithms are based on the same Hamiltonian, but the representation of the Hamiltonian uses a different number of Qbits. For circuit (1), we encode information from an image with a (relatively) low number of Qbits and processing the information from the image requires a (relatively) high number of 2-control gates, leading to a high error when implemented on a *real* NISQ quantum computer. In particular, circuit (1) requires $$\log_2(N) + \log_2(M)$$ Qbits for an $$N\times M$$-pixel image. For circuit (2), we encode the information from an image with a (relatively) high number of Qbits and processing the information from the information from the image requires a (relatively) low number of 2-control gate, leading to a low error when implemented on a *real* NISQ quantum computer. In particular, circuit (2) requires $$N\times M$$ Qbits for an $$N\times M$$-pixel image. The number of 2-control gates in this case is $$2(2N M - N -M)$$. We don't have an exact formula for the number of 2-control gates in the case of circuit (1). For a $$4\times4$$-pixel image, circuit (1) requires 162 2-control gates, after optimizing the circuit using the BQSKit software, and circuit (2) requires 48 2-control gates.

The Qbits represent the location of pixels of the image. The image (i.e.~the color of the pixels) is represented by the circuit.  

Below, you may find blog posts detailng some of out progress as we prepare our results for publication. Feel free to leave comments on the posts.

## Background: Quantum Spin Chains



## Objective: Image Segmentation

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
