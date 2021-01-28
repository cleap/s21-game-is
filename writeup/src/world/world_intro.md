# World Generation

In this chapter, we will cover (1) what procedural world generation can do and who uses procedural world generation, (2) how we implemented procedural world generation to fit our needs, and (3) provide some resources to go beyond what we have done here.

---

To fill space, here's a derivation of the golden ratio:

\\[ \frac{a + b}{a} = \frac{a}{b} \\]
\\[ ab + b^2 = a^2 \\]
\\[ a^2 - ab - b^2 = 0 \\]
\\[ a = \frac{b \pm \sqrt{b^2 - 4(-b^2)}}{2} \\]
\\[ a = \frac{b \pm \sqrt{5b^2}}{2} \\]
\\[ a = \frac{b \pm b\sqrt{5}}{2} \\]
Let \\( b=1\\), and let's choose \\(a\\) to be positive.
\\[ a = \frac{1 + \sqrt{5}}{2} \\]