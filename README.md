# petri-nets-model-checker
Petri Nets Model Checker in Shellscript

<p>This script basically uses awk to identify if an Initial Markup reach to the Final Markup.<p>

<code>./resdespetri.sh <input-file></code>

<p>Input File Example</p>
<code>
6 4         -> p(places), t(transitions)
1 0 0 0     -> I[p][t]
0 1 0 0     -> ..
0 0 1 0     -> ..
0 1 0 0     -> ..
0 0 1 0     -> ..
0 0 0 1     -> ..
0 0 0 1     -> O[p][t]
1 0 0 0     -> ..
1 0 0 0     -> ..
0 0 1 0     -> ..
0 1 0 0     -> ..
0 1 0 0     -> ..
1 0 0 0 1 0 -> Input[1][p]: Initial Markup
0 0 0 0 1 1 -> Output[1][p]: Final Markup
-1          -> END OF FILE
</code>
