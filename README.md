# petri-nets-model-checker
Petri Nets Model Checker in Shellscript

<p>This script basically uses awk to identify if an Initial Markup reach to the Final Markup.<p>

<code>./resdespetri.sh <input-file></code>

<p>Input File Example</p>
<p>
6 4         -> p(places), t(transitions)<br>
1 0 0 0     -> I[p][t]<br>
0 1 0 0     -> ..<br>
0 0 1 0     -> ..<br>
0 1 0 0     -> ..<br>
0 0 1 0     -> ..<br>
0 0 0 1     -> ..<br>
0 0 0 1     -> O[p][t]<br>
1 0 0 0     -> ..<br>
1 0 0 0     -> ..<br>
0 0 1 0     -> ..<br>
0 1 0 0     -> ..<br>
0 1 0 0     -> ..<br>
1 0 0 0 1 0 -> Input[1][p]: Initial Markup<br>
0 0 0 0 1 1 -> Output[1][p]: Final Markup<br>
-1          -> END OF FILE
</p>
